shader_type canvas_item;

uniform bool flash = false;
uniform vec4 flash_color:source_color;

void fragment() {
	vec4 previous_color = texture(TEXTURE, UV);
	vec4 new_color = flash_color;
	new_color.a = previous_color.a;
	if (flash) {
		COLOR = new_color;
	}
}