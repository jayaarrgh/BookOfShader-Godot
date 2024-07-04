shader_type canvas_item;

// Author @patriciogv - 2015
// Title: Truchet - 10 print

float random (in vec2 _st) {
    return fract(sin(dot(_st.xy,
                         vec2(12.9898,78.233)))*
        43758.5453123);
}

vec2 truchetPattern(in vec2 _st, in float _index){
    _index = fract(((_index-0.5)*2.0));
    if (_index > 0.75) {
        _st = vec2(1.0) - _st;
    } else if (_index > 0.5) {
        _st = vec2(1.0-_st.x,_st.y);
    } else if (_index > 0.25) {
        _st = 1.0-vec2(1.0-_st.x,_st.y);
    }
    return _st;
}

void fragment() {
    vec2 st = FRAGCOORD.xy/(1.0/SCREEN_PIXEL_SIZE).xy;
    st *= 10.0;
    // st = (st-vec2(5.0))*(abs(sin(TIME*0.2))*5.);
    // st.x += TIME*3.0;

    vec2 ipos = floor(st);  // integer
    vec2 fpos = fract(st);  // fraction

    vec2 tile = truchetPattern(fpos, random( ipos ));

    float color = 0.0;

    // Maze
    color = smoothstep(tile.x-0.3,tile.x,tile.y)-
            smoothstep(tile.x,tile.x+0.3,tile.y);

    // Circles
//    color = (step(length(tile),0.6) -
//             step(length(tile),0.4) ) +
//            (step(length(tile-vec2(1.)),0.6) -
//             step(length(tile-vec2(1.)),0.4) );

    // Truchet (2 triangles)
//    color = step(tile.x,tile.y);

    COLOR = vec4(vec3(color),1.0);
}
