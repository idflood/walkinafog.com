define [
  'text!../../../shaders/plain.vert',
  'text!../../../shaders/plain.frag',
  'text!../../../shaders/blurvignette.vert',
  'text!../../../shaders/blurvignetteH.frag',
  'text!../../../shaders/blurvignetteV.frag',
  'Three',
], (plain_vert, plain_frag, blur_vert, blurH_frag, blurV_frag) ->
  #### CustomShaders
  
  namespace "Next.shaders",
    BlurVignetteH:
      uniforms:
        tDiffuse: { type: "t", value: 0, texture: null }
        h:   { type: "f", value: 1.0 / 512.0 }
        r: { type: "f", value: 0.35 }
      vertexShader: blur_vert
      fragmentShader: blurH_frag
    BlurVignetteV:
      uniforms:
        tDiffuse: { type: "t", value: 0, texture: null }
        v:   { type: "f", value: 1.0 / 512.0 }
        r: { type: "f", value: 0.35 }
      vertexShader: blur_vert
      fragmentShader: blurV_frag
    Plain:
      'vertex': plain_vert
      'fragment': plain_frag