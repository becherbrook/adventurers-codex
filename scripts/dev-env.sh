#!/bin/bash

read -rsp "Database password: " DB_PASSWORD
echo

export DATABASE_URL="postgresql://codex_app:${DB_PASSWORD}@localhost:5432/adventurers_codex"

unset DB_PASSWORD

echo "DATABASE_URL configured for this shell."
