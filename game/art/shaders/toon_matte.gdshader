shader_type spatial;
render_mode diffuse_toon, specular_disabled;

uniform vec4 albedo_color : source_color = vec4(0.482353, 0.356863, 0.25098, 1.0);
// In GL Compatibility, source_color uniforms read raw sRGB values in light().
// Convert shadow colours there before comparing them with linear ALBEDO.
uniform vec4 shadow_indigo : source_color = vec4(0.172549, 0.192157, 0.258824, 1.0);
uniform bool paper_grain_enabled = true;
uniform float paper_grain_strength : hint_range(0.0, 0.06) = 0.04;
uniform float paper_fiber_scale : hint_range(4.0, 28.0) = 14.0;
uniform float paper_speckle_density : hint_range(1.0, 18.0) = 7.0;
// Hatch is intentionally opt-in: only broad, non-telegraph surfaces enable it.
uniform bool hatch_enabled = false;
uniform float hatch_density : hint_range(2.0, 12.0) = 5.0;
// Width is a fraction of one hatch interval. Broad shaded faces opt in to a
// wider value so the individual gouge strokes survive the phone downsample.
uniform float hatch_line_width : hint_range(0.04, 0.32) = 0.052;
uniform float hatch_strength : hint_range(0.0, 0.90) = 0.34;
// Defaults preserve the original broken-hatch pattern. Broad architectural
// faces may opt in to hand-cut spacing and lengths without changing the
// library materials that already use this shader.
uniform float hatch_irregularity : hint_range(0.0, 1.0) = 0.0;
uniform float hatch_dash_frequency : hint_range(0.20, 1.20) = 0.82;
// Lighter materials cut toward ink; dark materials may cut toward paper so
// their sparse relief remains distinct inside the indigo shadow band.
uniform vec3 hatch_gouge_colour : source_color = vec3(0.121569, 0.101961, 0.090196);

varying vec3 world_position;
varying vec3 world_normal;
varying float paper_mark;
varying float hatch_mark;

float hash21(vec2 value) {
	return fract(sin(dot(value, vec2(127.1, 311.7))) * 43758.5453123);
}

vec3 srgb_to_linear(vec3 colour) {
	vec3 lower = colour / 12.92;
	vec3 upper = pow((colour + 0.055) / 1.055, vec3(2.4));
	return mix(lower, upper, step(vec3(0.04045), colour));
}

float fiber_plane(vec2 plane, float scale) {
	// Long, slightly broken fibres: a paper mark, not evenly distributed white noise.
	vec2 cell = floor(plane * scale);
	float bend = (hash21(vec2(cell.y, cell.y + 11.0)) - 0.5) * 0.28;
	float fibre = 1.0 - smoothstep(0.03, 0.12, abs(fract((plane.x + bend) * scale) - 0.5));
	float broken = step(0.30, hash21(cell));
	float speckle = step(0.92, hash21(floor(plane * paper_speckle_density)));
	float pulp = hash21(floor(plane * scale * 0.45)) - 0.5;
	return (fibre * broken * 0.62 + speckle * 0.38 - 0.22) * 1.15 + pulp * 0.35;
}

float triplanar_paper(vec3 position, vec3 normal) {
	vec3 weights = pow(abs(normalize(normal)), vec3(4.0));
	weights /= max(weights.x + weights.y + weights.z, 0.0001);
	float marks = fiber_plane(position.yz, paper_fiber_scale) * weights.x;
	marks += fiber_plane(position.xz, paper_fiber_scale) * weights.y;
	marks += fiber_plane(position.xy, paper_fiber_scale) * weights.z;
	return clamp(marks, -1.0, 1.0);
}

float hatch_plane(vec2 plane, float density) {
	// Parallel, broken strokes use world axes, so they do not swim with the
	// camera or collapse into a flat shadow fill. Low density keeps each row
	// readable as a separate chisel pass rather than a texture fill.
	float across = (plane.x + plane.y * 0.32) * density;
	float along = (plane.y - plane.x * 0.32) * density;
	float row = floor(across);
	float legacy_start = mix(0.06, 0.22, hash21(vec2(row, row + 17.0)));
	float legacy_end = mix(0.66, 0.94, hash21(vec2(row + 31.0, row)));
	float dash_frequency = mix(0.82, hatch_dash_frequency, hatch_irregularity);
	float dash_coordinate = along * dash_frequency;
	float dash_phase = fract(dash_coordinate);
	float dash_index = floor(dash_coordinate);
	// Each physical cut receives a different phase and length. The broad
	// range (0.44..0.99 of a long interval) prevents decorative dot rows:
	// the longest cut is at least twice the shortest before its pointed tips.
	float cut_seed = hash21(vec2(row * 7.0 + 19.0, dash_index * 11.0 + 3.0));
	float phase_seed = hash21(vec2(row * 13.0 + 5.0, dash_index * 17.0 + 29.0));
	float cut_start = mix(0.01, 0.08, phase_seed);
	float cut_length = mix(0.44, 0.99, cut_seed);
	float cut_end = min(cut_start + cut_length, 0.99);
	float dash_start = mix(legacy_start, cut_start, hatch_irregularity);
	float dash_end = mix(legacy_end, cut_end, hatch_irregularity);
	float dash = step(dash_start, dash_phase) * (1.0 - step(dash_end, dash_phase));
	float distance_to_tip = min(dash_phase - dash_start, dash_end - dash_phase);
	float tip_span = min(0.16, (dash_end - dash_start) * 0.34);
	float tip = clamp(distance_to_tip / max(tip_span, 0.001), 0.0, 1.0);
	float stroke_half_width = hatch_line_width * tip;
	// Jittered row centres only apply to the opt-in chisel treatment; a zero
	// irregularity keeps the old evenly spaced hatch for every existing material.
	float row_offset = (hash21(vec2(row + 41.0, row * 3.0 + 7.0)) - 0.5) * 0.52 * hatch_irregularity;
	float line = 1.0 - step(stroke_half_width, abs(fract(across) - (0.5 + row_offset)));
	return line * dash;
}

float triplanar_hatch(vec3 position, vec3 normal) {
	vec3 weights = pow(abs(normalize(normal)), vec3(4.0));
	weights /= max(weights.x + weights.y + weights.z, 0.0001);
	return hatch_plane(position.yz, hatch_density) * weights.x
		+ hatch_plane(position.xz, hatch_density) * weights.y
		+ hatch_plane(position.xy, hatch_density) * weights.z;
}

void vertex() {
	world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	world_normal = normalize(MODEL_NORMAL_MATRIX * NORMAL);
}

void fragment() {
	paper_mark = paper_grain_enabled ? triplanar_paper(world_position, world_normal) : 0.0;
	hatch_mark = hatch_enabled ? triplanar_hatch(world_position, world_normal) : 0.0;
	ALBEDO = clamp(albedo_color.rgb * (1.0 + paper_mark * paper_grain_strength), vec3(0.0), vec3(1.0));
	ROUGHNESS = 1.0;
}

void light() {
	// Godot combines DIFFUSE_LIGHT with ALBEDO after light().  A lit face therefore
	// needs a unit multiplier, not its albedo a second time.  The directional
	// light supplies only a stable direction and shadow map: its tint and energy
	// must not recolour printed palette ink.
	float faces_light = step(0.20, dot(normalize(NORMAL), normalize(LIGHT)));
	float receives_light = step(0.01, ATTENUATION);
	float lit = faces_light * receives_light;
	float shadow_hatch = hatch_mark * (1.0 - lit) * hatch_strength;
	// ALBEDO is already linear. GL Compatibility exposes these source colours as
	// raw sRGB in light(), so linearise both before deriving the multiplier.
	vec3 linear_shadow_indigo = srgb_to_linear(shadow_indigo.rgb);
	vec3 linear_hatch_gouge = srgb_to_linear(hatch_gouge_colour);
	vec3 shadow_colour = mix(linear_shadow_indigo, linear_hatch_gouge, shadow_hatch);
	vec3 shadow_multiplier = shadow_colour / max(ALBEDO, vec3(0.02));
	DIFFUSE_LIGHT += mix(shadow_multiplier, vec3(1.0), lit);
}
