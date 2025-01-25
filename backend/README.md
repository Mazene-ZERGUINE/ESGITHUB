
# ESGIHUB Backend

The **ESGIHUB Backend** is the server-side application for ESGIHUB, providing APIs and logic for seamless interaction with the platform. It is developed using NestJs and includes support for secure data handling and API communication and interact with the code runner microservice to ensure a safe code executing environement

---

## 🚀 Features

- **RESTful API**: Provides secure and scalable API endpoints.
- **File Handling**: Handles user-uploaded files (e.g., avatars).
- **Database Integration**: Utilizes a robust database system for data persistence.
- **Error Handling**: Comprehensive error management with meaningful responses.
- **Middleware**: Includes essential middleware for request validation and logging.
and more 

---

## 🛠️ Technologies

- **Framework**: NestJs
- **Database**: PostgreSQL 
- **Authentication**: JSON Web Tokens (JWT)
- **File Storage**: Local filesystem for uploads plus S3 bucket

---

## 📦 Installation

### Prerequisites

Ensure you have the following installed:

- Node.js (v16 or higher)
- npm (v8 or higher)
- PostgreSQL 
- Docker and docker-compose

---

### Steps

1. Clone the repository:

   ```bash
   git clone https://github.com/Mazene-ZERGUINE/ESGITHUB.git
   ```

2. Navigate to the backend directory:

   ```bash
   cd backend
   ```

3. Install dependencies:

   ```bash
   npm install
   ```

6. Start the server:

   ```bash
   npm run start:dev
   ```

   The server will start on `http://localhost:3000`.


---

## 📖 API Documentation

The API documentation can be accessed at `http://localhost:3000/api` 
