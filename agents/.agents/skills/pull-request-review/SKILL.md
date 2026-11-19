---
name: pull-request-review
description: >-
  Review an existing pull request of the current repository, given its number
  or GitHub URL. Use when the user asks to review a PR, passes a PR link or
  number for review, wants review comments or replies posted on a PR, or
  hands over review feedback received on a PR to evaluate and address.
---

# Pull Request Review

Review the given pull request thoroughly and report findings. Reviewing does not authorize posting, approving, merging, or editing code.

## Workflow

1. Resolve the PR from the number or URL with `gh pr view <pr> --json number,title,body,url,author,isDraft,baseRefName,headRefName,headRefOid`. The PR must belong to the current repository; if the URL points elsewhere, say so and stop.
2. Read the repository instructions and the PR description. Note the intent the PR claims and the language the description is written in.
3. Read the diff with `gh pr diff <pr>` and enough surrounding code to judge callers, ownership, and conventions. Check out the PR (`gh pr checkout <pr>`) only when the current branch is the repository's default branch (`main`/`master`) and `git status --porcelain` is empty; switch back to that branch when the review is done. Otherwise leave the working tree alone: fetch the head (`git fetch origin pull/<pr>/head`) and read files with `git show <headRefOid>:<path>`.
4. Read existing reviews, comments, and CI state (`gh pr view <pr> --json reviews,comments`, `gh pr checks <pr>`). Do not repeat points that were already raised or resolved.
5. Review the change:
   - Correctness and regressions: does it do what the description claims, including edge cases and every caller it affects?
   - Security and data safety: untrusted input, permissions, destructive or irreversible operations, migrations.
   - Tests: is the risky behavior covered, and would the tests fail if the change were broken?
   - Project rules: conventions and constraints from the repository instructions.
   - Structure: apply the criteria of [mkr-code-quality-review](../mkr-code-quality-review/SKILL.md).
6. Report to the user in the conversation's language: a verdict (approve, comment, or request changes) and a small set of findings ordered by severity, each with file/line, the concrete failure mode or cost, and a suggested fix. Separate problems introduced by the PR from pre-existing debt. State what was not verified; do not invent test evidence.

## Received Feedback

When asked to address review feedback, treat each point as a claim, not a task:

1. Verify it against the code and reproduce it where possible. Call out points that are wrong, inflated, or style preference, and say why.
2. Classify each valid point as introduced by the PR or pre-existing.
3. For each valid point introduced by the PR, say why earlier work or review missed it.
4. Fix only valid points within the PR's scope. Name pre-existing issues instead of silently fixing them.
5. Re-verify each fix against the reproduction.

## Posting

Post only when the user asks for it. Prefer one review with inline comments over scattered single comments. Submit it as a plain comment review; approve or request changes only when the user explicitly says so. Verify the target PR before any write.

## Comment Language

Everything posted on the PR (review body, inline comments, replies) uses the language of the PR's description, no matter how many comments follow. Do not switch to the language of the conversation, of other commenters, or of earlier comments. Code, identifiers, and quoted output stay unchanged.
