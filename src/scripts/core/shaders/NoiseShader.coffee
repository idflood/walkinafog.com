define [
  'cs!core/shaders/CustomShaders',
  'Three',
], () ->
  #### Soundtrack
  
  namespace "Next.shaders",
    NoiseShader: class NoiseShader extends THREE.ShaderMaterial
      constructor: (parameters) ->
        super
        if typeof parameters.color is "string"
          parameters.color = new THREE.Color(parseInt(parameters.color))
          
        if typeof parameters.color is "number"
          parameters.color = new THREE.Color(parameters.color)
        uniforms =
          color:
            type: 'c'
            value: parameters.color
          amplitude:
            type: 'f'
            value: 0.0
          time:
            type: 'f'
            value: 0
          fogDensity:
            type: 'f'
            value: 0.00025
          fogNear:
            type: 'f'
            value: 1
          fogFar:
            type: 'f'
            value: 2000
          fogColor:
            type: 'c'
            value: new THREE.Color(0xffffffff)
        @uniforms = uniforms
        @vertexShader = Next.shaders.Plain.vertex
        @fragmentShader = Next.shaders.Plain.fragment
        @fog = true
        @doubleSided = true
        #wireframe = true