# Game Design Task Queue

**Queue rule:** this is a file-backed handoff, not permission to start every listed card. The root agent starts only the card the user selects or explicitly continues, and every task follows [WORKFLOW.md](WORKFLOW.md).

## Current design baseline

- **Approved:** Khế Ước Tàn Vương, its main-story ending, campaign expansion rules, item narrative rules and local-map event safety rules.
- **Proposed:** every concrete NPC name, map layout, enemy, combat stat, exact item, UI screen and economy number not explicitly approved in the story documents.
- **History/archive:** completed Task Cards and their outputs record how this baseline was made. They are not a priority order, a source of canon, or a request to restart completed work.

## Completed baseline — 2026-10-29

| Historical Task Card | Output now used as baseline | Status |
|---|---|---|
| [TASK-20261029-02](tasks/TASK-20261029-02.md) | [Cảng Hắc Thuế map brief](../maps/black-tax-port.md) | completed baseline |
| [TASK-20261029-03](tasks/TASK-20261029-03.md) | [inventory/loadout specification](../systems/inventory-and-loadout.md) | completed baseline |
| [TASK-20261029-04](tasks/TASK-20261029-04.md) | [vertical slice](../vertical-slice.md) | completed baseline |
| [TASK-20261029-05](tasks/TASK-20261029-05.md) | [cast and factions](../story/CHARACTERS_AND_FACTIONS.md) | completed baseline |
| [TASK-20261029-06](tasks/TASK-20261029-06.md) | [Act I item cards](../items/black-tax-port-items.md) | completed baseline |
| [TASK-20261029-07](tasks/TASK-20261029-07.md) | [art direction](../art-direction.md) | completed baseline |

The historical dependency below explains the order already completed; it does **not** schedule the map, inventory, vertical slice, cast, item or art work again.

```text
Map 01 brief ---------> Vertical slice
       |                     |
       v                     v
Inventory/loadout spec -> Act 01 item set

Cast/faction bible -> later map stories and update chapters
Art direction -------> prototype/UI/assets after vertical slice scope is stable
```

## Current closure sequence

| Order | Card / record | Handoff status | Root action boundary |
|---:|---|---|---|
| 1 | [TASK-20261105-50](tasks/TASK-20261105-50.md) and [corpus closure audit](CORPUS-CLOSURE-AUDIT.md) | Completed closure audit; it isolated CCA-01/CCA-02 with no design-source finding. | Do not reopen completed baseline work. |
| 2 | [TASK-20261105-51](tasks/TASK-20261105-51.md) | Completed repair: C0-only P1/P2 route-evidence mapping. | Only the two allowed playtest-protocol files changed. |
| 3 | [TASK-20261105-52](tasks/TASK-20261105-52.md) | Completed repair: queue correctly separates history/baseline from active closure. | No historical card or design source changed. |
| 4 | [TASK-20261105-53](tasks/TASK-20261105-53.md) | Completed recheck: CCA-01/CCA-02 `repaired`; corpus closure audit is `PASS`. | No build/playtest/implementation completion is claimed. |

## Current handoff rule

The current corpus closure sequence is complete. A task selected later must be based on a new reviewed finding or an explicit user request; the completed baseline table and closure sequence are reference material, not a backlog.
