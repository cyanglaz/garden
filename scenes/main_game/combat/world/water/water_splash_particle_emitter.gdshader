shader_type canvas_item;

uniform float transparency = 0.0;
uniform vec4 color_to_transparent:source_color;

varying vec4 modulate;

void vertex() {
	modulate = COLOR;
}

void fragment() {

	vec4 base_color = COLOR;
	if (base_color.rgb == color_to_transparent.rgb) {
		base_color.a = transparency;
	} else {
	}
	COLOR = base_color;
}
