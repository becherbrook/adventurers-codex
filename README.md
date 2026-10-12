# Adventurer's Codex

A small D&D-inspired rules API built as a cloud/DevOps learning project.

The application itself is deliberately simple. The main purpose of the project is to demonstrate:

* Python development
* Linux
* HTTP and APIs
* Testing
* PostgreSQL
* Docker
* Cloud infrastructure
* Infrastructure as Code
* CI/CD
* Monitoring and observability
* Incident investigation and recovery

## Current status

The project currently contains a small Python/FastAPI application backed by PostgreSQL.

Current endpoints:

* GET /classes — returns the available classes
* GET /classes/{class_name} — returns information about a specific class

The application connects to PostgreSQL using Psycopg.

Database configuration is supplied through the `DATABASE_URL` environment variable rather than being stored in source code.

The current development environment runs locally on Ubuntu Server VM using Uvicorn and PostgreSQL in Docker. PostgreSQL uses a persistent Docker volume for database storage.

## Development setup

The development environment uses Ubuntu, Docker and PostgreSQL.

### Configure the database connection

Start the development database container, then configure the connection string securely:

```bash
source scripts/dev-env.sh
```

Enter the local PostgreSQL password when prompted. The script configures `DATABASE_URL` for the current shell session without storing the password in the script or shell configuration.

Keep this shell open while running the application or tests.

### Run the tests

```bash
python -m pytest
```

### Run the API locally

```bash
uvicorn src.main:app --reload
```

The API will be available locally at `http://127.0.0.1:8000`.

### Monitoring

Prometheus scrapes the application's metrics from `/metrics/` when the development services are running on the configured Docker network.
