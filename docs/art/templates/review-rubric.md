# Rubric review hình ảnh

Dùng cho người tự kiểm (bước 5) và art director (bước 7) trong [ART_BIBLE §10](../ART_BIBLE.md#10-quy-trình-một-asset-bắt-buộc-với-agent).
Chấm trên **ba ảnh look-dev**: góc game 1280×720, cùng khung ở thang xám, và bản thu nhỏ cỡ điện thoại (640×360).

## A. Danh sách CẤM (một mục có là trượt)

| Mã | Có? | Ở đâu (ảnh/vùng) |
|---|---|---|
| AI-01 bóng nhựa | ☐ | |
| AI-02 phun sơn / gradient mượt | ☐ | |
| AI-03 chi tiết vô nghĩa | ☐ | |
| AI-04 ánh sáng studio / rim light | ☐ | |
| AI-05 bão hoà / ngoài palette | ☐ | |
| AI-06 hậu kỳ điện ảnh | ☐ | |
| AI-07 chữ hoặc ký tự giả | ☐ | |
| AI-08 hình học tan chảy / sai góc camera | ☐ | |
| AI-09 trope "epic" chung chung | ☐ | |
| AI-10 trôi phong cách so với mục tiêu | ☐ | |
| AI-11 dấu upscale / nén | ☐ | |
| AI-12 không rõ nguồn | ☐ | |

## B. Mười tiêu chí (0 = sai, 1 = tạm, 2 = đúng ART_BIBLE)

| # | Tiêu chí | Câu hỏi kiểm tra | Điểm |
|---|---|---|---|
| 1 | Silhouette | Ở ảnh cỡ điện thoại, nhận ra vật bằng bóng đen không? | |
| 2 | Value | Ở ảnh thang xám, player, loot và vật tương tác có tách khỏi nền không? | |
| 3 | Kỷ luật palette | Màu đúng làn chưa (env không phát sáng; signal chỉ cho gameplay; rarity không có trong thế giới)? | |
| 4 | Vật liệu mờ | Có điểm bóng hay phản chiếu nào trên bề mặt khô không? | |
| 5 | Ánh sáng 2 bậc | Ranh sáng/tối rõ không, bóng có ngả chàm không, hướng sáng có khớp LGT-01 không? | |
| 6 | Nét mực | Viền có cùng màu, cùng độ dày giữa các asset cùng loại không? | |
| 7 | Vết mòn có tác giả | Mỗi vết có lý do kể chuyện, hay là grunge phủ đều? | |
| 8 | Phân cấp chi tiết | Vật tương tác > landmark > tường > sàn? Sàn có yên cho telegraph không? | |
| 9 | Khớp camera | Đúng phép chiếu orthographic −30°/45°, không méo, không lệch tỉ lệ? | |
| 10 | Cùng một gia đình | Đặt cạnh mục tiêu đã duyệt có giống cùng một game không? | |

**Đạt:** không mục CẤM nào, tổng ≥ 16/20 và không tiêu chí nào 0 điểm.

## C. Báo cáo (dán vào report của card)

```text
Rubric: <tổng>/20 · CẤM: <không | AI-xx tại …>
Thấp nhất: <tiêu chí> — <vì sao> — <sửa gì>
Ảnh: build/lookdev/<…>.png
```
