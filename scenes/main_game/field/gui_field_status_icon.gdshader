shader_type canvas_item;

uniform vec4 blend_color:source_color = vec4(1, 1, 1, 1);
uniform float blend_strength = 0.0;

varying vec4 modulate;

void vertex() {
	modulate = COLOR;
}

void fragment() {

	vec4 base_color = COLOR;
	
	if (base_color.a > 0.0) {
    	COLOR = mix(base_color, blend_color, blend_strength) * modulate;
	}

}
