---
name: github-cli
description: Use the GitHub CLI (`gh`) for GitHub interactions such as reading issues, pull requests, workflows, releases, and creating or updating PRs, comments, and related metadata.
---

# GitHub CLI via gh

Use this skill for GitHub operations where `gh` is the clearest interface.

## When to use

Use for GitHub state and metadata, such as:
- viewing issues or PRs
- creating PRs
- commenting on issues or PRs
- checking workflow runs or CI failures
- viewing releases
- inspecting repository metadata

## When not to use

Do not use this skill when:
- the task is purely local git work with no GitHub interaction needed
- a repo-specific tool already provides a better source of truth
- the user only wants source code inspection and no GitHub metadata
- the task would perform destructive or high-impact remote actions without explicit user intent

## Rules

- Prefer `gh` for GitHub operations instead of manual API calls.
- Prefer read-only commands first unless the user clearly asked to create, edit, merge, close, or delete something.
- Establish the correct repo before acting; use the current repo when appropriate, a provided URL when available, or `--repo owner/name` when targeting another repository.
- Do not guess issue numbers, PR numbers, repo names, or branch names.
- For remote write actions such as commenting, editing, merging, closing, reopening, deleting, or rerunning workflows, verify the exact target before executing unless the user was already explicit.
- Prefer `--json` and `--jq` for reliable summaries or filtering.
- Use `gh api` only when the standard `gh` subcommand does not expose the needed operation cleanly.
- Summarize what was read or changed after using `gh`.

## Workflow

Before using `gh`, ensure it is installed, authenticated if needed, and pointed at the correct repository.

Useful checks:
```bash
gh --version
gh auth status
git remote -v
gh repo view
```

## Common examples

```bash
gh issue view 123
gh pr view 123 --json title,author,baseRefName,headRefName,url
gh pr checks 123
gh run list
gh pr create
```
