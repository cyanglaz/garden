shader_type canvas_item;

uniform vec4 core_color : source_color = vec4(1.0, 1.0, 0.8, 1.0); // White-ish center
uniform vec4 edge_color : source_color = vec4(1.0, 0.4, 0.0, 1.0); // Orange edge
uniform float scroll_speed = 3.0;
uniform sampler2D noise_texture : repeat_enable; 

void fragment() {
    // 1. Scroll noise along the LENGTH of the beam (UV.x)
    // We scroll UV.x to make the fire move up/down the beam.
    vec2 scroll_uv = UV + vec2(TIME * scroll_speed, 0.0);
    float noise = texture(noise_texture, scroll_uv).r;
    
    // 2. Create the "Beam" gradient ACROSS the width (UV.y)
    // UV.y goes from 0 (Edge) to 1 (Other Edge). 0.5 is Center.
    float dist_from_center = abs(UV.y - 0.5) * 2.0;
    
    // Invert it: 1.0 at center, 0.0 at edges
    float beam_mask = 1.0 - dist_from_center;
    
    // 3. Erode the beam edges with noise
    // smoothstep creates a soft cut-off based on the noise value
    float alpha = beam_mask * smoothstep(0.2, 0.8, noise);
    
    // 4. Mix colors (Hot center, cooler edges)
    // We multiply beam_mask * noise so the "hot" part wiggles with the noise
    vec4 final_color = mix(edge_color, core_color, beam_mask * noise);
    
    COLOR = vec4(final_color.rgb, alpha * final_color.a);
}