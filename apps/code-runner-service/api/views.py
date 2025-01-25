import os
import tempfile
import requests

from rest_framework import status
from rest_framework.response import Response
from rest_framework.views import APIView

from code_runner_service import settings
from .tasks import run_code, execute_code_with_files
from celery.result import AsyncResult
from .utils import FileDeletedResponseDto

OUT_FILE_DIR = os.path.join(settings.BASE_DIR, 'resources/out/')

class AddTask(APIView):
    def post(self, request):
        programming_language = request.data.get('programming_language')
        source_code = request.data.get('source_code')
        if programming_language and source_code:
            task = run_code.delay(source_code, programming_language)
            return Response({'task_id': task.id}, status=status.HTTP_200_OK)
        else:
            return Response({'error': 'Missing parameters'}, status=status.HTTP_400_BAD_REQUEST)


class GetTaskResult(APIView):
    def get(self, request, task_id):
        result = AsyncResult(task_id)
        if result.ready():
            response = result.get()
            # Check if 'result' key exists
            if 'result' in response:
                return Response({'status': 'Completed', 'result': response['result']}, status=status.HTTP_200_OK)
            return Response({'status': 'Completed', 'result': response}, status=status.HTTP_200_OK)
        else:
            return Response({'status': 'Pending'}, status=status.HTTP_200_OK)



class AddTaskWithFile(APIView):
    def post(self, request):
        programming_language = request.data.get('programming_language')
        source_code = request.data.get('source_code')
        input_files_paths = request.data.get('input_files_paths', [])
        output_files_formats = request.data.get('output_files_formats', [])

        if not programming_language or not source_code:
            return Response({'error': 'Missing parameters'}, status=status.HTTP_400_BAD_REQUEST)

        tmp_file_paths = []
        for input_file_url in input_files_paths:
            try:
                response = requests.get(input_file_url)
                response.raise_for_status()
            except requests.RequestException as e:
                return Response({'error': f'Failed to download the file {input_file_url}: {str(e)}'}, status=status.HTTP_400_BAD_REQUEST)

            try:
                tmp_dir = tempfile.gettempdir()
                tmp_file_path = os.path.join(tmp_dir, os.path.basename(input_file_url))
                with open(tmp_file_path, 'wb') as tmp_file:
                    tmp_file.write(response.content)
                tmp_file_paths.append(tmp_file_path)
            except Exception as e:
                return Response({'error': f'Failed to save the file {input_file_url}: {str(e)}'}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

        try:
            task = execute_code_with_files.delay(source_code, programming_language, tmp_file_paths, output_files_formats)
        except Exception as e:
            return Response({'error': 'Failed to create task: {}'.format(str(e))}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

        return Response({'task_id': task.id, 'status': 'Task created successfully'}, status=status.HTTP_200_OK)

class DeleteOutputFile(APIView):
    def delete(self, request):
        filename = request.query_params.get('file')
        file_path = os.path.join(OUT_FILE_DIR, filename)
        if not filename:
            return Response({"error": "No file path provided"}, status=status.HTTP_404_NOT_FOUND)
        else:
            try:
                os.remove(file_path)
                response = FileDeletedResponseDto(200, "File deleted successfully", True).to_dict()
                return Response(response, status=status.HTTP_200_OK)
            except Exception as e:
                return Response({"error": str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
