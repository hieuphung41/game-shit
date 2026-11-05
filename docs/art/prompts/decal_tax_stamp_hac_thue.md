# Prompt card — decal_tax_stamp_hac_thue

> Chép từ [../templates/prompt-card.md](../templates/prompt-card.md). **Không sửa** hai khối LOCK: `tools/check_art.py`
> so sánh chúng với template từng chữ. Chỉ điền các khối SUBJECT / OUTPUT / PALETTE ROLES. Không ghi tên hoạ sĩ,
> studio, game hay engine render. Ảnh sinh ra chỉ là phôi: phải chuẩn hoá theo ART_BIBLE §8 trước khi vào game.

- Brief: `docs/art/briefs/zone-a-outer-pier.md#decal_tax_stamp_hac_thue`
- Tool / model / ngày: chưa chạy / chưa chọn / — (điền khi tạo ảnh)
- Dùng làm: phôi decal

## SUBJECT
a single hand-pressed customs tax stamp mark of a harbour authority, lying face-up on a flat surface: a thick square
border with one corner cut off, and inside it one simple cargo hook shape; ink pressed unevenly so one side of the
border is fainter and slightly broken, as if stamped by hand at a slight tilt; no other marks, no inner patterns

## PALETTE ROLES
canvas_red_dark for all stamp ink; paper as the flat background only (to be removed to transparent during
normalisation); no other colours

## OUTPUT
square 1:1 image, one stamp mark centred with a clear margin on every side, nothing cut at the edges, flat plain
paper background, large solid shapes that stay readable when shrunk to 32 by 32 pixels

## Chuẩn hoá bắt buộc trước khi vào game (ART_BIBLE §8)

1. Nắn phối cảnh về nhìn thẳng (dấu là mặt phẳng; khối STYLE LOCK cho ảnh nghiêng theo camera game).
2. Xoá nền `paper` thành alpha trong suốt, cắt alpha cứng (không viền mờ).
3. Quantize về đúng `canvas_red_dark`; ≤ 48 màu (TEX-02), ≥ 97% pixel trong ΔE ≤ 8 của làn `env` (TEX-01).
4. Giảm về 64 × 64 px (bản biển thuế 128 × 128) `proposed`, PNG 8-bit (TEX-03); thử thu về 32 × 32 vẫn nhận ra.
5. Soát tay: không chữ, không ký tự giả, không hoa văn li ti (TEX-04, AI-03, AI-07); không hình thoi/mũi tên/ghim.
6. Chụp look-dev trên bàn dispatch và biển thuế, chấm rubric, ghi manifest `kind: generated`, `prompt_card`, `tool`,
   `date`, `normalized: true`, `lane: env`.

<!-- STYLE-LOCK v1 BEGIN -->
3D low-poly game asset rendered like a colour woodblock print on rough handmade paper. Flat colour fields only from
the listed palette, two-step light from the upper left, shadows shifted toward dark indigo, thin dark ink outline on
the outer silhouette, chunky slightly irregular hand-cut shapes, matte surfaces with no shine, wear only where the
subject says (stamps, wax seals, patches, rope, water lines). Orthographic view, camera pitch 30 degrees down, yaw 45
degrees, plain flat background, single object.
<!-- STYLE-LOCK v1 END -->

<!-- NEGATIVE-LOCK v1 BEGIN -->
no gloss, no specular highlights, no plastic, no wax-like skin, no airbrush, no smooth gradients, no photorealism,
no 3D render look, no subsurface scattering, no rim light, no soft studio lighting, no bloom, no glow, no lens flare,
no depth of field, no bokeh, no vignette, no film grain overlay, no hyperdetail, no ornamental micro-patterns, no
grunge overlay, no teal and orange, no saturated colours, no text, no letters, no numbers, no signatures, no
watermark, no logos, no frames, no mockup, no fantasy sparkles, no gold treasure glow
<!-- NEGATIVE-LOCK v1 END -->
