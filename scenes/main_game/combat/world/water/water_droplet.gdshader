shader_type canvas_item;

uniform float transparency = 0.0;
uniform vec4 color_to_transparent:source_color;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture;


varying vec4 modulate;

void vertex() {
	modulate = COLOR;
}

void fragment() {

	vec4 color = texture(SCREEN_TEXTURE, SCREEN_UV);
	if (COLOR.a > 0.0 && COLOR.rgb == color_to_transparent.rgb) {
		color = mix(color, COLOR, 0.6);
		color = mix(vec4(0.5), color, 1.4);
	} else {
		color = COLOR;
	}
	//vec4 base_color = COLOR;
	//if (base_color.rgb == color_to_transparent.rgb) {
		//base_color.a = transparency;
	//} else {
	//}
	COLOR = color;
}
