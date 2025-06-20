shader_type canvas_item;

uniform float progress : hint_range(0.0, 1.0) = 0.0;
uniform bool color_change = false;
uniform vec4 color: source_color;

void fragment() {
	
	vec2 stretch_uv = UV;
	// Calculate distance from vertical center (0.5)
	float dist_from_center_y = abs(UV.y - 0.5);
	float dist_from_center_x = abs(UV.x - 0.5);

	// Create a parabolic stretch factor that's strongest in the middle
	float stretch_amount_x = (1.0 - dist_from_center_y * 2.0) * progress * 0.5;

	// Apply horizontal stretch in both directions from center
	float center_x = 0.5;
	if (UV.x < center_x) {
		stretch_uv.x = UV.x + (dist_from_center_x * stretch_amount_x);
	} else {
		stretch_uv.x = UV.x - (dist_from_center_x * stretch_amount_x); 
	}
	
	//float stretch_amount_y = (1.0 - dist_from_center_x * 2.0) * progress;
	float stretch_amount_y = progress;
	
	float center_y = 0.5;
	if (UV.y < center_y) {
		stretch_uv.y = UV.y - (dist_from_center_y * stretch_amount_y);
	} else {
		stretch_uv.y = UV.y + (dist_from_center_y * stretch_amount_y); 
	}

	// Get the stretched texture
	vec4 tex = texture(TEXTURE, stretch_uv);

	//// Fade out alpha over time
	tex.a *= 1.0 - progress * progress;
	
	if (color_change) {
		tex.rgb = mix(tex.rgb, color.rgb, progress);
	}

	COLOR = tex;
}
