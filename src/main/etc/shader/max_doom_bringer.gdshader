shader_type canvas_item;

uniform vec2 circle_center = vec2(0.5);
uniform float circle_radius = 0.1;
uniform vec4 outside_color : source_color;

void fragment() {
	float ratio = SCREEN_PIXEL_SIZE.y / SCREEN_PIXEL_SIZE.x;
	
    float dist = distance(circle_center, vec2(mix(circle_center.x, UV.x, ratio), UV.y));
	
	float uv_radius = circle_radius / 360.0;
	
	if (dist > uv_radius){
	    COLOR = outside_color;
	}
	else{
		COLOR = vec4(outside_color.rgb, 0.0);
	}
		

}
