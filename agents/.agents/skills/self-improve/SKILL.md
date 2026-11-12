---
name: self-improve
description: Turn a correction, misunderstanding, or unexpected process in the current session into a durable improvement of agent instructions, or prune instructions that caused friction.
argument-hint: "What went wrong, or `review [global|project]` to prune existing instructions"
disable-model-invocation: true
---

Improve the instructions agents work from, based on evidence from this session. The goal is fewer, better rules, not more rules. Removing or loosening a rule is as valid an outcome as adding one.

# Modes

- **Learn** (default): analyze what went wrong in this session and propose a change.
- **Review** (`review`, optionally scoped to `global` or `project`): audit existing instructions for bloat, overly specific or conflicting rules, and propose cuts. No session incident needed.

# Learn

1. **Reconstruct.** From the conversation, state briefly: what the user expected, what the agent did, and the point where they diverged. Quote the user's correction if there is one. If the cause is unclear, ask one question instead of guessing.
2. **Find the cause.** Pick the closest:
   - Missing context (project fact, convention, environment detail).
   - Ambiguous or conflicting instruction.
   - **An existing rule was too strict, too specific, or wrong** and pushed the agent the wrong way.
   - The agent assumed instead of checking or asking, despite adequate instructions.
   - Missing or flawed workflow/skill.
   - Something that should be enforced deterministically, not by text.
   - Nothing durable: a one-off misunderstanding. Say so and stop; give the user a prompting tip if useful.
3. **Read the current instructions** that apply before proposing anything: the global instruction file, the project's instruction files, and relevant skills. Resolve symlinks and edit the source file (for example in the user's dotfiles), not the link.
4. **Choose the action**, in this order of preference:
   1. **Remove** a rule that caused or contributed to the problem.
   2. **Loosen or reword** an existing rule so it covers the case.
   3. **Merge** into an existing rule or skill step.
   4. **Add** a new rule, only when nothing above fits.
5. **Choose the target** by scope:

   | Learning | Target |
   |---|---|
   | Applies to all projects | Global instruction file of the current harness (source in dotfiles) |
   | Global workflow | Existing shared skill; new skill only for a distinct repeatable workflow |
   | Project fact or convention for everyone | Project instruction file in the repo (`AGENTS.md` / `CLAUDE.md`, whichever the project uses) |
   | Project knowledge only for this user | Local, gitignored instruction file (e.g. `CLAUDE.local.md`) |
   | Project workflow | Project skill in the repo |
   | "Always do X when Y" that must not be forgotten | Hook or harness setting, not prose |
   | How the user could phrase requests better | Chat output only, do not store |

   Do not put rules into an agent's automatic per-machine memory; it is not portable or shared.
6. **Propose** a diff per file, each with one line of rationale, plus any prompting tip for the user. Write rules as concrete behavior with a short *why*, at the most general level that still prevents the error. Do not encode the specific incident ("in file X, do Y") unless it is a real project fact.
7. **Apply only after explicit approval.** Do not commit or push.

# Review

1. Read the in-scope instruction files and skills fully.
2. Flag each rule that is:
   - **Redundant**: duplicated elsewhere, or default agent behavior anyway.
   - **Overly specific**: written for one past incident, unlikely to recur.
   - **Conflicting**: contradicts another rule or a project convention.
   - **Blocking**: forces extra steps, questions, or refusals the user does not want.
   - **Stale**: references files, tools, flags, or workflows that no longer exist (verify).
   - **Misplaced**: global rule in a project file or vice versa; prose that should be a hook.
3. Propose cuts, merges, and moves as diffs, ranked by expected benefit. Prefer deletion. Report the net line change per file.
4. Apply only after explicit approval. Do not commit or push.

# Rules

- Every proposed change cites evidence: the session incident, or the specific rule text in review mode.
- One concern per rule. If a rule needs an exception, consider whether the rule should exist at all.
- Keep instruction files short. Each rule costs context in every session; a long file dilutes the rules that matter.
- Never store secrets, credentials, or personal data.
