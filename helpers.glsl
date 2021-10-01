#define PI 3.1415926535897932385
#define TAU 2.*PI
#define PHI 1.61803398874989484820459
uniform float time;

float g_seed=0.;

uint baseHash(uvec2 p)
{
    p=1103515245U*((p>>1U)^(p.yx));
    uint h32=1103515245U*((p.x)^(p.y>>3U));
    return h32^(h32>>16);
}

float hash1(inout float seed){
    uint n=baseHash(floatBitsToUint(vec2(seed+=.1,seed+=.1)));
    return float(n)/float(0xffffffffU);
}

vec2 hash2(inout float seed){
    uint n=baseHash(floatBitsToUint(vec2(seed+=.1,seed+=.1)));
    uvec2 rz=uvec2(n,n*48271U);
    return vec2(rz.xy&uvec2(0x7fffffffU))/float(0x7fffffff);
}

vec3 hash3(inout float seed)
{
    uint n=baseHash(floatBitsToUint(vec2(seed+=.1,seed+=.1)));
    uvec3 rz=uvec3(n,n*16807U,n*48271U);
    return vec3(rz&uvec3(0x7fffffffU))/float(0x7fffffff);
}

float rand(vec2 v)
{
    return fract(sin(dot(v.xy,vec2(12.9898,78.233)))*43758.5453);
}

vec3 toLinear(vec3 c)
{
    return pow(c,vec3(2.2));
}

vec3 toGamma(vec3 c)
{
    return pow(c,vec3(1./2.2));
}

vec2 randomInUnitDisk(inout float seed){
    vec2 h=hash2(seed)*vec2(1.,6.28318530718);
    float phi=h.y;
    float r=sqrt(h.x);
    return r*vec2(sin(phi),cos(phi));
}

vec3 randomInUnitSphere(inout float seed)
{
    vec3 h=hash3(seed)*vec3(2.,6.28318530718,1.)-vec3(1.,0.,0.);
    float phi=h.y;
    float r=pow(h.z,1./3.);
    return r*vec3(sqrt(1.-h.x*h.x)*vec2(sin(phi),cos(phi)),h.x);
}

bool nearZero(vec3 v){
    if(abs(v.x)<1e-8&&abs(v.y)<1e-8&&abs(v.z)<1e-8){
        return true;
    }
    return false;
}

float atan2(float a,float b)
{
    return asin(a)>0.?acos(b):-acos(b);
}