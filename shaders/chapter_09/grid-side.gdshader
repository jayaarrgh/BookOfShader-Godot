shader_type canvas_item;

// Author @patriciogv ( patriciogonzalezvivo.com ) - 2015

const float TWO_PI = 6.28318530717958647693;
const float PHI = 1.618033988749894848204586834;

vec2 tile(vec2 _st, float _zoom){
    _st *= _zoom;
    return fract(_st);
}

float X(vec2 _st, float _width){
    float pct0 = smoothstep(_st.x-_width,_st.x,_st.y);
    pct0 *= 1.-smoothstep(_st.x,_st.x+_width,_st.y);

    float pct1 = smoothstep(_st.x-_width,_st.x,1.0-_st.y);
    pct1 *= 1.-smoothstep(_st.x,_st.x+_width,1.0-_st.y);

    return pct0+pct1;
}

void fragment(){
    vec2 st = FRAGCOORD.xy/(1.0/SCREEN_PIXEL_SIZE).xy;
    st = tile(st,10.0);

    vec3 color = vec3(X(st,0.03));

    COLOR = vec4(color,1.0);
}
