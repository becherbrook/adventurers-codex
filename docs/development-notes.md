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

## 25 September 2026

Installed PostgreSQL 18 in the Ubuntu VM and verified that the PostgreSQL cluster was online.

Created the `adventurers_codex` database and a `classes` table containing the class data previously held in the Python dictionary.

Inserted the existing Fighter, Wizard, Rogue and Cleric data into PostgreSQL and used SQL queries to verify that the data had been stored and could be retrieved.

Installed Psycopg 3.3.6 in the Python virtual environment to provide a Python interface to PostgreSQL.

Created a dedicated `codex_app` PostgreSQL user rather than using the administrative `postgres` account for the application.

The initial Python connection test attempted to connect using the PostgreSQL `postgres` user and failed with `Peer authentication failed`. The Python process was running as the Linux user `motoole`, while PostgreSQL's peer authentication requires the operating-system user and PostgreSQL user to match for that authentication method.

Investigated the authentication behaviour and created the dedicated `codex_app` user instead of changing PostgreSQL's authentication configuration.

Granted `codex_app` permission to connect to the `adventurers_codex` database and read from the `classes` table.

Successfully tested the complete Python connection using Psycopg over TCP:

Python → Psycopg → PostgreSQL → `codex_app` → `adventurers_codex`

A temporary Python connection test file was removed after verification. The Git working tree remains clean.

### Current milestone

The FastAPI application has now been migrated from in-memory class data to PostgreSQL-backed storage.

Created `src/database.py` to provide PostgreSQL connections using the `DATABASE_URL` environment variable rather than storing database credentials in source code.

Updated both API endpoints in `src/main.py` to query PostgreSQL:

- `GET /classes` retrieves all classes from the `classes` table.
- `GET /classes/{class_name}` retrieves a specific class from the database and returns `404 Not Found` when it does not exist.

Removed the obsolete `src/classes.py` module because the class data is now stored in PostgreSQL.

Ran the existing API test suite using:

`python -m pytest`

All three tests passed. The same two dependency deprecation warnings remain and were not investigated further.

Verified the database-backed API responses using `curl`.

The development environment now has the following flow:

Python/FastAPI → Psycopg → PostgreSQL

Database credentials are supplied through the `DATABASE_URL` environment variable and are not stored in the repository.

Next focus:

- Complete the database-backed application milestone and commit the changes.
- Continue towards Docker.
