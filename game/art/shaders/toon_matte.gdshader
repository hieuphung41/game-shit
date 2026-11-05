shader_type spatial;
render_mode diffuse_toon, specular_disabled;

uniform vec4 albedo_color : source_color = vec4(0.482353, 0.356863, 0.25098, 1.0);
// Keep this a vec4 source colour.  In GL Compatibility a vec3 colour parameter
// is passed as raw linear data, which raises the declared indigo during the
// final display transfer.  The alpha channel is unused, but vec4 preserves the
// palette's source-colour conversion just like albedo_color.
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
	float line = 1.0 - smoothstep(hatch_line_width * 0.28, hatch_line_width, abs(fract(across) - 0.5));
	float along = (plane.y - plane.x * 0.32) * density;
	// A long, interrupted dash survives the phone downsample; short hash cells
	// previously read as paper grain instead of individually cut strokes.
	float dash = step(0.38, hash21(floor(vec2(along * 0.82, across))));
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
	vec3 shadow_colour = mix(shadow_indigo.rgb, hatch_gouge_colour, shadow_hatch);
	vec3 shadow_multiplier = shadow_colour / max(ALBEDO, vec3(0.02));
	DIFFUSE_LIGHT += mix(shadow_multiplier, vec3(1.0), lit);
}
