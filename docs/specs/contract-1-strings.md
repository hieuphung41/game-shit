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
| Gọi trong code | `tr("KEY")`; chuỗi có placeholder dùng `tr("KEY").format({"seconds": 20})`. Placeholder: `{seconds}`, `{used}`, `{total}`. |
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

Đã vào glossary ngày 2026-11-06 (bỏ khỏi danh sách chờ): `Người Thu Hồi già`, `Kho K-7`, `Contract 2`,
`Recovery Contract`, `chưa thu hồi`.
