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

The current development environment runs locally on an Ubuntu Server VM using Uvicorn and PostgreSQL.

## Development setup

Set the PostgreSQL connection string in the shell environment before running the application or tests:

Use the password configured for the local `codex_app` PostgreSQL user:

```bash
export DATABASE_URL="postgresql://codex_app:PASSWORD@localhost:5432/adventurers_codex"
