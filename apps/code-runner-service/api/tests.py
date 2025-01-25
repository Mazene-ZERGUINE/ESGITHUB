from unittest.mock import patch, MagicMock
from api.tasks import run_code
import pytest
from unittest.mock import patch
from django.urls import reverse
from rest_framework import status
from rest_framework.test import APIClient


# Create your tests here.
@pytest.mark.django_db
def test_run_code_task():
    source_code = "print('Hello, World')"
    programming_language = 'python'

    with patch('subprocess.run') as mocked_run:
        mocked_result = MagicMock()
        mocked_result.stdout = 'Hello, World'
        mocked_result.stderr = ''
        mocked_result.returncode = 0
        mocked_run.return_value = mocked_result

        # Call the task
        result = run_code(source_code, programming_language)

        assert result['stdout'] == 'Hello, World'
        assert result['stderr'] == ''
        assert result['returncode'] == 0
        mocked_run.assert_called_once()


@pytest.mark.django_db
def test_add_task_view():
    client = APIClient()
    url = reverse('execute_task')

    data = {
        'programming_language': 'python',
        'source_code': "print('Hello, World')"
    }

    response = client.post(url, data, format='json')

    assert response.status_code == status.HTTP_200_OK
    assert 'task_id' in response.data


@pytest.mark.django_db
def test_get_task_result_view():
    client = APIClient()
    task_id = "fake-task-id"
    url = reverse('task_result', args=[task_id])

    with patch('celery.result.AsyncResult') as mock_async_result:
        mock_result = MagicMock()
        mock_result.ready.return_value = True
        mock_result.get.return_value = {'stdout': 'Hello, World', 'stderr': '', 'returncode': 0}
        mock_async_result.return_value = mock_result

        response = client.get(url)

        print("Mock ready():", mock_result.ready())
        print("Response data:", response.data)

        assert response.status_code == status.HTTP_200_OK
