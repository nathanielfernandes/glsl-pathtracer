#include "./helpers.glsl"

// Camera Stuff
struct Camera{
    vec3 origin,llc,horizontal,vertical,u,v,w;
    float lens_radius,time_0,time_1;
};

Camera new_camera(
    vec3 lookfrom,
    vec3 lookat,
    vec3 vup,
    float vfov,
    float aspect,
    float aperture,
    float focus_dist,
    float time_0,
float time_1)
{
    float theta=vfov*PI/180.;
    float half_height=tan(theta*.5);
    float half_width=aspect*half_height;
    
    Camera cam;
    cam.lens_radius=aperture*.5;
    cam.origin=lookfrom;
    cam.w=normalize(lookfrom-lookat);
    cam.u=normalize(cross(vup,cam.w));
    cam.v=cross(cam.w,cam.u);
    
    cam.llc=cam.origin-half_width*focus_dist*cam.u-half_height*focus_dist*cam.v-cam.w*focus_dist;
    cam.horizontal=2.*half_width*focus_dist*cam.u;
    cam.vertical=2.*half_height*focus_dist*cam.v;
    cam.time_0=time_0;
    cam.time_1=time_1;
    return cam;
    
}

// Ray Stuff
struct Ray{
    vec3 origin,direction;
    float time;
};

vec3 ray_at(Ray r,float t){
    return r.origin+r.direction*t;
}

Ray get_ray(Camera cam,vec2 uv){
    vec3 rd=cam.lens_radius*randomInUnitSphere(g_seed);
    vec3 offset=cam.u*rd.x+cam.v*rd.y;
    return Ray(cam.origin+offset,normalize(cam.llc+uv.x*cam.horizontal+uv.y*cam.vertical-cam.origin-offset),rand(vec2(cam.time_0,cam.time_1)));
}

// Textures
#define SOLIDCOLOR 0
#define CHECKERBOARD 1
#define DOTS 2

struct Texture{
    int type;
    float scalar;
    vec3 color_1,color_2;
};

Texture newSolidColor(vec3 color_1){
    Texture tex;
    tex.type=SOLIDCOLOR;
    tex.color_1=color_1;
    return tex;
}

Texture newCheckerBoard(vec3 color_1,vec3 color_2,float scalar){
    Texture tex;
    tex.type=CHECKERBOARD;
    tex.color_1=color_1;
    tex.color_2=color_2;
    tex.scalar=scalar;
    return tex;
}

Texture newDots(vec3 color_1,vec3 color_2,float scalar){
    Texture tex;
    tex.type=DOTS;
    tex.color_1=color_1;
    tex.color_2=color_2;
    tex.scalar=scalar;
    return tex;
}

// Materials
#define LAMBERTIAN 0
#define METAL 1
#define DIELECTRIC 2
#define EMISSIVE 3

struct Material{
    int type;// Material Enum
    Texture texture;
    float fuzz,ir;// fuzz for metals & index of refraction for Dielectrics
};

// Intersection
struct Intersection{
    vec3 point,normal,outward_normal;
    vec2 uv;
    float t;
    bool front_face;
    Material mat;
};

vec3 texure_color_at(Intersection hit){
    if(hit.mat.texture.type==SOLIDCOLOR){
        return hit.mat.texture.color_1;
    }
    
    if(hit.mat.texture.type==CHECKERBOARD){
        float sin_v=sin(hit.mat.texture.scalar*hit.point.x)*sin(hit.mat.texture.scalar*hit.point.y)*sin(hit.mat.texture.scalar*hit.point.z);
        return(sin_v<0.)?hit.mat.texture.color_1:hit.mat.texture.color_2;
    }
    
    if(hit.mat.texture.type==DOTS){
        float sin_v=sin(hit.mat.texture.scalar*hit.point.x)*sin(hit.mat.texture.scalar*hit.point.y)*sin(hit.mat.texture.scalar*hit.point.z)+rand(vec2(-1.,1.));
        return(sin_v<0.)?hit.mat.texture.color_1:hit.mat.texture.color_2;
        
    }
    
    return hit.mat.texture.color_1;
}

Material newLambertian(Texture texture){
    Material mat;
    mat.type=LAMBERTIAN;
    mat.texture=texture;
    return mat;
}

Material newMetal(Texture texture,float fuzz){
    Material mat;
    mat.type=METAL;
    mat.texture=texture;
    mat.fuzz=fuzz;
    return mat;
}

Material newDielectric(float ir){
    Material mat;
    mat.type=DIELECTRIC;
    mat.ir=ir;
    return mat;
}

Material newEmissive(Texture texture,float intensity){
    Material mat;
    mat.type=EMISSIVE;
    texture.color_1*=intensity;
    mat.texture=texture;
    return mat;
}

bool lambertian_scatter(Ray r,Intersection hit,out vec3 attenuation,out Ray scattered){
    vec3 target=hit.point+hit.normal+randomInUnitSphere(g_seed);
    scattered=Ray(hit.point,normalize(target-hit.point),r.time);
    attenuation=texure_color_at(hit);
    return true;
}

bool metal_scatter(Ray r,Intersection hit,out vec3 attenuation,out Ray scattered){
    vec3 reflected=reflect(normalize(r.direction),hit.normal);
    if(dot(reflected,hit.normal)>0.){
        scattered=Ray(hit.point,reflected+hit.mat.fuzz*randomInUnitSphere(g_seed),r.time);
        attenuation=texure_color_at(hit);
        return true;
    }
    return false;
}

float schlick(float cosine,float ref_idx){
    float r0=(1.-ref_idx)/(1.+ref_idx);
    r0*=r0;
    
    return r0+(1.-r0)*pow((1.-cosine),5.);
}

vec3 c_refract(vec3 uv,vec3 normal,float etai_over_etai){
    float cos_theta=min(dot(-normalize(uv),normal),1.);
    vec3 r_out_perp=etai_over_etai*(uv+cos_theta*normal);
    vec3 r_out_parallel=-sqrt(abs(1.-pow(length(r_out_perp),2.)))*normal;
    return r_out_perp+r_out_parallel;
    
}

bool dielectric_scatter(Ray r,Intersection hit,out vec3 attenuation,out Ray scattered){
    
    attenuation=vec3(1.);
    float eta=hit.mat.ir;
    vec3 normal=hit.normal;
    if(!hit.front_face){
        eta=1./eta;
    }
    
    float cos_theta=min(dot(-normalize(r.direction),normal),1.);
    float sin_theta=sqrt(1.-cos_theta*cos_theta);
    
    bool cannot_refract=sin_theta*eta>1.;
    
    if(cannot_refract||schlick(cos_theta,eta)>hash1(g_seed)){
        scattered=Ray(hit.point,reflect(r.direction,normal),r.time);
    }else{
        scattered=Ray(hit.point,c_refract(r.direction,normal,eta),r.time);
    }
    
    return true;
    
}

bool scatter(Ray r,Intersection hit,out vec3 attenuation,out vec3 emitted,out Ray scattered){
    emitted=vec3(0.);
    if(hit.mat.type==LAMBERTIAN){
        return lambertian_scatter(r,hit,attenuation,scattered);
    }
    
    if(hit.mat.type==METAL){
        return metal_scatter(r,hit,attenuation,scattered);
    }
    
    if(hit.mat.type==DIELECTRIC){
        return dielectric_scatter(r,hit,attenuation,scattered);
    }
    
    if(hit.mat.type==EMISSIVE){
        emitted=texure_color_at(hit);
        return false;
    }
    
    return false;
}

// Objects
struct Sphere{
    vec3 center;
    float radius;
    Material mat;
};

vec2 sphere_surf_uv(vec3 outward_normal){
    float theta=acos(-outward_normal.y);
    float phi=atan2(-outward_normal.z,outward_normal.x)+PI;
    return vec2(phi/TAU,theta/PI);
}

// use enums with match for other objects
bool hit_sphere(Sphere s,Ray r,float t_min,float t_max,inout Intersection hit){
    vec3 oc=r.origin-s.center;
    float b=dot(oc,r.direction);
    float c=dot(oc,oc)-s.radius*s.radius;
    float d=b*b-c;
    
    if(d<0.){
        return false;
    }
    float t1=(-b-sqrt(d));
    float t2=(-b+sqrt(d));
    float t=t1<t_min?t2:t1;
    
    vec3 p=ray_at(r,t);
    vec3 n=(p-s.center);
    // if front_face, the ray is in the sphere and not out, so invert normal
    bool front_face=dot(r.direction,n)>0.;
    
    if(t<t_min||t>t_max){
        return false;
    }
    n=front_face?-n:n;
    n/=s.radius;
    
    vec3 outward_normal=(hit.point-s.center)/s.radius;
    vec2 uv=sphere_surf_uv(outward_normal);
    if(t<hit.t){
        hit=Intersection(p,n,outward_normal,uv,t,front_face,s.mat);
    }
    
    return true;
}

// PlaneTypes
#define YZ 0
#define ZX 1
#define XY 2

#define YZ_axis uvec3(0,1,2);
#define ZX_axis uvec3(1,2,0);
#define XY_axis uvec3(2,0,1);

struct Plane{
    int type;
    float a0,a1,b0,b1,k;
    Material mat;
};

uvec3 get_axis(int plane_type){
    if(plane_type==YZ){
        return YZ_axis;
    }else if(plane_type==ZX){
        return ZX_axis;
    }else if(plane_type==XY){
        return XY_axis;
    }
}

vec3 plane_surf_normal(Plane p,Ray r,uvec3 axis){
    vec3 normal=vec3(0.);
    
    if(r.origin[axis.x]>p.k){
        normal[axis.x]=1.;
    }else{
        normal[axis.x]=-1.;
    }
    
    return normal;
}

bool hit_plane(Plane p,Ray r,float t_min,float t_max,inout Intersection hit){
    uvec3 axis=get_axis(p.type);
    
    float t=(p.k-r.origin[axis.x])/r.direction[axis.x];
    
    if(t<t_min||t>t_max){
        return false;
    }
    
    float a=r.origin[axis.y]+t*r.direction[axis.y];
    float b=r.origin[axis.z]+t*r.direction[axis.z];
    
    if(a<p.a0||a>p.a1||b<p.b0||b>p.b1){
        return false;
    }
    
    vec3 point=ray_at(r,t);
    float u=(a-p.a0)/(p.a1-p.a0);
    float v=(b-p.b0)/(p.b1-p.b0);
    
    vec3 n=plane_surf_normal(p,r,axis);
    if(t<hit.t){
        hit=Intersection(point,n,point,vec2(u,v),t,dot(r.direction,n)>0.,p.mat);
    }
    return true;
}

struct Box{
    Plane p1,p2,p3,p4,p5,p6;
    Material mat;
};

Box newBox(vec3 minn,vec3 maxx,Material mat){
    Box b;
    b.p1=Plane(ZX,minn.z,maxx.z,minn.x,maxx.x,minn.y,mat);
    b.p4=Plane(ZX,minn.z,maxx.z,minn.x,maxx.x,maxx.y,mat);
    b.p3=Plane(XY,minn.x,maxx.x,minn.y,maxx.y,minn.z,mat);
    b.p2=Plane(XY,minn.x,maxx.x,minn.y,maxx.y,maxx.z,mat);
    b.p5=Plane(YZ,minn.y,maxx.y,minn.z,maxx.z,minn.x,mat);
    b.p6=Plane(YZ,minn.y,maxx.y,minn.z,maxx.z,maxx.x,mat);
    b.mat=mat;
    return b;
}

bool hit_box(Box b,Ray r,float t_min,float t_max,inout Intersection hit){
    // return(hit_plane(b.p1,r,t_min,t_max,hit))||(hit_plane(b.p2,r,t_min,t_max,hit))||(hit_plane(b.p3,r,t_min,t_max,hit))||(hit_plane(b.p4,r,t_min,t_max,hit))||(hit_plane(b.p5,r,t_min,t_max,hit))||(hit_plane(b.p6,r,t_min,t_max,hit));
    bool intersected=false;
    
    if(hit_plane(b.p1,r,t_min,t_max,hit)){
        intersected=true;
    }
    
    if(hit_plane(b.p2,r,t_min,t_max,hit)){
        intersected=true;
    }
    
    if(hit_plane(b.p3,r,t_min,t_max,hit)){
        intersected=true;
    }
    
    if(hit_plane(b.p4,r,t_min,t_max,hit)){
        intersected=true;
    }
    
    if(hit_plane(b.p5,r,t_min,t_max,hit)){
        intersected=true;
    }
    
    if(hit_plane(b.p6,r,t_min,t_max,hit)){
        intersected=true;
    }
    
    return intersected;
}

