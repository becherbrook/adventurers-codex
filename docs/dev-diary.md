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

### Current milestone

The Adventurer's Codex is now a **containerised FastAPI application backed by PostgreSQL, deployed to AWS and managed through Terraform**.

Current application path:

```text
HTTP client
    ↓
AWS Security Group
    ↓
EC2
    ↓
Docker
    ↓
FastAPI / Uvicorn
    ↓
Docker network
    ↓
PostgreSQL
```

Terraform now manages the EC2 instance and its Security Group, including access rules, configuration variables, outputs and lifecycle protection.

The AWS and Terraform milestones are **complete**.

The next stage is **GitHub Actions / CI/CD**, followed by operational monitoring and observability.
