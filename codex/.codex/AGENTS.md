# Codex Global Rules

Applicable project instructions take precedence where they conflict.

## Working style

* Inspect relevant code and callers before non-trivial changes; form a short plan.
* Complete authorized work end to end. Resolve routine details from context; ask only when missing information materially affects correctness, scope, or risk.
* Preserve existing user changes and respect review-only requests and approval boundaries. Continue independent authorized work while a blocking question remains open.
* Use plain language and concise paragraphs. Report the outcome, relevant checks, and material limitations; never claim verification you did not perform.
* Flag risky or destructive operations before executing or recommending them.
* Use Conventional Commits for commit messages.
* Treat skills as workflow guidance, not additional approval requirements. Explicit user instructions take precedence; identify the file and instruction if a skill blocks authorized work.

## Implementation and tools

* Make the smallest correct change within scope. Preserve project conventions; avoid unrelated cleanup, speculative abstractions, dependencies, and formatting churn.
* Before adding a mechanism, check existing code, standard libraries, native features, and documented options, hooks, or extension points.
* Prefer installed CLI tools over MCPs; use `gh` for GitHub and project DDEV commands where configured.
* Use the project's package manager, lockfile, runtime versions, and documented commands. Do not install or update global tools as part of routine checks.
* If an approach fails twice, reassess assumptions and consult relevant documentation before choosing another approach.
* Fix shared root causes rather than adding compensation at individual callers. Validate untrusted input at external boundaries.
* Add comments only for non-obvious reasons, constraints, or invariants.
* PHP and TypeScript: strict typing and features supported by the project's version. JavaScript: ES6+ unless the project requires otherwise.

## Validation and browser testing

* Run targeted existing tests, static analysis, linting, formatting, or builds relevant to the change. Complete required project checks and fix failures caused by your changes.
* Add tests when they verify behavior or prevent regression, using the project's existing test approach. Broaden or repeat checks only for new changes, failures, or concrete unresolved risks.
* For UI changes, exercise the affected flow headlessly through CLI tools with `/usr/bin/chromium`; do not use browser MCPs or attach to personal browser sessions.
* Prefer existing project browser tests. For exploratory checks, use an installed Playwright CLI when available. Keep outputs focused; inspect relevant snapshot excerpts and use screenshots for visual questions.
* Check relevant desktop/mobile layouts, keyboard interaction, and console errors. Screenshots alone do not prove functional correctness; use interactions and assertions.
* Take application URLs, start commands, and test accounts from project instructions. Report browser checks that could not run.

## Review and delegation

* Before creating a PR with the shared `pull-request` skill, request a fresh read-only review from `~/.codex/agents/reviewer.toml`. Description-only requests do not require independent review.
* Supply actual base/head, diff scope, relevant rules, and validation evidence. Request findings only, with no edits or test execution.
* If independent review is unavailable or fails, report the blocker before creating the PR; do not claim self-review was independent or switch harnesses as a fallback.
* Delegate only when independent review, bounded research, isolation, or context reduction materially helps. Keep small tasks local; model defaults belong in config and agent definitions.
* One writer per checkout; reviewers inspect without editing. Give children explicit scope, applicable rules, and approval boundaries.
* Shared skills contain workflows, not harness-specific agent names, model IDs, or tool APIs. Never assume another harness's capabilities or permissions are available.

## DDEV + git worktrees

In a DDEV project (`.ddev/config.yaml` present), create worktrees with `ddev worktree <branch>`.
It sets the project name in gitignored `.ddev/config.local.yaml`, starts the project,
and copies the DB. Never use `ddev config --project-name`; it changes committed configuration.
Worktree creation and DB copying must be within the authorized task. Cleanup destroys
the worktree's database: confirm the exact disposable project and uncommitted state
before `ddev delete -O <name> && git worktree remove <dir>`.
