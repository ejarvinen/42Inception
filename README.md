# 42Inception
*this project is still under construction, stay tuned* :wink:

## Description
`Inception` is a system administration project aimed at setting up a small-scale infrastructure using Docker and Docker Compose. The goal is to create and manage multiple services in isolated containers, following best practices in containerization and security.

## Features
- Docker Compose-based container orchestration.
- Services run in separate containers:
  - **NGINX** with TLSv1.2 or TLSv1.3 support.
  - **WordPress** + php-fpm without NGINX.
  - **MariaDB** as a database.
- Persistent storage using Docker volumes.
- Secure networking using a dedicated Docker network.
- Containers restart automatically in case of failure.
- Proper environment variable management with `.env` file.

## Installation
1. Clone the repository:
```
git clone https://github.com/ejarvinen/42Inception.git
```
2. Navigate to the project directory:
```
cd 42Inception
```
3. Build and run the project using:
```
make
```
## Usage
- To start the containers:
```
make up
```
- To stop the containers:
```
make down
```
- To clean up and rebuild:
```
make re
```
## Directory Structure
```
.
├── Makefile
├── srcs
│   ├── docker-compose.yml
│   ├── .env
│   ├── requirements
│   │   ├── mariadb
│   │   ├── nginx
│   │   ├── wordpress
```
## Configuration
- Modify the `.env` file to set up your domain, database credentials, and other configurations.
- The domain name must follow the format `login.42.fr`, where login for this specific project is `emansoor`.
## Security Considerations
- No plaintext passwords in Dockerfiles.
- Environment variables should be stored in `.env`.
- NGINX serves as the only entry point on port 443.
