shader_type canvas_item;

const float PI = 3.141592653589793;

uniform vec4 colorA : source_color = vec4(0.149,0.141,0.912, 1.0);
uniform vec4 colorB : source_color = vec4(1.000,0.833,0.224, 1.0);

float plot (vec2 st, float pct){
  return  smoothstep( pct-0.01, pct, st.y) -
          smoothstep( pct, pct+0.01, st.y);
}

void fragment() {
    vec2 st = FRAGCOORD.xy/(1.0/SCREEN_PIXEL_SIZE).xy;
    vec3 color = vec3(0.0);

    vec3 pct = vec3(st.x);

    // pct.r = smoothstep(0.0,1.0, st.x);
    // pct.g = sin(st.x*PI);
    // pct.b = pow(st.x,0.5);

    color = mix(colorA.rgb, colorB.rgb, pct);

    // Plot transition lines for each channel
    color = mix(color,vec3(1.0,0.0,0.0),plot(st,pct.r));
    color = mix(color,vec3(0.0,1.0,0.0),plot(st,pct.g));
    color = mix(color,vec3(0.0,0.0,1.0),plot(st,pct.b));

    COLOR = vec4(color, 1.0);
}
