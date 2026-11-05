# Game-shit workflow

This project uses a bounded, file-backed agent workflow. The normative rules are in the root [AGENTS.md](../../AGENTS.md), with the reusable task loop at [game-task-loop](../../.agents/skills/game-task-loop/SKILL.md) and the narrative review gate at [game-lore-review](../../.agents/skills/game-lore-review/SKILL.md).

## Standard flow

```text
Task Card
   -> read-only research
   -> one owned draft
   -> independent review
   -> acceptance verification
   -> DONE report and stop
```

## Default team sizes

| Task | Team | Stop condition |
|---|---|---|
| Small lore edit | Root + writer + reviewer | criteria pass; one file changed |
| New map story | Root + explorer + writer + lore/gameplay reviewers | map brief and side-event checklist pass |
| Main-story change | Root + two explorers + writer + continuity reviewer | all cross-doc contradictions resolved |
| New update/event | Root + writer + gameplay reviewer + verifier | local state, recovery and expansion checks pass |

Use fewer agents for smaller cards. More agents are not progress by themselves.

## Task Card template

```markdown
# TASK-YYYYMMDD-NN

Outcome:
Owner/files:
Acceptance:
- [ ]
- [ ]
Out of scope:
Stop when:
Report format: use the Required report in `AGENTS.md`.
```

## Report template

```markdown
Task: TASK-YYYYMMDD-NN — <outcome>
Status: DONE | BLOCKED | NEEDS_DECISION
Changed:
Evidence:
Decisions:
Open questions:
Next task (not started):
```

## External reference policy

The workflow borrows ideas from Superpowers (mandatory phases), Foreman (gates/budgets/file-backed recovery), OpenRig (roles/ownership), Hindsight (durable retrospective filter), MinerU (document extraction), Open Glean (scoped retrieval), Repolyze (structured repository analysis) and OpenJEV (bounded candidate scoring). It does not require installing their runtimes. Add an external dependency only when a Task Card names the need, license/source is verified, and the user understands what global files/services it changes.
