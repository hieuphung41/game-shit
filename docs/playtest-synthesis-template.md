# Tổng hợp nhiều phiên playtest — Vertical slice “Giữ giấy phép”

**Trạng thái:** mẫu tổng hợp `proposed`. Mẫu này gom bằng chứng quan sát từ các [phiếu quan sát](playtest-observation-sheet.md) sau khi build đã qua [build-readiness](vertical-slice-build-readiness.md). Nó không thay đổi luật slice, không thay thế phiếu từng phiên và không phải hệ thống analytics, dashboard hay cơ sở dữ liệu.

**Nguồn ràng buộc:** [vertical slice](vertical-slice.md), [wireflow UX](vertical-slice-wireflow.md), [kế hoạch playtest](playtest-readability-plan.md), [phiếu quan sát](playtest-observation-sheet.md), [build-readiness](vertical-slice-build-readiness.md). Khi có khác biệt, tài liệu nguồn và bằng chứng màn hình thực tế được ưu tiên; không suy luật mới từ bản tổng hợp.

## 1. Cách dùng và giới hạn bằng chứng

Chỉ tổng hợp các phiên có **cùng build label**, control scheme và fixture/readiness có thể so sánh. Dùng duy nhất `Mã phiên` không định danh từ phiếu quan sát; không chép tên, contact, recording, hay thông tin nhận diện người chơi vào đây.

`C0` là run tự nhiên của người chơi first-time và là nguồn duy nhất cho quyết định route first-time ở P1/P2. `C1`–`C3` là coverage state có kiểm soát sau C0 hoặc ở fixture hợp lệ: chúng bổ sung evidence về state/UI, nhưng không được viết lại hành vi/lời nói đầu tiên tại C0.

Đặc biệt, **C2 chạy sau C0 của cùng người chơi không chứng minh lựa chọn route first-time cho P1/P2**. Nó chỉ dùng cho P3–P8 và evidence UI/state. Một C2 chỉ được ghi là evidence P1/P2 nếu thực tế là run first-time tự chọn, không hint route, và được ghi như C0 độc lập — không phải vì nó đi qua đầy đủ A → B → D → B → A.

Rút A ngay sau Manifest là success hợp lệ. Từ chối loot, không niêm, hoặc từ chối cargo sau khi người chơi đã cân nhắc footprint/công dụng/trade-off cũng là outcome hợp lệ. Một gameplay death không tự biến claim thành `FAIL`; phải ghi player hiểu hay không hiểu telegraph/counterplay, tách timing, control và lỗi kỹ thuật.

## 2. Nhóm phiên có thể so sánh

```text
Build label:
Control scheme:
Readiness/fixture trước nhóm phiên: GO / NOT READY / BLOCKER
Invariant hoặc state không có (nếu có):
Mã phiên được đưa vào nhóm (chỉ ID không định danh, không PII):
Lý do các phiên này có thể so sánh:
Khác biệt build/control/fixture không được gộp (nếu có):
```

Nếu fixture không tạo được đúng luật, hoặc build khác nhau ở state đang xét, tách nhóm hoặc chuyển state/claim đó thành `KHÔNG TEST ĐƯỢC`; không bù bằng mô tả miệng, mock text hay ký ức của facilitator.

## 3. Tình trạng coverage và fixture

| Coverage / state | Mã phiên có evidence | Kết quả coverage | State/outcome đã nhìn thấy | Fixture, can thiệp hoặc lỗi kỹ thuật ảnh hưởng | Dùng được cho claim nào | Không được suy ra |
|---|---|---|---|---|---|---|
| C0 — run tự nhiên first-time |  | Có / thiếu / `KHÔNG TEST ĐƯỢC` |  |  | P1/P2 route-first-time; P3/P4/P5/P7 và P8 sub-state chỉ khi state tự xuất hiện; P6 chỉ support | State/player choice chưa gặp; P6 `PASS` hay P8 tổng từ một C0 row |
| C1 — rút sớm |  | Có / thiếu / `KHÔNG TEST ĐƯỢC` | Manifest → A → call/hold/board → summary |  | P2 semantics bổ sung; P3/P7/P8a/P8c khi state xuất hiện | Quyết định route first-time P1/P2; P6/P8b/P8d |
| C2 — full-route tùy chọn |  | Có / thiếu / `KHÔNG TEST ĐƯỢC` | B combat/card → D cargo/Hộp → quay A → extract |  | P3/P4/P5/P7; P8 sub-state theo state; P6 chỉ support | P1/P2 route-choice first-time nếu chạy sau C0; P6 `PASS` hay P8 tổng từ một C2 row |
| C3 — death → Recovery |  | Có / thiếu / `KHÔNG TEST ĐƯỢC` | death thật → S11 → S12 → recovery → A → call/hold/board |  | P6 chỉ với full chain; P7; P8a recovery và P8d death/evidence | P1/P2 route-first-time, P3/P4/P5/P8b/P8c, completion/auto-recovery hoặc P8 tổng từ C3 |
| Presentation P8a–P8d |  | Có / thiếu / `KHÔNG TEST ĐƯỢC` |  |  | Sub-state P8 đã gặp | Một sub-state khác hoặc chỉ màu |

Các state phải theo wireflow `S0–S12`, overlay `O1–O5` và extract state `E0/E1`; chỉ ghi state đã nhìn thấy trên build. Easy cố định, Contract 1, A/B/D playable, A là extract duy nhất; C/E chỉ là silhouette không tương tác và Contract 2 chỉ là campaign state chưa playable.

## 4. Evidence C0 — first-time, run tự nhiên

Điền trước mọi evidence controlled. Mỗi hàng giữ hành vi/lời nói đầu tiên ngắn, có thể kiểm tra từ phiếu nguồn; không thay lời người chơi bằng diễn giải như “có vẻ hiểu”.

| Mã phiên | Build/control xác nhận | C0 outcome tự chọn | State/beat | Hành vi đầu tiên và lời nói nguyên văn/ngắn | Claim liên quan | Can thiệp facilitator | Control/technical/skill confounder | Kết quả tạm thời | Ghi chú route first-time |
|---|---|---|---|---|---|---|---|---|---|
|  |  | rút sớm / B-D rồi rút / death trước-sau Manifest / dừng / `KHÔNG TEST ĐƯỢC` |  |  |  | không / mô tả | không / mô tả | `PASS` / `FAIL` / `INVESTIGATE` / `KHÔNG TEST ĐƯỢC` | tự chọn, không hint / không dùng làm evidence P1/P2 |
|  |  |  |  |  |  |  |  |  |  |

Không coi việc một người chọn B/D là bằng chứng họ biết B/D tùy chọn nếu câu/hành vi đầu tiên cho thấy họ tin nó bắt buộc. Ngược lại, rút sớm sau Manifest với lý do đúng là P1/P2 evidence hợp lệ, không phải “bỏ content”.

## 5. Evidence C1–C3 — coverage có kiểm soát

Evidence dưới đây bổ sung đúng state còn thiếu, không retroactively sửa C0. Giữ C1/C2/C3 ở bảng tách để thấy rõ người chơi đã có knowledge từ C0 hay control instruction trước đó.

| Coverage | Mã phiên | State/fixture hợp lệ | Hành vi đầu tiên và lời nói nguyên văn/ngắn | Outcome trên màn | Claim có thể bổ sung | Can thiệp facilitator | Control/technical/skill confounder | Kết quả tạm thời | Giới hạn diễn giải |
|---|---|---|---|---|---|---|---|---|---|
| C1 — rút sớm |  |  |  |  | P2 semantics; P3/P7/P8a/P8c khi state xuất hiện |  |  | `PASS` / `FAIL` / `INVESTIGATE` / `KHÔNG TEST ĐƯỢC` | Không chứng minh P1/P2 route-choice first-time; không dùng cho P6/P8b/P8d |
| C2 — full-route |  |  |  |  | P3/P4/P5/P7; P8 sub-state đã thấy; P6 support only |  |  | `PASS` / `FAIL` / `INVESTIGATE` / `KHÔNG TEST ĐƯỢC` | Không ghi P1/P2 route-choice first-time khi chạy sau C0; không dùng C2 đơn lẻ cho P6 `PASS` hoặc P8 tổng |
| C3 — death → Recovery |  |  |  |  | P6 full chain; P7; P8a recovery/P8d death-evidence |  |  | `PASS` / `FAIL` / `INVESTIGATE` / `KHÔNG TEST ĐƯỢC` | Death không tự là `FAIL`; không dùng cho P1/P2 route-choice, P3/P4/P5/P8b/P8c hoặc P8 tổng |
| Presentation probe hợp lệ |  |  |  |  | P8a/P8b/P8c/P8d |  |  | `PASS` / `FAIL` / `INVESTIGATE` / `KHÔNG TEST ĐƯỢC` | Không suy một cue sang sub-state khác |

## 6. Evidence loại trừ hoặc bị nhiễu

Không đưa các hàng này vào mẫu nguyên nhân của `MUST_FIX` hay tỷ lệ/nhận định tổng hợp. Chúng vẫn được giữ để không làm mất bối cảnh và để mở `INVESTIGATE` khi cần.

| Mã phiên | Claim/state/coverage | Evidence quan sát hoặc nguyên văn | Loại trừ vì | Can thiệp / confounder | Xử lý đúng |
|---|---|---|---|---|---|
|  |  |  | hint route / `CAN THIỆP CONTROL` / bug kỹ thuật / fixture sai-thiếu / state không gặp / khác build / input-timing / evidence mâu thuẫn |  | `INVESTIGATE` hoặc `KHÔNG TEST ĐƯỢC`; không quy thành hiểu sai luật |
|  |  |  |  |  |  |

## 7. Roll-up theo claim

`PASS` cần evidence đúng ở cơ hội đầu phù hợp, không gameplay hint. `FAIL` cần action hoặc lời nói sai cụ thể sau cơ hội hợp lý. State không tạo được đúng luật là `KHÔNG TEST ĐƯỢC`; bằng chứng một lần, không rõ nguyên nhân hoặc bị nhiễu là `INVESTIGATE`. Không điền `FAIL` chỉ vì death, rút sớm, từ chối loot hay từ chối cargo có cân nhắc.

| Claim | Trạng thái tổng hợp | Mã phiên + evidence quan sát/nguyên văn | State/coverage hợp lệ | Can thiệp hoặc confounder tách riêng | Discipline owner nếu cần task | Triage / bước tiếp |
|---|---|---|---|---|---|---|
| P1 — Objective/route | `PASS` / `FAIL` / `INVESTIGATE` / `KHÔNG TEST ĐƯỢC` |  | **Primary:** C0 first-time; controlled coverage không backfill route-choice |  | Slice flow + map readability |  |
| P2 — Rút sớm là thắng | `PASS` / `FAIL` / `INVESTIGATE` / `KHÔNG TEST ĐƯỢC` |  | **Primary:** C0 route-choice; **supplementary:** C1 semantics. C2/C3 không chốt route-choice. |  | Slice flow + objective/extract presentation |  |
| P3 — Combat công bằng | `PASS` / `FAIL` / `INVESTIGATE` / `KHÔNG TEST ĐƯỢC` |  | **Primary:** C0/C1/C2 khi gặp combat state; không C3. |  | Encounter + readability |  |
| P4 — Loot-grid là quyết định | `PASS` / `FAIL` / `INVESTIGATE` / `KHÔNG TEST ĐƯỢC` |  | **Primary:** C0/C2 khi gặp card/grid/cargo; không C1/C3. |  | Inventory UX + item presentation |  |
| P5 — Claim khác rarity | `PASS` / `FAIL` / `INVESTIGATE` / `KHÔNG TEST ĐƯỢC` |  | **Primary:** C0/C2/presentation khi gặp card claim-rarity; không C1/C3. |  | Item presentation + lore delivery |  |
| P6 — Hộp/evidence/death/recovery | `PASS` / `FAIL` / `INVESTIGATE` / `KHÔNG TEST ĐƯỢC` |  | **Primary cho `PASS`:** C3 full chain. **Support only:** C0/C2 placement, seal, Hộp/evidence; không row/coverage đơn lẻ nào đủ. |  | Inventory/recovery UX + contract wording |  |
| P7 — Extract/summary | `PASS` / `FAIL` / `INVESTIGATE` / `KHÔNG TEST ĐƯỢC` |  | **Primary:** C0/C1/C2/C3 khi gặp extract/summary/recovery state tương ứng. |  | Extract presentation + summary/narrative delivery |  |
| P8a — Landmark/objective/extract A | `PASS` / `FAIL` / `INVESTIGATE` / `KHÔNG TEST ĐƯỢC` |  | **Primary:** C0/C1/C2/C3/presentation khi gặp landmark A tương ứng; không suy route-first-time từ controlled coverage. |  | Art/presentation + UI accessibility |  |
| P8b — Claim khác rarity trên card | `PASS` / `FAIL` / `INVESTIGATE` / `KHÔNG TEST ĐƯỢC` |  | **Primary:** C0/C2/presentation khi gặp card; không C1/C3. |  | Art/presentation + UI accessibility |  |
| P8c — Hazard/telegraph | `PASS` / `FAIL` / `INVESTIGATE` / `KHÔNG TEST ĐƯỢC` |  | **Primary:** C0/C1/C2/presentation khi gặp hazard; không C3. |  | Art/presentation + UI accessibility |  |
| P8d — Hộp/evidence/death state | `PASS` / `FAIL` / `INVESTIGATE` / `KHÔNG TEST ĐƯỢC` |  | **Primary:** C0/C2/C3/presentation khi gặp state; không C1. |  | Art/presentation + UI accessibility |  |
| **P8 tổng** | `PASS` / `FAIL` / `INVESTIGATE` / `KHÔNG TEST ĐƯỢC` |  | **Roll-up only:** P8a–P8d. Không coverage/row riêng lẻ nào đủ `PASS`. |  | Art/presentation + UI accessibility | `PASS` chỉ khi P8a–P8d đều `PASS`; một sub-state thiếu làm P8 tổng `KHÔNG TEST ĐƯỢC`. |

Khi ghi P6, giữ nguyên semantics: Manifest đã niêm vẫn `chưa extract`; death sau Manifest là `unrecovered`; chỉ đồ niêm không-phải-evidence được giữ; gear/loot không niêm mất; Recovery Contract còn available và không phục hồi đồ đã tự bỏ/mất ngoài Hộp.

## 8. Sổ quyết định triage `proposed`

| Candidate | Bằng chứng phải có | Quyết định được phép | Hành động tiếp theo |
|---|---|---|---|
| Critical semantic/fairness candidate | Một row thuộc **source/coverage hợp lệ cho claim ở §7**, cùng build/control/fixture có thể so sánh theo §1, không hint/control/technical/skill confounder; ghi đủ **state → action/lời nói đầu tiên → outcome trên màn**. Ví dụ seal = completion, death = extract, không có recovery, extract/lane không được báo, hoặc C/E bị tưởng playable. | Chỉ thành `BLOCKER` khi outcome phá invariant/critical semantic-fairness và tái hiện được **cùng state → action → outcome** một lần trên cùng build. Trước đó là `INVESTIGATE`. | Ghi reproduction ngắn; dừng dùng finding để mở rộng content; chỉ khi ngưỡng đạt mới tạo repair Task Card sửa wording/state/readability. |
| Cùng nguyên nhân hiểu sai hoặc tín hiệu bị che lặp lại | Hai evidence **độc lập** thuộc source/coverage hợp lệ cho claim ở §7, cùng build/control/fixture/state có thể so sánh, không hint/control/technical/skill confounder. **Hoặc:** hai C0 first-time độc lập cùng causal misunderstanding tại cùng claim/beat (không chỉ cùng nhãn `FAIL`). **Hoặc:** cùng tín hiệu combat/UI bị che/lẫn tại hai coverage hợp lệ, cùng state cụ thể. | `MUST_FIX`. | Chỉ khi ngưỡng đạt mới tạo một repair Task Card hẹp cho một claim/beat/hypothesis; không đổi map, economy hoặc lore để che triệu chứng. |
| Evidence một lần, mâu thuẫn hoặc bị nhiễu | Hint/control support, input-timing, bug kỹ thuật, skill failure, khác build, fixture sai/thấp coverage hoặc source/coverage không hợp lệ theo §7. | `INVESTIGATE`. | Chỉ tạo handoff chẩn đoán hẹp để kiểm tra control/bug/fixture hoặc quan sát lại đúng claim. Đây không là bằng chứng lỗi design và **không** mở repair Task Card cho claim. |
| Fixture/state hợp lệ không tồn tại | Build không tạo được state theo flow thật. | `KHÔNG TEST ĐƯỢC`. | Chỉ tạo handoff readiness/fixture hẹp để đưa coverage về trạng thái quan sát được; không giả lập outcome bằng lời, không coi là lỗi design đã xác nhận và không mở repair Task Card cho claim. |
| Hiểu đúng hoặc lựa chọn khác mục tiêu nhưng trade-off đúng | Hành vi/câu trả lời đầu tiên phù hợp rule. | `PASS` / không mở task. | Không thêm popup, lore hoặc reward chỉ để ép full-route. |

## 9. Handoff Task Card hẹp

Một handoff chỉ có **một claim hoặc một state/fixture xác định**, không được gộp nhiều claim hoặc tự đề xuất content mới. Evidence bị loại ở §6 không được dùng để đạt ngưỡng. Chỉ `BLOCKER`/`MUST_FIX` dưới đây mới là repair Task Card cho claim; `INVESTIGATE`/`KHÔNG TEST ĐƯỢC` chỉ là handoff chẩn đoán hoặc readiness/fixture.

### Repair Task Card — chỉ `BLOCKER` hoặc `MUST_FIX`

```text
Task ID đề nghị:
Outcome một câu:
Claim ID duy nhất:
Evidence source / coverage hợp lệ theo §7:
Build / control / fixture và mã phiên evidence (ID không định danh):
Kiểm tra comparability + confounder: cùng build/control/fixture; không hint/control/technical/skill confounder
Beat / state / coverage bị lỗi:
Observed evidence: action → first words → on-screen outcome
Classification và ngưỡng đã đạt: BLOCKER / MUST_FIX
Reproduction (bắt buộc nếu BLOCKER): cùng state → action → outcome, một lần cùng build
Hypothesis cần kiểm tra:
Allowed files/sections:
Out of scope:
Acceptance: người chơi first-time mới sẽ thấy/hiểu <một điều có thể quan sát>
Discipline owner:
```

### Handoff chẩn đoán/readiness — chỉ `INVESTIGATE` hoặc `KHÔNG TEST ĐƯỢC`

```text
Diagnostic/readiness ID đề nghị:
Claim hoặc state/fixture duy nhất:
Classification: INVESTIGATE / KHÔNG TEST ĐƯỢC
Evidence source / coverage và build / control / fixture hiện có:
Observed evidence hoặc gate/state thiếu:
Confounder, mâu thuẫn hoặc lý do source chưa hợp lệ:
Phạm vi kiểm tra hoặc fixture/readiness hẹp:
Điều phải quan sát lại để trở về evidence hợp lệ:
Allowed files/sections:
Out of scope:
Discipline owner:
```

Handoff này không xác nhận causal design failure, không có acceptance sửa claim cho người chơi mới và không được nâng thành repair Task Card nếu chưa đạt lại ngưỡng `BLOCKER` hoặc `MUST_FIX` ở §8.

## 10. Điều bản tổng hợp này không thể kết luận

Bản tổng hợp này không xác lập đủ cỡ mẫu, causal statistics hay tính đại diện. Nó cũng không chứng minh balance combat/economy, sở thích người chơi, performance, accessibility certification hoặc release readiness. Nó không là quy trình tuyển người, consent, recording, lưu trữ dữ liệu, telemetry, implementation hay kế hoạch nội dung mới.

Kết quả duy nhất được phép là: ở state/beat nào, bằng chứng quan sát hiện có cho thấy người chơi hiểu đúng, hiểu sai, chưa rõ, hoặc chưa thể test — và liệu điều đó đã đạt đúng ngưỡng cho một Task Card hẹp hay chưa.
