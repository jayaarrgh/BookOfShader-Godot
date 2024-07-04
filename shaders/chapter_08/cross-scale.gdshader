shader_type canvas_item;

// Author @patriciogv ( patriciogonzalezvivo.com ) - 2015

mat2 scale(vec2 _scale){
    return mat2(vec2(_scale.x,0.0),
                vec2(0.0,_scale.y));
}

float box(in vec2 _st, in vec2 _size){
    _size = vec2(0.5) - _size*0.5;
    vec2 uv = smoothstep(_size,
                        _size+vec2(0.001),
                        _st);
    uv *= smoothstep(_size,
                    _size+vec2(0.001),
                    vec2(1.0)-_st);
    return uv.x*uv.y;
}

float makeCross(in vec2 _st, float _size){
    return  box(_st, vec2(_size,_size/4.)) +
            box(_st, vec2(_size/4.,_size));
}

void fragment(){
    vec2 st = FRAGCOORD.xy/(1.0/SCREEN_PIXEL_SIZE).xy;
    vec3 color = vec3(0.0);

    st -= vec2(0.5);
    st = scale( vec2(sin(TIME)+1.0) ) * st;
    st += vec2(0.5);

    // Show the coordinates of the space on the background
    // color = vec3(st.x,st.y,0.0);

    // Add the shape on the foreground
    color += vec3(makeCross(st,0.2));

    COLOR = vec4(color,1.0);
}
