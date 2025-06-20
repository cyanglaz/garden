shader_type canvas_item;

uniform sampler2D character_texture: repeat_disable;
uniform vec4 shadow_color: source_color;

void fragment() {
	vec2 texture_size = vec2(textureSize(character_texture, 0));
	vec2 uv = UV;

	// Calculate aspect ratio to make oval shadow
	float aspect = texture_size.x / texture_size.y;
	float shadow_height = 0.5; // Half height relative to width

	// Center UV and scale
	vec2 centered_uv = (uv - 0.5) * 2.0;

	// Create pixelated oval shape
	vec2 pixel_uv = vec2(centered_uv.x * aspect, centered_uv.y / shadow_height);
	vec2 pixel_size = vec2(0.2, 0.1); // Controls pixelation amount
	pixel_uv = floor(pixel_uv / pixel_size) * pixel_size;
	float oval = length(pixel_uv);

	// Create hard edge with slight pixel stepping
	float shadow = 1.0 - step(0.95, oval);
	shadow *= step(oval, 1.0);

	// Output final color with pixelated alpha
	COLOR = shadow_color;
	COLOR.a *= shadow;
}
