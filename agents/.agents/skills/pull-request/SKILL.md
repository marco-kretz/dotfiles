---
name: pull-request
description: >-
  Use this skill whenever the user asks to create a pull request (PR), merge
  request, or when preparing changes for code review. This includes generating
  PR descriptions, summarizing code changes for review, or formatting
  contributions to be submitted to a repository.

  Also use when: drafting PR summaries, writing change descriptions for GitHub
  or GitLab, explaining what a branch changes, or preparing a patch for review.
---

# Pull Request Format

When creating a pull request or describing code changes for review, always
structure the description using the following three sections.

## 1. Summary

Provide a concise overview of the most important changes introduced by this
pull request. Focus on the "what" — the key modifications, additions, or
removals — so a reviewer can grasp the scope at a glance.

- Keep it to 2–4 bullet points or a short paragraph.
- Highlight only the changes that affect behavior, public APIs, or
  architecture.
- Omit trivial formatting or refactoring unless it is the primary purpose of
  the PR.

## 2. Problem

Describe the original problem or motivation that necessitated these changes.
Explain why the current state was insufficient, incorrect, or sub-optimal.

- State the issue clearly (bug, missing feature, performance bottleneck,
  technical debt, etc.).
- Include context such as error messages, user reports, or observed
  behavior.
- If a ticket or issue exists, reference it here (e.g., "Closes #123").

## 3. Solution

Propose the approach taken to tackle the problem outlined above. Explain the
"how" and "why" of the fix or implementation.

- Describe the chosen strategy and any trade-offs considered.
- Mention alternative approaches that were evaluated and why this one was
  selected.
- If applicable, note any follow-up work, known limitations, or areas that
  need extra scrutiny during review.

---

## Usage Notes

- Maintain a professional, neutral tone throughout.
- Use present tense (e.g., "Fixes race condition" rather than "Fixed race
  condition").
- Keep the total description scannable; reviewers should understand the PR
  within 30 seconds.
- If the PR is a work in progress, mark it as draft and add a **WIP**
  notice at the top.
