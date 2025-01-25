
# Django Code-Runner Service

This Django project demonstrates the integration of Django REST Framework for APIs, Celery with RabbitMQ for asynchronous task handling, Django-Celery-Results for tracking task results, and Flower for monitoring Celery tasks. It is designed to execute code received from the application's main API asynchronously.

## Prerequisites

- Python 3.10 or higher
- pip
- RabbitMQ server or Docker container

## Getting Started

### 1. Clone the Repository

Clone the repository to your local machine:

```bash
git clone git@github.com:Mazene-ZERGUINE/4AL2PA-resources-runner-service.git
cd resources-runner-service
```

### 2. Setup the Virtual Environment

Create and activate a virtual environment:

```bash
python3 -m venv venv
source venv/resources/activate  # On Windows use `venv\Scripts\activate`
```

### 3. Install Dependencies

Install the required dependencies:

```bash
pip install -r requirements.txt
```

### 4. Setup RabbitMQ

If you do not have RabbitMQ installed on your machine, you can install it as follows:

#### For macOS

```bash
brew install rabbitmq
export PATH="$PATH:/usr/local/opt/rabbitmq/sbin"
brew services start rabbitmq
```

#### For Linux

```bash
sudo apt update
sudo apt upgrade -y
sudo apt install -y erlang

wget -O- https://www.rabbitmq.com/rabbitmq-release-signing-key.asc | sudo gpg --dearmor -o /usr/share/keyrings/rabbitmq-archive-keyring.gpg
sudo apt update
sudo apt install -y rabbitmq-server
```

#### Using Docker

```bash
docker run -d --hostname my-rabbit --name some-rabbit -p 5672:5672 -p 15672:15672 rabbitmq:3-management
```

For more information, visit: [RabbitMQ installation guide](https://www.rabbitmq.com/download.html).

### 5. Run Migrations

Run the initial database migrations:

```bash
python manage.py migrate django_celery_results
python manage.py migrate
```

### 6. Build code execution container

```bash
docker build -t code_runner:latest .
```

### 7. Start the Celery Worker

Start the Celery worker to process tasks:

```bash
celery -A code_runner_service worker --loglevel=info
```

### 8. Start the Development Server

Start the Django development server:

```bash
export ENV=dev; python manage.py runserver 8080
```

### 9. Monitor Celery (Optional)

Start Flower to monitor Celery tasks:

```bash
celery -A code_runner_service flower
```

Flower will be available at `http://localhost:5555`.

