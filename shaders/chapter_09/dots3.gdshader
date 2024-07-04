shader_type canvas_item;

// Author @patriciogv ( patriciogonzalezvivo.com ) - 2015
const float rows = 10.0;

vec2 brickMirrorTile(vec2 _st, float _zoom){
  _st *= _zoom;
  if (fract(_st.y * 0.5) > 0.5){
      _st.x += 0.5;
      _st.y = 1.0-_st.y;
  }
  return fract(_st);
}

float circle(vec2 _st, float _radius){
  vec2 pos = vec2(0.5)-_st;
  _radius *= 0.75;
  return 1.-smoothstep(_radius-(_radius*0.01),_radius+(_radius*0.01),dot(pos,pos)*3.14);
}

void fragment(){

  vec2 st = FRAGCOORD.xy/(1.0/SCREEN_PIXEL_SIZE).xy;
  st.x *= (1.0/SCREEN_PIXEL_SIZE).x/(1.0/SCREEN_PIXEL_SIZE).y;

  st = brickMirrorTile(st,5.);
  vec3 color = vec3(circle(st+vec2(0.,0.05), 0.007)+
                    circle(st+vec2(0.075,-0.07), 0.007)+
                    circle(st+vec2(-0.075,-0.07), 0.007));

  COLOR = vec4(color,1.0);
}
