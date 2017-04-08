varying vec2 vUv;
uniform float mouseX;
uniform float mouseY;
uniform int mouseStatus;

void main() {
    vUv = uv;
    vec4 zoom = vec4(1.0);
    
    if(mouseStatus == 1) {
        zoom = vec4(1.05,1.00,1.0,1.0);
    };

    gl_Position =  projectionMatrix * modelViewMatrix* vec4( position + vec3(mouseX, mouseY, 0.0), 1.0 )*zoom;

}