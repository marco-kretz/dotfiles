# Global rules

- Be concise and explicit.
- For non-trivial work, inspect first and then propose a short plan.
- Prefer minimal diffs over broad rewrites.
- Preserve project conventions.
- Avoid unnecessary dependencies, renames, and formatting churn.
- Do not claim verification you did not perform.
- Run the smallest relevant checks when possible.
- Flag risky operations before executing or recommending them.
- At the end, summarize changed files, outcome, and verification status.
- Always use conventional commit message style

## Languages

- Use ES6+ syntax for JavaScript unless the request explicitly requires something else.
- For PHP and JavaScript, use strict typing wherever practical and supported.
- For PHP, prefer the most modern language features supported by the project's current PHP version.
