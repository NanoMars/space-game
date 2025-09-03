shader_type canvas_item;

// ----- DITHER SETTINGS -----
const float lookupSize = 64.0;
const float errorCarry = 0.3;
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

// Sample grayscale from the screen
float getGrayscale(vec2 coords, vec2 iResolution){
    vec2 uv = coords / iResolution.xy;
    uv.y = 1.0 - uv.y; // flip if needed
    vec3 c = texture(screen_texture, uv).rgb;
    return dot(c, vec3(0.2126, 0.7152, 0.0722));
}

void fragment() {
    vec2 iResolution = 1.0 / SCREEN_PIXEL_SIZE;

    // Floyd–Steinberg-ish 1D error carry horizontally + vertically
    float xError = 0.0;
    for (float xLook = 0.0; xLook < lookupSize; xLook++) {
        float g = getGrayscale(FRAGCOORD.xy + vec2(-lookupSize + xLook, 0.0), iResolution);
        g += xError;
        float bit = g >= 0.5 ? 1.0 : 0.0;
        xError = (g - bit) * errorCarry;
    }

    float yError = 0.0;
    for (float yLook = 0.0; yLook < lookupSize; yLook++) {
        float g = getGrayscale(FRAGCOORD.xy + vec2(0.0, -lookupSize + yLook), iResolution);
        g += yError;
        float bit = g >= 0.5 ? 1.0 : 0.0;
        yError = (g - bit) * errorCarry;
    }

    float g0 = getGrayscale(FRAGCOORD.xy, iResolution) + 0.5 * (xError + yError);
    float bit = g0 >= 0.5 ? 1.0 : 0.0;
    COLOR = vec4(bit, bit, bit, 1.0);
}