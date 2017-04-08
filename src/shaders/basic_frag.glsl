
varying vec2 vUv;
varying float noise;
uniform float time;
uniform sampler2D texture;

vec3 getColor(float t) {
    vec3 a = vec3(0.6, 0.1, 0.6);
    vec3 b = vec3(0.5);
    vec3 c = vec3(1.0);
    vec3 d = vec3(0.340,0.092,0.200);
    
    return a + b * cos(TWO_PI * (c * t + d));
}

void main() {

  vec2 uv = vUv;//vec2(1.0) - vUv;
  vec3 color = vec3(noise);

  vec3 supplementary;
  
  supplementary = vec3(pow(sin(5. * noise), 1.0));
  supplementary = vec3(min(abs(sin(3. * noise)),abs(sin(50. * noise))));

  color = (color * supplementary);// * getColor(noise);

  gl_FragColor = vec4( color.rgb, 1.0 );
}