varying vec2 vUv;
uniform vec2 resolution;
uniform sampler2D tex;
uniform sampler2D tex_or;
uniform float mouseX;
uniform float mouseY;

float threshold(in float thr1, in float thr2 , in float val) {
  if (val < thr1) {return 0.0;}
  if (val > thr2) {return 1.0;}
  return val;
}

// averaged pixel difference from 3 color channels
float diff(in vec4 pix1, in vec4 pix2) {
  return (
    abs(pix1.r - pix2.r) +
    abs(pix1.g - pix2.g) +
    abs(pix1.b - pix2.b)
  ) / 3.0;
}

float edge(in sampler2D tex, in vec2 coords, in vec2 renderSize){
  float dx = 1.0 / renderSize.x;
  float dy = 1.0 / renderSize.y;
  vec4 pix[9];
  
  pix[0] = texture2D(tex, coords + vec2( -1.0 * dx, -1.0 * dy));
  pix[1] = texture2D(tex, coords + vec2( -1.0 * dx , 0.0 * dy));
  pix[2] = texture2D(tex, coords + vec2( -1.0 * dx , 1.0 * dy));
  pix[3] = texture2D(tex, coords + vec2( 0.0 * dx , -1.0 * dy));
  pix[4] = texture2D(tex, coords + vec2( 0.0 * dx , 0.0 * dy));
  pix[5] = texture2D(tex, coords + vec2( 0.0 * dx , 1.0 * dy));
  pix[6] = texture2D(tex, coords + vec2( 1.0 * dx , -1.0 * dy));
  pix[7] = texture2D(tex, coords + vec2( 1.0 * dx , 0.0 * dy));
  pix[8] = texture2D(tex, coords + vec2( 1.0 * dx , 1.0 * dy));

  // average color differences around neighboring pixels
  float delta = (diff(pix[1],pix[7])+
          diff(pix[5],pix[3]) +
          diff(pix[0],pix[8])+
          diff(pix[2],pix[6])
           )/4.;

  return clamp(5.0*delta,0.0,1.0);
}

void main() {
    vec2 st = vUv;


    // vec2 st_ = st + clamp(0.3, 0.5, length(st - vec2(mouseX, mouseY)));
    float ed = edge(tex_or, st, resolution);
    vec3 color_or = texture2D(tex, st + ed).rgb;
    gl_FragColor = vec4(color_or, 1.0);
}