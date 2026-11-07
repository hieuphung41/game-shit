# Chữ in-game Contract 1 — Giữ giấy phép

**Trạng thái:** spec chuỗi `proposed` cho ui-programmer/gameplay-engineer. Nguồn chữ duy nhất là
[`game/i18n/strings.csv`](../../game/i18n/strings.csv). Mọi giới hạn ký tự, nhãn trạng thái và câu không trích
nguyên văn từ tài liệu nguồn đều `proposed`. Tài liệu này không đổi luật/flow của
[vertical slice](../vertical-slice.md) hay [wireflow](../vertical-slice-wireflow.md).

## 1. Quy ước

| Quy ước | Giá trị |
|---|---|
| File | `game/i18n/strings.csv`, UTF-8 (không BOM), header `keys,vi`; chỉ cột tiếng Việt. Godot import thành `strings.vi.translation` (gitignored). |
| Key | `SCREEN_CONTEXT_PURPOSE` viết hoa, ổn định: đổi chữ thì giữ key; đổi nghĩa thì thêm key mới. |
| Gọi trong code | `tr("KEY")`; chuỗi có placeholder dùng `tr("KEY").format({"seconds": 20})`. Placeholder: `{seconds}`, `{used}`, `{total}`; S03 thêm `{hp}`, `{max_hp}`, `{quantity}`, `{free}`, `{w}`, `{h}`, `{item}` (TASK-84); S04 thêm `{value_total}`, `{value_per_cell}` (TASK-98). |
| Danh sách động | Tên item trong `Đã giữ` / `Đã mất` lấy từ tên item, không ghép câu trong code. |
| Đếm ký tự | Ký tự Unicode NFC, tính cả khoảng trắng và dấu câu; placeholder tính theo giá trị đã điền. |
| Đăng ký locale | CSV đã import được, nhưng chưa thêm vào `internationalization/locale/translations` của `project.godot` (ngoài phạm vi card này). |

### Giới hạn ký tự đề xuất `proposed`

| Loại | Tối đa | Dùng cho |
|---|---:|---|
| Tiêu đề màn/overlay | 32 | `*_TITLE` |
| Nút, nhãn, tag | 24 | `*_BUTTON_*`, `CARD_ACTION_*`, `LOADOUT_LABEL_*`, `BEACON_*_LABEL`, `INVENTORY_SEAL_LABEL_*`, `SUMMARY_GROUP_*`, `*_CONFIRM_*_ACCEPT`, `UI_LOADING`, `INVENTORY_PICKUP_SOURCE_*`, `INVENTORY_REASON_*` (trừ hai key khóa ở dòng 72) |
| Tên item | 24 | `ITEM_*_NAME` |
| Lựa chọn route | 32 | `PROMPT_ROUTE_*`, `SUMMARY_NEXT_CONTRACT2_*` |
| Objective HUD | 48 | `HUD_OBJECTIVE_*` (một dòng trên HUD ngang 1280×720) |
| Dòng card item | 64 | `CARD_MANIFEST_R17_*` |
| Dòng summary, trạng thái, prompt, gợi ý | 72 | `SUMMARY_*` (trừ nhóm/nút), `EXTRACT_S*`, `EXTRACT_CONFIRM_CLOSED_*`, `BEACON_*_REASON`, `PROMPT_SAFEBOX_*`, `RECOVERY_BODY_*`, `UI_ERROR_*`, `*_HINT*`, `INVENTORY_REASON_CROSS_GRID_LOCKED`, `INVENTORY_REASON_WITHDRAW_LOCKED` |
| Briefing / thoại / thân O5 | 80–110 | xem cột giới hạn từng key; mọi `*_CONFIRM_*_BODY` tối đa 90 |
| Nhãn nút combat (S03) | 10 | `HUD_BUTTON_ATTACK`, `HUD_BUTTON_DODGE`, `HUD_BUTTON_GUARD`, `HUD_BUTTON_REMEDY` (nút 112 px; `HUD_BUTTON_INVENTORY` vẫn 24) |
| Số/hậu tố ngắn (S03) | 6–12 | `CARD_QUANTITY_SUFFIX` 6, `INVENTORY_FOOTPRINT_CHIP` 8, `HUD_HEALTH_VALUE` 12 |
| Tag ngắn (S03) | 16 | `HUD_HEALTH_LOW`, `CARD_TAG_*`, `CARD_FIT_*` |
| Dòng HUD cảnh báo (S03) | 24 | `HUD_ALERT_*`, `HUD_DANGER_*`, `ENEMY_*_NAME`, `WORLD_INTERACT_*` |
| Dòng card loot B (S03) | 24 / 32 / 64 | `CARD_<ID>_NAME`, `_FOOTPRINT` 24 · `_CLAIM`, `_RARITY` 32 · `_USE`, `_LORE` 64 (`<ID>` ≠ `MANIFEST_R17`) |
| Toast/prompt S03 | 72 | `PROMPT_COMBAT_*`, `PROMPT_LOOT_*`, `COMBAT_*` (trừ nút), `CACHE_CLOSED_*`, `CARD_PLACED_CONFIRM_*`, `INVENTORY_PREVIEW_*` |
| S04 (TASK-98) | theo [UX khu D](zone-d-ux-spec.md) §9.1 | `CARD_VALUE_*` 24 · `INVENTORY_CONFIRM_TARGET_*` 32 · `RECALL_SIGIL_MOMENT_LINE` 48 · `INVENTORY_CONFIRM_DROP_EVIDENCE_S*_NOTE` 72; còn lại theo nhóm ở trên |

## 2. Key → màn hình / state

### S1 — Briefing & loadout

| Key | Màn hình / state | Tối đa | Nguồn / ghi chú |
|---|---|---:|---|
| `BRIEFING_HEADER_TITLE` | S1 tiêu đề | 32 | Nguyên văn [§2.1](../vertical-slice.md). |
| `BRIEFING_OBJECTIVE_MAIN` | S1 dòng mục tiêu | 80 | Nguyên văn §2.1. |
| `BRIEFING_RULES_LINE` | S1 dòng độ khó/extract/luật mất đồ | 90 | Nguyên văn §2.1. |
| `BRIEFING_MENTOR_SPEAKER` | S1 tên người nói | 24 | Tên vai trong MAIN_STORY. |
| `BRIEFING_MENTOR_LINE` | S1 thoại một câu | 110 | Nguyên văn §2.1. |
| `BRIEFING_TOOLTIP_UNSEALED_LOSS` | S1 tooltip một lần về niêm phong | 72 | Beat 0. `proposed` câu chữ. |
| `BRIEFING_BUTTON_ENTER` | S1 nút bắt đầu run | 24 | `Vào cảng` theo Beat 0; chỉ sáng khi loadout hợp lệ. |
| `BRIEFING_BUTTON_ENTER_BLOCKED` | S1 lý do nút tắt | 72 | `proposed`. |
| `LOADOUT_LABEL_BACKPACK` | S1/O3 nhãn lưới | 24 | Glossary. |
| `LOADOUT_LABEL_SLING_POUCH` | S1 nhãn slot | 24 | Glossary. |
| `LOADOUT_LABEL_NOTARY_BOX` | S1/O4 nhãn Hộp | 24 | Glossary. |
| `LOADOUT_SUMMARY_DEFAULT_KIT` | S1 tóm tắt kit chấp nhận | 110 | Wireflow §4 (kit mặc định). |
| `BRIEFING_BUTTON_EDIT_LOADOUT` | S1 nút mở O1 | 24 | TASK-71 `proposed`; [UX vòng A](loop-a-ux-flow-spec.md) §5.1. |
| `BRIEFING_BUTTON_BACK` | S1 nút về Boot | 24 | TASK-71 `proposed`; UX §5.1. |
| `UI_LOADING` | S1, S10 nhãn đang chuyển màn | 24 | TASK-71 `proposed`; UX §5.1, §5.9. |
| `UI_ERROR_SCENE_LOAD` | S1, S10 tải màn lỗi, nút bật lại | 72 | TASK-71 `proposed`; UX §5.1. |
| `LOADOUT_TITLE` | O1 tiêu đề | 32 | TASK-71 `proposed`; UX §5.2. |
| `LOADOUT_HINT_SELECT` | O1 và O3/O4 `view`, chưa chọn món | 72 | TASK-71 `proposed`; UX §4.2. |
| `LOADOUT_BUTTON_DONE` | O1 `Xong` → S1, giữ thay đổi | 24 | TASK-71 `proposed`; UX §5.2. |
| `LOADOUT_BUTTON_CANCEL` | O1 `Hủy` → S1, khôi phục snapshot | 24 | TASK-71 `proposed`; UX §5.2. |
| `ITEM_STARTER_REMEDY_NAME` | O1, O3/O4, S10 — tên `starter_remedy` | 24 | TASK-71 `proposed`; **tên mới chờ duyệt** (§3). Câu `LOADOUT_SUMMARY_DEFAULT_KIT` giữ chữ "vật hồi phục" (mô tả loại, vẫn đúng). |

### S2–S5 — Objective HUD, bàn dispatch, card Manifest

| Key | Màn hình / state | Tối đa | Nguồn / ghi chú |
|---|---|---:|---|
| `HUD_OBJECTIVE_TAKE_MANIFEST` | HUD, S2 trước khi nhặt | 48 | Nguyên văn Beat 0. |
| `HUD_OBJECTIVE_CROSS_TAX_POST` | HUD, S4 trong combat B | 48 | Nguyên văn Beat 3. |
| `HUD_OBJECTIVE_DELIVER_PIER_A` | HUD, S3/S4/S5 sau Manifest | 48 | Nguyên văn Beat 6. |
| `HUD_OBJECTIVE_HOLD_PIER_A` | HUD, S8 | 48 | `proposed`. |
| `HUD_OBJECTIVE_BOARD_BOAT` | HUD, S9 | 48 | `proposed`. |
| `HUD_OBJECTIVE_RECOVER_MANIFEST` | HUD, S2 sau S12 (Manifest `unrecovered`) | 48 | `proposed`. |
| `WORLD_INTERACT_DISPATCH_DESK` | Nhãn tương tác bàn dispatch A | 24 | `proposed`. |
| `CARD_MANIFEST_R17_NAME` | O2 dòng 1 — tên | 64 | Glossary. |
| `CARD_MANIFEST_R17_FOOTPRINT` | O2 dòng 2 — footprint | 64 | [Item 01](../items/black-tax-port-items.md). |
| `CARD_MANIFEST_R17_USE` | O2 dòng 3 — công dụng | 64 | Nguyên văn Beat 2. |
| `CARD_MANIFEST_R17_CLAIM` | O2 dòng 4 — claim | 64 | Item 01; chỉ ghi phe trong glossary. |
| `CARD_MANIFEST_R17_RARITY` | O2 dòng 5 — lớp thẩm định | 64 | Item 01 (Xanh lá); cần cue ngoài màu (G7). |
| `CARD_MANIFEST_R17_LORE` | O2 dòng 6 — một dòng lore | 64 | Nguyên văn Item 01. |
| `CARD_MANIFEST_R17_STATE_NOT_EXTRACTED` | O2/O3/O4 tag evidence | 24 | Wireflow §3 nhãn `chưa extract`. |
| `CARD_ACTION_PICK_AND_PLACE` | O2 nút | 24 | Nguyên văn wireflow §5. |
| `CARD_ACTION_SKIP` | O2 nút (loot ngoài Manifest) | 24 | Beat 4 `Bỏ qua`. |
| `CARD_ACTION_CLOSE` | O2/O3/O4 đóng | 24 | `proposed`. |
| `INVENTORY_SEAL_LABEL_SEALED` | O4 nhãn item thường đã niêm | 24 | [Inventory spec](inventory-grid-slice-spec.md) `sealed`. |
| `INVENTORY_SEAL_LABEL_SEALED_NOT_EXTRACTED` | O4 nhãn Manifest đã niêm | 24 | Inventory spec `sealed_not_extracted`; G10. |
| `PROMPT_SAFEBOX_SEAL_HINT` | Prompt S2→S3 khi xếp Manifest | 72 | Nguyên văn Beat 2. |
| `PROMPT_ROUTE_EXTRACT_NOW` | S3 lựa chọn không chặn | 32 | Nguyên văn Beat 2. |
| `PROMPT_ROUTE_GO_MARKET` | S3 lựa chọn không chặn | 32 | Nguyên văn Beat 2. |
| `HUD_BUTTON_INVENTORY` | HUD H3, mở O3/O4 `view` | 24 | TASK-71 `proposed`; UX §5.3. |
| `INVENTORY_PANEL_TITLE` | O3/O4 `view` tiêu đề | 32 | TASK-71 `proposed`; cùng chữ với nút H3. |
| `INVENTORY_PICKUP_HINT` | O3/O4 `pickup` hướng dẫn | 72 | TASK-71 `proposed`; nói đặt vào Hộp là niêm (UX §4.4), không nói là hoàn thành. |
| `INVENTORY_PICKUP_SOURCE_DESK` | O3/O4 `pickup` tag thẻ "đang cầm" | 24 | TASK-71 `proposed`; Manifest chưa rời bàn. |
| `INVENTORY_REASON_OK` … `INVENTORY_REASON_SORT_NO_FIT` | O1, O3/O4 dòng lý do; một key mỗi giá trị `InventoryReason` (12 key) | 24 | TASK-71; chữ giống hệt cột "Nhãn UI" của [inventory spec](inventory-grid-slice-spec.md) §7 và `InventoryReason.label_vi`, viết thường vì ghép sau tên món. |
| `INVENTORY_REASON_CROSS_GRID_LOCKED` | O1, chạm ô ở ngăn khác | 72 | TASK-71 `proposed`; UX §4.3. |
| `INVENTORY_REASON_WITHDRAW_LOCKED` | O3/O4 trong run, Hộp → ba lô ở S02 | 72 | TASK-71 `proposed`; chữ "chưa" vì S04 mới mở. |

Thứ tự hiển thị card: `NAME → FOOTPRINT → USE → CLAIM → RARITY → LORE`, theo wireflow §3 và G7; tag
`STATE_NOT_EXTRACTED` là badge, không chen giữa các dòng.

### E0/E1, O5, S7–S9 — Beacon và extract Cầu tàu A

| Key | Màn hình / state | Tối đa | Nguồn / ghi chú |
|---|---|---:|---|
| `BEACON_E0_STATE_LABEL` | Beacon A, E0 `unavailable` | 24 | `proposed`. |
| `BEACON_E0_STATE_REASON` | Beacon A, E0 lý do | 72 | `proposed`; nêu điều kiện, không giấu luật. |
| `BEACON_E1_STATE_LABEL` | Beacon A, E1 `callable` | 24 | `proposed`. |
| `BEACON_E1_OUT_OF_ZONE_REASON` | W2, E1 ngoài `BeaconZoneA` (BCN-09) | 72 | TASK-71 `proposed`; [beacon spec](beacon-extract-state-spec.md) §10.6. |
| `EXTRACT_E1_BUTTON_CALL` | E1 nút | 24 | Nguyên văn Beat 7. |
| `EXTRACT_CONFIRM_TITLE` | O5 tiêu đề | 32 | `proposed`. |
| `EXTRACT_CONFIRM_BODY` | O5 hậu quả, `{seconds}` = thời gian giữ đã công bố (15–25) | 90 | `proposed`. |
| `EXTRACT_CONFIRM_ACCEPT` | O5 xác nhận → S7 | 24 | `proposed`. |
| `EXTRACT_CONFIRM_CANCEL` | O5 hủy → E1 | 24 | `proposed`. |
| `EXTRACT_CONFIRM_CLOSED_LEFT_ZONE` | R4 toast, O5 đóng vì rời vòng (BCN-13) | 72 | TASK-71 `proposed`; UX §5.7. |
| `EXTRACT_S7_CALL_ACCEPTED` | S7 trạng thái | 72 | `proposed`. |
| `EXTRACT_S8_HOLD_TIMER` | S8 HUD, `{seconds}` còn lại | 72 | `proposed`. |
| `EXTRACT_S8_HOLD_PAUSED` | R2, S8 `hold_pause_reason == out_of_zone` (BCN-18) | 72 | TASK-71 `proposed`; đồng hồ dừng, không reset. |
| `EXTRACT_S8_LANE_ALERT` | S8 cảnh báo lane B (đi cùng đèn/âm thanh) | 72 | `proposed`. |
| `EXTRACT_S9_BOAT_READY` | S9 trạng thái | 72 | `proposed`. |
| `EXTRACT_S9_BUTTON_BOARD` | S9 nút lên thuyền | 24 | `proposed`. |

### S10 — Success summary (G15)

| Key | Màn hình / state | Tối đa | Nguồn / ghi chú |
|---|---|---:|---|
| `SUMMARY_SUCCESS_TITLE` | S10 tiêu đề | 32 | `proposed`. |
| `SUMMARY_GROUP_KEPT` | S10/S11 nhóm `Đã giữ` | 24 | G15. |
| `SUMMARY_GROUP_LOST` | S10/S11 nhóm `Đã mất`; S10 ẩn nếu rỗng | 24 | G15. |
| `SUMMARY_GROUP_EVIDENCE` | S10/S11 nhóm `Vật chứng` | 24 | G15. |
| `SUMMARY_GROUP_NEXT` | S10 nhóm `Tiếp theo` | 24 | G15. |
| `SUMMARY_SUCCESS_KEPT_LICENCE` | S10 `Đã giữ` dòng đầu | 72 | `proposed`. |
| `SUMMARY_SUCCESS_KEPT_CELLS` | S10 `Đã giữ`, `{used}/{total}` ô ba lô | 72 | §4.2 (so theo footprint, không chấm điểm). |
| `SUMMARY_SUCCESS_LOST_LEFT_BEHIND` | S10 `Đã mất`, chú thích dưới tên item | 72 | `proposed`; không gọi là phạt. |
| `SUMMARY_SUCCESS_EVIDENCE_MANIFEST` | S10 `Vật chứng` | 72 | Wireflow S10; không phải Bộ Phản Niêm. |
| `SUMMARY_SUCCESS_EVIDENCE_LIMIT` | S10 `Vật chứng` dòng phụ | 72 | §6.2 Narrative. |
| `SUMMARY_SUCCESS_EVIDENCE_LEAD` | S10 `Vật chứng` / hub lead | 72 | §4.1 “Mã R-17 chỉ về Kho K-7”. |
| `SUMMARY_SUCCESS_MENTOR_LINE` | S10/hub phản ứng một câu | 110 | `proposed`; né chuyện cũ, không exposition. |
| `SUMMARY_NEXT_CONTRACT2_TITLE` | S10 `Tiếp theo` card | 32 | `proposed`; không có nút bắt đầu. |
| `SUMMARY_NEXT_CONTRACT2_TAG` | S10 tag card Contract 2 | 32 | Nguyên văn §4.1. |
| `SUMMARY_BUTTON_HUB` | S10 nút → S0 | 24 | Nguyên văn wireflow S10. |

### S11 / S12 — Death summary và Recovery Contract

| Key | Màn hình / state | Tối đa | Nguồn / ghi chú |
|---|---|---:|---|
| `SUMMARY_DEATH_TITLE` | S11 tiêu đề | 32 | `proposed`; không dùng chữ của success. |
| `SUMMARY_DEATH_KEPT_SEALED` | S11 `Đã giữ` | 72 | Wireflow S11. |
| `SUMMARY_DEATH_LOST_UNSEALED` | S11 `Đã mất` | 72 | Wireflow S11. |
| `SUMMARY_DEATH_EVIDENCE_AT_DESK` | S11 `Vật chứng`, chết trước Manifest | 72 | Wireflow S11. |
| `SUMMARY_DEATH_EVIDENCE_UNRECOVERED` | S11 `Vật chứng`, chết sau Manifest (kể cả S8/S9) | 72 | Wireflow S11 `Vật chứng — unrecovered`. |
| `SUMMARY_DEATH_NOT_EXTRACTED` | S11 dòng nhắc chưa hoàn thành | 72 | §5.1 tách `không mất vĩnh viễn` / `chưa extract`. |
| `SUMMARY_DEATH_BUTTON_PREPARE` | S11 trước Manifest → S1 | 24 | Nguyên văn wireflow S11. |
| `SUMMARY_DEATH_BUTTON_RECOVERY` | S11 sau Manifest → S12 | 24 | Nguyên văn wireflow S11. |
| `RECOVERY_HEADER_TITLE` | S12 tiêu đề | 32 | Tên trong vertical slice §4.3. |
| `RECOVERY_BODY_LOCATION` | S12 vị trí Manifest | 72 | Wireflow S12. |
| `RECOVERY_BODY_RULE` | S12 điều kiện hoàn thành | 90 | Wireflow S12; E1 chưa là success. |
| `RECOVERY_BODY_KIT` | S12 kit cơ bản | 72 | Wireflow S12. |
| `RECOVERY_BUTTON_BRIEFING` | S12 nút → S1 recovery | 24 | `proposed`. |

### S04 — Manifest dưới đất và O5 cho bỏ / rút / đổi gear (G11) `proposed`

Viết sẵn để trả các `KEY_MỚI?` của [beacon spec](beacon-extract-state-spec.md) §7.1, §10.6. **Không dùng ở S02**: S02
không có affordance bỏ item, rút đồ niêm hay đổi gear ([UX vòng A](loop-a-ux-flow-spec.md) §5.7). Tên key do TASK-71
đặt vì beacon spec chưa đặt; luật/flow của ba O5 này vẫn do card S04 chốt.

| Key | Màn hình / state | Tối đa | Nguồn / ghi chú |
|---|---|---:|---|
| `HUD_OBJECTIVE_PICK_UP_MANIFEST` | HUD, `DROPPED` (BCN-26) | 48 | Beacon spec §10.6; Manifest không tự về bàn. |
| `INVENTORY_CONFIRM_DROP_TITLE` | O5 bỏ item, tiêu đề | 32 | Beacon spec §7.1. |
| `INVENTORY_CONFIRM_DROP_BODY` | O5 bỏ item thường, hậu quả | 90 | "Item về đất, có thể mất khỏi run". |
| `INVENTORY_CONFIRM_DROP_EVIDENCE_BODY` | O5 bỏ Manifest, hậu quả thay câu trên | 90 | BCN-26: E0 tới khi nhặt lại. |
| `INVENTORY_CONFIRM_DROP_ACCEPT` | O5 bỏ item, nút xác nhận | 24 | — |
| `INVENTORY_CONFIRM_WITHDRAW_TITLE` | O5 rút khỏi Hộp, tiêu đề | 32 | Beacon spec §7.1. |
| `INVENTORY_CONFIRM_WITHDRAW_BODY` | O5 rút item thường khỏi Hộp, hậu quả | 90 | "Item mất bảo vệ khi chết". Không dùng cho Manifest: vật chứng đã niêm vẫn `chưa thu hồi` khi chết (INV-27), nên câu "sẽ mất" sai với nó. |
| `INVENTORY_CONFIRM_WITHDRAW_ACCEPT` | O5 rút, nút xác nhận | 24 | — |
| `LOADOUT_CONFIRM_GEAR_TITLE` | O5 đổi gear ở O1 | 32 | Beacon spec §7.1. |
| `LOADOUT_CONFIRM_GEAR_BODY` | O5 đổi gear, hậu quả | 90 | "Đổi tổ hợp đồ mang vào run". |
| `LOADOUT_CONFIRM_GEAR_ACCEPT` | O5 đổi gear, nút xác nhận | 24 | — |
| `LOADOUT_CONFIRM_NO_WEAPON_TITLE` | O5 vào run không vũ khí | 32 | Beacon spec §7.1; nút xác nhận dùng lại `BRIEFING_BUTTON_ENTER`. |
| `LOADOUT_CONFIRM_NO_WEAPON_BODY` | O5 vào run không vũ khí, hậu quả | 90 | — |
| `CONFIRM_BUTTON_CANCEL` | Nút `Hủy` chung của các O5 S04 | 24 | Không dùng lại `EXTRACT_CONFIRM_CANCEL` để key extract chỉ mang một nghĩa. |

### S03 — Khu B: HUD combat, cảnh báo, card loot cache B, lưới, stub HP 0 `proposed`

Trả mọi key ở [UX khu B](zone-b-ux-spec.md) §8. Ui-programmer (TASK-89) và gameplay-engineer (TASK-90) chỉ gọi `tr(key)`.
Cột **Dài** là số ký tự đếm theo §1 (placeholder đã điền bằng giá trị dài nhất trong slice, ghi ở ghi chú). Mọi câu là
`proposed`, trừ câu ghi "nguyên văn".

**HUD combat, máu, thuốc** ([UX khu B](zone-b-ux-spec.md) §5.1, [combat](combat-slice-spec.md) §3–§4)

| Key | Màn hình / state | Tối đa | Dài | Nguồn / ghi chú |
|---|---|---:|---:|---|
| `HUD_BUTTON_ATTACK` | C1 | 10 | 4 | `Đánh`. |
| `HUD_BUTTON_DODGE` | C2 | 10 | 2 | `Né`. |
| `HUD_BUTTON_GUARD` | C3 | 10 | 9 | `Giữ khiên`: chữ nói luôn đây là thao tác giữ (UX khu B §2.3). |
| `HUD_BUTTON_REMEDY` | C4 (+ badge số) | 10 | 10 | `Dùng thuốc`; không ghi tên gói để vừa 10. |
| `HUD_HEALTH_VALUE` | H2 số | 12 | 7 | `{hp}/{max_hp}`, đo với `100/100`. |
| `HUD_HEALTH_LOW` | H2 tag khi máu ≤ 30% | 16 | 8 | Đi cùng icon nứt (cue ngoài màu). |
| `COMBAT_REMEDY_REFUSED_NO_REMEDY` | R4' toast, `no_remedy` | 72 | 26 | Gọi đúng tên ngăn `túi đeo chéo`. |
| `COMBAT_REMEDY_REFUSED_HP_FULL` | R4' toast, `hp_full` | 72 | 34 | Không tiêu thuốc. |
| `COMBAT_REMEDY_INTERRUPTED` | R4' toast, kênh bị ngắt | 72 | 44 | Nói rõ thuốc **chưa mất** (combat §3.5.3). |

**Objective B** — dùng lại key S02, không thêm key: `HUD_OBJECTIVE_CROSS_TAX_POST` (`Qua trạm thuế.`, nguyên văn Beat 3)
khi encounter B đang diễn ra; `HUD_OBJECTIVE_DELIVER_PIER_A` (`Đưa Manifest ra Cầu tàu A.`, nguyên văn Beat 6) sau đó.
Thứ tự theo UX khu B §5.1.1.

**Cảnh báo, prompt vai địch, nguy hiểm khi overlay mở** (UX khu B §5.2, §5.6)

| Key | Màn hình / state | Tối đa | Dài | Nguồn / ghi chú |
|---|---|---:|---:|---|
| `HUD_ALERT_LANE_B` | H5, `lane_alert_started` → `boat_ready` | 24 | 20 | Câu báo địch lane B lúc hold; cùng mũi tên H5. `EXTRACT_S8_LANE_ALERT` (S02) vẫn là toast R4' một lần. |
| `HUD_ALERT_PATROL_B` | H5, `patrol_cue_started` | 24 | 21 | Patrol là `tax_guard` nên gọi `Vệ binh`; `lối A` = `SeamAB` (layout B). |
| `HUD_DANGER_NEAR` | D1 dòng 1 | 24 | 13 | — |
| `HUD_DANGER_WINDUP` | D1 dòng 1 khi `windup_started` | 24 | 16 | — |
| `HUD_DANGER_CLOSE_HINT` | D1 dòng 2 | 24 | 21 | D1 là nút: chạm = đóng như hủy. |
| `PROMPT_COMBAT_TAX_GUARD_FIRST_SEEN` | R4', `role_first_seen(tax_guard)` | 72 | 67 | Quạt sàn = `guard_hold_ring` khi windup; khiên không chặn ở hông/sau, và ở `strike`/`recover` (combat §5.2). |
| `PROMPT_COMBAT_FOREMAN_FIRST_SEEN` | R4', `role_first_seen(foreman)` | 72 | 68 | Vạch sàn = `charge_lane_stripe`; foreman không charge người ngoài lane (combat §5.3). |
| `ENEMY_TAX_GUARD_NAME` | Không hiện ở S03 (không nhãn trên đầu địch); để dùng thống nhất | 24 | 23 | Tên vai trong combat §1. Glossary: §3. |
| `ENEMY_FOREMAN_NAME` | như trên | 24 | 8 | Tên vai trong combat §1 và vertical slice Beat 3. Glossary: §3. |

**Cache B: tương tác, card O2B, toast** (UX khu B §5.4, [loot B](zone-b-loot-spec.md) §7)

| Key | Màn hình / state | Tối đa | Dài | Nguồn / ghi chú |
|---|---|---:|---:|---|
| `WORLD_INTERACT_CACHE_B` | R5' trong 1.5 m quanh `CacheB` | 24 | 17 | Cache là rương tịch thu của trạm (loot B §3.1). |
| `PROMPT_LOOT_COLOR_NOT_VALUE` | R4', lần đầu mở card | 72 | 60 | Nguyên văn Beat 4. |
| `CACHE_CLOSED_LEFT_RANGE` | R4' toast, ra ngoài tầm | 72 | 63 | Nói món chưa nhặt vẫn còn (loot B §6.2). |
| `CARD_PLACED_CONFIRM_BACKPACK` | R4' toast sau `commit_pickup` vào ba lô | 72 | 36 | `{item}` = tên item; đo với `Manifest Hàng Hóa R-17` (22). |
| `CARD_PLACED_CONFIRM_NOTARY_BOX` | R4' toast sau niêm vào Hộp | 72 | 53 | Như trên; nói "đã niêm". |
| `CARD_QUANTITY_SUFFIX` | chip, dòng 1, ô lưới | 6 | 2 | `×{quantity}`, đo với `×3` (`stack_max` 3). |
| `CARD_TAG_ROTATABLE` | card dòng 2a | 16 | 9 | — |
| `CARD_TAG_STACKABLE` | card dòng 2a | 16 | 14 | — |
| `CARD_TAG_SEALABLE` | card dòng 2a | 16 | 9 | — |
| `CARD_BACKPACK_FREE` | card dòng 2b | 24 | 17 | `Ba lô trống {free}/{total}`, đo với `12/12`. |
| `CARD_FIT_BACKPACK_FITS` | card dòng 2b, `fits` | 16 | 9 | Đi cùng icon ô + tích. |
| `CARD_FIT_BACKPACK_ROTATED_ONLY` | card dòng 2b, `fits_rotated_only` | 16 | 12 | — |
| `CARD_FIT_BACKPACK_NO_FIT` | card dòng 2b, `no_fit` | 16 | 15 | — |
| `CARD_FIT_NOTARY_BOX_FITS` | card dòng 2b, Hộp `fits` | 16 | 7 | — |
| `CARD_FIT_NOTARY_BOX_NO_FIT` | card dòng 2b, Hộp `no_fit` | 16 | 16 | Sổ Kho khi Manifest đã niêm. |
| `CARD_FIT_NOTARY_BOX_NOT_SEALABLE` | card dòng 2b, `not_sealable` | 16 | 15 | Không món cache B nào dùng; để sẵn. |

**Hai món cache B** — thứ tự `NAME → FOOTPRINT → USE → CLAIM → RARITY → LORE` như card Manifest. Tên giữ nguyên
catalogue; lore là **một dòng nguyên văn** từ [item catalogue](../items/black-tax-port-items.md). `USE` nói giá trị
tương quan, không số tiền, không nói lớp cao hơn là đáng giá hơn (loot B §7.3).

| Key | Màn hình / state | Tối đa | Dài | Nguồn / ghi chú |
|---|---|---:|---:|---|
| `ITEM_SCRAPED_TAX_COIN_NAME` | ô lưới, dải S, toast, S10 | 24 | 17 | `Đồng Thuế Cạo Mặt`, items #14. |
| `CARD_SCRAPED_TAX_COIN_NAME` | O2B dòng 1 | 24 | 17 | Cùng chữ. |
| `CARD_SCRAPED_TAX_COIN_FOOTPRINT` | O2B dòng 2a | 24 | 9 | `1x1 · 1 ô`; xếp chồng nằm ở tag. |
| `CARD_SCRAPED_TAX_COIN_USE` | O2B dòng 3 | 64 | 28 | "Valuable gọn" (#14) + đáng giữ theo ô. |
| `CARD_SCRAPED_TAX_COIN_CLAIM` | O2B dòng 4 | 32 | 19 | Phe theo glossary. |
| `CARD_SCRAPED_TAX_COIN_RARITY` | O2B dòng 5 | 32 | 28 | Xanh lá, bậc 2/6 bằng chữ. |
| `CARD_SCRAPED_TAX_COIN_LORE` | O2B dòng 6 | 64 | 62 | Nguyên văn #14. |
| `ITEM_WATERLOGGED_STOCK_LEDGER_NAME` | ô lưới, dải S, toast, S10 | 24 | 16 | `Sổ Kho Ngấm Nước`, items #16. |
| `CARD_WATERLOGGED_STOCK_LEDGER_NAME` | O2B dòng 1 | 24 | 16 | Cùng chữ. |
| `CARD_WATERLOGGED_STOCK_LEDGER_FOOTPRINT` | O2B dòng 2a | 24 | 9 | `1x2 · 2 ô`; xoay nằm ở tag. |
| `CARD_WATERLOGGED_STOCK_LEDGER_USE` | O2B dòng 3 | 64 | 48 | "Tài sản đăng ký gọn vừa … không main evidence" (#16). |
| `CARD_WATERLOGGED_STOCK_LEDGER_CLAIM` | O2B dòng 4 | 32 | 19 | Claim chính là Hắc Thuế (loot B §4). |
| `CARD_WATERLOGGED_STOCK_LEDGER_RARITY` | O2B dòng 5 | 32 | 31 | Xanh dương, bậc 3/6 bằng chữ. |
| `CARD_WATERLOGGED_STOCK_LEDGER_LORE` | O2B dòng 6 | 64 | 59 | Nguyên văn #16. |

**Lưới O3B** (UX khu B §4, §5.5)

| Key | Màn hình / state | Tối đa | Dài | Nguồn / ghi chú |
|---|---|---:|---:|---|
| `INVENTORY_PICKUP_SOURCE_CACHE` | dải S tag, `pickup` | 24 | 22 | Món chưa rời rương tới khi commit. |
| `INVENTORY_PICKUP_HINT_ITEM` | dải S dòng 2, `pickup` | 72 | 52 | Bản chung của `INVENTORY_PICKUP_HINT` (S02, riêng Manifest). |
| `INVENTORY_PREVIEW_FITS_BACKPACK` | dải S dòng 2, ngón đè ô hợp lệ ở ba lô | 72 | 32 | — |
| `INVENTORY_PREVIEW_FITS_NOTARY_BOX` | dải S dòng 2, ngón đè ô hợp lệ ở Hộp | 72 | 55 | Báo trước khóa rút (`WITHDRAW_LOCKED`). |
| `INVENTORY_BUTTON_ROTATE` | nút `Xoay` | 24 | 4 | — |
| `INVENTORY_FOOTPRINT_CHIP` | chip footprint | 8 | 3 | `{w}×{h}`, đo với `1×2`. Khác `INVENTORY_SELECTED_ITEM` (S02, `{width}`/`{height}`). |

**Stub HP 0 — O6** (UX khu B §5.7, combat §4.4). Không dùng chữ "chết", Phù Hiệu Hồi Hương hay Recovery: đây không phải
S11/S12 (S04).

| Key | Màn hình / state | Tối đa | Dài | Nguồn / ghi chú |
|---|---|---:|---:|---|
| `COMBAT_STUB_HP_ZERO` | O6 dòng duy nhất | 72 | 69 | Run kết thúc; nói đây là giới hạn của **bản thử** (chưa có cứu hộ và thu hồi), không phải luật thế giới. Không nhắc giữ/mất đồ, kể cả đồ đã niêm: lời hứa của Hộp Công Chứng (`inventory-and-loadout.md`) giữ nguyên. "cứu hộ", "thu hồi" viết thường, chỉ tính năng chưa có; không gọi tên Phù Hiệu Hồi Hương hay Recovery Contract. TASK-92. |
| `COMBAT_STUB_BUTTON_BOOT` | O6 nút, khóa 2.5 s đầu | 24 | 10 | Về Boot. |

### S04 — Kho Nổi D, Hộp trong run, Phù Hiệu Hồi Hương, S11 ba nhóm, S10 full-route (TASK-98) `proposed`

Trả mọi key ở [UX khu D](zone-d-ux-spec.md) §9.1 (luật: [cargo/Hộp/chết](zone-d-cargo-notary-death-spec.md)). Ui-programmer
(TASK-100/101) và gameplay-engineer chỉ gọi `tr(key)`. Cột **Dài** đếm theo §1; placeholder điền giá trị dài nhất trong
slice (ghi ở ghi chú). Mọi câu `proposed`, trừ câu ghi "nguyên văn".

**Hai món D** — thứ tự `NAME → FOOTPRINT → USE → CLAIM → RARITY → LORE` như card cache B. `USE` không gọi lựa chọn nào là
"đúng/tốt hơn", không hứa bán, turn-in hay Local Story (luật S04 §3.3.4). Hai món cùng lớp Trắng nên dòng 5 giống hệt
nhau (chủ ý, UX §4.2.1.5).

| Key | Màn hình / state | Tối đa | Dài | Nguồn / ghi chú |
|---|---|---:|---:|---|
| `ITEM_CARGO_D_2X2_NAME` | ô lưới, dải S, toast, S10, S11 | 24 | 20 | `Vải Cứu Trợ Đổi Nhãn`, nguyên văn items #11. |
| `CARD_CARGO_D_2X2_NAME` | O2D dòng 1 | 24 | 20 | Cùng chữ. |
| `CARD_CARGO_D_2X2_FOOTPRINT` | O2D dòng 2a | 24 | 9 | `2x2 · 4 ô`. |
| `CARD_CARGO_D_2X2_USE` | O2D dòng 3a | 64 | 52 | Cồng kềnh, tổng cao, theo ô thấp, không niêm được. Bỏ ý "về kho khi extract" của luật §3.3.4 vì slice không có kho hub (S04 §14 câu 1); chữ không hứa giữ sang run sau. |
| `CARD_CARGO_D_2X2_CLAIM` | O2D dòng 4 | 32 | 19 | Một `claim_id` (luật §3.2.2); chữ chỉ nói ai đòi quyền, không gọi là lệnh tịch thu. Phía dân bến nằm ở dòng lore. |
| `CARD_CARGO_D_2X2_RARITY` | O2D dòng 5 | 32 | 26 | Trắng, bậc 1/6 bằng chữ. |
| `CARD_CARGO_D_2X2_LORE` | O2D dòng 6 | 64 | 51 | **Nguyên văn** items #11 (“Nhãn mới biến chăn mùa mưa thành tang vật hợp pháp.”): một dòng, chăn của dân bến bị dán nhãn thuế. |
| `ITEM_TAX_STAMP_D_NAME` | như `ITEM_CARGO_D_2X2_NAME` | 24 | 8 | `Dấu Thuế`, tên fixture của D brief (luật §3.2.3). |
| `CARD_TAX_STAMP_D_NAME` | O2D dòng 1 | 24 | 8 | Cùng chữ. |
| `CARD_TAX_STAMP_D_FOOTPRINT` | O2D dòng 2a | 24 | 9 | `1x2 · 2 ô`; xoay/niêm nằm ở tag. |
| `CARD_TAX_STAMP_D_USE` | O2D dòng 3a | 64 | 32 | Gọn, theo ô cao hơn, niêm được. "cao hơn" là so số theo ô, không phải lời khen. |
| `CARD_TAX_STAMP_D_CLAIM` | O2D dòng 4 | 32 | 19 | Hắc Thuế. |
| `CARD_TAX_STAMP_D_RARITY` | O2D dòng 5 | 32 | 26 | Trắng, bậc 1/6. |
| `CARD_TAX_STAMP_D_LORE` | O2D dòng 6 | 64 | 62 | **Không có card catalogue** (luật §3.2.3) nên không có câu nguyên văn để lấy; câu mới `proposed`, chỉ nói dấu nằm ở bàn cân và đóng lên hàng trước khi cân ([layout D](zone-d-layout-encounter-spec.md) §8, `TaxStampD`). Không nối Counterseal, không gọi là bằng chứng. Lore-reviewer duyệt. |

**Dòng giá trị, tương tác, nguồn nhặt** (UX §4.1, §4.2.1, §4.3)

| Key | Màn hình / state | Tối đa | Dài | Nguồn / ghi chú |
|---|---|---:|---:|---|
| `CARD_VALUE_TOTAL` | O2D dòng 3b, ô trái | 24 | 17 | `Tổng ước lượng: {value_total}`, đo với `8`. Không tiền, không "giá bán". |
| `CARD_VALUE_PER_CELL` | O2D dòng 3b, ô phải | 24 | 11 | `Theo ô: {value_per_cell}`, đo với `2,5` (dạng dài nhất UX §4.2.1.4; slice chỉ có `2`/`3`). |
| `WORLD_INTERACT_CARGO_D` | R5' gần `CargoD` | 24 | 12 | — |
| `WORLD_INTERACT_TAX_STAMP_D` | R5' gần `TaxStampD` | 24 | 12 | — |
| `WORLD_INTERACT_GROUND_DROP` | R5' gần `GroundDrop` | 24 | 17 | — |
| `INVENTORY_PICKUP_SOURCE_D` | dải S tag, `pickup` ở D | 24 | 24 | Cùng dạng `INVENTORY_PICKUP_SOURCE_CACHE`. |
| `INVENTORY_PICKUP_SOURCE_GROUND` | dải S tag, `pickup` từ `GroundDrop` | 24 | 23 | — |

**Lưới, Hộp đầy, nút món** (UX §4.3.2–§4.3.5)

| Key | Màn hình / state | Tối đa | Dài | Nguồn / ghi chú |
|---|---|---:|---:|---|
| `INVENTORY_PREVIEW_SEAL_NOTARY_BOX` | dải S dòng 2, đè ô Hộp hợp lệ | 72 | 48 | Thay `INVENTORY_PREVIEW_FITS_NOTARY_BOX` (nghĩa cũ sai từ S04). |
| `INVENTORY_PREVIEW_WITHDRAW_BACKPACK` | dải S dòng 2, đè ô ba lô khi rút | 72 | 45 | Nhấc ngón chỉ mở O5i, chưa rút. |
| `INVENTORY_WITHDRAW_PICK_CELL_HINT` | dải S dòng 2 sau `Rút` | 72 | 40 | "dấu vừa" = dấu ô hợp lệ của lưới. |
| `INVENTORY_HINT_NOTARY_BOX_MAKE_ROOM` | R4' sau khi Hộp từ chối | 72 | 72 | Lý do + việc người chơi tự làm; Hộp không tự đổi chỗ. Lý do ô (`CELLS_OCCUPIED` / `OUT_OF_BOUNDS`) và `CARD_FIT_NOTARY_BOX_NO_FIT` / `_NOT_SEALABLE` dùng key cũ. |
| `INVENTORY_HINT_BACKPACK_MAKE_ROOM` | R4' khi ba lô không có chỗ | 72 | 70 | — |
| `INVENTORY_BUTTON_DROP` | R10g-A | 24 | 2 | `Bỏ`. |
| `INVENTORY_BUTTON_WITHDRAW` | R10g-A | 24 | 3 | `Rút`. |

**O5i bỏ / rút** (UX §4.6, luật §5). Tiêu đề, thân món thường, nút xác nhận và `Hủy` dùng key S04 có sẵn (bảng TASK-71 ở
trên).

| Key | Màn hình / state | Tối đa | Dài | Nguồn / ghi chú |
|---|---|---:|---:|---|
| `INVENTORY_CONFIRM_TARGET_GROUND` | O5i hàng đích, drop | 32 | 23 | — |
| `INVENTORY_CONFIRM_TARGET_BACKPACK` | O5i hàng đích, withdraw | 32 | 21 | "ô có khung" = bóng ô đích trong dock. |
| `INVENTORY_SEAL_LABEL_UNSEALED` | O5i nhãn đổi (món thường) | 24 | 10 | Đi sau `INVENTORY_SEAL_LABEL_SEALED` (`đã niêm`). |
| `INVENTORY_SEAL_LABEL_NOT_EXTRACTED` | O5i nhãn đổi (Manifest) | 24 | 24 | Đi sau `INVENTORY_SEAL_LABEL_SEALED_NOT_EXTRACTED` (`đã niêm — chưa extract`, key cũ, nhãn Hộp R10g-E). Ý "vẫn là vật chứng" rút gọn cho vừa 24. |
| `INVENTORY_CONFIRM_WITHDRAW_EVIDENCE_BODY` | O5i thân, rút Manifest | 90 | 87 | Luật §5.2: không mất hẳn, vẫn gọi được thuyền, chưa extract (= chưa hoàn thành gì). Không dùng chữ "sẽ mất". |
| `INVENTORY_CONFIRM_DROP_EVIDENCE_S8_NOTE` | O5i dòng thêm, bỏ Manifest ở S8 | 72 | 47 | BCN-28. |
| `INVENTORY_CONFIRM_DROP_EVIDENCE_S9_NOTE` | O5i dòng thêm, bỏ Manifest ở S9 | 72 | 47 | BCN-29. |
| `CARD_PLACED_CONFIRM_DROPPED` | R4' sau drop | 72 | 51 | `{item}`, đo với `Manifest Hàng Hóa R-17` (22). |
| `CARD_PLACED_CONFIRM_WITHDRAWN` | R4' sau withdraw | 72 | 52 | Như trên. |

**O7 và S11** (UX §4.7, §4.8; luật §6.3, §7)

| Key | Màn hình / state | Tối đa | Dài | Nguồn / ghi chú |
|---|---|---:|---:|---|
| `RECALL_SIGIL_MOMENT_LINE` | O7 dòng duy nhất | 48 | 30 | Tên đúng glossary; không nhắc giữ/mất. |
| `SUMMARY_DEATH_GROUP_EVIDENCE_UNRECOVERED` | S11 tiêu đề cột `Vật chứng`, chỉ `after_manifest` | 24 | 24 | **Thêm ngoài UX §9.1** để card có tiêu đề `Vật chứng — chưa thu hồi` (wireflow S11). `before_manifest` giữ `SUMMARY_GROUP_EVIDENCE`. Cùng chỗ, cùng badge; ui-programmer chọn key theo biến thể. |
| `SUMMARY_DEATH_LOST_LEFT_BEHIND` | S11 `Đã mất` phân nhóm b | 72 | 31 | — |
| `SUMMARY_DEATH_LOST_EQUIPPED` | S11 `Đã mất` dòng trang bị | 72 | 39 | Canon: gear không niêm mất. |
| `SUMMARY_DEATH_BUTTON_BOOT` | S11 nút `after_manifest` → Boot | 24 | 10 | — |
| `SUMMARY_DEATH_RECOVERY_UNAVAILABLE` | S11 dòng thu hồi, `after_manifest` | 72 | 43 | Chỉ báo bản thử chưa có; không mời bắt đầu Recovery, không hứa hồi đồ hay thời điểm. |

**Key cũ dùng lại ở S04, không đổi chữ** (UX §9.2): S11 `SUMMARY_GROUP_KEPT` (`Đã giữ`), `SUMMARY_GROUP_LOST` (`Đã mất`),
`SUMMARY_GROUP_EVIDENCE`, `SUMMARY_DEATH_TITLE` (`Phù Hiệu Hồi Hương đã kích hoạt`), `_KEPT_SEALED`, `_LOST_UNSEALED`,
`_EVIDENCE_AT_DESK` (Manifest vẫn ở bàn dispatch A, Contract 1 còn hiệu lực), `_EVIDENCE_UNRECOVERED` (`chưa thu hồi`, không
gọi là hoàn thành), `_NOT_EXTRACTED` (giấy phép chưa được giữ), `_BUTTON_PREPARE`. S10 full-route: `SUMMARY_SUCCESS_KEPT_CELLS`
(`Ô ba lô đã dùng: {used}/{total}`), `SUMMARY_SUCCESS_LOST_LEFT_BEHIND`, `INVENTORY_FOOTPRINT_CHIP`; không có key điểm hay giá
trị. Trong 14 key S04 của TASK-71: 9 key dùng (`HUD_OBJECTIVE_PICK_UP_MANIFEST`, `INVENTORY_CONFIRM_DROP_*`,
`INVENTORY_CONFIRM_WITHDRAW_*`, `CONFIRM_BUTTON_CANCEL`); 5 key `LOADOUT_CONFIRM_*` không hiện ở slice (luật §5.6), giữ.

**Key cũ đổi chữ (giữ key, cùng nghĩa)**

| Key | Tối đa | Dài | Lý do |
|---|---:|---:|---|
| `INVENTORY_CONFIRM_DROP_EVIDENCE_BODY` | 90 | 85 | UX §9.2: nói thêm đèn phao A ở trạng thái chưa gọi được thuyền tới khi nhặt lại (E0, BCN-26). Dùng "báo chưa gọi được thuyền" (chữ của `BEACON_E0_STATE_LABEL`) thay "tắt", vì E0 là icon "chưa mở", không phải đèn tắt (UX vòng A W2). |

**Key không còn hiện từ S04** (giữ trong CSV, UX §9.3): `COMBAT_STUB_HP_ZERO`, `COMBAT_STUB_BUTTON_BOOT`,
`INVENTORY_REASON_WITHDRAW_LOCKED`, `INVENTORY_PREVIEW_FITS_NOTARY_BOX`, `SUMMARY_DEATH_BUTTON_RECOVERY` (để cho S05).

### Thay đổi TASK-98

- 43 key mới ở mục S04 trên (append cuối CSV): 42 key của UX §9.1 (6+6 key card hai món tính riêng) và
  `SUMMARY_DEATH_GROUP_EVIDENCE_UNRECOVERED`. 178 key cũ giữ tên; chỉ `INVENTORY_CONFIRM_DROP_EVIDENCE_BODY` đổi chữ.
- §1: thêm placeholder `{value_total}`, `{value_per_cell}` và một dòng giới hạn S04.
- §3: đề xuất glossary cho hai món D.

### Thay đổi TASK-92

- Chỉ sửa giá trị `COMBAT_STUB_HP_ZERO`; câu cũ ("…không giữ món nào, kể cả đồ đã niêm") dạy người chơi một luật sai,
  trái lời hứa của Hộp Công Chứng. Câu mới chỉ nói bản thử chưa có cứu hộ và thu hồi. Tên key giữ nguyên;
  `COMBAT_STUB_BUTTON_BOOT` không mâu thuẫn nên giữ nguyên.

### Thay đổi TASK-84

- 56 key mới ở mục S03 (append cuối CSV); 122 key cũ giữ nguyên tên **và** nội dung.
- §1: thêm placeholder S03 và sáu dòng giới hạn S03. `CARD_<ID>_*` của món cache B dùng giới hạn riêng (24/32/64), không
  dùng dòng 64 chung của `CARD_MANIFEST_R17_*`.
- Không cần key objective mới cho B; không có chữ trên đầu địch ở S03.

### Thay đổi TASK-71

- 44 key mới (30 key S02 ghi `TASK-71`, 14 key S04 ở bảng trên); 75 key cũ giữ nguyên tên **và** nội dung.
- `EXTRACT_CONFIRM_BODY` giữ câu cảnh báo địch dù S02 không có địch (beacon spec §8, quyết định S02).
- Sửa một dòng tài liệu ở §1: objective HUD là "một dòng trên HUD ngang 1280×720", thay chữ "mobile dọc" (UX Q5).

## 3. Thuật ngữ cần Producer duyệt `proposed`

Các chữ dưới đây có trong chuỗi in-game nhưng chưa có dòng trong `memory/glossary.md`:

| Chữ hiển thị | Nguồn | Gợi ý |
|---|---|---|
| `Cuộn Băng Muối` (`ITEM_STARTER_REMEDY_NAME`) | TASK-71, tên mới cho `starter_remedy` (inventory spec §8.3 "tên cuối chưa chốt") | **Chờ Producer duyệt** làm tên item. Chưa chốt vật hồi phục ở túi đeo chéo có cùng `def_id` không (UX Q4); nếu khác, cần tên riêng. |
| `bàn dispatch`, `trạm thuế`, `kit thu hồi`, `vòng đèn phao`, `Đồ mang theo` | vertical-slice Beat 1/3, §4.3; UX vòng A §5.3, §5.7 | Mô tả, không phải tên riêng. |

**Đề xuất glossary S03 (TASK-84) `proposed`** — chưa sửa `memory/glossary.md`; Producer duyệt rồi mới thêm.

| Tiếng Việt | English | code | Nguồn | Ghi chú |
|---|---|---|---|---|
| Vệ binh thuế khiên nhẹ | Light-shield Tax Guard | `tax_guard` | [combat](combat-slice-spec.md) §1; `ENEMY_TAX_GUARD_NAME` | Vai địch; patrol B là cùng vai, chữ HUD gọi tắt `Vệ binh`. |
| Đốc công | Foreman | `foreman` | combat §1; vertical slice Beat 3; `ENEMY_FOREMAN_NAME` | Vai địch charge theo lane. |
| Đồng Thuế Cạo Mặt | Scraped Tax Coin | `scraped_tax_coin` | items #14; [loot B](zone-b-loot-spec.md) §4 | Món cache B. |
| Sổ Kho Ngấm Nước | Waterlogged Stock Ledger | `waterlogged_stock_ledger` | items #16; loot B §4 | Món cache B; không phải vật chứng. |
| rương tịch thu (cache B) | confiscation chest | `cache_b` | loot B §3.1; `WORLD_INTERACT_CACHE_B` | Mô tả vật thể, không phải tên riêng. |
| Gói Băng Muối | sling remedy | `sling_remedy` | combat §1; `ITEM_SLING_REMEDY_NAME` (đã có trong CSV) | HUD S03 chỉ gọi là `thuốc`; tên chưa có dòng glossary. |

**Đề xuất glossary S04 (TASK-98) `proposed`** — chưa sửa `memory/glossary.md`; Producer duyệt rồi mới thêm.

| Tiếng Việt | English | code | Nguồn | Ghi chú |
|---|---|---|---|---|
| Vải Cứu Trợ Đổi Nhãn | Relabelled Relief Cloth | `cargo_d_2x2` | items #11; [luật S04](zone-d-cargo-notary-death-spec.md) §3.1; `ITEM_CARGO_D_2X2_NAME` | Cargo `2x2` ở D, không niêm được. HUD/R5' gọi mô tả `kiện vải`. |
| Dấu Thuế | Tax Stamp | `tax_stamp_d` | D brief §1; luật S04 §3.1–§3.2.3; `ITEM_TAX_STAMP_D_NAME` | Món gọn `1x2` ở D; không phải #15 Dấu Niêm Thuế Đã Cạo Tên, không phải Counterseal. |

Đã vào glossary ngày 2026-11-06 (bỏ khỏi danh sách chờ): `Người Thu Hồi già`, `Kho K-7`, `Contract 2`,
`Recovery Contract`, `chưa thu hồi`.
