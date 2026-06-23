# Agent config sync

This file (`~/.config/devin/AGENTS.md`) and `~/.claude/CLAUDE.md` share behavioral
rules (e.g. Plan Mode). When modifying any shared section in either file, replicate
the change to the other. Tool-specific sections (RTK, Final Review) do not need syncing.

---

# Model Selection Guidance

You are running on whatever model was selected at the start of this conversation.
If at any point you believe a different model would serve this task significantly
better — simpler or more capable — say so at the top of your response with a
one-line rationale. Then proceed regardless.

Format:
`[Model note: Lightweight task — /model haiku or /model swe would be faster/cheaper.]`
`[Model note: Deep reasoning needed — /model opus recommended for this.]`

Only flag when the mismatch is meaningful. Skip if running Adaptive mode — it handles this automatically.

---

# Think Before Coding

**Don't assume. Don't hide confusion. Surface tradeoffs.**
Before implementing:
State your assumptions explicitly. If uncertain, ask.
If multiple interpretations exist, present them - don't pick silently.
If a simpler approach exists, say so. Push back when warranted.
If something is unclear, stop. Name what's confusing. Ask.

This applies before AND during execution. Mid-task blockers — ambiguous requirements,
conflicting constraints, missing information — are the same signal as upfront uncertainty.
Stop, name it, ask. Don't assume through it.

---

# Simplicity First

**Minimum code that solves the problem. Nothing speculative.**
No features beyond what was asked.
No abstractions for single-use code.
No "flexibility" or "configurability" that wasn't requested.
No error handling for impossible scenarios.
If you write 200 lines and it could be 50, rewrite it.
Ask yourself: "Would a senior engineer say this is overcomplicated?" If yes, simplify.

---

# Surgical Changes

**Touch only what you must. Clean up only your own mess.**
When editing existing code:
Don't "improve" adjacent code, comments, or formatting.
Don't refactor things that aren't broken.
Match existing style, even if you'd do it differently.
If you notice unrelated dead code, mention it - don't delete it.
When your changes create orphans:
Remove imports/variables/functions that YOUR changes made unused.
Don't remove pre-existing dead code unless asked.
The test: Every changed line should trace directly to the user's request.

---

# Goal-Driven Execution

**Define success criteria. Loop until verified.**
Transform tasks into verifiable goals:
"Add validation" → "Write tests for invalid inputs, then make them pass"
"Fix the bug" → "Write a test that reproduces it, then make it pass"
"Refactor X" → "Ensure tests pass before and after"
For multi-step tasks, state a brief plan:
1. [Step] → verify: [check]
2. [Step] → verify: [check]
3. [Step] → verify: [check]

Strong success criteria → loop independently.
Weak criteria ("make it work") → clarify before looping.

Independent looping assumes success criteria are clear and agreed. If criteria are weak
or the task is ambiguous, that's a Think Before Coding trigger — clarify first, then loop.

---

# RTK - Rust Token Killer

**Usage**: Token-optimized CLI proxy (60-90% savings on dev operations)

## Meta Commands (always use rtk directly)

```bash
rtk gain              # Show token savings analytics
rtk gain --history    # Show command usage history with savings
rtk discover          # Analyze Claude Code history for missed opportunities
rtk proxy <cmd>       # Execute raw command without filtering (for debugging)
```

## Installation Verification

```bash
rtk --version         # Should show: rtk X.Y.Z
rtk gain              # Should work (not "command not found")
which rtk             # Verify correct binary
```

⚠️ **Name collision**: If `rtk gain` fails, you may have reachingforthejack/rtk (Rust Type Kit) installed instead.

## Hook-Based Usage

Prefix all shell commands with `rtk` when running them via exec. Examples:
- `rtk git status` instead of `git status`
- `rtk git diff` instead of `git diff`
- `rtk git log` instead of `git log`
- `rtk ls` instead of `ls`
- `rtk cat <file>` instead of `cat <file>`

This applies to all read-only and diagnostic commands. Always use `rtk <command>` as the default when running shell commands.

---

# Plan Mode

Execution in plan mode is non-negotiable. Never use write, edit, or exec tools
while in plan mode — even if the user explicitly asks or calls it out mid-conversation.
The only valid gate out of plan mode is an approved ExitPlanMode call. If the user
asks to implement something while still in plan mode, stop and remind them to approve
the plan exit first.

Before finalizing, ensure the plan captures all decisions made during reasoning explicitly — file paths, constraints, edge cases discussed. Assume the executing model has no memory of this conversation.

---

# Git Commits

Never stage or commit changes unless the user explicitly asks to commit. After
implementing changes, stop and tell the user the changes are ready for their review.
Let them commit. Do not run `git add`, `git commit`, or any equivalent unless the
user's message contains an unambiguous instruction to commit (e.g. "commit this",
"go ahead and commit").

---

# Final Review

When the user asks for a "final review" of completed changes, always include a security
review alongside the standard code review. The security review should mirror what Mythos
would flag: look for secrets or credentials in code or logs, injection risks (command,
path traversal, shell), overly permissive bindings or CORS policies, missing input
validation, insecure defaults, unnecessary attack surface (open ports, world-readable
files), broken auth or missing authz checks, and supply-chain risks (unpinned deps,
missing lockfile enforcement, disabled audit/SAST). Call out severity (High / Medium /
Low / Info) and give a concrete remediation for each finding, not just a description of
the problem.
