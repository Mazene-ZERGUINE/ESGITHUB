from __future__ import absolute_import, unicode_literals
import os
from celery import Celery
from dotenv import load_dotenv

load_dotenv()
ENVIRONMENT = os.getenv('ENV')

print(f'celery worker is running on {ENVIRONMENT}')
print('-----------------------------------------')


os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'code_runner_service.settings')

app = Celery('code_runner_service')
app.config_from_object('django.conf:settings', namespace='CELERY')
app.autodiscover_tasks()
