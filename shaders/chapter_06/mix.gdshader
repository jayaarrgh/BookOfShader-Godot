shader_type canvas_item;

uniform vec4 colorA : source_color = vec4(0.149,0.141,0.912,1.0);
uniform vec4 colorB : source_color = vec4(1.000,0.833,0.224,1.0);

void fragment() {
    vec4 color = vec4(0.0);

    float pct = abs(sin(TIME));

    // Mix uses pct (a value from 0-1) to
    // mix the two colors
    COLOR = mix(colorA, colorB, pct);
}
