shader_type canvas_item;

uniform vec4 outline_color:source_color;
uniform int outline_size = 0;
uniform vec4 blend_color:source_color = vec4(1, 1, 1, 1);
uniform float blend_strength = 0.0;
uniform bool inner_outline = false;
uniform vec4 inner_outline_color:source_color = vec4(1, 1, 1, 1);

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
	alpha += textureLod(TEXTURE, UV + vec2(size_x * float(outline_size), 0), 0).a;
	alpha += textureLod(TEXTURE, UV + vec2(-size_x * float(outline_size), 0), 0).a;
	alpha += textureLod(TEXTURE, UV + vec2(0, -size_y * float(outline_size)), 0).a;
	alpha += textureLod(TEXTURE, UV + vec2(0, size_y * float(outline_size)), 0).a;
	sprite_color = mix(sprite_color, outline_color, clamp(alpha, 0.0, 1.0));
	sprite_color = vec4(sprite_color.rgb, clamp(abs(alpha) + sprite_color.a, 0.0, 1.0));

	// Replace the outer-most opaque pixels of the source texture with
	// `inner_outline_color`. A pixel is "outer-most" when it is opaque and
	// either (a) has at least one transparent 8-neighbour (orthogonal or
	// diagonal) or (b) sits on the texture's own border (so its neighbour
	// would be outside the texture).
	if (inner_outline) {
		vec4 src_color = texture(TEXTURE, UV);
		if (src_color.a > 0.0) {
			bool on_edge = false;
			for (int dy = -1; dy <= 1; dy++) {
				for (int dx = -1; dx <= 1; dx++) {
					if (dx == 0 && dy == 0) continue;
					vec2 n_uv = UV + vec2(float(dx) * size_x, float(dy) * size_y);
					float n_alpha = (n_uv.x < 0.0 || n_uv.x > 1.0 || n_uv.y < 0.0 || n_uv.y > 1.0)
						? 0.0
						: textureLod(TEXTURE, n_uv, 0).a;
					if (n_alpha <= 0.0) {
						on_edge = true;
					}
				}
			}
			if (on_edge) {
				sprite_color = vec4(inner_outline_color.rgb, src_color.a * inner_outline_color.a);
			}
		}
	}

	base_color = sprite_color;

	if (base_color.a > 0.0) {
    	COLOR = mix(base_color, blend_color, blend_strength) * modulate;
	} else {
		COLOR = base_color * modulate;
	}
}
