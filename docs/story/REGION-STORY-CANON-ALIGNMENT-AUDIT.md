# Audit canon vùng truyện — Khế Ước Tàn Vương

**Trạng thái:** audit `proposed` cho TASK-20261105-38. Phạm vi chỉ đồng bộ Act III–V của [vùng truyện và tiến trình](REGION_STORY_AND_PROGRESSION.md) với nguồn canon. Nó không tạo map, item, contract, ending, gameplay system hay nội dung hậu game mới.

## Nguồn đối chiếu

- [Tuyến truyện chính](MAIN_STORY.md) §§9–12: Witness Key/Mark, raid Thành Mưa Tro, Field Authority Seal, ba điều khoản và canon hậu campaign.
- [Cast và phe phái](CHARACTERS_AND_FACTIONS.md) §5: chuỗi vật chứng và beat Act III–V.
- [Story Bible](STORY_BIBLE.md) §§3–4: động cơ vùng, phe và ràng buộc mở rộng sau campaign.

## Kết quả đối chiếu

| Kiểm tra | Mismatch trước audit | Xử lý | Kết quả |
|---|---|---|---|
| Act III — xác thực registry và lead tới Act IV | Vùng truyện chỉ có lời khai/tọa độ, thiếu Witness Key xác thực registry và Witness Mark xác nhận người thầy giữ Seal. | Ghi lại Witness Key xác thực registry/lời khai; Witness Mark xác nhận người thầy còn sống, giữ Field Authority Seal và dẫn đến Thành Mưa Tro. | `repaired` |
| Act IV — objective và vật chứng | Chỉ nêu Ấn Chủ Quyền/bằng chứng nợ, thiếu raid vừa mở đường sơ tán vừa extract Seal và registry, cùng hậu quả canon. | Khóa raid relay → sơ tán + dual extraction, với người dân có đường thoát nhưng không cứu được tất cả. | `repaired` |
| Act V — điều khoản và hậu quả chung | Cũ ghi `Cải tổ / Phá / Chiếm Khế Ước`, gợi ý một nhánh hỗn loạn hoặc ba kết game tách rời. | Đổi thành `Cải Ước / Hoàn Trả / Giữ Ấn`; cả ba thay Khế Ước cũ bằng Hiến Ước Lâm Thời, mở vùng tranh chấp có kiểm soát và không reset thế giới. | `repaired` |
| Scope | Sửa có thể vô tình biến map outline thành map/contract implementation mới. | Chỉ phục hồi nhân quả, vật chứng, objective raid và hậu quả canon đã có ở nguồn chuẩn; bản sắc gameplay từng vùng giữ nguyên. | `clear` |

## Quy tắc được giữ cố định

- Vật chứng phải được extract mới mở mục tiêu tiếp theo; không NPC nào thay chuỗi evidence.
- Thành Mưa Tro giữ lựa chọn gameplay giữa thời gian relay/sơ tán và lấy evidence, nhưng campaign không rẽ nhánh canon ở Act IV.
- Campaign đóng xung đột cũ bằng Hiến Ước Lâm Thời; map update sau là hậu quả của luật mới, không retcon hay tận thế mới.

## Ngoài phạm vi

Audit không harmonize [Campaign Outline superseded](CAMPAIGN_OUTLINE.md), không đổi map brief, item, actor, combat, economy, UI, implementation, scope launch hoặc viết contract/hội thoại mới.
