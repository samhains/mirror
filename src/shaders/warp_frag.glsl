// #ifdef GL_ES
// precision mediump float;
// #endif

uniform vec2 resolution;
uniform vec2 mouse;
uniform float time;
uniform sampler2D tex; 
uniform sampler2D scene;
varying vec2 vUv;

float random (in vec2 st) { 
    return fract(sin(dot(st.xy,
                         vec2(12.9898,78.233))) 
                * 43758.5453123);
}

mat2 rotate2d(float angle){
    return mat2(cos(angle),-sin(angle),
                sin(angle),cos(angle));
}

void main() {
    vec2 st = vUv; //gl_FragCoord.xy/u_resolution.xy;
    // st.y *= resolution.y/resolution.x;

    st.x -= 0.03;

    vec2 initial_st = st;

    vec3 perChannelColor = vec3(0.0);

    for( int i=0; i<15; i++ ){
        float i_c = dot(texture2D( tex, st ).xyz, vec3(0.5));
        float i_c2 = dot(texture2D( tex, vec2(st.x - 50., 5.* sin(st.x * 100.))).xyz, vec3(0.5));
        float i_c3 = dot(texture2D( tex, vec2(st.x, 12.* sin(st.x * 10. + 0.5 * sin(time / 5. - st.x)))).xyz, vec3(0.5));

        vec2 move = vec2((i_c + i_c2)/2.0, (i_c + i_c3)/2.);

        st.y -= 0.0035 * move.x - 0.05*sin(time/10.);
        st.x -= 0.0055 * move.y;

        perChannelColor = texture2D( tex, st ).rgb;
    }

    perChannelColor = perChannelColor / 2.0;

    gl_FragColor = vec4(2.0 * (perChannelColor), 0.1);
}