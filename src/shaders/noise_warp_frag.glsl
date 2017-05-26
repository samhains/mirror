varying vec2 vUv;
uniform vec2 resolution;
uniform sampler2D tex;
uniform sampler2D tex2;
uniform float time;
uniform int mouseStatus;
uniform float mouseX;
uniform float mouseY;

float rand(in float t) {
    return fract(sin(t * 12.895) * 43858.46);
}


float noise(in float t) {
    float i = floor(t);
    t = fract(t);
    
    float u = t * t * (3.0 - 2.0 * t ); // custom cubic curve
  float y = mix(rand(i), rand(i + 1.0), u);
    
    return y;
}

float random(in vec2 st) {
    return fract(sin(5543.027 - dot(st.x,st.y) * 12664.895) * 43648.092);
}


// 2D Noise based on Morgan McGuire @morgan3d
// https://www.shadertoy.com/view/4dS3Wd
float noise (in vec2 st) {
    vec2 i = floor(st);
    vec2 f = fract(st);

    // Four corners in 2D of a tile
    float a = random(i);
    float b = random(i + vec2(1.0, 0.0));
    float c = random(i + vec2(0.0, 1.0));
    float d = random(i + vec2(1.0, 1.0));

    // Smooth Interpolation

    // Cubic Hermine Curve.  Same as SmoothStep()
    vec2 u = f*f*(3.0-2.0*f);
    // u = smoothstep(0.,1.,f);

    // Mix 4 coorners porcentages
    return mix(a, b, u.x) + 
            (c - a)* u.y * (1.0 - u.x) + 
            (d - b) * u.x * u.y;
}

mat2 rotate2d(float _angle) {
    return mat2(cos(_angle),-sin(_angle),
                sin(_angle),cos(_angle));
}

vec3 rgb2hsv(vec3 c){
    vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
    vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));
    
    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return vec3(abs(( (q.z + (q.w - q.y) / (6.0 * d + e))) ), d / (q.x + e), q.x);
}

vec3 hsv2rgb(vec3 c){
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}


vec3 getTileWarp(in vec2 st) {
    st = st * 5.;
    // st = st * rotate2d(noise(st));
    float tile = 0.0;
    float sg = 1.0;
    
    // vec2 f = fract(st);
    
    vec3 color;
    vec2 offset;
    vec2 i;

    i = floor(st);

    if(mod(i.x + i.y, 2.0) == 0.0) {
      sg = 1.0;
    } else {
      sg = -1.0;
    };

    offset = vec2(sg * sin(time/6. + st.y), sg * cos(time/6. + st.x));

    i = floor(i + offset + 0.5*(0.5 + 0.5*mouseY)*st.x + 0.5*(0.5 + 0.5*mouseX)*st.y);

    for(int j = 0; j < 3; j++) {
        i = i - (float(j) * 0.5);
                
        tile = smoothstep(-1.0, 1.0, mod(i.x + i.y + mouseY * 0.5, 2.0 - mouseX * 0.5));
        float r_c = random(i);
        
        color[j] = (tile + r_c/2.0) / 2.0;
    }

    vec3 colortex = vec3(texture2D(tex, vec2(vUv.x + color.x, vUv.y + color.z) - color.y).rgb);

    return colortex;
}


vec3 getTile(in vec2 st) {
    st = st;
    float tile = 0.0;
    
    vec3 color;
    vec2 offset;
    vec2 i;
    float sg = 1.0;
    float dir = 1.0;

    vec2 i_f = floor(st + (mouseX - mouseY) * 0.5);

    if(random(i_f) < 0.5) {
      dir = -1.0;
    }

    if(random(i_f + vec2(3.0)) < 0.5) {
      sg = 0.0;
    }

    if(mod(i_f.x + i_f.y, 2.0) == 0.0) {
      sg = 1.0;
    } else {
      sg = 2.0;
    };

    offset = vec2(dir * sg * (time/6.), dir * (1.0 - sg) * (time/6.));
    i = floor(st + 0.1 * offset);

    for(int j = 0; j < 3; j++) {
        i = i + (float(j) * 0.5);
                
        tile = smoothstep(-1.0, 1.0, mod(i.x + i.y + mouseY * 0.5, 2.0 - mouseX * 0.5));
        float r_c = random(i);
        
        color[j] = (tile + r_c/2.0) / 2.0;
    }

    vec3 colortex1 = vec3(texture2D(tex, st).rgb);
    
    return colortex1;
}

vec3 getTile3(in vec2 st) {
    st = st * 5.;
    float tile = 0.0;
    
    vec3 color;
    vec2 offset;
    vec2 i;
    float sg = 1.0;
    float dir = 1.0;

    vec2 i_f = floor(st + (mouseX - mouseY) * 0.5);

    if(random(i_f) < 0.5) {
      dir = -1.0;
    }

    if(random(i_f + vec2(3.0)) < 0.5) {
      sg = 0.0;
    }

    if(mod(i_f.x + i_f.y, 2.0) == 0.0) {
      sg = 1.0;
    } else {
      sg = 2.0;
    };

    offset = vec2(dir * sg * (time/6.), 0.0);
    i = floor(st + 0.1 * offset);

    vec3 colortex;

    for(int j = 0; j < 3; j++) {
        i = i + (float(j) * 0.1);
                
        tile = smoothstep(-1.0, 1.0, mod(i.x + i.y + mouseY * 0.5, 2.0 - mouseX * 0.5));
        float r_c = random(i);
        
        color[j] = (tile + r_c/2.0) / 6.0;
    }
    
    colortex = vec3(texture2D(tex, vec2(vUv.x + color.x, vUv.y + color.z) - color.y).rgb);
    colortex.z += (texture2D(tex, vec2(vUv.x + 2.0*color.y, vUv.y - 2.0*color.x) - color.z)[1]);

    //  = vec3(texture2D(tex, vec2(vUv.x + color.x, vUv.y + color.z) - color.y).rgb);

    vec3 hsv = rgb2hsv(colortex);

    // hsv.y -= 0.3 * sin(color.z * 5.);
    // hsv.x += 0.3 * sin(color.x * 5.);

    vec3 rgb = hsv2rgb(hsv);
  
    return rgb;
}

void main() {
    vec2 st = vUv;
    // st.x *= resolution.x/resolution.y;
    st = st ;
    
    vec3 fin;
    vec3 checkerboard;

    checkerboard = getTile(st);


    gl_FragColor = vec4(checkerboard,1.0);
}
