shader_type spatial;
render_mode cull_back, depth_draw_opaque, specular_schlick_ggx;
varying vec3 v_world_pos;

// TEXTURES
uniform sampler2D albedo_tex : source_color;
uniform sampler2D normal_tex : hint_normal; // tangent-space normal map
uniform sampler2D height_tex;               // height in R channel (0..1)

// CONTROLS
uniform float tile_scale   = 0.10;  // world meters -> UV tiling density (smaller = more tiles)
uniform float scroll_speed = 1.5;   // meters/sec along +Z (world)
uniform float height_scale = 0.05;  // visual depth in meters (keep small)
uniform int   layers_min   = 12;
uniform int   layers_max   = 32;
uniform bool  binary_refine = true;
uniform int   refine_steps  = 4;

uniform float roughness_val = 0.8;
uniform float metallic_val  = 0.0;

// ---------- Helpers ----------
vec3 unpack_normal(vec3 n){ return normalize(n * 2.0 - 1.0); }

// Build a TBN basis from NORMAL only (no mesh tangents needed)
mat3 tbn_from_normal(vec3 n){
    n = normalize(n);
    // pick an "up" that isn't parallel to n
    vec3 up = abs(n.y) < 0.999 ? vec3(0.0,1.0,0.0) : vec3(1.0,0.0,0.0);
    vec3 t = normalize(cross(up, n));
    vec3 b = cross(n, t);
    return mat3(t, b, n);
}

// POM in tangent space
vec2 pom(vec2 uv, vec3 view_dir_tan){
    float ndotv = abs(view_dir_tan.z);
    float layers_f = mix(float(layers_max), float(layers_min), clamp(ndotv, 0.0, 1.0));
    int layers = int(layers_f);

    float layer_depth = 1.0 / float(layers);
    float current_depth = 0.0;

    vec2 delta_uv = (view_dir_tan.xy / max(view_dir_tan.z, 0.001)) * height_scale * (1.0 / float(layers));

    vec2 uv_curr = uv;
    float h = texture(height_tex, uv_curr).r;

    // linear march
    while (current_depth < h && layers > 0){
        uv_curr -= delta_uv;
        current_depth += layer_depth;
        h = texture(height_tex, uv_curr).r;
        layers--;
    }

    // interpolate between last two steps
    vec2 uv_prev = uv_curr + delta_uv;
    float d_after = h - current_depth;
    float h_before = texture(height_tex, uv_prev).r - (current_depth - layer_depth);
    float w = d_after / max(d_after - h_before, 1e-4);
    vec2 uv_lin = mix(uv_curr, uv_prev, clamp(w, 0.0, 1.0));

    if (!binary_refine) return uv_lin;

    // short binary refine
    vec2 a = uv_prev, b = uv_curr;
    float depth_a = h_before, depth_b = d_after;
    for (int i=0;i<refine_steps;i++){
        vec2 m = (a + b) * 0.5;
        float hm = texture(height_tex, m).r;
        // param t between prev and curr for depth estimate
        float t = length(m - uv_prev) / max(length(uv_curr - uv_prev), 1e-4);
        float dm = (current_depth - layer_depth) + t * layer_depth;
        float diff = hm - dm;
        if (diff > 0.0) { a = m; depth_a = diff; }
        else            { b = m; depth_b = diff; }
    }
    return (a + b) * 0.5;
}

void vertex(){
    vec4 wp = (MODEL_MATRIX * vec4(VERTEX, 1.0));
    v_world_pos = wp.xyz;
}

void fragment(){
    // world-space UVs so it doesn't swim with camera
    vec2 uv_ws = v_world_pos.xz * tile_scale;
    uv_ws.y += TIME * scroll_speed; // infinite scroll along +Z
    uv_ws = fract(uv_ws);           // keep in 0..1 range for tiling textures

    // build TBN from the current surface normal only
    vec3 n_geom = normalize(NORMAL);
    mat3 TBN = tbn_from_normal(n_geom);

    // view dir in tangent space
    vec3 V_world = normalize(-VIEW);
    vec3 V_tan = normalize(transpose(TBN) * V_world);

    // parallax-occluded UV
    vec2 uv_pom = pom(uv_ws, V_tan);

    // sample textures
    vec4 albedo_s = texture(albedo_tex, uv_pom);
    vec3 n_tan     = unpack_normal(texture(normal_tex, uv_pom).rgb);
    vec3 n_world   = normalize(TBN * n_tan);

    ALBEDO    = albedo_s.rgb;
    NORMAL    = n_world;
    ROUGHNESS = roughness_val;
    METALLIC  = metallic_val;
}