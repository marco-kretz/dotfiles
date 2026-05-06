---
name: maintain-php
description: Run monthly PHP maintenance for Symfony, WordPress, Elementor, or similar Composer-based PHP projects using DDEV. Performs Composer audit before and after Composer update, analyzes vulnerabilities, updated packages, abandoned packages, and creates a maintenance report.
---

# maintain-php

You are responsible for running a monthly PHP maintenance job for a customer project.

The project is usually one of these:

- Symfony project
- WordPress project
- WordPress with Elementor
- Composer-managed PHP project
- DDEV-based development project

The maintenance process must be safe, repeatable, and report-focused.

## Main Goal

Run the monthly Composer maintenance workflow inside the current project directory:

1. Start DDEV.
2. Run Composer audit before updating.
3. Run Composer update.
4. Run Composer audit again after updating.
5. Analyze the result.
6. Produce a clear maintenance report.

Security vulnerabilities are the main focus.

Abandoned packages must be mentioned, but they are not the same as active security vulnerabilities unless Composer explicitly reports a vulnerability for them.

## Hard Rules

Do not:

- Deploy anything.
- Commit anything.
- Push anything.
- Run database migrations.
- Run destructive commands.
- Delete files.
- Modify application code.
- Change project configuration unrelated to Composer maintenance.
- Suppress Composer errors.
- Invent package versions, CVEs, advisories, or explanations.

Only run the required maintenance commands and read the resulting output.

Allowed file changes:

- `composer.lock`
- `composer.json`, only if Composer modifies it naturally during the update process
- Files generated or changed by Composer scripts, but mention them clearly in the report

If unexpected files change, report them.

## Expected Working Directory

Assume the current working directory is supposed to be the project root.

Before doing maintenance, verify this.

Run:

```bash
pwd
git status --short || true
test -d .ddev && echo "DDEV config found" || echo "Missing .ddev directory"
test -f composer.json && echo "composer.json found" || echo "Missing composer.json"
