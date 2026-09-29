# Incident Report

## Date

**28 September 2026**


**Severity:** Low
**Status:** Resolved

## What happened

During deployment of the Adventurer's Codex to AWS EC2, the PostgreSQL container was created using an outdated version of the `classes` table schema.

The FastAPI application expected an `id` column, but the deployed database table only contained `name` and `hit_die`.

The API therefore failed when attempting to retrieve class data.

## Investigation

Checked the application error logs and identified:

`psycopg.errors.UndefinedColumn: column "id" does not exist`

Checked the current application source and PostgreSQL migration history to establish the expected schema.

Confirmed that the deployed database schema did not match the current application.

## Resolution

Recreated the PostgreSQL database with the current `classes` schema and restored the expected class data.

Restarted the application and verified the API successfully returned class data.

External testing then confirmed:

`GET /classes/fighter` → HTTP 200

`GET /classes/paladin` → HTTP 404

The AWS deployment was confirmed to be working correctly.

## Lessons learned

The database schema must match the version of the application being deployed.

When troubleshooting deployment failures, application logs provide the initial error, but the current source code and migration history should be used to establish the expected state.

The incident followed the operational process:

**observe → diagnose → verify → correct → retest**
