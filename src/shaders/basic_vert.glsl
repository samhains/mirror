varying vec2 vUv;
uniform float time;
uniform float amplitude;
varying float noise;

float rand(in vec3 t) {
    return fract(sin(dot(t, vec3(7.3145, 5.6482, 16.7394) * 78.425)));
}

float Noise3D(in vec3 pos) {
    float x0 = floor(pos.x);
    float y0 = floor(pos.y);
    float z0 = floor(pos.z);
    float x1 = x0 + 1.0;
    float y1 = y0 + 1.0;
    float z1 = z0 + 1.0;

    // Front, Back, Up, Down, Left, Right
    // SWAP z0 -> z1;
    float FUL = rand(vec3(x0, y1, z0));
    float FUR = rand(vec3(x1, y1, z0));
    float FDL = rand(vec3(x0, y0, z0));
    float FDR = rand(vec3(x1, y0, z0));
    float BUL = rand(vec3(x0, y1, z1));
    float BUR = rand(vec3(x1, y1, z1));
    float BDL = rand(vec3(x0, y0, z1));
    float BDR = rand(vec3(x1, y0, z1));

    vec3 f = fract(pos);

    float FU = mix(FUL, FUR, f.x);
    float FD = mix(FDL, FDR, f.x);
    float F_ = mix(FU, FD, f.y);

    float BU = mix(BUL, BUR, f.x);
    float BD = mix(BDL, BDR, f.x);
    float B_ = mix(BU, BD, f.y);

    float Z_ = mix(F_, B_, f.z);

    return Z_;
}

float OctaveNoise3D(in vec3 pos) {
    float total = 0.0;

    total += Noise3D(pos * 2.0) * 0.500;
    total += Noise3D(pos * 4.0) * 0.250;
    total += Noise3D(pos * 8.0) * 0.125;

    return total;
}

void main() {
    vUv = uv;

    float n = amplitude * OctaveNoise3D(position + time);
    vec3 offset = normal + vec3(n);

    gl_Position = projectionMatrix * modelViewMatrix * vec4( position + offset, 1.0 );
    noise = n;
}