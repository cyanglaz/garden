shader_type canvas_item;
// 3. Create a uniform for animation
uniform float ghost_progress: hint_range(0.0, 1.0);

void fragment() {
	// 2. Utlize UV mapping to mapthe texture upwards
	vec4 base_color = textureLod(TEXTURE, UV, ghost_progress);

	//// 5. add transparency
	float ghost_opacity = 1.0;
	float min_ghost_opacity = 0.9;
	base_color.a *= (1.0 - ghost_progress * min_ghost_opacity) * ghost_opacity;

	COLOR.rgba = base_color;
}