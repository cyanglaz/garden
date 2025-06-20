shader_type canvas_item;

group_uniforms outline;
uniform bool has_outline = false;
uniform vec4 outline_color:source_color;
uniform float outline_size = 1;

varying vec4 modulate;

void vertex() {
	modulate = COLOR;
}

uniform bool flash = false;
uniform vec4 flash_color:source_color;

void fragment() {

	vec4 color = texture(TEXTURE, UV);
	if (flash) {
		vec4 new_color = flash_color;
		new_color.a = color.a;
		color = new_color;
	}

	if (has_outline) {
		float size_x = 1.0/float(textureSize(TEXTURE, 0).x);
		float size_y = 1.0/float(textureSize(TEXTURE, 0).y);
		vec4 sprite_color = color;
		float alpha  = -4.0 * sprite_color.a;
		alpha += textureLod(TEXTURE, UV + vec2(size_x * outline_size, 0), 0).a;
		alpha += textureLod(TEXTURE, UV + vec2(-size_x * outline_size, 0), 0).a;
		alpha += textureLod(TEXTURE, UV + vec2(0, -size_y * outline_size), 0).a;
		alpha += textureLod(TEXTURE, UV + vec2(0, size_y * outline_size), 0).a;
		sprite_color = mix(sprite_color, outline_color, clamp(alpha, 0.0, 1.0));
		sprite_color = vec4(sprite_color.rgb, clamp(abs(alpha) + sprite_color.a, 0.0, 1.0));
		color = sprite_color;
	}

	COLOR = color * modulate;
}