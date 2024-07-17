shader_type canvas_item;

uniform sampler2D noise;
uniform float angle: hint_range(-5.0, 5.0) = 0.0;
void fragment() {
	vec2 dist = vec2(.5) - UV;
	float s = sin(angle);
	float c = cos(angle);
	mat2 m = mat2(vec2(c, -s), vec2(s, c));
	dist *= m;
	vec4 coord = texture(noise, dist);
	coord.x -= .5;
	coord.y -= .5;
	vec4 lens_color = texture(TEXTURE, UV + coord.xy);
    COLOR = lens_color;
}