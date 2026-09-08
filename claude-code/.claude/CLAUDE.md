# Global Rules

- For non-trivial work, inspect first, then propose a short plan before acting.
- Prefer minimal diffs and the simplest fix. Look for a one-line / one-flag answer before building a parallel mechanism.
- Preserve project conventions. Avoid unnecessary dependencies, renames, and formatting churn.
- Run the smallest relevant check before reporting done.
- If the same error occurs twice, stop repeating the approach. Check the docs or alternatives, then pick the simplest in-scope fix.
- When a third-party library's behavior is in the way, use its documented opt-out / skip / hook API. Don't build a compensation layer around it.
- Commit messages: Conventional Commits.
- Delegate reads of files over ~400 lines and multi-file searches to an Explore subagent when only the conclusion is needed; use Read offset/limit for targeted reads.

## Code Style

- Comments only where the WHY is non-obvious (hidden constraint, workaround, subtle invariant). Keep docs required by project conventions or public APIs.
- No abstractions beyond what the task requires.
- No speculative error handling for impossible internal states; validate untrusted input and external boundaries.
- PHP and TypeScript: strict typing and modern language features as supported by the project's version.

## DDEV + git worktrees

In a DDEV project (`.ddev/config.yaml` present): create worktrees with `ddev worktree <branch>`,
never with plain `git worktree add` and not with the EnterWorktree tool. It sets the project name
in `.ddev/config.local.yaml` (gitignored; never use `ddev config --project-name`, that changes the
committed config.yaml), starts the project and copies the DB.
Cleanup: `ddev delete -O <name> && git worktree remove <dir>`.
