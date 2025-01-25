# ESGITHUB - Social Media Platform for Developers

ESGITHUB is a social media platform designed for software developers to share, test, and collaborate on programmes in various programming languages. The platform provides an integrated web-based real-time code editor, allowing users to test and execute their scripts before sharing them. It also offers file handling integrations for image processing and file transformations.

To view more about the project presentation and technical architecture, [view the documentation](./docs/).
## Key Features

- **Authentication & Authorization**:

  - JWT-based authentication.
  - User registration and login.
- **Program Management**:

  - Publish, edit, and delete scripts.
  - Support for multiple publishing modes: Public, Private, Followers-only.
  - Commenting and liking on posts.
  - Replying to comments and annotating specific parts of the code.
- **Account Management**:

  - User profile management.
  - Follow/unfollow other developers.
- **Groups Management**:

  - Create, update, and delete groups.
  - Manage group memberships.
  - Join private groups.
  - Post scripts within groups.
- **Integrated Code Editor**:

  - Real-time collaborative coding.
  - Support for various programming languages: C++, Python, JavaScript, PHP.
  - Secure and sandboxed code execution.
  - Rate limiting to prevent abuse.
- **File and Image Handling**:

  - Transform and process images.
  - Requires an S3 bucket for image handling (add credentials to the `.env` file).

## Tech Stack

### Frontend

- **Framework**: Angular
- **Languages**: TypeScript, SCSS
- **Styling**: Tailwind CSS

### Backend

- **Framework**: NestJS
- **Database**: PostgreSQL
- **Language**: TypeScript

### Code Runner Microservice

- **Framework**: Django
- **Language**: Python
- **Task Queue**: Celery

### Environment & Tools

- **Version Control**: Git, GitHub
- **Containerization**: Docker
- **Message Broker**: RabbitMQ

## Setup and Installation

### Prerequisites

1. [Node.js](https://nodejs.org/) and npm/yarn installed.
2. [Docker](https://www.docker.com/) installed for containerization.
3. Access to an S3 bucket (for image handling).
4. RabbitMQ for message brokering.

### Installation Steps

to run this project locally :

1. Clone the repository:
   ```bash
   git clone git@github.com:Mazene-ZERGUINE/ESGITHUB.git
   ```
2. Follow the installating and running steps in each folder readme.md
