shader_type canvas_item;

uniform vec3 color: source_color = vec3(0.5);
uniform float speed: hint_range(0.01, 10.0, 0.01) = 0.1;
uniform float density: hint_range(1.0, 10000.0, 1.0) = 100.0;
uniform float compression: hint_range(0.1, 2.0, 0.01) = 0.2;
uniform float trail_size: hint_range(5.0, 100.0, 0.1) = 50.0;
uniform float brightness: hint_range(0.1, 10.0, 0.1) = 5.0;

// tiny hash so each column gets stable randoms
float hash11(float n) {
	return fract(sin(n) * 43758.5453123);
}

void fragment() {
	vec2 uv = -UV;
	float t = TIME * speed;

	// columns
	uv.x *= density;

	// integer column id: use this ONLY for randomness, never scale it by compression
	float col = floor(uv.x);

	// per-column randoms (stable when compression changes)
	float r0 = hash11(col);
	float r1 = hash11(col + 17.123);
	float offset = r0 * 2.0 - 1.0;         // -1..1
	float fall = (r1 * 2.0 - 1.0);         // -1..1, acts like your old cos(duv.x*30)

	// apply compression only to the vertical axis
	float y = uv.y * compression;

	// vertical motion + offset, wrapped to 0..1
	float drop = fract(y + t * fall + offset);

	// trail shaping (keep your feel)
	float trail = mix(100.0, trail_size, abs(fall));
	drop = 1.0 / max(drop * trail, 1e-3);
	drop = smoothstep(0.0, 1.0, drop * drop);
	drop = sin(drop * PI) * fall * brightness;

	// keep the “column shape” across the width of a cell
	float shape = sin(fract(uv.x) * PI);
	drop *= shape * shape;

	COLOR = vec4(color * max(drop, 0.0), 1.0);
}