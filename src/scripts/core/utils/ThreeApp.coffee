define [
  'Underscore',
  'libs/namespace',
  'cs!core/utils/AutoReload',
  'cs!core/utils/CameraManager',
  'Three',
  'EffectComposer',
  'RenderPass',
  'BloomPass',
  'FilmPass',
  'TexturePass',
  'ShaderPass',
  'MaskPass',
  'ShaderExtras',
], (_) ->
  #### App
  
  namespace "Next",
    ThreeApp: class ThreeApp
      constructor: () ->
        @finished = false
        @preInit()
        @onResize()
        @animate()
      
      preInit: () =>
        # Setup autoreload on source change
        new Next.AutoReload()
        
        # Setup some other variables
        @clock = new THREE.Clock()
        @scene = new THREE.Scene()
        
        @createCamera()
        @createLights()
        @createWorld()
        @createRenderer()
        
        $(window).bind "resize", (e) => @onResize()
      
      createRenderer: () =>
        # Create html container
        $("body").append("<div id='container'></div>")
        @container = $("#container")[0]
        
        # Create a webgl renderer
        @renderer = new THREE.WebGLRenderer( { clearColor: Next.settings.backgroundColor, clearAlpha: 1, antialias: false } )
        @renderer.setSize( window.innerWidth, window.innerHeight )
        @renderer.autoClear = false
        # Add the renderer to the dom
        @container.appendChild( @renderer.domElement )
        
        if Next.settings.postprocessing == true
          @renderModel = new THREE.RenderPass(@scene, @cameras.currentCamera)
          @effectBloom = new THREE.BloomPass(1.3)
          @effectFilm = new THREE.FilmPass(0.51, 0.135, 648, false)
          @effectVignette = new THREE.ShaderPass( THREE.ShaderExtras[ "vignette" ] )
          @effectVignette.uniforms['darkness'].value = 1.6
          
          renderTargetParameters = { minFilter: THREE.LinearFilter, magFilter: THREE.LinearFilter, format: THREE.RGBAFormat, stencilBuffer: false }
          @renderTarget = new THREE.WebGLRenderTarget( window.innerWidth, window.innerHeight, renderTargetParameters )

          @composer = new THREE.EffectComposer( @renderer, @renderTarget )
          @composer.addPass( @renderModel )
          @composer.addPass( @effectBloom )
          @composer.addPass( @effectFilm )

          textureDirt = THREE.ImageUtils.loadTexture("textures/lens_dirt.jpg")
          textureGlitch = THREE.ImageUtils.loadTexture("textures/glitch3.jpg")
          @mainShader = new THREE.ShaderPass( Next.shaders.GlitchShader )

          @mainShader.material.uniforms.tLensDirt.texture = textureDirt
          @mainShader.material.uniforms.tGlitch.texture = textureGlitch
          @composer.addPass( @mainShader )

          @composer.addPass( @effectVignette )
          
          # make the last pass render to screen so that we can see something
          @effectVignette.renderToScreen = true
      
      createLights: () =>
        @directionalLight = new THREE.DirectionalLight( 0xffffff, 1.15 )
        @directionalLight.position.set( 500, 1000, 0 )
        @scene.add( @directionalLight )
      
      createCamera: () =>
        @cameras = new Next.utils.CameraManager(@scene)
      
      # Needs to be overriden
      createWorld: () => return false
      updateWorld: () => return false
      
      animate: () =>
        delta = @clock.getDelta()
        time = @clock.getElapsedTime() * 10

        @updateWorld(time, delta)
        @render(time, delta)

        if @finished == false then requestAnimationFrame( @animate )
      
      render: (time, delta) =>
        @renderer.clear()
        
        if @composer
          @composer.render(delta)
        else
          @renderer.render(@scene, @cameras.currentCamera)

      onResize: () =>
        ratio = window.innerWidth / window.innerHeight
        for camera in @cameras.items
          camera.aspect = ratio
          camera.updateProjectionMatrix()
        
        @renderer.setSize( window.innerWidth, window.innerHeight )
        if @composer
          @composer.reset()
      
