# Kenney Pirate Kit 2.1 — phần dùng cho Bến Ngoài

- Nguồn chính thức: https://kenney.nl/assets/pirate-kit
- Tải ngày: 2026-11-06
- Giấy phép: CC0-1.0 (bản gốc trong `License.txt`)
- Chỉ giữ bốn hình khối GLB cần cho look-dev Bến Ngoài: `crate`, `barrel`,
  `platform-planks`, `structure-platform-dock`.

Các file được chép nguyên trạng vào `game/assets/third_party/kenney-pirate-kit/`.
Trong game, `ThirdPartyLookdevMaterial` thay toàn bộ material của pack bằng các
material mờ thuộc thư viện dự án; texture/atlas gốc không được dùng để render.
Không có ảnh texture nào được nhập vào `game/assets/`, nên không phát sinh thiết
lập filter, mipmap hay compression riêng.
