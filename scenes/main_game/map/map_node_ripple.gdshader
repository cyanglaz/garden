shader_type canvas_item;

// Ripple center point (0.0-1.0 UV coordinates)
uniform vec2 ripple_center = vec2(0.5, 0.5);

// Animation speed (how fast the ripples expand)
uniform float ripple_speed : hint_range(0.1, 10.0) = 2.0;

// Number of ripple rings
uniform float ripple_count : hint_range(1.0, 10.0) = 3.0;

// Ring width (controls how thick each ring is)
uniform float ring_width : hint_range(0.01, 0.5) = 0.1;

// Ripple intensity (how strong the effect is)
uniform float ripple_intensity : hint_range(0.0, 1.0) = 0.5;

// Fade out distance (how far ripples travel before fading)
uniform float fade_distance : hint_range(0.1, 2.0) = 1.0;

// Time offset (to sync multiple ripples or delay start)
uniform float time_offset : hint_range(0.0, 10.0) = 0.0;

// Ripple color tint
uniform vec4 ripple_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);

void fragment() {
	vec2 uv = UV;
	
	// Calculate distance from center
	vec2 center_offset = uv - ripple_center;
	float dist = length(center_offset);
	
	// Calculate the ripple phase based on distance and time
	float t = TIME * ripple_speed + time_offset;
	float phase = dist * ripple_count - t;
	
	// Create the ripple pattern using sine wave for smooth expanding rings
	// Use sine to create wave-like ripples that expand outward
	float wave = sin(phase * 6.28318); // 6.28318 = 2 * PI
	
	// Create distinct rings by making peaks bright and troughs dark
	// Use abs() to create double rings (both peaks and troughs become visible)
	float ring_pattern = abs(wave);
	
	// Sharpen the rings and control their width
	ring_pattern = pow(ring_pattern, 1.0 / (ring_width * 10.0 + 0.1));
	
	// Normalize to 0-1 range
	float ring = ring_pattern;
	
	// Fade out based on distance (ripples get weaker as they expand)
	float fade = 1.0 - smoothstep(0.0, fade_distance, dist);
	
	// Combine ring pattern with fade
	float ripple_alpha = ring * fade * ripple_intensity;
	
	// Sample the original texture
	vec4 tex_color = texture(TEXTURE, uv);
	
	// Apply ripple effect
	// You can either add the ripple as an overlay or multiply it
	vec3 final_color = mix(tex_color.rgb, ripple_color.rgb, ripple_alpha * ripple_color.a);
	
	COLOR = vec4(final_color, tex_color.a);
}
