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

`GET /classes`
`GET /classes/{class_name}`

Started the application locally with Uvicorn and successfully tested both endpoints using curl.

The API returned JSON responses as expected.

## 23 September 2026

Reviewed the existing FastAPI application and confirmed that the local API was still functioning correctly.

Used `curl` to make HTTP requests against the API and examined the HTTP response headers.

Explored the basic relationship between:

- HTTP requests
- GET requests
- URL paths
- Ports
- FastAPI route handlers
- HTTP response status codes
- JSON responses

Tested the existing endpoints:

- `GET /classes` returned `200 OK`.
- `GET /classes/fighter` returned `200 OK`.

Deliberately requested a class that does not exist:

- `GET /classes/paladin` returned `500 Internal Server Error`.

Identified that the current implementation raises a Python `KeyError` when an unknown

### Current milestone

The HTTP/API fundamentals have now been introduced using the working Codex application.

Next focus:

- Introduce pytest.
- Test the existing API endpoints.
- Add appropriate handling for unknown classes so that the API returns a suitable HTTP response rather than an unhandled server error.
