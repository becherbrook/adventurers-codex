# Dev Diary

## 21 September 2026

Set up the Ubuntu Server VM and established SSH access via Windows Terminal desktop PC.

Cloned the Adventurer's Codex repository and configured GitHub SSH authentication.

Established basic Git workflow of repository from the Ubuntu VM.

## 22 September 2026

Created Python virtual environment for the project (.venv). Resolved missing Ubuntu Python package requirement (python3.14-venv).

Confirmed Python 3.14.4 was available in the project environment and added .venv/ to .gitignore.

Created the initial Python data model in src/classes.py, containing small set of D&D character classes and hit points (fighter, cleric, rogue, wizard).

Introduced FastAPI and Uvicorn.

Created src/main.py containing the first API endpoints:

`GET /classes`
`GET /classes/{class_name}`

Started the application locally with Uvicorn and successfully tested both endpoints using curl. API returned JSON responses as expected.

## 23 September 2026

Reviewed and confirmed the existing FastAPI application.

Used `curl` to make HTTP requests against the API and examined the HTTP response headers.

Explored the basic relationship between:

* HTTP requests
* GET requests
* URL paths
* Ports
* FastAPI route handlers
* HTTP response status codes
* JSON responses

Tested existing endpoints:

* `GET /classes` returned `200 OK`.
* `GET /classes/fighter` returned `200 OK`.

Deliberately requested a class that does not exist:

* `GET /classes/paladin` returned `500 Internal Server Error`.

Identified that current implementation raised a Python `KeyError` when an unknown class was requested because the requested class name was used directly as a dictionary key without checking whether it existed.

## 24 September 2026

Introduced pytest and created API tests for the existing endpoints.

Added a test for an unknown class before changing the app code. The test initially failed because requesting `/classes/paladin` resulted in an unhandled `KeyError` and a `500 Internal Server Error`.

Updated `src/main.py` to explicitly handle unknown class names using FastAPI's `HTTPException`, returning `404 Not Found` with the detail `Class not found`.

Ran the test suite using: `python -m pytest`, tests passed.

The test run produced 2 deprecation warnings relating to current TestClient/httpx and AnyIO dependencies. These did not affect the test results and were not investigated further at this stage.

This development error demonstrated the workflow:

* Observe the failure.
* Investigate the evidence.
* Identify the root cause.
* Define the expected behaviour.
* Write a test for that behaviour.
* Implement the correction.
* Run the tests.
* Verify the result.

This was a dev error rather than a prod incident, but it is being documented because the investigation and correction provide a useful record of the development and operational learning process.

## 25 September 2026

Installed PostgreSQL 18 in the Ubuntu VM and verified that the PostgreSQL cluster was online.

Created the `adventurers_codex` database and a `classes` table containing the class data previously held in the Python dictionary.

Migrated existing Fighter, Wizard, Rogue and Cleric data into PostgreSQL and used SQL queries to verify that the data had been stored and could be retrieved.

Installed Psycopg 3.3.6 in the Python venv. to provide a Python interface to PostgreSQL.

Created a dedicated PostgreSQL user rather than using the administrative account for the application.

The initial Python connection test attempted to connect using the PostgreSQL user and failed with `Peer authentication failed`. The Python process was running as the Linux VM user, while PostgreSQL's peer authentication requires the operating-system user and PostgreSQL user to match for that authentication method.

Investigated the authentication behaviour and created the dedicated user instead of changing PostgreSQL's authentication configuration. Granted user permission to connect to the `adventurers_codex` database and read from the `classes` table.

Successfully tested the complete Python connection using Psycopg over TCP:

Python → Psycopg → PostgreSQL → USER → `adventurers_codex`

A temporary Python connection test file was removed after verification. The Git working tree remains clean.

## 26 September 2026

Containerised the Adventurer's Codex application using Docker.

Created a `Dockerfile`, `.dockerignore` and `requirements.txt` with pinned runtime dependencies. Installed Docker Engine in the Ubuntu VM and configured user access.

Successfully built and ran the application in a container, including testing port mapping and FastAPI startup.

Investigated and resolved connectivity between the container and the PostgreSQL database running on the host.

Configured PostgreSQL to accept connections from the Docker network and added a restricted authentication rule for the application database user.

Verified end-to-end connectivity, successfully retrieving class data through the containerised API.

The application now runs in Docker and retrieves its data from PostgreSQL. The Docker milestone is complete.

A database credential was also exposed during troubleshooting. The credential was rotated immediately and the incident was documented separately.


## 27 September 2026

Updated the class structure to rename `Rogue` to `Thief`.

Updated the PostgreSQL data and API test to use `Thief` / `thief`.

Ran the full test suite after the change:

`3 passed, 2 warnings`

The existing historical diary entries were left unchanged.


## 28 September 2026

Set up the AWS environment for the Adventurer's Codex and deployed the existing containerised application to an EC2 instance in the London region (`eu-west-2`).

Configured:

* AWS account access and AWS CLI
* An EC2 instance with restricted SSH access
* Docker and the Adventurer's Codex repository
* A read-only GitHub deploy key
* FastAPI and PostgreSQL containers on a Docker network

During deployment, the PostgreSQL container initially used an outdated schema. The API failed because the expected `id` column was missing. Checked the current application source and migration history, corrected the schema and recreated the database with the expected data.

Configured the AWS Security Group to allow TCP port 8000 from the user's IP and successfully tested the API externally, including both successful and 404 responses.

The AWS deployment milestone is complete. The EC2 instance was stopped after testing to avoid unnecessary compute charges.

## 29 September 2026

Terraform installed and initialised:

* Existing EC2 instance imported into Terraform rather than recreated.
* EC2 configuration defined in code.
* Terraform-managed Security Group created.
* SSH and API access restricted to my IP.
* Old AWS-generated Security Group removed.
* `terraform plan` confirmed no drift.
* Changes committed and pushed.

A minor AWS error occurred because the Security Group description contained an unsupported apostrophe. This was corrected before applying the configuration.

## 30 September 2026

Completed the Terraform milestone.

Parameterised the Terraform configuration using variables for the AWS region, EC2 instance type, VPC, subnet and allowed IP ranges.

Added Terraform outputs for the EC2 instance ID, private IP and Security Group ID.

Examined the Terraform dependency graph and how resource references create dependencies between resources.

Tested using an AWS AMI data source. `terraform plan` correctly identified that changing the AMI would require the existing EC2 instance to be replaced. The change was not applied and the original configuration was restored.

Created a temporary Terraform module to examine module inputs and outputs. The module was removed after the concept had been demonstrated as it was not required for the current project.

Reviewed Terraform state and backend concepts. Retained local state as appropriate for the current single-user project.

Made a controlled infrastructure change by adding an `Environment = "dev"` tag to the EC2 instance and confirmed that Terraform updated the instance in place.

Added `prevent_destroy = true` to the EC2 resource to protect the instance from accidental Terraform destruction.

Ran `terraform fmt`, `terraform validate` and `terraform plan`. Terraform reported no pending infrastructure changes.

Committed and pushed the completed Terraform work. The Git working tree remains clean.

## 5 October 2026

Introduced GitHub Actions to automate the project's test suite on pushes and pull requests.

Created `.github/workflows/ci.yml` to:

* Check out the repository.
* Set up Python 3.14.
* Install the project's runtime and development dependencies.
* Start a temporary PostgreSQL 18 service.
* Initialise the database using `scripts/init_db.sql`.
* Run the test suite using `python -m pytest`.

The initial workflow failed because `pytest` was not included in the installed dependencies. Created `requirements-dev.txt` to include the runtime requirements and development/testing dependencies.

A subsequent local test run showed that the application requires `DATABASE_URL` to be present when the database module is imported. The CI workflow was updated to provide a `DATABASE_URL` pointing to the PostgreSQL service running on the GitHub Actions runner.

The CI database uses a temporary PostgreSQL service rather than the deployed AWS database. This keeps CI isolated from the production infrastructure and allows each workflow run to start with a known database state.

The next CI run failed because the FastAPI test client required the `httpx2` package. Added `httpx2` to `requirements-dev.txt`.

The workflow then completed successfully. GitHub Actions now verifies the application by creating a clean Python environment, starting PostgreSQL, initialising the database and running the API tests.

The GitHub Actions / CI milestone is complete.

## 6 October 2026

Started the operational monitoring and observability stage of the project, beginning with application logging.

Added Python logging to the FastAPI application and introduced useful `INFO`, `WARNING` and `ERROR` messages for normal activity, handled 404 responses and database connection failures.

Tested the logging behaviour using `curl` and deliberately introduced controlled failures to investigate the evidence available to an operator.

A request for an unknown class generated a 404 response and corresponding application warning.

Deliberately configured an incorrect PostgreSQL password and tested the API. The client received a generic `500 Internal Server Error`, while the application logs identified the database connection failure and the underlying `psycopg.OperationalError`.

Investigated why application log messages were initially not appearing and identified that the Python logging system had not been configured for the application process. Added `logging.basicConfig(level=logging.INFO)` and verified that application logs were then produced alongside the Uvicorn access logs.

Added explicit handling for `psycopg.OperationalError` around the database connection. Restored the correct database configuration and verified successful API operation.

A temporary Python indentation error (`TabError`) was also encountered and corrected during the changes.

This stage reinforced the operational investigation workflow:

```text
Observe
    ↓
Diagnose
    ↓
Verify
    ↓
Correct
    ↓
Retest
```

`curl` was used as a command-line HTTP diagnostic tool throughout the investigation.

The next stage is metrics and health visibility, followed by CloudWatch, Prometheus, Grafana and alerting.

## 7 October 2026

Continued the operational monitoring and observability stage by adding a health endpoint to the FastAPI application.

Added `GET /health` to verify database connectivity and return `200 OK` when the database is available or `503 Service Unavailable` when it is unavailable.

The existing local PostgreSQL installation was identified as a native Ubuntu service listening on port 5432. Created and verified a PostgreSQL database dump before making infrastructure changes.

Stopped the native PostgreSQL service and created a persistent Docker volume for the database. Deployed PostgreSQL 18 as a Docker container with a restart policy of `unless-stopped` and restored the existing database from the verified backup.

The database dump contained ownership metadata referring to the old PostgreSQL `postgres` role. Updated the restored `classes` table to be owned by the application's `codex_app` user.

Searched the project source and configuration for references to the old `postgres` role. The only active references were found in the GitHub Actions CI configuration, where the PostgreSQL superuser is currently used for the temporary CI database.

Reconnected the FastAPI application to the Docker PostgreSQL instance using the existing `DATABASE_URL` configuration and verified that `/health` returned `200 OK` with the database connected.

Performed a controlled failure test by stopping the PostgreSQL container. `/health` correctly returned `503 Service Unavailable` with the database reported as unavailable.

Restarted the PostgreSQL container and verified that the application recovered successfully. Confirmed that all four class records remained present after the container restart, demonstrating that the Docker volume was providing persistent database storage.

The local PostgreSQL environment now uses a persistent Docker container rather than the native PostgreSQL installation.

Reviewed the GitHub Actions CI database configuration and changed the temporary CI PostgreSQL service to use the application's `codex_app` user rather than the PostgreSQL superuser. Updated the CI `DATABASE_URL` accordingly and verified that the workflow completed successfully.

The next stage is to continue the operational monitoring and observability work with metrics and health visibility beyond the current health check.

## 8 October 2026

Continued the operational monitoring and observability stage by introducing a repeatable local database credential-handling procedure.

Previously, starting a development session required manually setting up the database environment and supplying the required connection details. There was no defined procedure for handling the database password.

Created `scripts/dev-env.sh` to prompt for the database password at the start of a development session, construct the required `DATABASE_URL` and export it for the current shell session.

The temporary password variable is then unset after the connection string has been created.

This means the normal development process is now:

```text
Start development session
    ↓
Run scripts/dev-env.sh
    ↓
Enter database password when prompted
    ↓
DATABASE_URL configured for the current shell
    ↓
Run application / development commands
```

The password is not stored in the script or shell configuration.

The new procedure provides a simple, repeatable approach to local credential handling and establishes a basic security process where none previously existed.

Continued the operational monitoring and observability stage by adding Prometheus metrics to the FastAPI application.

Added the Prometheus client library and exposed a `/metrics/` endpoint. Added request metrics recording the HTTP method, endpoint and response status.

Created a Prometheus container on the same Docker network as the FastAPI and PostgreSQL containers. Configured Prometheus to scrape the application using the Docker container hostname rather than a container IP address.

Verified that Prometheus could retrieve the application's metrics and recorded both successful requests and the previously tested `503` database failure and subsequent `200` recovery.

During configuration, Prometheus initially failed to resolve the application hostname. Investigation showed that the configured hostname contained a spelling error. Correcting the hostname restored connectivity and the Prometheus target returned to `UP`.

This reinforced the operational investigation principle of verifying configuration and service names before assuming an underlying infrastructure failure.

The first metrics milestone is complete:

```text
Application
    ↓
/metrics
    ↓
Prometheus
    ↓
Queryable operational data
```

## 12 October 2026

Conducted a repository security and publication-readiness review before considering making the GitHub repository public.

Reviewed the tracked files and confirmed that local environment files, Terraform state and variable files were not tracked. Reviewed `.gitignore` and `.dockerignore` to ensure local credentials, Terraform working files and variable files were excluded from Git and the Docker build context. Added a general `*.tfvars` exclusion to both files and committed and pushed the changes.

Reviewed the repository history and removed the previously exposed IP address and personal email address from historical commit content and author metadata. Force-pushed the rewritten history to GitHub and verified that the remote `main` branch matched the cleaned history.

Searched tracked files for common credential patterns and confirmed that the remaining matches were expected examples or runtime credential-handling code, rather than identified live credentials. Confirmed that the development database password is entered through `scripts/dev-env.sh` rather than stored in the script or shell configuration.

Updated the README to document the development setup, secure database connection procedure, test command, local API startup and Prometheus monitoring. Committed and pushed the documentation changes.

This review reinforced that repository security requires attention to more than the current source files. Git history, environment configuration, infrastructure state, Docker build context and documentation can all expose information if they are not handled correctly.

The repository security review and corrective changes are complete. The project is now ready for the final checks before making the GitHub repository public.

## 22 October 2026

Responded to an external security advisory concerning compromised eMudhra/emSign certificate authority infrastructure.

Assessed the Adventurer's Codex development and runtime environments to determine whether affected certificate trust was present.

The Ubuntu development VM was found to have an older CA certificate package and was updated to the vendor-fixed version. The Docker application image was also found to contain an older Debian CA certificate package, so the Python base image was refreshed and the application image rebuilt with the patched certificate store.

The Python development virtual environment contained an affected version of `certifi`. This was upgraded to the patched release and the Python environment was checked for broken dependencies. Investigation confirmed that `certifi` was not part of the application's declared runtime dependencies and was not present in the rebuilt application container.

The existing Prometheus container image was inspected and confirmed to contain the affected `emSign ECC Root CA - G3`. Prometheus was updated to the vendor's security-fixed 3.15.1 release and the container was recreated while retaining its existing configuration and persistent data.

During the Prometheus update, repeated Docker image pulls caused the VirtualBox VM to become unresponsive with CPU soft-lockup messages. The VM resource allocation was increased from 2 to 4 vCPUs and from approximately 2 GB to 4 GB RAM. The same image pull subsequently completed successfully, although the precise cause of the VM lockup was not established.

Post-remediation testing confirmed that the application, PostgreSQL connectivity, API endpoints, automated tests and Prometheus metrics continued to operate successfully.

The security response has been documented separately in `docs/incidents/2026-10-22-emudhra-ca-remediation.md`.

This exercise demonstrated assessment and remediation of a real external security advisory across multiple layers of an application environment rather than simply applying an operating-system update.

## Current milestone

The main Adventurer's Codex infrastructure and operations milestones are **complete**.

The project currently demonstrates:

* Python/FastAPI application development and API testing.
* PostgreSQL database integration and persistent containerised storage.
* Docker application and service containerisation.
* AWS EC2 deployment.
* Terraform infrastructure management.
* GitHub Actions CI.
* Application logging and health monitoring.
* Prometheus metrics and service monitoring.
* Secure local credential handling.
* Repository security review and remediation.
* Structured troubleshooting and incident documentation.
* Assessment and remediation of an external security advisory.

The project is currently in a **stable, paused state** rather than active feature development.

Possible future work includes CloudWatch, Grafana, alerting and further reliability or incident-response exercises, but these are not currently committed milestones. Future development can resume when there is a useful technical or learning objective rather than extending the project solely for the sake of adding more tooling.
