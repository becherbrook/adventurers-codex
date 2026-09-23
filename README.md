# Adventurer's Codex

A small D&D-inspired rules API built as a cloud/DevOps learning project.

The application itself is deliberately simple. The main purpose of the project is to demonstrate:

* Python development
* Linux
* HTTP and APIs
* Testing
* Databases
* Docker
* Cloud infrastructure
* Infrastructure as Code
* CI/CD
* Monitoring and observability
* Incident investigation and recovery

## Current status

The project currently contains a small Python/FastAPI application providing a basic HTTP API for D&D classes.

Current endpoints:

* GET /classes — returns the available classes
* GET /classes/{class_name} — returns information about a specific class

The initial data is stored in a simple Python data structure. The API currently runs locally using Uvicorn.

The project is being developed incrementally, with infrastructure and operational engineering deliberately receiving more attention than application complexity.

## Planned progression


Python
  ↓
FastAPI
  ↓
Testing
  ↓
PostgreSQL
  ↓
Docker
  ↓
AWS
  ↓
Terraform
  ↓
CI/CD
  ↓
Monitoring / observability
  ↓
Incident investigation and recovery


Operational incidents will eventually be deliberately introduced and documented as part of the learning process.

