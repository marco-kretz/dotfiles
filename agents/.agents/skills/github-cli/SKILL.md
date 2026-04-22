---
name: github-cli
description: Use the GitHub CLI (`gh`) for GitHub interactions such as reading issues, pull requests, workflows, releases, and creating or updating PRs, comments, and related metadata.
---

# GitHub CLI via gh

Use this skill when interacting with GitHub from the terminal is the most direct and reliable option.

## Purpose

This skill tells the agent to use `gh` for GitHub-related work such as:
- reading issues
- reading and reviewing pull requests
- creating pull requests
- commenting on issues or PRs
- checking workflow runs
- viewing releases
- inspecting repository metadata
- browsing GitHub objects tied to the current repository

Prefer `gh` over hand-written GitHub API requests when the needed operation is supported cleanly by the CLI.

## When to use

Use this skill when the task involves GitHub state, for example:
- "show me issue 123"
- "list open PRs"
- "create a PR"
- "comment on this issue"
- "check why CI failed"
- "show recent workflow runs"
- "open the PR in browser"
- "list releases"
- "see what branch this PR targets"

## When not to use

Do not use this skill when:
- the task is purely local git work with no GitHub interaction needed
- a repo-specific tool already provides a better source of truth
- the user only wants source code inspection and no GitHub metadata
- the task would perform destructive or high-impact remote actions without explicit user intent

## Core rules

- Prefer `gh` for GitHub operations instead of manual API calls.
- Prefer read-only commands first unless the user clearly asked to create, edit, merge, close, or delete something.
- Use the current git remote and repo context when available.
- If repo context is unclear, determine it before acting.
- Do not guess issue numbers, PR numbers, repo names, or branch names.
- For write operations, make sure the intended target is clearly identified before executing.
- Summarize what was read or changed after using `gh`.

## Preconditions

Before using `gh`:
1. Check that `gh` is installed.
2. Check authentication status if the task requires API access.
3. Confirm the current repository context when relevant.

Useful checks:
```bash
gh --version
gh auth status
git remote -v
gh repo view
