# Development Notes

## 21 September 2026

Set up the Ubuntu Server development VM and established SSH access.

Cloned the Adventurer's Codex repository and configured GitHub SSH authentication.

Established the basic Git workflow for working with the repository from the Ubuntu VM.

## 22 September 2026

Created a Python virtual environment for the project.

Resolved the Ubuntu Python packaging requirement for virtual environments by installing the appropriate python3.14-venv package.

Confirmed Python 3.14.4 was available in the project environment.

Added .venv/ to .gitignore.

Created the initial Python data model in src/classes.py, containing a small set of D&D character classes.

Introduced FastAPI and Uvicorn.

Created src/main.py containing the first API endpoints:

GET /classes
GET /classes/{class_name}

Started the application locally with Uvicorn and successfully tested both endpoints using curl.

The API returned JSON responses as expected.

## Current milestone

The Adventurer's Codex is now a functioning local Python/FastAPI HTTP API.

Next focus:

Understand the HTTP request/response model.
Introduce automated testing with pytest.
Add appropriate error handling.
Keep the application deliberately small while building the engineering foundations around it.
