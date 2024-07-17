shader_type canvas_item;
//render_mode unshaded; // optional
uniform float alpha : hint_range(0.0, 1.0) = 1.0;
// Noise texture
uniform sampler2D noise_texture: repeat_enable, filter_nearest;
// Fog density
uniform float density: hint_range(0.0, 1.0) = 0.25;
// Fog speed
uniform vec2 speed = vec2(0.02, 0.01);
uniform float scale: hint_range(2.0, 4.0) = 2.0;


// Called for every pixel the material is visible on
void fragment() {
	// Make the fog slowly move
	vec2 uv = UV + speed * TIME;
	// Sample the noise texture
	float noise = texture(noise_texture, uv).r;
	// Convert the noise from the (0.0, 1.0) range to the (-1.0, 1.0) range
	// and clamp it between 0.0 and 1.0 again
	float fog = clamp(noise * scale - 1.0, 0.0, 1.0);
	// Apply the fog effect
	vec4 mixed_color = COLOR;
	mixed_color.a *= fog * density;
	
	COLOR = vec4(mixed_color.rgb, mixed_color.a * alpha);
	
	
}
