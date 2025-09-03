shader_type canvas_item;

uniform float outerRadius : hint_range(-5.0, 5.0) = 1.0;
uniform float fadeDistance : hint_range(0.0, 5.0) = 1.0;
uniform float MainAlpha   : hint_range(0.0, 1.0) = 1.0;

// color picker
uniform vec4 effect_color : source_color = vec4(0.6, 0.0, 0.0, 0.5);

void fragment() {
    // center UV [-1,1]
    vec2 p = (UV - 0.5) * 2.0;
    float dist = length(p);

    // fade starts at outerRadius and ends at outerRadius+fadeDistance
    float v = smoothstep(outerRadius, outerRadius + fadeDistance, dist);

    // rgb from color, alpha blended
    COLOR = vec4(effect_color.rgb, effect_color.a * v * MainAlpha);
}