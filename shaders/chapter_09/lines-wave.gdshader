shader_type canvas_item;

// Author @patriciogv - 2015 - patricio.io

vec2 wave(vec2 st, float freq) {
	st.y += cos(st.x*freq);
	return st;
}

vec2 zigzag(vec2 st, float freq) {
	st.y += mix(abs(floor(sin(st.x*3.1415))),abs(floor(sin((st.x+1.)*3.1415))),fract(st.x*freq));
	return st;
}

float line(vec2 st, float width) {
    return step(width,1.0-smoothstep(.0,1.,abs(sin(st.y*PI))));
}

void fragment(){
    vec2 st = FRAGCOORD.xy/(1.0/SCREEN_PIXEL_SIZE).xy;
    st.x *= (1.0/SCREEN_PIXEL_SIZE).x/(1.0/SCREEN_PIXEL_SIZE).y;

   	st *= 10.;
   	st = wave(st, 3.);
    vec3 color = vec3(line(st,.5));
    COLOR = vec4(color, 1.0);
}
