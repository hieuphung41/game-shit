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
| Nút, nhãn, tag | 24 | `*_BUTTON_*`, `CARD_ACTION_*`, `LOADOUT_LABEL_*`, `BEACON_*_LABEL`, `INVENTORY_SEAL_LABEL_*`, `SUMMARY_GROUP_*` |
| Lựa chọn route | 32 | `PROMPT_ROUTE_*`, `SUMMARY_NEXT_CONTRACT2_*` |
| Objective HUD | 48 | `HUD_OBJECTIVE_*` (một dòng trên mobile dọc) |
| Dòng card item | 64 | `CARD_MANIFEST_R17_*` |
| Dòng summary, trạng thái, prompt | 72 | `SUMMARY_*` (trừ nhóm/nút), `EXTRACT_S*`, `BEACON_*_REASON`, `PROMPT_SAFEBOX_*`, `RECOVERY_BODY_*` |
| Briefing / thoại / O5 body | 80–110 | xem cột giới hạn từng key |

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

Thứ tự hiển thị card: `NAME → FOOTPRINT → USE → CLAIM → RARITY → LORE`, theo wireflow §3 và G7; tag
`STATE_NOT_EXTRACTED` là badge, không chen giữa các dòng.

### E0/E1, O5, S7–S9 — Beacon và extract Cầu tàu A

| Key | Màn hình / state | Tối đa | Nguồn / ghi chú |
|---|---|---:|---|
| `BEACON_E0_STATE_LABEL` | Beacon A, E0 `unavailable` | 24 | `proposed`. |
| `BEACON_E0_STATE_REASON` | Beacon A, E0 lý do | 72 | `proposed`; nêu điều kiện, không giấu luật. |
| `BEACON_E1_STATE_LABEL` | Beacon A, E1 `callable` | 24 | `proposed`. |
| `EXTRACT_E1_BUTTON_CALL` | E1 nút | 24 | Nguyên văn Beat 7. |
| `EXTRACT_CONFIRM_TITLE` | O5 tiêu đề | 32 | `proposed`. |
| `EXTRACT_CONFIRM_BODY` | O5 hậu quả, `{seconds}` = thời gian giữ đã công bố (15–25) | 90 | `proposed`. |
| `EXTRACT_CONFIRM_ACCEPT` | O5 xác nhận → S7 | 24 | `proposed`. |
| `EXTRACT_CONFIRM_CANCEL` | O5 hủy → E1 | 24 | `proposed`. |
| `EXTRACT_S7_CALL_ACCEPTED` | S7 trạng thái | 72 | `proposed`. |
| `EXTRACT_S8_HOLD_TIMER` | S8 HUD, `{seconds}` còn lại | 72 | `proposed`. |
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

## 3. Thuật ngữ cần Producer duyệt `proposed`

Các chữ dưới đây đã có trong tài liệu slice/story nhưng chưa có dòng trong `memory/glossary.md`:

| Chữ hiển thị | Nguồn | Gợi ý |
|---|---|---|
| `Người Thu Hồi già` | MAIN_STORY (nhân vật) | Thêm như vai NPC. |
| `Kho K-7` | MAIN_STORY (lead R-17) | Thêm như địa điểm/lead. |
| `Contract 2`, `Recovery Contract` | vertical-slice §4 | Thêm như tên contract. |
| `chưa thu hồi` | Việt hóa state `unrecovered` | Chốt làm nhãn state. |
| `bàn dispatch`, `trạm thuế`, `kit thu hồi` | vertical-slice Beat 1/3, §4.3 | Mô tả, không phải tên riêng. |
