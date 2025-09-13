shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture;

uniform float angle_deg : hint_range(0.0, 360.0, 0.1) = 0.0; // direction in degrees
uniform float power_px : hint_range(0.0, 32.0, 0.1) = 7.0;    // pixels of shift magnitude
uniform float green_ratio : hint_range(0.0, 1.0, 0.01) = 0.0; // 0 = no green shift

uniform float height : hint_range(0.0, 1.0, 0.1) = 0.7;
uniform float width  : hint_range(0.0, 1.0, 0.1) = 0.5;

uniform float fade = 0.7;

void fragment() {
    // vignette alpha
    float shrink_width = 2.0 / max(width, 0.0001);
    float shrink_height = 2.0 / max(height, 0.0001);
    float dist = distance(vec2(UV.x * shrink_width, UV.y * shrink_height),
                          vec2(0.5 * shrink_width, 0.5 * shrink_height));

    // direction from angle
    vec2 dir = vec2(cos(radians(angle_deg)), sin(radians(angle_deg)));

    // per-channel offsets in pixels -> UV using SCREEN_PIXEL_SIZE
    vec2 r_off =  dir * power_px;
    vec2 g_off =  dir * power_px * green_ratio;
    vec2 b_off = -dir * power_px;

    float r = texture(SCREEN_TEXTURE, SCREEN_UV + SCREEN_PIXEL_SIZE * r_off, 0.0).r;
    float g = texture(SCREEN_TEXTURE, SCREEN_UV + SCREEN_PIXEL_SIZE * g_off, 0.0).g;
    float b = texture(SCREEN_TEXTURE, SCREEN_UV + SCREEN_PIXEL_SIZE * b_off, 0.0).b;

    COLOR = vec4(r, g, b, dist - fade);
}