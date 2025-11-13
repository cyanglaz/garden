shader_type canvas_item;

//
// Shader: Per-block animated horizontal shift, discarding empty blocks,
// using per-block animated noise for varying phase/amount.
//
// Configurable: min shift, max shift, block size, per-block delay, cycle duration, noise scale, speed, per-block seed offset.

uniform int shift_min : hint_range(-256,256) = -1;
uniform int shift_max : hint_range(-256,256) = 1;
uniform int shift_per_block : hint_range(-32,32) = 0;
uniform int offset : hint_range(-256,256) = 0; // base scanline offset
uniform int lines_per_block : hint_range(1,256) = 2;
uniform float block_delay_time : hint_range(0,2) = 0.05;
uniform float cycle_duration : hint_range(0.05,5.0) = 1.5;

// ROW RANGE FOR SHIFTING ANIMATION
uniform int shifting_row_min : hint_range(-1000,1000) = 5; // minimum row index to include in shifting (use -1000 to disable)
uniform int shifting_row_max : hint_range(-1000,1000) = 1000; // maximum row index to include in shifting (use 1000 to disable)

// NOISE SETTINGS
uniform float noise_scale : hint_range(0.01,2.0) = 0.3; // noise period; higher is smoother across blocks
uniform float noise_speed : hint_range(0.01,3.0) = 1.0; // cycles per second
uniform float block_seed_offset : hint_range(0,20) = 7.47;

// WATER REFLECTION
uniform vec4 water_reflection_color : source_color = vec4(0.5, 0.7, 0.9, 0.3); // water tint color (default: light blue)
uniform float water_blend_amount : hint_range(0.0, 1.0) = 0.4; // how much to blend the water color


// Simple hash-based noise (does not require imported simplex)
float hash(float n) { return fract(sin(n) * 43758.5453); }
float noise1d(float x) {
    float i = floor(x);
    float f = fract(x);
    float u = f * f * (3.0 - 2.0 * f);
    return mix(hash(i), hash(i+1.0), u);
}

void fragment() {
    ivec2 tex_size = textureSize(TEXTURE, 0);
    if (tex_size.x < 1 || tex_size.y < 1) {
        discard;
    }

    int scan_y = int(floor(UV.y * float(tex_size.y)));
    int block_idx = (scan_y - offset) / max(lines_per_block, 1);

    float block_shift_min = float(shift_min) + float(block_idx * shift_per_block);
    float block_shift_max = float(shift_max) + float(block_idx * shift_per_block);

    int block_y = block_idx * lines_per_block + offset;
    int block_y_end = min(block_y + lines_per_block, tex_size.y);

    bool is_block_empty = true;
    for (int y = block_y; y < block_y_end; y++) {
        if (y < 0 || y >= tex_size.y) continue;
        for (int x = 0; x < tex_size.x; x++) {
            vec2 check_uv = vec2(
                (float(x) + 0.5) / float(tex_size.x),
                (float(y) + 0.5) / float(tex_size.y)
            );
            if (texture(TEXTURE, check_uv).a > 0.001) {
                is_block_empty = false;
                break;
            }
        }
        if (!is_block_empty) break;
    }
    if (is_block_empty) {
        discard;
    }

    // Check if this row should participate in shifting animation
    bool should_shift = (scan_y >= shifting_row_min && scan_y <= shifting_row_max);
    
    vec2 shifted_uv;
    if (should_shift) {
        // --- ANIMATION SECTION WITH NOISE ---
        // Per-block time delay (optional, still possible)
        float t = TIME * noise_speed - float(block_idx) * block_delay_time;

        // Per-block seed (so noise differs per block)
        float phase_offset = block_seed_offset * float(block_idx);

        // Plug in our block index, time, and scale into noise
        float noise_input = float(block_idx) * noise_scale + t + phase_offset;

        // Noise returns 0-1
        float nval = noise1d(noise_input);

        // Animate: let phase go from 0->1, back and forth, using per-block noise
        // That is, have each block loop in a noisy, but looping, manner, and animate the shift
        // We'll use noise(time + block_index) to vary where in the loop each block is

        // Or use the noise value directly as our interpolation
        float animated_shift = mix(block_shift_min, block_shift_max, nval);

        // Perform horizontal shift for this block
        int x_pixel = int(floor(UV.x * float(tex_size.x)));
        int new_x = int(round(float(x_pixel) - animated_shift));
        new_x = (new_x + tex_size.x) % tex_size.x;
        shifted_uv = vec2(
            (float(new_x) + 0.5) / float(tex_size.x),
            (float(scan_y) + 0.5) / float(tex_size.y)
        );
    } else {
        // No shifting - use original UV coordinates
        shifted_uv = UV;
    }
    vec4 tex_color = texture(TEXTURE, shifted_uv);
    
    // Blend water reflection color with the sprite
    // Use overlay-like blending for water reflection effect
    vec3 blended_color = mix(tex_color.rgb, water_reflection_color.rgb * tex_color.rgb, water_blend_amount * water_reflection_color.a);
    COLOR = vec4(blended_color, tex_color.a);
}






