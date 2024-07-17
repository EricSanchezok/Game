shader_type canvas_item;


uniform vec4 line_color : source_color = vec4(1.0, 1.0, 1.0, 0.0);
uniform float line_width : hint_range(0.0, 10.0, 0.1) = 1.0;

const vec2 OFFSET[8] = {
	vec2(1.0, 0.0),
	vec2(1.0, 1.0),
	vec2(0.0, 1.0),
	vec2(-1.0, 1.0),
	vec2(-1.0, 0.0),
	vec2(-1.0, -1.0),
	vec2(0.0, -1.0),
	vec2(1.0, -1.0)
};


void fragment() {
	vec2 size = TEXTURE_PIXEL_SIZE * line_width;
	float outline = 0.0;

	for (int i = 0; i < OFFSET.length(); i++) {
		outline += texture(TEXTURE, UV + OFFSET[i] * size).a;
	}

	outline = min(outline, 1.0);

	vec4 color = texture(TEXTURE, UV);
	COLOR = mix(color, line_color, outline - color.a);

}