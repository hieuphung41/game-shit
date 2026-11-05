# External workflow references

This project uses the ideas below as references. It does not install their runtimes by default. External code, daemons, remote databases and global configuration changes require a separate Task Card and explicit approval.

| Project | Verified role | Adopted locally | Not adopted / reason |
|---|---|---|---|
| [obra/superpowers](https://github.com/obra/superpowers) | composable skills; brainstorm -> worktree/plan -> micro-task -> review -> finish | mandatory phases and review gate | no global plugin install for a lore-only workspace |
| [VisionForge-OU/foreman](https://github.com/VisionForge-OU/foreman) | gated plan/ADR/issues/build pipeline, budgets, file-backed recovery | task cards, gates, bounded retries and human handoff | targets a Claude headless orchestrator; do not run a second supervisor inside Codex |
| [mvschwarz/openrig](https://github.com/mvschwarz/openrig) | persistent role/seat ownership across agents | explicit role cards and disjoint file ownership | daemon/tmux/Node setup changes global Codex/agent files; not needed for small tasks |
| [EfficientStreet/hindsight](https://github.com/EfficientStreet/hindsight) | end-of-session durable process retrospective | optional manual retrospective checklist | no automatic memory writes; user must explicitly request memory updates |
| [opendatalab/MinerU](https://github.com/opendatalab/MinerU) | PDF/Office to LLM-ready Markdown/JSON | reserved as an opt-in document-extraction task | unnecessary for current Markdown lore files |
| [hydra-db/open-glean](https://github.com/hydra-db/open-glean) | scoped knowledge retrieval and cited deep research | source-scoped research rule | requires external Hydra DB/service; not needed for the local story bible |
| [MxCorpIn/Repolyze](https://github.com/MxCorpIn/Repolyze) | repository health/architecture analysis | structured verifier checklist | current workspace is a design-doc folder, not a software repo to analyse |
| [zhihz/openjev](https://github.com/zhihz/openjev) | bounded candidate scoring | use only as a mental model for decision tables | research preview is not a general narrative authority |

## Official Codex guidance used

[Build skills - OpenAI Developers](https://developers.openai.com/codex/skills/) states that a skill is a directory containing `SKILL.md` plus optional scripts/references, and that repository-scoped skills can live under `.agents/skills/`. The two local skills in this project follow that shape.

## Installation rule

Do not run `npx`, install a daemon, modify `~/.codex/config.toml`, add a remote database, or download a model merely because a project name appeared in a brainstorm. First create a Task Card with: exact dependency, license, paths/services changed, rollback, and why a repo-local Markdown/skill rule is insufficient.
