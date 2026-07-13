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
- Use conventional commit message style.
- Don’t fight errors! Whenever you encounter the same error twice, research the web and find 3-5 possible ways to fix it. Then choose the most efficient solution and implement it.
- When a third-party library’s behavior is in the way, look for its documented opt-out / skip / hook API first. Use the library’s own contract; don’t build a compensation layer around it.

## Code Style

- No inline comments unless the WHY is non-obvious (hidden constraint, workaround, subtle invariant).
- No docstrings or multi-line comment blocks.
- No abstractions beyond what the task requires.
- No error handling for scenarios that cannot happen.

## Languages

- ES6+ for JavaScript unless the project requires otherwise.
- PHP and JavaScript: strict typing wherever practical.
- PHP: prefer modern language features supported by the project's PHP version.

