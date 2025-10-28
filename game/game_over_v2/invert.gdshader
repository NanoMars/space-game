shader_type canvas_item;
render_mode unshaded;

// required since Godot 4.3
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

uniform float strength : hint_range(0.0, 1.0) = 1.0;
uniform bool use_sprite_alpha = true;

void fragment() {
    vec4 behind = texture(SCREEN_TEXTURE, SCREEN_UV);
    vec3 inverted = 1.0 - behind.rgb;

    float mask = 1.0;

	mask = texture(TEXTURE, UV).a;
    vec3 mixed_rgb = mix(behind.rgb, inverted, strength * mask);
    COLOR = vec4(mixed_rgb, mask);
}