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

Identified that the current implementation raised a Python `KeyError` when an unknown class was requested because the requested class name was used directly as a dictionary key without checking whether it existed.

## 24 September 2026

Introduced pytest and created API tests for the existing endpoints.

Added a test for an unknown class before changing the application code. The test initially failed because requesting `/classes/paladin` resulted in an unhandled `KeyError` and a `500 Internal Server Error`.

Updated `src/main.py` to explicitly handle unknown class names using FastAPI's `HTTPException`, returning `404 Not Found` with the detail `Class not found`.

Ran the test suite using:

`python -m pytest`

All three tests passed.

The test run produced two deprecation warnings relating to the current TestClient/httpx and AnyIO dependencies. These did not affect the test results and were not investigated further.

This development error demonstrated the workflow:

- Observe the failure.
- Investigate the evidence.
- Identify the root cause.
- Define the expected behaviour.
- Write a test for that behaviour.
- Implement the correction.
- Run the tests.
- Verify the result.

This was a development error rather than a production incident, but it is being documented because the investigation and correction provide a useful record of the development and operational learning process.

### Current milestone

The HTTP/API fundamentals have now been introduced using the working Codex application.

Pytest has been introduced and is being used to test the API endpoints.

The API now handles requests for unknown classes explicitly, returning `404 Not Found` rather than an unhandled `500 Internal Server Error`.

The current test suite contains three API tests covering:

- `GET /classes`
- `GET /classes/fighter`
- `GET /classes/paladin` returning `404 Not Found`

All three tests currently pass.

Next focus:

- Reinforce HTTP/API and testing concepts.
- Introduce SQL and PostgreSQL.
- Continue documenting development problems, fixes, and operational lessons as they occur.
