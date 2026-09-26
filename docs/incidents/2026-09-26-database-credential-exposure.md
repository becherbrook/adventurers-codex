# Incident Report

## Incident

**Date:** 26 September 2026
**Severity:** Low
**Status:** Resolved

## Summary

During Docker networking configuration, the PostgreSQL application connection string was displayed in the development session while verifying the `DATABASE_URL` environment variable.

The connection string contained the password for the development `codex_app` PostgreSQL user.

The credential was treated as compromised immediately. The `codex_app` password was changed and the new credential was used for subsequent Docker connection testing.

The exposed credential is not recorded in this incident report or project documentation.

## Impact

The affected credential was for the local development PostgreSQL `codex_app` user on the Ubuntu VM.

The credential was not used for production infrastructure or external services.

The application database remained available and no data loss or corruption occurred.

The affected credential was invalidated shortly after the exposure was identified.

## Detection

The exposure was identified during manual review of the output produced while verifying the `DATABASE_URL` environment variable.

The command output displayed the complete PostgreSQL connection string, including the password.

## Initial Hypothesis

The immediate concern was that the development database credential should be considered compromised because it had been displayed outside the intended local development environment.

## Investigation

Confirmed that the exposed credential belonged to the dedicated `codex_app` PostgreSQL user.

Confirmed that the account was used only for the local Adventurer's Codex development database.

Confirmed that the application database was running on the Ubuntu development VM.

No production systems, cloud resources or external services used the exposed credential.

## Root Cause

The database connection string was manually displayed while troubleshooting and verifying Docker-to-PostgreSQL connectivity.

The connection string contained the database password directly, resulting in accidental credential exposure.

## Corrective Action

Changed the password for the PostgreSQL `codex_app` user using PostgreSQL's `ALTER ROLE` command.

Updated the `DATABASE_URL` environment variable in the active development shell with the new credential.

Did not record either the exposed or replacement password in project documentation.

## Verification

Confirmed that PostgreSQL accepted the password change.

Started the Dockerised Adventurer's Codex application using the updated `DATABASE_URL`.

Successfully queried:

`GET /classes`

The container returned the expected class data from PostgreSQL, confirming that the replacement credential worked.

## Preventive Improvement

Avoid displaying complete database connection strings when verifying environment variables.

When checking that a credential exists, display only a redacted representation that does not expose the password.

Continue using environment variables rather than storing database credentials in source code or committed project files.

As the project progresses towards AWS, move towards an appropriate secrets-management approach rather than manually handling credentials in shell commands.

## Lessons Learned

Environment variables prevent credentials from being committed to application source code, but they do not automatically prevent credentials from being exposed through shell commands or command output.

Credentials should be treated as sensitive wherever they appear, including terminal output, logs and troubleshooting commands.

A development credential should still be rotated immediately when exposed, even when the affected system is not production.

The incident also demonstrated the value of separating application configuration from source code while recognising that secure handling of configuration values remains an operational responsibility.
