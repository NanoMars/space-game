shader_type canvas_item;

uniform float opacity : hint_range(0.0, 1.0) = 0.5;
uniform float seed = 0.0; // shuffle the pattern
uniform vec4 dissolve_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);

// Random generator
float rand(vec2 co){
    return fract(sin(dot(co.xy, vec2(12.9898,78.233)) + seed) * 43758.5453);
}

void fragment(){
    vec4 tex = texture(TEXTURE, UV);
    float noise = rand(FRAGCOORD.xy);

    if(noise < opacity){
        // Multiply texture by dissolve_color
        COLOR = tex * dissolve_color;
    } else {
        COLOR = vec4(0.0, 0.0, 0.0, 0.0);
    }
}