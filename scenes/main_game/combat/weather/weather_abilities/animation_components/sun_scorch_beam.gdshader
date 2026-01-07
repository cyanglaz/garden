shader_type canvas_item;

// Colors
uniform vec4 core_color : source_color = vec4(1.0, 1.0, 1.0, 1.0); // Inside color
uniform vec4 edge_color : source_color = vec4(1.0, 0.5, 0.0, 1.0); // Outside color
uniform float beam_hardness : hint_range(0.0, 1.0) = 0.5; // Sharpness of the core

void fragment() {
    // UV.y represents the WIDTH (thickness) of the line in standard Line2D
    // 0.0 = Top Edge, 1.0 = Bottom Edge, 0.5 = Center
    
    // 1. Calculate distance from the vertical center of the texture
    float dist_from_center = abs(UV.y - 0.5) * 2.0;
    
    // 2. Generate the Gradient Mask
    // High beam_hardness makes the core tighter
    float mask = pow(dist_from_center, beam_hardness * 4.0);
    
    // 3. Mix Colors
    vec4 final_color = mix(core_color, edge_color, mask);
    
    // 4. Fade Alpha at the very edges to prevent jagged aliasing
    float alpha = 1.0 - smoothstep(0.8, 1.0, dist_from_center);
    
    COLOR = vec4(final_color.rgb, final_color.a * alpha);
}