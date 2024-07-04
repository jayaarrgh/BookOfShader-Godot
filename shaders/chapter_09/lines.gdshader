shader_type canvas_item;

// Author @patriciogv - 2015 - patricio.io

mat2 rotate2d(float angle){
    return mat2(vec2(cos(angle),-sin(angle)),
                vec2(sin(angle),cos(angle)));
}

float stripes(vec2 st){
    st = rotate2d( PI*-0.25 ) * st*10.;
    return step(.5,1.0-smoothstep(.3,1.,abs(sin(st.x*PI))));
}

void fragment(){
    vec2 st = FRAGCOORD.xy/(1.0/SCREEN_PIXEL_SIZE).xy;
    st.x *= (1.0/SCREEN_PIXEL_SIZE).x/(1.0/SCREEN_PIXEL_SIZE).y;

    vec3 color = vec3(stripes(st));
    COLOR = vec4(color, 1.0);
}
