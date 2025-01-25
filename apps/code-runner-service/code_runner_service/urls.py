"""
URL configuration for code_runner_service project.

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/5.0/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  path('', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  path('', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.urls import include, path
    2. Add a URL to urlpatterns:  path('blog/', include('blog.urls'))
"""
from django.conf import settings
from django.conf.urls.static import static
from django.contrib import admin
from django.urls import path

from api.views import AddTask, GetTaskResult, AddTaskWithFile, DeleteOutputFile

urlpatterns = [
    path("admin/", admin.site.urls),
    path('execute/', AddTask.as_view(), name='execute_task'),
    path('result/<str:task_id>/', GetTaskResult.as_view(), name='task_result'),
    path('file/execute', AddTaskWithFile.as_view(), name='execute_task_with_file'),
    path('file/delete', DeleteOutputFile.as_view(), name='delete-output-file'),
]


if settings.DEBUG:
    urlpatterns += static(settings.STATIC_URL, document_root=settings.STATICFILES_DIRS[0])