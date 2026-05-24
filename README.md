# Fullstack Crew

> 全栈开发专家团 — 8 Agent · 10 Skills · 一键导入

A full-stack software development team with 10 specialized skills covering backend, frontend, QA, code review, research, DevOps, and design. An Agent Company package for Fusion, based on the companies.sh standard.

## What's Inside

| | Count |
|---|---|
| Agents | 8 |
| Skills | 10 |

### Agents

| Agent | Role | Reports To |
|---|---|---|
| Team Lead | triage | — |
| Backend Engineer | engineer | Team Lead |
| Frontend Engineer | engineer | Team Lead |
| QA Engineer | reviewer | Team Lead |
| Code Review Engineer | reviewer | Team Lead |
| Research Engineer | engineer | Team Lead |
| DevOps Engineer | engineer | Team Lead |
| UX Designer | engineer | Team Lead |

### Skills

| Skill | Description |
|---|---|
| gitnexus-cli | CLI tools for GitNexus codebase analysis |
| gitnexus-debugging | Debugging and error tracing |
| gitnexus-exploring | Code exploration and architecture understanding |
| gitnexus-guide | GitNexus tool reference and workflow guide |
| gitnexus-impact-analysis | Safety analysis before code changes |
| gitnexus-pr-review | Pull request review and risk assessment |
| gitnexus-refactoring | Safe code restructuring and refactoring |
| playwright-cli | Browser automation and E2E testing with Playwright |
| devils-advocate | Critical reasoning — challenge ideas and decisions |
| spec-miner | Reverse-engineer specs from existing codebases |

## Getting Started

### 1. Import Agents

```bash
git clone https://github.com/kenlin8827/fullstack-crew
cd fullstack-crew

fn agent import .              # Fusion
npx paperclipai company import . # Paperclip
```

### 2. Optimize (Fusion only, recommended)

```bash
bash fusion-tune.sh             # Linux/Mac
.\fusion-tune.ps1               # Windows
```

> ⚠️ Without tuning, agents use default heartbeat (1h) and may auto-claim tasks. Tuning enables economy mode, differentiated agent roles, and quality gates.

After import, 8 agents appear in Dashboard. Create a task and assign to Team Lead for intelligent routing, or assign directly to any expert.

## Team Structure

```
Team Lead (triage)
├── Backend Engineer        API / Database / Services
├── Frontend Engineer       React / Vue / Components
├── QA Engineer             Testing / Quality Gates
├── Code Review Engineer    Code Review / Security
├── Research Engineer       Tech Selection / ADR
├── DevOps Engineer         CI/CD / Docker / K8s
├── UX Designer          Interaction / Accessibility
```

## Quality Gates

After importing agents, enable Fusion Workflow Steps in Dashboard → Settings → Workflow Steps:
- **QA Check** — Lint, tests, typecheck verification
- **Security Audit** — OWASP Top 10, dependency scanning

Or run setup script with dashboard running for automatic configuration.

## License

MIT
