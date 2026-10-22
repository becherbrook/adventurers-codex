# Incident Report

## Date

22 October 2026

**Severity:** Low  
**Status:** Resolved

## What happened

A security advisory reported compromised eMudhra/emSign certificate authority infrastructure, requiring removal of the affected `emSign ECC Root CA - G3` trust path from certificate stores.

Adventurer's Codex was not observed to be compromised. This was a preventative security response to determine whether development and runtime environments trusted the affected CA and to apply the relevant vendor updates.

## Investigation

The project's relevant certificate stores and dependencies were checked individually.

The Ubuntu 26.04 development VM was running `ca-certificates 20260601~26.04.1`. After refreshing package information, Ubuntu offered `20260816ubuntu0.26.04.1`, which contained the relevant CA remediation.

The existing Adventurer's Codex Docker application image was based on Debian 13 and contained `ca-certificates 20250419`. A refreshed `python:3.14-slim` base contained the patched `20250419+deb13u1` package.

The Python development virtual environment contained `certifi 2026.7.22`, an affected version. Investigation showed that `certifi` was not a declared Adventurer's Codex runtime dependency. It had been introduced through additional tooling installed in the development environment. The rebuilt application Docker image did not contain `certifi`.

The existing Prometheus image was inspected directly. Its CA bundle contained `emSign ECC Root CA - G3`, confirming that the Prometheus runtime also required remediation.

During the Prometheus image update, two Docker pulls caused the VirtualBox development VM to become unresponsive. Kernel logs recorded CPU soft lockups involving both `dockerd` and the idle kernel task, along with clocksource and virtual `e1000` watchdog warnings. The VM had been configured with 2 vCPUs, approximately 1.6 GiB RAM and no swap.

The VM allocation was increased to 4 vCPUs and 4 GB RAM. The same Prometheus pull then completed successfully. This demonstrated that increasing VM resources resolved the reproducible failure, although the investigation did not establish whether CPU, memory, VirtualBox scheduling or another VM-level factor was the precise underlying cause.

## Resolution

The Ubuntu host CA package was upgraded to `20260816ubuntu0.26.04.1` and the installed version was verified.

The `python:3.14-slim` base image was refreshed and the Adventurer's Codex application image rebuilt. The rebuilt image was verified to contain Debian `ca-certificates 20250419+deb13u1`.

The development virtual environment was upgraded from `certifi 2026.7.22` to `certifi 2026.10.19`. `pip check` subsequently reported no broken requirements.

The Prometheus image was updated to Prometheus `3.15.1`, built 21 October 2026. The existing Prometheus container was recreated from the updated image while retaining its existing configuration, Docker network, port mapping and persistent data volume. The replacement container started successfully.

Post-remediation verification included:

- Python test suite: all 3 tests passed.
- `/health`: HTTP 200, confirming application and database connectivity.
- `/classes`: HTTP 200 with the expected four class records.
- `/metrics/`: HTTP 200 with Prometheus metrics, including successful `/health` and `/classes` request counters.
- PostgreSQL recovered successfully following the VM interruptions and reported that it was accepting connections.
- Replacement Prometheus container successfully entered the running state.

## Lessons learned

External security advisories should be assessed against each relevant runtime rather than assuming that updating the host operating system protects containers or Python environments.

Container images maintain their own certificate stores and must be rebuilt or replaced when their trust stores are affected.

Python virtual environments may contain their own CA bundle through `certifi`, even when it is not a direct application dependency. Dependency provenance should therefore be investigated before adding packages or version pins to project requirements.

Verification should include both package/version evidence and functional testing of the application after remediation.

The incident also exposed an unrelated resource limitation in the development VM. Repeated Docker image pulls produced reproducible VM-level soft lockups under the previous resource allocation. Increasing the VM resources allowed the same operation to complete successfully.

The response followed the project's operational troubleshooting approach: observe, diagnose, verify, correct and retest.
