# Incident Report

## Date

**Severity:** Low
**Status:** Resolved

## What happened

The initial attempt to run the project's test suite using the `pytest` command failed because Python could not import the project's `src` package.

The standalone command produced:

`ModuleNotFoundError: No module named 'src'`

The application itself continued to run correctly.

## Investigation

Confirmed that the project application could be imported successfully using:

`python -c "from src.main import app; print(app)"`

This demonstrated that Python could locate the `src` package when invoked directly.

The tests were then run using:

`python -m pytest`

This successfully located the project package and executed the test suite.

The exact difference in module resolution between the standalone `pytest` command and `python -m pytest` was not investigated further because using pytest through the active Python interpreter resolved the problem without requiring changes to the application.

## Resolution

Adopted:

`python -m pytest`

as the project's test command.

The full test suite was run successfully:

`3 passed, 2 warnings`

The warnings were deprecation warnings from dependencies and did not cause test failures.

No application code changes were required.

## Lessons learned

The failure demonstrated the importance of distinguishing between a problem with the application code, the test code, and the development environment or way a tool is being invoked.

It also reinforced the value of testing through the project's active Python interpreter before making unnecessary changes to the application.
