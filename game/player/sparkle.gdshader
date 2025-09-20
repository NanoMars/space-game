shader_type canvas_item;

uniform vec4 color: source_color = vec4(1.0,1.0,1.0,1.0);
uniform float alpha: hint_range(-2.0,2.0) = 0.0;         // baseline opacity
uniform float strength: hint_range(0.0,10.0) = 2.0;      // how bright the burst is
uniform float shney_disperse: hint_range(0.01,10.0) = 1.0;
uniform float shney_speed: hint_range(0.0,1000.0) = 0.5;
uniform float twist_speed: hint_range(-2.0,2.0) = 1.0;
uniform float rota_speed: hint_range(-10.0,10.0) = 1.0;
uniform float curve_ci: hint_range(0.0,2.0) = 0.3;

/* Drive from script—seconds since trigger. Tween 0 -> PI/shney_speed for a single burst. */
uniform float playhead = 0.0;

void fragment() {
    vec2 uv = (UV - 0.5) * 2.0;

    float t = clamp(playhead * shney_speed, 0.0, PI); // 0..PI
    float pulse = max(sin(t), 0.0);                   // 0->1->0

    // rotate with playhead (not TIME)
    vec2 a = vec2(cos(playhead * rota_speed), -sin(playhead * rota_speed));
    vec2 b = vec2(sin(playhead * rota_speed),  cos(playhead * rota_speed) * twist_speed);
    uv = vec2(uv.x * a.x + uv.y * a.y, uv.x * b.x + uv.y * b.y);

    // Gaussian “lobe” gated by pulse
    float sig2 = max(pulse, 1e-4);
    float r2 = dot(uv, uv);
    float gauss = exp(-r2 / (2.0 * sig2 * shney_disperse));
    float L = clamp(alpha + strength * gauss, 0.0, 1.0) * pulse;

    // your shape mask
    float ycurve_pos = pow(max(0.0, 1.0 - pow(abs(uv.x), curve_ci)), 1.0 / curve_ci);
    bool inside = (uv.y >= -ycurve_pos) && (uv.y <= ycurve_pos);

    if (inside) {
        COLOR = color;
        COLOR.a = L;
    } else {
        COLOR = vec4(0.0);
    }
}