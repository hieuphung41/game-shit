shader_type spatial;
render_mode diffuse_toon, specular_toon;

// Water is the only wet material: its small toon specular remains below the
// printed colour blocks rather than forming a PBR highlight.
uniform vec4 albedo_color : source_color = vec4(0.180392, 0.321569, 0.301961, 1.0);
// GL Compatibility exposes source colours as raw sRGB inside light().
uniform vec4 shadow_indigo : source_color = vec4(0.172549, 0.192157, 0.258824, 1.0);
uniform float wet_roughness : hint_range(0.75, 1.0) = 0.88;
uniform float wet_specular_strength : hint_range(0.0, 0.15) = 0.08;

vec3 srgb_to_linear(vec3 colour) {
	vec3 lower = colour / 12.92;
	vec3 upper = pow((colour + 0.055) / 1.055, vec3(2.4));
	return mix(lower, upper, step(vec3(0.04045), colour));
}

void fragment() {
	ALBEDO = albedo_color.rgb;
	ROUGHNESS = wet_roughness;
	SPECULAR = wet_specular_strength;
}

void light() {
	// Keep PRT-01 identical to toon_matte: light gives direction and the
	// shadow map only; it never tints the palette water colour.
	float faces_light = step(0.20, dot(normalize(NORMAL), normalize(LIGHT)));
	float receives_light = step(0.01, ATTENUATION);
	float lit = faces_light * receives_light;
	vec3 shadow_colour = srgb_to_linear(shadow_indigo.rgb);
	vec3 shadow_multiplier = shadow_colour / max(ALBEDO, vec3(0.02));
	DIFFUSE_LIGHT += mix(shadow_multiplier, vec3(1.0), lit);
	// This is the sole wet exception: a rare, two-step glint at eight percent.
	// It is absent from shadow so the indigo block stays readable and never
	// becomes a broad glossy PBR reflection.
	float half_alignment = dot(normalize(NORMAL), normalize(LIGHT + VIEW));
	float wet_glint = step(0.96, half_alignment) * lit * wet_specular_strength;
	SPECULAR_LIGHT += vec3(wet_glint);
}
