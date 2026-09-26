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

## 26 September 2026

Started containerising the Adventurer's Codex application.

Created `requirements.txt` containing the pinned runtime dependencies required by the application:

* FastAPI 0.141.1
* Uvicorn 0.53.0
* Psycopg 3.3.6

Created a `Dockerfile` using `python:3.14-slim` as the base image. The image installs the runtime dependencies, copies the application source and starts Uvicorn on port 8000.

Created `.dockerignore` to exclude `.git`, `.venv`, Python cache files and pytest cache from the Docker build context.

Installed Docker Engine in the Ubuntu VM and configured the `motoole` user for Docker access.

Built the `adventurers-codex:latest` Docker image successfully.

Initially tested the container with a dummy `DATABASE_URL` to verify that the FastAPI application could start successfully inside the container.

Tested Docker port mapping using `-p 8000:8000`. A request to `/` returned the expected FastAPI `404 Not Found`, confirming that the request reached the container.

Investigated container-to-host PostgreSQL networking. PostgreSQL was initially listening only on `127.0.0.1:5432`, which is not accessible from a Docker container.

Configured PostgreSQL to listen on both `localhost` and the Docker bridge address `172.17.0.1`.

Added a PostgreSQL `pg_hba.conf` rule allowing the dedicated `codex_app` user to connect to the `adventurers_codex` database from the Docker bridge subnet using SCRAM authentication.

Started the application container with `DATABASE_URL` supplied as an environment variable and successfully retrieved the class data through:

Docker container → FastAPI → Docker network → PostgreSQL → `classes` table

Verified with:

`curl http://localhost:8000/classes`

The containerised application returned the expected Cleric, Fighter, Rogue and Wizard data.

This milestone demonstrates that the application can now run as a Docker container while using PostgreSQL as an external database service.

Next focus:

* Review the Docker setup and tests.
* Commit and push the completed Docker milestone.

### Current milestone

The FastAPI application is now running successfully as a Docker container and continues to use PostgreSQL for persistent storage.

Created `requirements.txt` containing the pinned runtime dependencies required by the application.

Created a `Dockerfile` using `python:3.14-slim` and configured the container to run Uvicorn on port 8000.

Created `.dockerignore` to prevent development files, Git metadata and Python cache files from being included in the Docker build context.

Installed Docker Engine in the Ubuntu VM, configured Docker access for the development user and successfully built the `adventurers-codex:latest` image.

Configured Docker port mapping so that port 8000 on the Ubuntu VM reaches port 8000 inside the application container.

Configured PostgreSQL to accept connections from the Docker bridge address and added a restricted `pg_hba.conf` rule allowing `codex_app` to connect to the `adventurers_codex` database from the Docker bridge subnet.

Verified the complete containerised application path:

Docker container → FastAPI → Docker network → PostgreSQL → `classes` table

The `/classes` endpoint successfully returned the expected database-backed class data when requested through the containerised application.

Database credentials continue to be supplied through the `DATABASE_URL` environment variable and are not stored in the repository.

A development credential was accidentally exposed during the Docker networking setup. The exposed credential was immediately treated as compromised and replaced with a new password. The exposed credential itself is not recorded in project documentation.

Next focus:

* Complete the final Docker test and documentation review.
* Review the Git diff and commit the Docker milestone.
* Push the completed milestone to GitHub.
* Update the career transition handoff to record Docker as completed.
* Continue to AWS once the Docker milestone is clean and documented.
