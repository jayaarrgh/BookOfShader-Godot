shader_type canvas_item;

// Author @patriciogv - 2015
// http://patriciogonzalezvivo.com

//const float PI = 3.14159265359;
const float TWO_PI = 6.28318530718;

float shape(vec2 st, int N){
    st = st *2.-1.;
    float a = atan(st.x,st.y)+PI;
    float r = TWO_PI/float(N);
    return cos(floor(.5+a/r)*r-a)*length(st);
}

// Antialiazed Step function
// from http://webstaff.itn.liu.se/~stegu/webglshadertutorial/shadertutorial.html
float aastep(float threshold, float value) {
  //#ifdef GL_OES_standard_derivatives
  //float afwidth = 0.7 * length(vec2(dFdx(value), dFdy(value)));
  //return smoothstep(threshold-afwidth, threshold+afwidth, value);
  //#else
  return step(threshold, value);
  
}

void fragment(){
  vec2 st = FRAGCOORD.xy/(1.0/SCREEN_PIXEL_SIZE).xy;
  st.x *= (1.0/SCREEN_PIXEL_SIZE).x/(1.0/SCREEN_PIXEL_SIZE).y;
  vec3 color = vec3(0.0);
  float d = 0.0;

  d = min(shape(st,3),shape(st+vec2(0.,0.19),4));

  COLOR = vec4(vec3(1.0-aastep(.2,d)),1.0);
}
