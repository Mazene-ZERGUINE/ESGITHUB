from celery import shared_task
import subprocess
import uuid
import os
from celery.utils.log import get_task_logger
import boto3
from botocore.exceptions import NoCredentialsError
from code_runner_service import settings
from .utils import ProgramingLanguagesEnum, ProgramResultDto, ProgramWithFileResultDto

from dotenv import load_dotenv
load_dotenv()


DIR_PATH = os.path.join(settings.BASE_DIR, 'resources')
VENV_PATH = '/app/.venv/bin/python'
PHP_AUTOLOAD_PATH = os.getenv('PHP_AUTOLOAD_PATH', '/app/resources/php/vendor/autoload.php')
logger = get_task_logger(__name__)

ENV = os.getenv('ENV', 'dev')
STATIC_FILES_URL = "http://127.0.0.1:8080/static/" if ENV == "dev" else "http://prod_domain/static/"

# S3 Configuration
S3_BUCKET_NAME = os.getenv('S3_BUCKET_NAME')
AWS_ACCESS_KEY_ID = os.getenv('AWS_ACCESS_KEY_ID')
AWS_SECRET_ACCESS_KEY = os.getenv('AWS_SECRET_ACCESS_KEY')
S3_REGION_NAME = os.getenv('S3_REGION_NAME')



s3_client = boto3.client(
    's3',
    aws_access_key_id=AWS_ACCESS_KEY_ID,
    aws_secret_access_key=AWS_SECRET_ACCESS_KEY,
    region_name=S3_REGION_NAME
)
def upload_file_to_s3(file_path, s3_bucket, s3_key):

    logger.error(f"S3_BUCKET_NAME: {S3_BUCKET_NAME}")
    logger.error(f"AWS_ACCESS_KEY_ID: {AWS_ACCESS_KEY_ID}")
    logger.error(f"AWS_SECRET_ACCESS_KEY: {AWS_SECRET_ACCESS_KEY}")
    logger.error(f"S3_REGION_NAME: {S3_REGION_NAME}")
    logger.error(f"ENV: {ENV}")
    try:
        s3_client.upload_file(file_path, s3_bucket, s3_key)
        s3_url = f"https://{s3_bucket}.s3.{S3_REGION_NAME}.amazonaws.com/{s3_key}"
        return s3_url
    except FileNotFoundError:
        logger.error(f'File not found: {file_path}')
        return None
    except NoCredentialsError:
        logger.error('AWS credentials not available')
        return None

def run_docker_command(cmd):
    try:
        result = subprocess.run(cmd, capture_output=True, text=True, timeout=30)
        logger.info(f'Command executed successfully: {cmd}')
        logger.info(f'stdout: {result.stdout}')
        logger.info(f'stderr: {result.stderr}')
        return result
    except subprocess.TimeoutExpired as e:
        logger.error(f'Execution time exceeded: {str(e)}, Command: {cmd}')
        return {'error': 'Execution time exceeded'}
    except subprocess.CalledProcessError as e:
        logger.error(f'Subprocess error: {str(e)}, stdout: {e.stdout}, stderr: {e.stderr}')
        return {'error': str(e)}
    except Exception as e:
        logger.error(f'Unexpected error: {str(e)}, Command: {cmd}')
        return {'error': 'Unexpected error occurred'}


def get_docker_run_command(language, container_path, unique_id):
    common_args = [
        'docker', 'run', '--rm', '--cpus', '1.0', '--memory', '512m', '--memory-swap', '512m',
        '--pids-limit', '100', '--cap-drop', 'ALL', '--security-opt', 'no-new-privileges',
        '-v', f'{DIR_PATH}:/app/resources',
        '-v', f'/tmp/docker_temp_{unique_id}:/tmp'  # Add this line to mount a writable temp directory
    ]

    if language == ProgramingLanguagesEnum.PYTHON.value:
        return common_args + ['code_runner:latest', VENV_PATH, container_path]
    elif language == ProgramingLanguagesEnum.JAVASCRIPT.value:
        return common_args + ['code_runner:latest', 'node', container_path]
    elif language == ProgramingLanguagesEnum.PHP.value:
        return common_args + ['code_runner:latest', 'php', container_path]
    elif language == ProgramingLanguagesEnum.CPP.value:
        compiled_path = f'/app/resources/{language}/compiled_{unique_id}'
        compile_cmd = common_args + ['code_runner:latest', 'g++', container_path, '-o', compiled_path]
        compile_result = run_docker_command(compile_cmd)
        if compile_result.returncode != 0:
            logger.error(f'Error compiling C++ code: {compile_result.stderr}')
            return ProgramResultDto(compile_result.stdout, compile_result.stderr, compile_result.returncode).to_dict()
        return common_args + ['code_runner:latest', compiled_path]
    else:
        logger.error(f'Unsupported programming language: {language}')
        return None


@shared_task
def run_code(source_code, programming_language):
    unique_id = uuid.uuid4()
    extension = {'python': 'py', 'javascript': 'js', 'php': 'php', 'c++': 'cpp'}.get(programming_language, 'txt')
    temp_filename = os.path.join(DIR_PATH, f'{programming_language}/code_to_run_{unique_id}.{extension}')
    container_path = f'/app/resources/{programming_language}/code_to_run_{unique_id}.{extension}'

    os.makedirs(os.path.dirname(temp_filename), exist_ok=True)
    with open(temp_filename, 'w') as f:
        f.write(source_code)

    cmd = get_docker_run_command(programming_language, container_path, unique_id)
    if cmd is None:
        return {'error': 'Unsupported programming language'}

    result = run_docker_command(cmd)

    if os.path.exists(temp_filename):
        os.remove(temp_filename)

    return ProgramResultDto(result.stdout, result.stderr, result.returncode).to_dict() if isinstance(result, subprocess.CompletedProcess) else result

@shared_task
def execute_code_with_files(source_code, programming_language, source_files, output_files_formats):
    unique_id = uuid.uuid4()
    extension = {'python': 'py', 'javascript': 'js', 'php': 'php', 'c++': 'cpp'}.get(programming_language, 'txt')

    temp_code_filename = os.path.join(DIR_PATH, f'{programming_language}/code_to_run_{unique_id}.{extension}')
    temp_output_dir = os.path.join(DIR_PATH, 'out')
    container_code_path = f'/app/resources/{programming_language}/code_to_run_{unique_id}.{extension}'

    os.makedirs(os.path.dirname(temp_code_filename), exist_ok=True)
    os.makedirs(temp_output_dir, exist_ok=True)

    container_input_paths = []
    for idx, source_file in enumerate(source_files):
        file_extension = os.path.splitext(source_file)[1]
        container_input_path = f'/app/resources/{programming_language}/input_file_{unique_id}_{idx}{file_extension}'
        container_input_paths.append(container_input_path)
        input_file_path = os.path.join(DIR_PATH, f'{programming_language}/input_file_{unique_id}_{idx}{file_extension}')
        with open(input_file_path, 'wb') as input_file:
            with open(source_file, 'rb') as src_file:
                input_file.write(src_file.read())
        source_code = source_code.replace(f'INPUT_FILE_PATH_{idx}', f"'{container_input_path}'")

    output_file_paths = []
    if output_files_formats:
        for idx, file_output_format in enumerate(output_files_formats):
            container_output_path = f'/app/resources/out/output_file_{unique_id}_{idx}.{file_output_format}'
            output_file_paths.append(container_output_path)
            source_code = source_code.replace(f'OUTPUT_FILE_PATH_{idx}', f"'{container_output_path}'")

    with open(temp_code_filename, 'w') as f:
        f.write(source_code)

    cmd = get_docker_run_command(programming_language, container_code_path, unique_id)
    if cmd is None:
        return {'error': 'Unsupported programming language'}

    result = run_docker_command(cmd)

    output_paths = []
    if output_file_paths:
        for path in output_file_paths:
            filename = path.split('/')[-1]
            local_path = os.path.join(DIR_PATH, 'out', filename)
            logger.error(local_path)
            if os.path.exists(local_path):
                s3_key = f'{unique_id}/out/{filename}'
                s3_url = upload_file_to_s3(local_path, S3_BUCKET_NAME, s3_key)
                if s3_url:
                    output_paths.append(s3_url)
                os.remove(local_path)
            else:
                logger.warning(f'Output file not found: {local_path}')

    if os.path.exists(temp_code_filename):
        os.remove(temp_code_filename)
    for input_file_path in container_input_paths:
        input_file_path = os.path.join(DIR_PATH, input_file_path.split('/app/resources/')[1])
        logger.error(input_file_path)
        if os.path.exists(input_file_path):
            os.remove(input_file_path)

    return ProgramWithFileResultDto(result.stdout, result.stderr, result.returncode, output_paths).to_dict() if isinstance(result, subprocess.CompletedProcess) else result
