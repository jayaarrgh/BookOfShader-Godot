shader_type canvas_item;

// Author @patriciogv ( patriciogonzalezvivo.com ) - 2015

const float rows = 10.0;

vec2 brickTile(vec2 _st, float _zoom){
    _st *= _zoom;
    if (fract(_st.y * 0.5) > 0.5){
        _st.x += 0.5;
    }
    return fract(_st);
}

vec2 rotate2D(vec2 _st, float _angle){
    _st -= 0.5;
	_st =  mat2(vec2(cos(_angle),-sin(_angle)),
                vec2(sin(_angle),cos(_angle))) * _st;
	_st += 0.5;
    return _st;
}

void fragment(){

	vec2 st = FRAGCOORD.xy/(1.0/SCREEN_PIXEL_SIZE).xy;
	st = brickTile(st,rows);

	float angle = PI*0.25*cos(TIME*0.5);

	if (fract( (FRAGCOORD.y/(1.0/SCREEN_PIXEL_SIZE).y) * 0.5 * rows) > 0.5){
        angle *= -1.0;
    }

	st = rotate2D(st,angle);

	st *= 2.0;
	float pct = (1.0+cos(PI*st.x))*0.5;

	vec3 color = vec3( 1.0-smoothstep( 0.5,0.6, pow(pct,st.y) ) * 1.0-smoothstep( 0.79,0.81, pow(pct,2.0-st.y )  ) );

	COLOR = vec4(color,1.0);
}
