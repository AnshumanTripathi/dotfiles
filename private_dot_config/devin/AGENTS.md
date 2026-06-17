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
