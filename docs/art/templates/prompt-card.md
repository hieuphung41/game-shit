# Prompt card — <asset-id>

> Chép file này sang `docs/art/prompts/<asset-id>.md`. **Không sửa** hai khối LOCK: `tools/check_art.py` so sánh
> chúng với template từng chữ. Chỉ điền các khối SUBJECT / OUTPUT / PALETTE ROLES. Không ghi tên hoạ sĩ, studio,
> game hay engine render. Ảnh sinh ra chỉ là phôi: phải chuẩn hoá theo ART_BIBLE §8 trước khi vào game.

- Brief: `docs/art/briefs/<file>.md#<asset-id>`
- Tool / model / ngày: <tool> / <model> / <YYYY-MM-DD>
- Dùng làm: concept | phôi texture | phôi decal | phác icon

## SUBJECT
<một vật cụ thể, vai trò gameplay, trạng thái; ví dụ: "a tax inspector's slanted wooden booth with a stamped price board, one leg patched with rope">

## PALETTE ROLES
<liệt kê tên màu từ game/art/palette.json và vai trò; ví dụ: "canvas_red for the awning, wood_dark for posts, paper for the board, ink for outlines">

## OUTPUT
<tỉ lệ khung, nền phẳng `paper` hoặc trong suốt, một vật duy nhất, không cắt mép>

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
