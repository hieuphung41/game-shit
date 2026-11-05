shader_type spatial;
render_mode diffuse_toon, specular_disabled;

uniform vec4 albedo_color : source_color = vec4(0.482353, 0.356863, 0.25098, 1.0);
uniform vec3 shadow_indigo : source_color = vec3(0.172549, 0.192157, 0.258824);
uniform bool paper_grain_enabled = true;
uniform float paper_grain_strength : hint_range(0.0, 0.04) = 0.012;

varying vec3 world_position;

float paper_grain(vec3 position) {
	return fract(sin(dot(floor(position.xz * 20.0), vec2(12.9898, 78.233))) * 43758.5453) - 0.5;
}

void vertex() {
	world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	float grain = paper_grain_enabled ? paper_grain(world_position) * paper_grain_strength : 0.0;
	ALBEDO = clamp(albedo_color.rgb + vec3(grain), vec3(0.0), vec3(1.0));
	ROUGHNESS = 1.0;
}

void light() {
	// Keep the dark step as the palette's indigo instead of multiplying it into
	// black. ATTENUATION carries the directional shadow map result on GL
	// Compatibility; the normal test keeps the lit edge hard and readable.
	float faces_light = step(0.20, dot(normalize(NORMAL), normalize(LIGHT)));
	float receives_light = step(0.01, ATTENUATION);
	float lit = faces_light * receives_light;
	DIFFUSE_LIGHT += mix(shadow_indigo, ALBEDO * LIGHT_COLOR.rgb, lit);
}
