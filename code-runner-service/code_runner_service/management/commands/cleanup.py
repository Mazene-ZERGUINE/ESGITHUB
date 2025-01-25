import os
import glob
from django.core.management.base import BaseCommand

class Command(BaseCommand):
    help = 'Delete files from specific directories except for certain files'

    def handle(self, *args, **kwargs):
        directories = [
            'resources/c++',
            'resources/python',
            'resources/javascript',
            'resources/php'
        ]

        exclusions = [
            'resources/python/requirements.txt',
            'resources/javascript/packages.json',
            'resources/javascript/package-lock.json'
        ]

        def delete_files(directory, exclusions):
            for file_path in glob.glob(os.path.join(directory, '*')):
                if file_path not in exclusions:
                    try:
                        if os.path.isfile(file_path):
                            os.remove(file_path)
                            self.stdout.write(self.style.SUCCESS(f'Deleted file: {file_path}'))
                        elif os.path.isdir(file_path):
                            os.rmdir(file_path)
                            self.stdout.write(self.style.SUCCESS(f'Deleted directory: {file_path}'))
                    except Exception as e:
                        self.stderr.write(self.style.ERROR(f'Failed to delete {file_path}: {e}'))

        for directory in directories:
            delete_files(directory, exclusions)
