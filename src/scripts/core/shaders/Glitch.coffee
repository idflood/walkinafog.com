define [
  'text!../../../shaders/basic.vert',
  'text!../../../shaders/glitch.frag',
  'Three',
], (basic_vert, glitch_frag) ->
  #### GlitchShader

  #window.textureDirt = THREE.ImageUtils.loadTexture("lens_dirt.jpg")

  namespace "Next.shaders",
    GlitchShader:
      uniforms:
        time: { type: "f", value: 0 }
        glitch_intensity: {type: "f", value: 0.1}
        resolution: { type: "v3", value: new THREE.Vector3(0,0,0) }
        offset_color: { type: "v3", value: new THREE.Vector3( 0.005, 0.0, 0.0 ) }
        tDiffuse: {type: "t", value: 0, texture: null}
        tLensDirt: {type: "t", value: 1, texture: null}
        tGlitch: {type: "t", value: 2, texture: null}
        #lensDirt: {type: "t", value: 0, texture: null}

      vertexShader: basic_vert
      fragmentShader: glitch_frag

