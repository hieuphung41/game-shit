# Prompt cards

Một file cho mỗi asset được tạo bằng AI, chép từ [../templates/prompt-card.md](../templates/prompt-card.md).
`tools/check_art.py` kiểm tra: hai khối LOCK còn nguyên từng chữ, và không có cụm từ bị cấm (tên hoạ sĩ, studio,
engine render, "8k", "hyperrealistic"…).
