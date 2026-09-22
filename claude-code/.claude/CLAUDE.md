# Claude Code instructions

## Working style

- Be concise and explicit. Inspect first, then form a short plan for non-trivial work.
- Complete authorized work end to end; ask when missing information materially affects correctness, scope, or risk.
- Prefer minimal diffs and the simplest correct fix. Reuse existing code, native features, and installed dependencies before adding mechanisms.
- Preserve project conventions. Avoid unnecessary dependencies, renames, abstractions, and formatting churn.
- Do not claim verification you did not perform. Flag risky or destructive operations before acting.
- If an approach fails twice, stop repeating it. Check the docs or alternatives, then choose the simplest in-scope solution.
- When third-party behavior gets in the way, prefer its documented configuration, opt-out, hook, or extension point over a compensation layer.
- Use Conventional Commits. Do not commit, push, publish, or deploy without user authorization.
- Treat skills as workflow guidance, not permission to expand scope or perform remote writes. Respect review-only requests.

## Code and validation

- Comments only where the WHY is non-obvious. Keep documentation required by project conventions or public APIs.
- No speculative handling of impossible internal states; validate untrusted input and external boundaries.
- PHP and TypeScript: strict typing and modern features supported by the project's version. JavaScript: ES6+ unless the project requires otherwise.
- Use the project's existing test approach. Add focused regression coverage when it meaningfully verifies behavior; do not introduce a separate framework for a small change.
- Run the smallest relevant checks, then required project checks. Repeat or broaden checks for new changes, failures, or concrete unresolved risks; report anything not run.

## Harness boundaries

- Shared skills contain the workflow, not harness-specific agent names, model IDs, or tool APIs. Use the current harness's configured review/delegation policy.
- Delegate only when independent review, bounded research, isolation, or context reduction materially helps. Keep small tasks local.
- One writer per checkout; reviewers inspect and report without editing. Give children explicit scope, applicable shared/project rules, and approval boundaries.
- Never assume another harness's agents, tools, MCP servers, or permissions are available. Do not switch harnesses as a fallback without approval.

## DDEV + git worktrees

In a DDEV project (`.ddev/config.yaml` present), create worktrees with `ddev worktree <branch>`,
not plain `git worktree add` or a harness's generic worktree tool. It sets the project name
in `.ddev/config.local.yaml` (gitignored), starts the project, and copies the DB.
Never use `ddev config --project-name` for this; it changes committed configuration.
Worktree creation and DB copying must be within the authorized task. Cleanup destroys the
worktree's database: confirm the exact disposable project and uncommitted state before
`ddev delete -O <name> && git worktree remove <dir>`.

## Delegation and review

- Use Claude Code's native subagents, not Pi or Codex agent names and tool APIs.
- Delegate large-file reads and multi-file searches to Explore when only a bounded conclusion is needed; use targeted reads for small questions.
- For the shared `pull-request` skill, use `code-quality-reviewer` for a fresh, read-only review before creating a PR. Supply the actual base/head, diff scope, project rules, and validation evidence.
- Keep implementation and publication decisions in the parent. Reviewers report findings; they do not edit or run test suites.
- If the configured reviewer is unavailable or fails to launch, report the blocker rather than silently substituting another harness or an in-session review.
- For DDEV projects, do not use EnterWorktree; follow the DDEV worktree rules above.

## Browser testing

- Use `playwright-cli` (headless) from Bash; do not use browser MCP tools.
- Prefer `find <text>`, `eval`, and scoped `snapshot <ref>` over full-page snapshots.
- Screenshot only when layout matters; save to `$TMPDIR` and Read the file.
- One session per task (`-s <name>`), `close` when done.
