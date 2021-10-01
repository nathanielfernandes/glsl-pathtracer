// #extension GL_OES_standard_derivatives:enable
#include "./scenes.glsl"
#iChannel0"self"

precision mediump float;

#define MAX_BOUNCES 50
#define SAMPLES_PER_FRAME 1
#define SCENE 0
#define MAX_SAMPLES 5000.

int frame_count=1;

bool world_hit(Ray r,float t_min,float t_max,out Intersection hit,out vec3 background){
  if(SCENE==0){
    return scene2(r,t_min,t_max,hit,background);
  }
  
  if(SCENE==1){
    return scene1(r,t_min,t_max,hit,background);
  }
  
  if(SCENE==2){
    return scene3(r,t_min,t_max,hit,background);
  }
  
}

vec3 color(Ray r){
  Intersection hit;
  vec3 c=vec3(1.);
  vec3 background;
  for(int i=0;i<MAX_BOUNCES;++i){
    if(world_hit(r,.001,10000.,hit,background)){
      Ray scattered;
      vec3 attenuation;
      vec3 emitted;
      if(scatter(r,hit,attenuation,emitted,scattered)){
        c*=emitted+attenuation;
        r=scattered;
      }else{
        c*=emitted;
        return c;
      }
    }else{
      
      c*=background;
      return c;
    }
  }
  return c;
}

vec3 trace(Ray r){
  vec3 c=color(r);
  return c/float(frame_count);
}

void main(){
  g_seed=float(baseHash(floatBitsToUint(gl_FragCoord.xy)))/float(0xffffffffU)+iTime;//random(gl_FragCoord.xy*(mod(time,100.)));
  
  vec2 uv=gl_FragCoord.xy/iResolution.xy;
  
  vec2 m=iMouse.xy/iResolution.xy;
  m.x=m.x*2.-1.;
  
  vec3 offset_p,offset_t;
  vec2 sens;
  
  if(SCENE==0){
    offset_p=vec3(0.,5.,10.);
    offset_t=vec3(0.,0.,0.);
    sens=vec2(5.,11.5);
  }else if(SCENE==1){
    offset_p=vec3(0.,0.,0.);
    offset_t=vec3(0.,0.,0.);
    sens=vec2(5.,11.5);
  }else if(SCENE==2){
    offset_p=vec3(278.,278.,-800.);
    offset_t=vec3(278.,278.,0.);
    sens=vec2(500.,100.);
  }
  
  // vec3 cPos=vec3(0.,11.5,10.);
  vec3 cPos=vec3(m.x*sens.x,m.y*sens.y,m.y*(sens.y/2.)-5.)+offset_p;
  vec3 cTar=vec3(0.,.5,0.)+offset_t;
  float focus_dist=length(cTar-cPos);
  
  Camera cam=new_camera(
    cPos,
    cTar,
    vec3(0.,1.,0.),// world up vector
    40.,
    iResolution.x/iResolution.y,
    .0,
  1000.,0.,1.);
  
  vec4 prev=texture(iChannel0,uv);
  vec3 prevLinear=toLinear(prev.xyz);
  prevLinear*=prev.w;
  
  vec2 aa_uv=vec2(uv.x+hash1(g_seed)/iResolution.x,uv.y+hash1(g_seed)/iResolution.y);
  // color || trace
  vec3 col=trace(get_ray(cam,aa_uv));
  
  if(iMouseButton.x!=0.||iMouseButton.y!=0.)
  {
    col=toGamma(col);
    
    gl_FragColor=vec4(col,1.);
    return;
  }
  if(prev.w>MAX_SAMPLES)
  {
    gl_FragColor=prev;
    return;
  }
  
  col=(col+prevLinear);
  float w=prev.w+1.;
  col/=w;
  col=toGamma(col);
  gl_FragColor=vec4(col,w);
  frame_count++;
}

