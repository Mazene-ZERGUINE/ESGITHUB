from enum import Enum


class ProgramingLanguagesEnum(Enum):
    JAVASCRIPT = 'javascript'
    PYTHON = 'python'
    PHP = 'php'
    CPP = 'c++'


class ProgramResultDto:
    def __init__(self, stdout, stderr, returncode):
        self.stdout = stdout
        self.stderr = stderr
        self.returncode = returncode

    def to_dict(self):
        return {
            'stdout': self.stdout,
            'stderr': self.stderr,
            'returncode': self.returncode
        }


class ProgramWithFileResultDto:
    def __init__(self, stdout, stderr, returncode, output_file_path):
        self.stdout = stdout
        self.stderr = stderr
        self.returncode = returncode
        self.output_file_path = output_file_path

    def to_dict(self):
        return {
            'stdout': self.stdout,
            'stderr': self.stderr,
            'returncode': self.returncode,
            'output_file_paths': self.output_file_path
        }

class FileDeletedResponseDto:
    def __init__(self, response_status, message, success):
        self.response_status = response_status
        self.message = message
        self.success = success


    def to_dict(self):
        return {
            'status': self.response_status,
            'message': self.message,
            'success': self.success
        }