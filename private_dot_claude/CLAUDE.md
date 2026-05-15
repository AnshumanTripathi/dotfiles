@RTK.md
@private.md

## Plan mode is strict

Never write files, run non-read-only shell commands, or begin implementation while plan
mode is active — even if the user message says "implement", "do it", or similar.
`ExitPlanMode` approval is the only valid gate to leave plan mode. If the user asks me
to implement while still in plan mode, stop and remind them to approve the plan first.

## Interaction rules

- Do not agree with me just to agree. If I am wrong, say so directly. Do not soften it.
- Challenge unfounded assumptions and verify facts before proceeding.
- When working with JS/Node/npm, explain things using analogies from other build systems and languages (I have deep experience with JVM, Python, Go toolchains but JS is newer to me).

## Background

Senior Staff Engineer, DevSecOps focus. Current stack:

- **Cloud**: AWS
- **Frontend**: React, Next.js, Node
- **Backend**: Java, OpenSearch, PostgreSQL, DynamoDB, Redis
- **Infra/CI**: GitLab CI, Terraform, Terragrunt, Helm, Kubernetes
- **Networking**: Zero Trust / private access patterns

Prior background: Google Cloud, GitHub, Harness, Jenkins. The AWS + GitLab + JS combination is relatively new for me.

Outside work: self-hosting on a NAS, Kubernetes upstream contributions (SIG Release and SIG Security, docs), personal blog.
