shader_type canvas_item;

uniform float normal_offset : hint_range(0, 2, .1) = 1.5;
uniform float time_influence : hint_range(0, 50) = 3;
uniform float y_div : hint_range(0, 10, .1) = 2.87;

uniform float opacity : hint_range(0.0, 1.0) = 1.0;
uniform float seed = 0.0;

uniform vec4 tint_color : source_color = vec4(1.0, 1.0, 1.0, 1.0); // ← added color control

// Random number generator based on pixel position
float rand(vec2 co) {
    return fract(sin(dot(co.xy, vec2(12.9898, 78.233)) + seed) * 43758.5453);
}

void vertex() {
    VERTEX.x += sin(VERTEX.y * y_div + round(TIME * time_influence)) * normal_offset;
    VERTEX.y += sin(VERTEX.x * y_div + round(TIME * time_influence)) * normal_offset;
}

void fragment() {
    vec4 tex = texture(TEXTURE, UV);
    float noise = rand(FRAGCOORD.xy);

    if (noise < opacity) {
        COLOR = tex * tint_color; // ← applies tint to texture color
    } else {
        COLOR = vec4(0.0, 0.0, 0.0, 0.0);
    }
}