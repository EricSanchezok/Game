shader_type canvas_item;

uniform sampler2D noise_texture;
uniform float noise_speed: hint_range(0.0, 1.0) = 1.0;
uniform float noise_size: hint_range(0.0, 1.0) = 1.0;
uniform vec4 edge_color: source_color;

void fragment(){
	vec4 base_color = texture(TEXTURE, UV);
	
	vec2 noise_uv = UV;
	noise_uv.y = noise_uv.y + TIME * noise_speed;
	noise_uv.y = float(uint(noise_uv.y * 100.0) % uint(100)) / 100.0;
	vec4 noise_color = texture(noise_texture, noise_uv);
	float noise = pow(noise_color.r, 5.0) * noise_size;
	
	vec2 uv = UV;
	vec2 uv1 = clamp(uv + noise, vec2(0.0), vec2(1.0));
	vec2 uv2 = clamp(uv - noise, vec2(0.0), vec2(1.0));
	
	float tex_color_a = texture(TEXTURE, uv1).a;
	tex_color_a += texture(TEXTURE, uv2).a;
	tex_color_a = clamp(tex_color_a, 0.0, 1.0);
	
	vec4 _edge_color = edge_color;
	_edge_color.a = edge_color.a * tex_color_a;
	
	vec4 outline_color = mix(base_color, _edge_color, clamp(tex_color_a - base_color.a, 0.0, 1.0));
	COLOR = outline_color;
	
	
}