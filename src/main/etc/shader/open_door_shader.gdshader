shader_type canvas_item;

uniform float ratio : hint_range(0.0, 1.0) = 0.0;

void fragment() {
    float centerX = 0.5; // 纹理中心的 X 坐标
    float width = ratio * 0.5; // 应显示为不透明的中心矩形的一半宽度

    // 计算当前像素是否在中间矩形内
    bool inCenterRect = abs(UV.x - centerX) < width;
    // 获取纹理的原始颜色
    vec4 origColor = texture(TEXTURE, UV);

    // 如果在中间矩形内，alpha设为1，否则设为0
    origColor.a = inCenterRect ? 0.0 : 1.0;

    // 输出颜色
    COLOR = origColor;
}

