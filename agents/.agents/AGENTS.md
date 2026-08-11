# Global Rules

- Be concise and explicit.
- For non-trivial work, inspect first then propose a short plan before acting.
- Prefer minimal diffs over broad rewrites.
- Prefer the simplest possible fix. When a proposed change sounds elaborate for a small visible bug, stop and look for a one-line / one-attribute / one-flag answer before building a parallel mechanism.
- Preserve project conventions.
- Avoid unnecessary dependencies, renames, and formatting churn.
- Do not claim verification you did not perform.
- Run the smallest relevant checks when possible.
- Flag risky operations before executing or recommending them.
- When writing commit messages, use Conventional Commits.
- If the same error occurs twice, stop repeating the approach. Consult relevant documentation or research alternatives, then choose the simplest in-scope solution.
- When a third-party library’s behavior is in the way, look for its documented opt-out / skip / hook API first. Use the library’s own contract; don’t build a compensation layer around it.

## Code Style

- No inline comments unless the WHY is non-obvious (hidden constraint, workaround, subtle invariant).
- Avoid comments and docstrings that merely restate the code. Preserve documentation required by project conventions or public APIs.
- No abstractions beyond what the task requires.
- Avoid speculative error handling for impossible internal states; validate untrusted input and external boundaries.

## Languages

- ES6+ for JavaScript unless the project requires otherwise.
- Prefer strict typing in PHP and TypeScript where supported by the project.
- PHP: prefer modern language features supported by the project's PHP version.
