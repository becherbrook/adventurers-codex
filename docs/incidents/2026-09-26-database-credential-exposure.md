# Incident Report

## Date

**Severity:** Low
**Status:** Resolved

## What happened

During Docker networking configuration, the PostgreSQL application connection string was displayed while verifying the `DATABASE_URL` environment variable.

The connection string contained the password for the development `codex_app` PostgreSQL user.

The credential was treated as compromised immediately. The password was changed and the new credential was used for subsequent Docker connection testing.

The exposed credential is not recorded in this incident report or project documentation.

The affected credential was for the local development PostgreSQL database on the Ubuntu VM. It was not used for production infrastructure or external services. No data loss or corruption occurred.

## Investigation

Confirmed that the exposed credential belonged to the dedicated `codex_app` PostgreSQL user and was used only for the local Adventurer's Codex development database.

The exposure occurred because the complete database connection string, including the password, was displayed during troubleshooting.

No production systems, cloud resources or external services used the exposed credential.

## Resolution

Changed the password for the PostgreSQL `codex_app` user using PostgreSQL's `ALTER ROLE` command.

Updated the `DATABASE_URL` environment variable in the active development shell with the new credential.

The replacement credential was verified by starting the Dockerised Adventurer's Codex application and successfully querying:

`GET /classes`

The container returned the expected class data from PostgreSQL.

Neither the exposed nor replacement password was recorded in project documentation.

## Lessons learned

Environment variables prevent credentials from being committed to application source code, but they do not prevent credentials being exposed through shell commands, terminal output or logs.

Credentials should be treated as sensitive wherever they appear. When checking environment variables, use a redacted representation rather than displaying the complete connection string.

A development credential should still be rotated immediately when exposed, even when the affected system is not production.

As the project progresses towards AWS, an appropriate secrets-management approach should replace manual handling of credentials where practical.
