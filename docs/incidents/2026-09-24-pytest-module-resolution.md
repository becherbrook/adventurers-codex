# Development Environment Incident — Pytest Module Resolution

## Incident

**Date:** 24 September 2026  
**Severity:** Low  
**Status:** Resolved

## Summary

The initial attempt to run the project's test suite using the `pytest` command failed because Python could not import the project's `src` package.

## Impact

The API test suite could not initially be executed using the standalone `pytest` command.

The application itself continued to run correctly, and importing the application directly with Python worked.

## Detection

The problem was detected when running the test suite after pytest was introduced.

The standalone command produced:

`ModuleNotFoundError: No module named 'src'`

## Initial Hypothesis

The initial indication was that the test runner's Python/module search path differed from the environment being used to run the application.

## Investigation

Confirmed that the project application could be imported successfully using:

`python -c "from src.main import app; print(app)"`

This demonstrated that Python could locate the `src` package when invoked directly.

The tests were then run using:

`python -m pytest`

This successfully located the project package and executed the test suite.

## Root Cause

The standalone `pytest` invocation did not resolve the project's `src` package in the current development environment.

The exact difference in module resolution between the standalone `pytest` command and `python -m pytest` was not investigated further because running pytest through the active Python interpreter resolved the problem without requiring changes to the application.

## Corrective Action

Adopted:

`python -m pytest`

as the project's test command.

No changes to the application code were required.

## Verification

The full test suite was run using:

`python -m pytest`

Result:

`3 passed, 2 warnings`

The warnings were deprecation warnings from dependencies and did not cause test failures.

## Preventive Improvement

Use `python -m pytest` consistently so that the test runner is executed through the active project Python environment.

The project's documented development workflow should use this form of the command.

## Lessons Learned

The failure demonstrated the importance of distinguishing between:

- a problem with the application code,
- a problem with the test code, and
- a problem with the development environment or way a tool is being invoked.

It also reinforced the value of testing the same operation through the project's active Python interpreter before making unnecessary changes to the application.
