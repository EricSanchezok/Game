shader_type canvas_item;

uniform float radius : hint_range(0.0, 1.0) = 0.5; // 控制透明渐变的半径
uniform float fade_dis : hint_range(0.0, 0.3) = 0.1;

void fragment() {
    // 使用UV坐标，其中(0.5, 0.5)是纹理的中心点
    vec2 center = vec2(0.5, 0.5);
    float dist = distance(UV, center);

    // 计算透明度
    float alpha = smoothstep(radius, radius + fade_dis, dist); // 逐渐变为完全透明

    // 获取当前片段的颜色
    vec4 tex_color = texture(TEXTURE, UV);

    // 应用透明度
    COLOR = vec4(tex_color.rgb, tex_color.a * (1.0 - alpha));
}
