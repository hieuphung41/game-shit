shader_type spatial;
render_mode unshaded, cull_front, specular_disabled;

uniform vec3 ink : source_color = vec3(0.121569, 0.101961, 0.090196);
// Shared phone-readable world-space ink width for priority silhouettes.
uniform float outline_width : hint_range(0.03, 0.07) = 0.055;

void vertex() {
	VERTEX += NORMAL * outline_width;
}

void fragment() {
	ALBEDO = ink;
}
