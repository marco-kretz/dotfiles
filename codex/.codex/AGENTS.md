# Codex Global Rules

These are the complete global rules for Codex. Applicable project instructions still
apply and take precedence where they conflict.

## Review routing

* For the shared `pull-request` skill, delegate to the `reviewer` agent defined in `~/.codex/agents/reviewer.toml` with a fresh read-only review task.
* Supply the actual base/head, diff scope, relevant rules, and validation evidence. Request findings only, with no edits or test execution.
* If independent review is unavailable or fails, report the blocker before creating the PR; do not switch to another harness or claim self-review was independent.

## Working Style

* Be concise and explicit.
* Inspect relevant code before making non-trivial changes.
* For non-trivial work, form a short plan before acting.
* Preserve project conventions.
* Prefer minimal diffs and the simplest correct fix.
* Before introducing a new mechanism, check for an existing option, flag, attribute, hook, extension point, or documented API.
* Avoid unnecessary dependencies, renames, abstractions, and formatting churn.
* Do not claim verification you did not perform.
* Run the smallest relevant checks when possible.
* Flag risky or destructive operations before executing or recommending them.
* Use Conventional Commits for commit messages.
* Complete authorized work end to end. Resolve routine details from context and project conventions; ask only when missing information materially affects correctness, scope, or risk.
* Respect explicit review-only requests and approval boundaries. Continue independent, authorized work while a blocking question remains open.
* Use plain language and concise paragraphs. Use lists or tables when they make the answer easier to understand.
* Treat skills as workflow guidance, not additional approval requirements. Explicit user instructions take precedence over skill guidance; if a skill blocks authorized work, identify the file and the specific instruction.

## Problem Solving

* Do not over-engineer small problems.
* If an approach fails twice, stop repeating it. Reassess assumptions, consult relevant documentation when useful, and choose the simplest in-scope alternative.
* When third-party behavior causes a problem, prefer the library's documented configuration, opt-out, hook, extension point, or skip mechanism over building a compensation layer around it.

## Code Changes

* Make only changes required for the task.
* Avoid unrelated cleanup.
* Do not introduce abstractions beyond what the task requires.
* Avoid comments and docstrings that merely restate the code.
* Add comments only when the reason is non-obvious, such as a hidden constraint, workaround, or subtle invariant.
* Avoid speculative handling of impossible internal states.
* Validate untrusted input and external boundaries appropriately.

## Validation

* Prefer targeted tests, static analysis, linting, formatting, or build checks relevant to the changed code.
* Prefer targeted checks before expensive project-wide checks.
* Add tests only when they meaningfully verify behavior or prevent regression; use the project's existing test approach rather than introducing a separate harness for a small change.
* Once relevant checks pass, broaden or repeat them only for new changes, failures, or concrete unresolved risks. Complete required project checks.
* Fix failures caused by your changes.
* Clearly report checks that could not be run.

## Typing

* PHP and TypeScript: strict typing and modern features supported by the project's version. JavaScript: ES6+ unless the project requires otherwise.

## Harness boundaries

* Shared skills contain the workflow, not harness-specific agent names, model IDs, or tool APIs. Use Codex's own review and delegation routing above.
* Delegate only when independent review, bounded research, isolation, or context reduction materially helps. Keep small tasks local.
* One writer per checkout; reviewers inspect and report without editing. Give children explicit scope, applicable project rules, and approval boundaries.
* Never assume another harness's agents, tools, MCP servers, or permissions are available. Do not switch harnesses as a fallback without approval.

## DDEV + git worktrees

In a DDEV project (`.ddev/config.yaml` present), create worktrees with `ddev worktree <branch>`,
not plain `git worktree add` or a generic worktree tool. It sets the project name
in `.ddev/config.local.yaml` (gitignored), starts the project, and copies the DB.
Never use `ddev config --project-name` for this; it changes committed configuration.
Worktree creation and DB copying must be within the authorized task. Cleanup destroys the
worktree's database: confirm the exact disposable project and uncommitted state before
`ddev delete -O <name> && git worktree remove <dir>`.
