shader_type canvas_item;

uniform float value : hint_range(0.0, 1.0);

void fragment() {
    float t = UV.x;

    // Green to red gradient
    vec3 color = mix(vec3(1.0, 0.0, 0.0),vec3(0.0, 1.0, 0.0), t);

  

    COLOR = vec4(color, 1.0);
}
