shader_type spatial;

render_mode cull_back, depth_draw_opaque;

uniform sampler3D HEIGHTMAP;
uniform float amplitude = 2.0;
uniform float scroll_speed = 0.15;
uniform vec2 world_scale = vec2(0.04, 0.04); // scales world XZ -> noise coords
uniform vec3 scroll_dir = vec3(0.0, 0.0, 1.0);
uniform vec3 tint = vec3(0.24, 0.55, 0.33);
uniform float normal_eps = 0.5; // small step in local X/Z for normal calc

// Map a WORLD position (x,z) into 3D noise UVW and sample height (-1..1)
float sample_height_world(vec3 world_pos) {
    vec3 uvw = vec3(world_pos.x * world_scale.x,
                    world_pos.z * world_scale.y,
                    0.0);
    // time-based scroll for "moving" terrain
    uvw.z += TIME * scroll_speed;
    uvw += scroll_dir * TIME * scroll_speed;
    float n = texture(HEIGHTMAP, uvw).r; // 0..1
    return n * 2.0 - 1.0; // -1..1
}

void vertex() {
    // Original local-space vertex
    vec3 lp = VERTEX;

    // Compute heights at current, +X, +Z using WORLD positions for noise
    vec3 world_p  = (MODEL_MATRIX * vec4(lp, 1.0)).xyz;
    vec3 world_px = (MODEL_MATRIX * vec4(lp + vec3(normal_eps, 0.0, 0.0), 1.0)).xyz;
    vec3 world_pz = (MODEL_MATRIX * vec4(lp + vec3(0.0, 0.0, normal_eps), 1.0)).xyz;

    float h   = sample_height_world(world_p)  * amplitude;
    float hx  = sample_height_world(world_px) * amplitude;
    float hz  = sample_height_world(world_pz) * amplitude;

    // Displace current vertex in local Y
    VERTEX.y += h;

    // Build three displaced points in LOCAL space (so the resulting normal is local)
    vec3 p  = vec3(lp.x,               lp.y + h,  lp.z);
    vec3 px = vec3(lp.x + normal_eps,  lp.y + hx, lp.z);
    vec3 pz = vec3(lp.x,               lp.y + hz, lp.z + normal_eps);

    // Compute local-space normal via cross product
    vec3 nx = normalize(cross(pz - p, px - p));
    NORMAL = nx;
}

void fragment() {
    ALBEDO = tint;
    ROUGHNESS = 0.9;
    METALLIC = 0.0;
}