shader_type canvas_item;

uniform vec4 color: source_color = vec4(1.0,1.0,1.0,1.0);
uniform float alpha: hint_range(-2.0,2.0) = -.5;
uniform float shney_disperse: hint_range(0.01,10.0) = 1.0;
uniform float shney_speed: hint_range(0.0,1000.0) = 0.5;
uniform float twist_speed: hint_range(-2.0,2.0) = 1.0;
uniform float rota_speed: hint_range(-10.0,10.0) = 1.0;
uniform float curve_ci: hint_range(0.0,2.0) = 0.3;

/*
Drive this from script. Seconds since trigger.
Tween it 0 -> PI/shney_speed for a single non-looping burst.
*/
uniform float playhead = 0.0;

void fragment() {
    vec2 uv = (UV - 0.5) * 2.0;

    float t = clamp(playhead * shney_speed, 0.0, PI); // 0..PI one-shot window
    float pulse = max(sin(t), 0.0);                   // 0 -> 1 -> 0 envelope

    // rotate + twist over playhead time, not TIME
    vec2 a = vec2(cos(playhead * rota_speed), -sin(playhead * rota_speed));
    vec2 b = vec2(sin(playhead * rota_speed), cos(playhead * rota_speed) * twist_speed);
    uv = vec2(uv.x * a.x + uv.y * a.y, uv.x * b.x + uv.y * b.y);

    // avoid div by zero at start/end but keep alpha gated by pulse
    float sig2 = max(pulse, 1e-4);
    float L = (1.0 / (2.0 * PI * sig2)) * exp(-((uv.x * uv.x + uv.y * uv.y) / (2.0 * sig2 * shney_disperse))) + alpha;
    L *= pulse; // hard gate by the envelope so it’s fully invisible before/after

    if (uv.x > 0.0 && uv.y > 0.0) {
        if (uv.y <= pow(-(pow(uv.x, curve_ci) - 1.0), 1.0 / curve_ci)) {
            COLOR = color;
            COLOR.a = L;
        } else COLOR.a = 0.0;
    } else if (uv.x > 0.0 && uv.y < 0.0) {
        if (uv.y >= -pow(-(pow(uv.x, curve_ci) - 1.0), 1.0 / curve_ci)) {
            COLOR = color;
            COLOR.a = L;
        } else COLOR.a = 0.0;
    } else if (uv.x < 0.0 && uv.y > 0.0) {
        if (uv.y <= pow(-(pow(-uv.x, curve_ci) - 1.0), 1.0 / curve_ci)) {
            COLOR = color;
            COLOR.a = L;
        } else COLOR.a = 0.0;
    } else if (uv.x < 0.0 && uv.y < 0.0) {
        if (uv.y >= -pow(-(pow(-uv.x, curve_ci) - 1.0), 1.0 / curve_ci)) {
            COLOR = color;
            COLOR.a = L;
        } else COLOR.a = 0.0;
    }
}