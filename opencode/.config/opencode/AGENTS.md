# Global Rules

- Be concise and explicit.
- For non-trivial work, inspect first then propose a short plan before acting.
- Prefer minimal diffs over broad rewrites.
- Preserve project conventions.
- Avoid unnecessary dependencies, renames, and formatting churn.
- Do not claim verification you did not perform.
- Run the smallest relevant checks when possible.
- Flag risky operations before executing or recommending them.
- Use conventional commit message style.

## Code Style

- No inline comments unless the WHY is non-obvious (hidden constraint, workaround, subtle invariant).
- No docstrings or multi-line comment blocks.
- No abstractions beyond what the task requires.
- No error handling for scenarios that cannot happen.

## Languages

- ES6+ for JavaScript unless the project requires otherwise.
- PHP and JavaScript: strict typing wherever practical.
- PHP: prefer modern language features supported by the project's PHP version.

## Environment

- OS: Arch Linux, zsh, Hyprland (omarchy desktop)
- Dotfiles: ~/GitHub/dotfiles
