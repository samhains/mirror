// import THREE from 'three';
const THREE = require('three');
import Stage from './stage.js';

let container, scene, renderer;
let scene2, scene3, scenewarp;
let tex1, tex2, tex3, texwarp;
let camera, perspCam;
let shader1, shader2, shader3, shaderwarp;
let mouseX = 0, mouseY = 0;
let w = window.innerWidth;
let h = window.innerHeight;
let cube;
let globalTime = 1;
var video, video2, videoTexture, videoTexture2;
// let mouseX = 0.0, mouseY = 0.0;

initVideo();
createBuffers();
animate();

document.addEventListener('mousemove', setMousePos);
document.addEventListener('click', onMouseClick);

function onMouseClick() {
  globalTime = 1;
  shaderwarp.uniforms.mouseStatus.value = (shaderwarp.uniforms.mouseStatus.value + 1) % 2;
}

function setMousePos(event) {
  mouseX = event.clientX/w;
  mouseY = event.clientY/h;

  shader3.uniforms.mouseX.value = mouseX;
  shader3.uniforms.mouseY.value = mouseY;
  shader2.uniforms.mouseX.value = mouseX;
  shader2.uniforms.mouseY.value = mouseY;
  shaderwarp.uniforms.mouseX.value = mouseX;
  shaderwarp.uniforms.mouseY.value = mouseY;
}

function initVideo() {
  
  video = document.createElement('video');
  video.width = w;
  video.height = h;
  video.autoplay = true;

    
  video2 = document.createElement('video');
  video2.width = w;
  video2.height = h;
  video2.autoplay = true;

  var constraints = { audio: false, video: { width: w, height: h } }; 

  navigator.mediaDevices.getUserMedia(constraints)
  .then(function(mediaStream) {
    video.srcObject = mediaStream;
    video2.srcObject = mediaStream;
    video.onloadedmetadata = function(e) {
      video.play();
    };
  })
  .catch(function(err) { console.log(err.name + ": " + err.message); });

  videoTexture = new THREE.Texture( video );
  videoTexture.minFilter = THREE.NearestFilter;
  videoTexture2 = new THREE.Texture( video2 );
  videoTexture2.minFilter = THREE.NearestFilter;
}

function createBuffers() {

  scene2 = new THREE.Scene();
  scene3 = new THREE.Scene();
  scenewarp = new THREE.Scene();

  camera = new THREE.OrthographicCamera(w/-2, w/2,  h/2, h/-2, -10000, 10000);
  perspCam = new THREE.PerspectiveCamera( 90, w/h, 0.1,40000);

  scene2.add(camera);
  scene3.add(camera);
  scenewarp.add(camera);

  let photo = videoTexture;//THREE.ImageUtils.loadTexture('../assets/789.jpg');

  tex1 = new THREE.WebGLRenderTarget( w,h, { minFilter: THREE.LinearFilter, magFilter: THREE.LinearFilter, format: THREE.RGBAFormat });
  tex2 = new THREE.WebGLRenderTarget( w,h, { minFilter: THREE.LinearFilter, magFilter: THREE.LinearFilter, format: THREE.RGBAFormat });
  tex3 = new THREE.WebGLRenderTarget( w,h, { minFilter: THREE.LinearFilter, magFilter: THREE.LinearFilter, format: THREE.RGBAFormat });
  texwarp = new THREE.WebGLRenderTarget( w,h, { minFilter: THREE.LinearFilter, magFilter: THREE.LinearFilter, format: THREE.RGBAFormat });

  shader3 = new THREE.ShaderMaterial({
    uniforms: {
      time: { type: 'f', value: 0.0 },
      tex: { type: 't', value: photo},
      tex_or: { type: 't', value: photo},
      resolution: { type: 'v2', value: new THREE.Vector2(w, h)},
      mouseX: { type: 'f', value: mouseX},
      mouseY: { type: 'f', value: mouseY}
    },
    vertexShader: require('./shaders/pass_vert.glsl'),
    fragmentShader: require('./shaders/edge_frag.glsl'),
  });

  shader2 = new THREE.ShaderMaterial({
    uniforms: {
      time: { type: 'f', value: 0.0 },
      tex: { type: 't', value: tex1 },
      tex_or: {type: 't', value: photo},
      scene: { type: 't', value: texwarp },
      mouseX: { type: 'f', value: mouseX},
      mouseY: { type: 'f', value: mouseY}
    },
    vertexShader: require('./shaders/pass_vert.glsl'),
    fragmentShader: require('./shaders/mix_frag.glsl'),
    side: THREE.DoubleSide
  });

  shaderwarp = new THREE.ShaderMaterial({
    uniforms: {
      time: { type: 'f', value: 0.0 },
      tex: { type: 't', value: photo },
      tex2: { type: 't', value: tex3 },
      mouseStatus: { type: 'i', value: 1 },
      mouseX: { type: 'f', value: mouseX},
      mouseY: { type: 'f', value: mouseY}
    },
    vertexShader: require('./shaders/pass_vert.glsl'),
    fragmentShader: require('./shaders/noise_warp_frag.glsl'),
    side: THREE.DoubleSide
  });

  let plane = new THREE.PlaneGeometry(w, h);
  let screen2 = new THREE.Mesh(plane, shader2);
  screen2.position.set(0,0,-w);
  scene2.add(screen2);

  let screen3 = new THREE.Mesh(plane, shader3);
  screen3.position.set(0,0,-w);
  scene3.add(screen3);

  let screenwarp = new THREE.Mesh(plane, shaderwarp);
  screenwarp.position.set(0,0,-w);
  scenewarp.add(screenwarp);

  renderer = new THREE.WebGLRenderer();
  renderer.setSize( window.innerWidth, window.innerHeight);
  renderer.autoClear = true;

  document.body.appendChild( renderer.domElement);
}

function animate(){
  setTimeout( function(){
    requestAnimationFrame(animate);
  }, 1000/ 30);
  
  render();
}

function render() {
  shader2.uniforms.time.value = 0.1 * globalTime;
  shader3.uniforms.time.value = 0.1 * globalTime;
  shaderwarp.uniforms.time.value = 0.1 * globalTime;
  shader2.uniforms.tex.value = tex1;

  if( video.readyState === video.HAVE_ENOUGH_DATA ){
    videoTexture.needsUpdate = true;
  };

  if( video2.readyState === video2.HAVE_ENOUGH_DATA ){
    videoTexture2.needsUpdate = true;
  };

  globalTime++;

  renderer.render(scene2, camera, tex2, false); 
  renderer.render(scene3, camera, tex3, false);
  renderer.render(scenewarp, camera, texwarp, false);
  renderer.render(scene2, camera);
  
  var tt = tex2;
  tex2 = tex1;
  tex1 = tt;
}
