shader_type canvas_item;

uniform bool has_outline = true;
uniform vec4 outline_color:source_color;
uniform float outline_size = 1;

varying vec4 modulate;

void vertex() {
	modulate = COLOR;
}

void fragment() {

	vec4 base_color = COLOR;

	float size_x = 1.0/float(textureSize(TEXTURE, 0).x);
	float size_y = 1.0/float(textureSize(TEXTURE, 0).y);
	vec4 sprite_color = texture(TEXTURE, UV);
	float alpha  = -4.0 * sprite_color.a;
	alpha += textureLod(TEXTURE, UV + vec2(size_x * outline_size, 0), 0).a;
	alpha += textureLod(TEXTURE, UV + vec2(-size_x * outline_size, 0), 0).a;
	alpha += textureLod(TEXTURE, UV + vec2(0, -size_y * outline_size), 0).a;
	alpha += textureLod(TEXTURE, UV + vec2(0, size_y * outline_size), 0).a;
	sprite_color = mix(sprite_color, outline_color, clamp(alpha, 0.0, 1.0));
	sprite_color = vec4(sprite_color.rgb, clamp(abs(alpha) + sprite_color.a, 0.0, 1.0));
	base_color = sprite_color;

	COLOR = base_color * modulate;

}
