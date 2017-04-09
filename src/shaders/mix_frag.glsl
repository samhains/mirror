varying vec2 vUv;
uniform float time;
uniform sampler2D tex;
uniform sampler2D tex_or;
uniform sampler2D scene;
uniform float mouseX;
uniform float mouseY;

vec3 getColor(vec2 st) {
    vec3 color = vec3(0.0);

     for( int i=0; i<3; i++ ){
        float i_c = dot(texture2D( tex, st).xyz, vec3(0.5));
        float i_c2 = dot(texture2D( tex, vec2(st.x * cos(st.y), 5.* sin(st.x * 10.))).xyz, vec3(0.5));
        float i_c3 = dot(texture2D( tex, vec2(st.x, 12.* sin(st.x * 10. + 50. * sin(time / 5. - st.x)))).xyz, vec3(0.5));

        vec2 move = vec2((i_c + i_c2)/2.0, (i_c + i_c3)/2.);

        st.y -= 0.0075 * move.x + 0.005*sin(5. -  mouseY * (st.x * 1. + 2.));
        st.x -= 0.0055 * move.y + 0.005*cos(5. -  mouseX * (st.y * 1. + 2.));

        color[i] = texture2D( tex, st )[i];
    }

    return color;
}

vec3 rgb2hsv(vec3 c)
{
    vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
    vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));
    
    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return vec3(abs(( (q.z + (q.w - q.y) / (6.0 * d + e))) ), d / (q.x + e), q.x);
}

vec3 hsv2rgb(vec3 c)
{
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

float rand(float p)
{
    return fract(cos(p * 48.233)*375.42); 
}

float random(in vec2 st) {
    return fract(sin(5543.027 - dot(st.x,st.y) * 12664.895) * 43648.092);
}


// 2D Noise based on Morgan McGuire @morgan3d
// https://www.shadertoy.com/view/4dS3Wd
float noise2d (in vec2 st) {
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

float noise(in float t) {
    float i = floor(t);
    t = fract(t);
    
    float u = t * t * (3.0 - 2.0 * t ); // custom cubic curve
  float y = mix(rand(i), rand(i + 1.0), u);
    
    return y;
}

mat2 rotate2d(float _angle) {
    return mat2(cos(_angle),-sin(_angle),
                sin(_angle),cos(_angle));
}

void main() {
    // vec2 offset = vec2(vUv.x - sin(time / (10. + 10.*vUv.y)), 0.0);

    vec3 t2 = texture2D(scene, vUv).rgb;
    vec3 t3 = texture2D(tex, vUv).rgb;
    vec3 t1 = getColor(vUv);
    vec3 tt = (t1 * t2) * 0.75; //length(vUv - vec2(mouseX, mouseY));

    // // vec2 st = vUv * rotate2d(noise(vUv.x * 50. + vUv.y * 50.));

    // vec3 color = texture2D( tex_or, t1.rb ).rgb * 0.5 + mix(t2, tt, 0.5);
    vec2 coord = vec2(
     vUv.x - 0.05 * (length(vUv - t1.rb) * (0.1 + vUv.x)),
     vUv.y - 0.05 * (length(vUv - t1.gb) * (0.1 + vUv.y))
    );

    vec3 rgb;
    rgb[0] = (texture2D( scene, coord).r);
    rgb[1] = (texture2D( scene, coord + vec2(0.0025, 0.0)).g);
    rgb[2] = (texture2D( scene, coord + vec2(0.005, 0.0)).b);

    vec3 color = mix(mix(mix(t2, t3, 0.95), tt, 0.1), rgb, 0.15);//texture2D( tex_or, coord).rgb * 0.5 + mix(t2, tt, 0.5);
    
    gl_FragColor = vec4(color, 0.5);
}


// uniform sampler2D tex;
