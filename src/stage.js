// import THREE from 'three';
const THREE = require('three');
const OrbitControls = require('three-orbit-controls')(THREE);

let props = {
  w: window.innerWidth,
  h: window.innerHeight
};

function init(loadCb, updateCb, renderCb = null) {
  let stage = {},
    scene,
    renderer,
    camera;

  window.addEventListener('load', initialize);

  function tick() {
    updateCb(stage);

    if(renderCb) {
      renderCb(stage);
    } else {
      renderer.render(scene, camera);
    }

    requestAnimationFrame(tick);
  }

  function initialize() {
    scene = new THREE.Scene();
    camera = new THREE.PerspectiveCamera( 45, window.innerWidth/window.innerHeight, 0.1, 10000 );
    renderer = new THREE.WebGLRenderer( { antialias: true } );
    renderer.setPixelRatio(window.devicePixelRatio);
    renderer.setSize(window.innerWidth, window.innerHeight);
    // renderer.setClearColor(0x3a15a9);

    let controls = new OrbitControls(camera, renderer.domElement);
    controls.enableDamping = true;
    controls.enableZoom = true;
    controls.target.set(0, 0, 0);
    controls.rotateSpeed = 0.3;
    controls.zoomSpeed = 1.0;
    controls.panSpeed = 2.0;

    document.body.appendChild(renderer.domElement);

    window.addEventListener('resize', () => {
      props.w = window.innerWidth;
      props.h = window.innerHeight;
      camera.aspect = window.innerWidth / window.innerHeight;
      camera.updateProjectionMatrix();
      renderer.setSize(window.innerWidth, window.innerHeight);
    });

    stage.scene = scene;
    stage.camera = camera;
    stage.renderer = renderer;

    tick();

    loadCb(stage); 
  };
}

export default {
  init,
  props
};