# Codex Global Rules

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

## Delegation

* Work in the main agent by default. Keep small changes, simple questions, short lookups, and tightly coupled work local.
* Unless the user explicitly requests delegation, use subagents only for substantial, clearly bounded, independent tasks when the expected time, cost, or quality benefit clearly outweighs extra tokens, duplicated context, and coordination. When unsure, stay local.
* Do not spawn an agent merely because a task is long, multiple files are involved, or parallel work is possible. Before spawning, briefly state the concrete benefit.
* Keep requirements, architecture, difficult debugging, task decomposition, and integration decisions in the main agent.
* Use `explorer` for substantial read-only investigation that can proceed independently; use `worker` for implementation whose scope and intended behavior are already clear.
* Use the fewest agents needed. Give each explicit scope, only relevant context, expected output, and targeted validation requirements. Subagents should finish their own assignments without further delegation unless explicitly requested by the parent.
* Avoid agents modifying the same files or tightly coupled code. Continue useful independent work in the main agent when possible.
* Review delegated results and perform final integration and validation in the main agent; reuse credible checks rather than repeating them without cause.

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
