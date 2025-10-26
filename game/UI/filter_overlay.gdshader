shader_type canvas_item;

// Put this on a full-screen ColorRect to affect everything behind it.

uniform int levels : hint_range(1,16) = 8;
uniform float threshold : hint_range(0.0,1.0) = 0.3;
uniform int pixelate : hint_range(-1,10) = 3;
uniform sampler2D dither_texture : filter_nearest;

// Palette texture (1-pixel-high strip)
uniform sampler2D palette : filter_nearest;
uniform int palette_size : hint_range(1,256) = 16;

// Important: use hint_screen_texture and disable repeat/filter
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, repeat_disable, filter_nearest;

float dither(float raw, float d, int depth) {
	float div = 1.0 / float(depth);
	for (int i = 0; i < depth; i++) {
		if (raw <= div * float(i + 1)) {
			if ((raw * float(depth)) - float(i) <= d * 0.999)
				return div * float(i);
			else
				return div * float(i + 1);
		}
	}
	return 1.0;
}

vec3 nearest_palette_color(vec3 c) {
	float min_d = 9999.0;
	vec3 best = vec3(0.0);
	for (int i = 0; i < palette_size; i++) {
		vec2 uv = vec2((float(i)+0.5)/float(palette_size), 0.5);
		vec3 p = texture(palette, uv).rgb;
		float dist = distance(p, c);
		if (dist < min_d) { min_d = dist; best = p; }
	}
	return best;
}

void fragment() {
	vec2 screen_size = vec2(textureSize(SCREEN_TEXTURE, 0)) / float(pixelate);
	vec2 sample_uv = floor(UV * screen_size) / screen_size;

	vec2 d_size = vec2(textureSize(dither_texture, 0));
	vec2 d_uv = mod(UV * screen_size, d_size) / d_size;

	vec3 col = texture(SCREEN_TEXTURE, sample_uv).rgb;
	float d_val = texture(dither_texture, d_uv).r;

	vec3 q;
	for (int i = 0; i < 3; i++)
		q[i] = dither(col[i], threshold * d_val, levels);

	COLOR.rgb = nearest_palette_color(q);
	COLOR.a = 1.0;
}