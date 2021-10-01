#include "./stuff.glsl"

vec3 sky(Ray r){
    float t=.5*(normalize(r.direction).y+1.);
    return(1.-t)*vec3(1.)+t*vec3(.5,.7,1.);
}

bool scene1(Ray r,float t_min,float t_max,out Intersection hit,out vec3 background){
    bool intersected=false;
    hit.t=t_max;
    Plane p1=Plane(XY,-1.,1.,.2,2.2,-3.,newEmissive(newSolidColor(vec3(.9922,.5059,.1608)),4.));
    if(hit_plane(p1,r,t_min,hit.t,hit)){
        intersected=true;
    }
    
    Plane p2=Plane(XY,-1.,1.,.2,2.2,3.,newEmissive(newSolidColor(vec3(.1608,.5529,1.)),4.));
    if(hit_plane(p2,r,t_min,hit.t,hit)){
        intersected=true;
    }
    
    Sphere s1=Sphere(vec3(0.,-1000.,-1.),1000.,newLambertian(newCheckerBoard(vec3(1.),vec3(.1),10.)));
    if(hit_sphere(s1,r,t_min,hit.t,hit)){
        intersected=true;
    };
    
    Sphere s2=Sphere(vec3(0.,.5,1.),.5,newDielectric(1.4));
    if(hit_sphere(s2,r,t_min,hit.t,hit)){
        intersected=true;
    };
    
    Sphere s5=Sphere(vec3(1.,.5,-1.),.5,newMetal(newSolidColor(vec3(1.)),.02));
    if(hit_sphere(s5,r,t_min,hit.t,hit)){
        intersected=true;
    };
    
    background=vec3(0.);
    return intersected;
}

bool scene2(Ray r,float t_min,float t_max,out Intersection hit,out vec3 background){
    bool intersected=false;
    hit.t=t_max;
    
    // floor
    Sphere s0=Sphere(vec3(0.,-999.9,-1.),1000.,newLambertian(newCheckerBoard(vec3(1.,.0863,.0863),vec3(.5176,0.,0.),8.)));
    if(hit_sphere(s0,r,t_min,hit.t,hit)){
        intersected=true;
    };
    
    // box
    Box b=newBox(vec3(-7.,0.,-5.),vec3(7.,.5,4.),newLambertian(newSolidColor(vec3(1.,.040,.040))));
    if(hit_box(b,r,t_min,hit.t,hit)){
        intersected=true;
    }
    
    Sphere s1=Sphere(vec3(-2.7,1.2,2.45),.7,newLambertian(newSolidColor(vec3(1.))));
    if(hit_sphere(s1,r,t_min,hit.t,hit)){
        intersected=true;
    }
    
    Sphere s2=Sphere(vec3(4.6,1.6,0.),1.1,newDielectric(1.4));
    if(hit_sphere(s2,r,t_min,hit.t,hit)){
        intersected=true;
    }
    
    Sphere s3=Sphere(vec3(-4.8,1.5,-.6),1.,newMetal(newSolidColor(vec3(1.)),.01));
    if(hit_sphere(s3,r,t_min,hit.t,hit)){
        intersected=true;
    }
    
    Sphere s4=Sphere(vec3(2.2,1.35,-2.15),.70,newLambertian(newSolidColor(vec3(1.,.4157,0.))));
    if(hit_sphere(s4,r,t_min,hit.t,hit)){
        intersected=true;
    }
    
    Sphere s5=Sphere(vec3(2.2,1.35,-2.15),.855,newDielectric(1.9));
    if(hit_sphere(s5,r,t_min,hit.t,hit)){
        intersected=true;
    }
    
    // Sphere s6=Sphere(vec3(.25,.75,.25),.1,newEmissive(newSolidColor(vec3(1.,.4157,0.)),1.));
    // if(hit_sphere(s6,r,t_min,hit.t,hit)){
        //     intersected=true;
    // }
    
    Box b1=newBox(vec3(0.,.5,0.),vec3(.5,1.,.5),newMetal(newSolidColor(vec3(1.)),1.2));
    if(hit_box(b1,r,t_min,hit.t,hit)){
        intersected=true;
    }
    
    Box b2=newBox(vec3(-.20,.5,-.20),vec3(.0,.70,.0),newEmissive(newSolidColor(vec3(1.,.851,.1843)),1.2));
    if(hit_box(b2,r,t_min,hit.t,hit)){
        intersected=true;
    }
    
    int lights=8;
    float d=.8;
    float w=.4;
    float s=.2;
    for(int i=-lights;i<lights;++i){
        Plane pl=Plane(ZX,-2.,1.1,(float(i)*d)+s,(float(i)*d)+w+s,4.3,newEmissive(newSolidColor(vec3(1.,1.,.83)),4.));
        if(hit_plane(pl,r,t_min,hit.t,hit)){
            intersected=true;
        }
    }
    
    background=vec3(.0);
    return intersected;
    
}
bool scene3(Ray r,float t_min,float t_max,out Intersection hit,out vec3 background){
    bool intersected=false;
    hit.t=t_max;
    
    // green
    Plane p1=Plane(YZ,0.,555.,0.,555.,555.,newLambertian(newSolidColor(vec3(.12,.45,.15))));
    if(hit_plane(p1,r,t_min,hit.t,hit)){
        intersected=true;
    }
    
    //red
    Plane p2=Plane(YZ,0.,555.,0.,555.,0.,newLambertian(newSolidColor(vec3(.65,.05,.05))));
    if(hit_plane(p2,r,t_min,hit.t,hit)){
        intersected=true;
    }
    
    // white walls
    Plane p3=Plane(ZX,0.,555.,0.,555.,0.,newLambertian(newSolidColor(vec3(.73,.73,.73))));
    if(hit_plane(p3,r,t_min,hit.t,hit)){
        intersected=true;
    }
    Plane p4=Plane(ZX,0.,555.,0.,555.,555.,newLambertian(newSolidColor(vec3(.73,.73,.73))));
    if(hit_plane(p4,r,t_min,hit.t,hit)){
        intersected=true;
    }
    Plane p5=Plane(XY,0.,555.,0.,555.,555.,newLambertian(newSolidColor(vec3(.73,.73,.73))));
    if(hit_plane(p5,r,t_min,hit.t,hit)){
        intersected=true;
    }
    
    Plane ll=Plane(ZX,213.,343.,227.,332.,554.,newEmissive(newSolidColor(vec3(1.)),15.));
    if(hit_plane(ll,r,t_min,hit.t,hit)){
        intersected=true;
    }
    
    // Sphere s=Sphere(vec3(265.,330.,200.),100.,newDielectric(1.4));
    // if(hit_sphere(s,r,t_min,hit.t,hit)){
        //     intersected=true;
    // }
    
    Box b0=newBox(vec3(265.,0.,265.),vec3(430.,330.,460.),newLambertian(newSolidColor(vec3(.73,.73,.73))));
    if(hit_box(b0,r,t_min,hit.t,hit)){
        intersected=true;
    }
    
    Box b=newBox(vec3(130.,0.,65.),vec3(295.,165.,230.),newLambertian(newSolidColor(vec3(.73,.73,.73))));
    if(hit_box(b,r,t_min,hit.t,hit)){
        intersected=true;
    }
    
    background=vec3(.0);
    return intersected;
}
// bool scene3(Ray r,float t_min,float t_max,out Intersection hit,out vec3 background){
    //     bool intersected=false;
    //     hit.t=t_max;
    
    //     int balls=4;
    //     for(int x=-balls;x<balls;++x){
        //         for(int y=-balls;y<balls;++y){
            
            //             float fx=float(x);
            //             float fy=float(y);
            //             float seed=fx+fy/1000.;
            //             vec3 rand1=hash3(seed);
            //             vec3 center=vec3(fx+.5*rand1.x,.2,fy+.5*rand1.y);
            //             float chooseMaterial=rand1.z;
            //             if(distance(center,vec3(4.,.2,0.))>.9)
            //             {
                //                 if(chooseMaterial<.6)
                //                 {
                    //                     Sphere ss=Sphere(center,.2,newLambertian(newSolidColor(hash3(seed)*hash3(seed))));
                    //                     if(hit_sphere(
                            //                             ss,
                            //                             r,
                            //                             t_min,
                            //                             hit.t,
                        //                         hit))
                        //                         {
                            //                             intersected=true;
                            //                             hit.mat=ss.mat;
                        //                         }
                    //                     }
                    //                     else if(chooseMaterial<.9)
                    //                     {
                        //                         Sphere ss=Sphere(center,.2,newMetal(newSolidColor((hash3(seed)+1.)*.5),hash1(seed)));
                        //                         if(hit_sphere(
                                //                                 ss,
                                //                                 r,
                                //                                 t_min,
                                //                                 hit.t,
                            //                             hit))
                            //                             {
                                //                                 intersected=true;
                                //                                 hit.mat=ss.mat;
                            //                             }
                        //                         }
                        
                        //                         else if(chooseMaterial<.98)
                        //                         {
                            //                             Sphere ss=Sphere(center,.2,newEmissive(newSolidColor((hash3(seed)+1.)*.5),2.));
                            //                             if(hit_sphere(
                                    //                                     ss,
                                    //                                     r,
                                    //                                     t_min,
                                    //                                     hit.t,
                                //                                 hit))
                                //                                 {
                                    //                                     intersected=true;
                                    //                                     hit.mat=ss.mat;
                                //                                 }
                            //                             }
                            
                            //                             else
                            //                             {
                                //                                 Sphere ss=Sphere(center,.2,newDielectric(1.5));
                                //                                 if(hit_sphere(
                                        //                                         ss,
                                        //                                         r,
                                        //                                         t_min,
                                        //                                         hit.t,
                                    //                                     hit))
                                    //                                     {
                                        //                                         intersected=true;
                                        //                                         hit.mat=ss.mat;
                                    //                                     }
                                //                                 }
                                
                            //                             }
                            
                        //                         }
                    //                     }
                    
                    //                     // Sphere s2=Sphere(vec3(0.,1.,1.),1.,newDielectric(1.4));
                    //                     // if(hit_sphere(s2,r,t_min,hit.t,hit)){
                        //                         //     intersected=true;
                        //                         //     hit.mat=s2.mat;
                    //                     // };
                    
                    //                     Sphere s1=Sphere(vec3(0.,-1000.,-1.),1000.,newLambertian(newDots(vec3(1.),vec3(.1),10.)));
                    //                     if(hit_sphere(s1,r,t_min,hit.t,hit)){
                        //                         intersected=true;
                        //                         hit.mat=s1.mat;
                    //                     };
                    
                    //                     // Sphere s3=Sphere(vec3(1.5,.6,0.),.6,newMetal(vec3(.7,.7,1.),0.));
                    //                     // if(hit_sphere(s3,r,t_min,hit.t,hit)){
                        //                         //     intersected=true;
                        //                         //     hit.mat=s3.mat;
                        
                        //                         background=vec3(.05);
                        //                         return intersected;
                    //                     }
                    //                     // Sphere s3=Sphere(vec3(1.5,2.6,0.),.2,newEmissive(newSolidColor(vec3(.8588,.6627,.9882)),30.));
                    //                     // if(hit_sphere(s3,r,t_min,hit.t,hit)){
                        //                         //     intersected=true;
                        //                         //     hit.mat=s3.mat;
                    //                     // }
                    
                    