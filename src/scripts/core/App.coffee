define [
  'Underscore',
  'Three',
  'libs/namespace',
  'cs!core/utils/ThreeApp',
  'cs!core/objects/Buildings',
  'cs!core/objects/Tree',
  'cs!core/objects/Cars',
  'cs!core/objects/Planes',
  'cs!core/objects/Biped',
  'cs!core/shaders/Glitch',
  'cs!core/utils/AudioManager',
  'cs!core/utils/Rc4Random',
], (_) ->
  #### App
  namespace "Next",
    settings:
      postprocessing: true
      backgroundColor: 0x111517
    
    App: class App extends Next.ThreeApp
      constructor: () ->
        @mouse =
          x: 0
          y: 0
        @playing = false
        @is_paused = false
        @cameras = []
        @outro = false

        super

        $("#container canvas").fadeOut(0)
        @audio = new Next.utils.AudioManager("audio/walk_in_a_fog.mp3", @onSoundLoaded)
        
        @camera.position.set(0, 2, 200)
        @camera.lookAt(new THREE.Vector3(0,1480,0 - 3800))
        
        $("body").mousemove (e) =>
          maxW = document.width
          maxH = document.height
          dx = e.pageX
          dy = e.pageY
          @mouse.x = dx / maxW - 0.5
          @mouse.y = dy / maxH - 0.5

        document.addEventListener("webkitvisibilitychange", @handleVisibilityChange, false)

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
          @renderModel = new THREE.RenderPass(@scene, @currentCamera)
          @effectBloom = new THREE.BloomPass(1.3)
          @effectFilm = new THREE.FilmPass(0.51, 0.135, 648, false)
          @effectVignette = new THREE.ShaderPass( THREE.ShaderExtras[ "vignette" ] )
          @effectVignette.uniforms['darkness'].value = 1.6
                    
          @composer = new THREE.EffectComposer( @renderer )
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

      createWorld: () =>
        @scene.fog = new THREE.FogExp2( 0x101213, 0.0035 )

        @buildings = new Next.objects.Buildings()
        @buildings.position.z = -8000 + 2000
        @scene.add(@buildings)

        materialTree = new THREE.MeshBasicMaterial( { color: 0x333333, fog: true, doubleSided: true } )
        materialTree = new THREE.MeshPhongMaterial( { color: 0x333333, fog: true, doubleSided: true } )
        materialTree2 = new THREE.MeshBasicMaterial( { color: 0x555555, fog: true, doubleSided: true, wireframe: true } )
        plane = new THREE.PlaneGeometry( 1, 1, 1, 1 )

        
        materialTrail1 = new THREE.MeshBasicMaterial( { color: 0xff3333, fog: true,  blending: THREE.AdditiveBlending, transparent: true} )
        materialTrail2 = new THREE.MeshBasicMaterial( { color: 0xffffff, fog: true,  blending: THREE.AdditiveBlending, transparent: true} )

        materialPlane = new THREE.MeshBasicMaterial( { color: window.userColor, fog: false,  blending: THREE.AdditiveBlending, transparent: true} )

        @planes1 = new Next.objects.Planes(materialPlane, plane)
        @planes1.position.z = -10400
        @scene.add(@planes1)


        cube2 = new THREE.CubeGeometry( 1, 1, 1 )
        @cars1 = new Next.objects.Cars(materialTrail1, cube2)
        @cars1.position.x = 30
        @scene.add(@cars1)

        @cars2 = new Next.objects.Cars(materialTrail2, cube2, true)
        @cars2.position.x = -30
        @scene.add(@cars2)

        @cars3 = new Next.objects.Cars(materialTrail1, cube2)
        @cars3.scale.x = 0.6
        @cars3.position.x = 300
        @cars3.position.z = -4170 + 2000
        @cars3.rotation.y = Math.PI * 0.5
        @scene.add(@cars3)

        @cars4 = new Next.objects.Cars(materialTrail2, cube2)
        @cars4.scale.x = 0.6
        @cars4.position.x = -300
        @cars4.position.z = -4320 + 2000
        @cars4.rotation.y = Math.PI * -0.5
        @scene.add(@cars4)

        @cars5 = new Next.objects.Cars(materialTrail2, cube2)
        @cars5.scale.x = 0.6
        @cars5.position.x = -300
        @cars5.position.z = -7170 + 2000
        @cars5.rotation.y = Math.PI * -0.5
        @scene.add(@cars5)

        treeGeometries = []
        # create 10 different tree geometries
        for num in [0..10]
          treeGeometries.push(new Next.objects.Tree(plane, materialTree, materialTree2))

        treeScale = 0.5

        randomTrees = new Next.utils.Rc4Random("42z6drBPvsdfayBAJVT4kNHR")
        @trees = new THREE.Geometry()
        for num in [0..40]
          geom = treeGeometries[parseInt(randomTrees.getRandom() * 10)]
          tree = new THREE.Mesh(geom, materialTree)
          tree.position.x = 60
          tree.position.z = -9000 + num * 220 + randomTrees.getRandom() * 30
          tree.doubleSided = true
          THREE.GeometryUtils.merge(@trees, tree)

          geom = treeGeometries[parseInt(randomTrees.getRandom() * 10)]
          tree = new THREE.Mesh(geom, materialTree)
          tree.position.x = -60
          tree.position.z = -9000 + num * 220 + 110 + randomTrees.getRandom() * 30
          tree.doubleSided = true
          THREE.GeometryUtils.merge(@trees, tree)

        @treesMesh = new THREE.Mesh( @trees, materialTree )
        @treesMesh.doubleSided = true
        @treesMesh.position.z = 700
        @scene.add(@treesMesh)

        # Create a ground
        @materialPlane = new THREE.MeshLambertMaterial( { color: 0x050505, fog: true } )
        @plane = new THREE.PlaneGeometry( 30000, 30000, 10, 10 )
        ground = new THREE.Mesh( @plane, @materialPlane )
        @scene.add(ground)

        # Create a walker
        materialSimple = new THREE.MeshBasicMaterial( { color: 0xffffff, fog: true } )
        materialWire = new THREE.MeshBasicMaterial( { color: 0xffffff, fog: true, wireframe: true } )
        @thing = new Next.shapes.Biped(this, materialSimple, materialWire)
        walker_scale = 0.3
        @thing.scale.set(walker_scale, walker_scale, walker_scale)
        @scene.add(@thing)
        @thing.position.y = 0
        @thing.position.z = 240

        # And the cameras
        @cameraSide1 = new THREE.PerspectiveCamera( 60, window.innerWidth / window.innerHeight, 1, 20000 )
        @cameraSide1.position.set(500, 2, 200)
        @cameraSide1.lookAt(new THREE.Vector3(0,50,200))
        @scene.add(@cameraSide1)
        @cameras.push(@cameraSide1)

        @cameraSide2 = new THREE.PerspectiveCamera( 60, window.innerWidth / window.innerHeight, 1, 20000 )
        @cameraSide2.position.set(100, 2, 200)
        @cameraSide2.lookAt(new THREE.Vector3(0,30,150))
        @scene.add(@cameraSide2)
        @cameras.push(@cameraSide2)
        
        @cameraIntro2 = new THREE.PerspectiveCamera( 60, window.innerWidth / window.innerHeight, 1, 20000 )
        @cameraIntro2.position.set(89, 5, -250)
        @cameraIntro2.lookAt(new THREE.Vector3(0,10,-280))
        @scene.add(@cameraIntro2)
        @cameras.push(@cameraIntro2)

        @cameraIntro3 = new THREE.PerspectiveCamera( 60, window.innerWidth / window.innerHeight, 1, 20000 )
        @cameraIntro3.position.set(70, 2, -280)
        @cameraIntro3.lookAt(new THREE.Vector3(0,15,-270))
        @scene.add(@cameraIntro3)
        @cameras.push(@cameraIntro3)

        @cameraCity1 = new THREE.PerspectiveCamera( 60, window.innerWidth / window.innerHeight, 1, 20000 )
        @cameraCity1.position.set(160, 220, -5070 + 2000)
        @cameraCity1.lookAt(new THREE.Vector3(0,0,-4980 + 2000))
        @scene.add(@cameraCity1)
        @cameras.push(@cameraCity1)

        @cameraCity2 = new THREE.PerspectiveCamera( 60, window.innerWidth / window.innerHeight, 1, 20000 )
        @cameraCity2.position.set(160, 320, -4500 + 2000)
        @cameraCity2.lookAt(new THREE.Vector3(0,0,-4100 + 2000))
        @scene.add(@cameraCity2)
        @cameras.push(@cameraCity2)

        @cameraCityTop1 = new THREE.PerspectiveCamera( 80, window.innerWidth / window.innerHeight, 1, 20000 )
        @cameraCityTop1.position.set(0, 250, -2180)
        @cameraCityTop1.lookAt(new THREE.Vector3(0,0,-2200))
        @scene.add(@cameraCityTop1)
        @cameras.push(@cameraCityTop1)

        @currentCamera = @cameraSide1

      onResize: () =>
        super
        ratio = window.innerWidth / window.innerHeight
        for camera in @cameras
          camera.aspect = ratio
          camera.updateProjectionMatrix()
      
      onSoundLoaded: () =>
        @playing = true
        $("#container canvas").delay(20).fadeIn(3000)

      handleVisibilityChange: () =>
        if @finished == true then return

        if document.webkitHidden
          @audio.pause()
          @is_paused = true
        else
          @audio.play()
          @is_paused = false

      updateWorld: (time, delta) =>
        @time = time
        if @is_paused == true then return
        if @playing == false then return

        if @audio && @audio
          realTime = @audio.now
        else
          realTime = 0

        if !@audio then return
        
        @audio.update()
        walkerOffsetZ = 0.0
        cameraOffsetZ = 0.0

        if realTime > 16.0
          @cars1.update()
          @cars2.update()
          @cars3.update()
          @cars4.update()
          @cars5.update()
          if @audio.bass > 0.32 && Math.random() > 0.89
            #console.log @audio.bass
            @cars1.createMesh()
          if @audio.high > 0.37 && Math.random() > 0.86
            @cars2.createMesh()
          if @audio.bass > 0.32 && Math.random() > 0.80
            @cars3.createMesh()
          if @audio.mid > 0.33 && Math.random() > 0.52
            @cars4.createMesh()
            @cars5.createMesh()

        if realTime > 80.0
          @planes1.update(@audio.high > 0.37 && Math.random() > 0.82)

        switchCameras = true
        @cameraSide1.position.x += (90 - @cameraSide1.position.x) * 0.0015
        @cameraSide1.position.z = 200.0 - realTime * 18.0 + 20
        @cameraSide2.position.z = 200.0 - realTime * 18.0 + 10
        cameraTop_speedY = 0
        if switchCameras
          if realTime > 25.0
            @currentCamera = @cameraIntro2
          if realTime > 28.0
            @currentCamera = @cameraIntro3
            @cameraIntro3.position.z = 200.0 - realTime * 12.0 - 150.0
          if realTime > 32.0
            @cameraSide1.position.x = 150
            @cameraSide1.position.y = 10 - 2
            @cameraSide1.lookAt(@thing.position)
            @currentCamera = @cameraSide1
          
          if realTime > 41.0 then @currentCamera = @cameraSide2
          if realTime > 45.0
            @currentCamera = @cameraSide1
            @cameraSide1.position.y = 1
            @cameraSide1.position.x = 65
            @cameraSide1.lookAt(new THREE.Vector3(@thing.position.x, @thing.position.y + 30, @thing.position.z + 10))
          if realTime > 49.0
            @currentCamera = @cameraIntro3
            @cameraIntro3.position.z = 200.0 - realTime * 15.0 - 130.0
          if realTime > 53.0
            @currentCamera = @cameraIntro2
            @cameraIntro2.position.z = -730
            @cameraIntro2.position.y = 1

          if realTime > 57.0
            @currentCamera = @cameraSide2
            @cameraSide2.position.z = 200.0 - realTime * 12.0 - 290.0
            @cameraIntro3.position.x = 130.0

          if realTime > 64.0 then @currentCamera = @camera
          if realTime > 96.0 then @currentCamera = @cameraCityTop1
          if realTime > 112.0 && realTime < 120.0
            walkerOffsetZ = -1210.0
            @currentCamera = @cameraCity1
            @cameraCity1.lookAt(@thing.position)
          if realTime > 120.0 && realTime <= 133.0
            walkerOffsetZ = -200.0
            @currentCamera = @cameraCity2
            @cameraCity2.position.y += (120 - @cameraCity2.position.y) * 0.002
            #@cameraCity2.lookAt(@thing.position)
            # position camera top for next frame
            @cameraCityTop1.position.z = -2180


          if realTime > 133.0
            @currentCamera = @cameraCityTop1
            cameraTop_speedY += 0.5 + cameraTop_speedY
            @cameraCityTop1.position.y += cameraTop_speedY
            @cameraCityTop1.position.z -= 0.6

          # little hack for last step to avoid camera in the middle of car line
          if realTime > 142.0 && realTime < 143.0
            cameraOffsetZ = -700.0
          if realTime > 144.0
            walkerOffsetZ = 1000.0

            @currentCamera = @camera
            @mainShader.uniforms.offset_color.value.x = 0.02
            @mainShader.uniforms.glitch_intensity.value = 0.3

        # This is the end
        if realTime > 169.0 && @outro == false
          @outro = true
          _gaq.push(["_trackEvent", "Animation", "completed"])
          $("#container canvas").fadeOut 5000, () =>
            @finished = true
            $("body").append('<a href="/" id="replay">Replay</a>')
            $("#replay").hide().fadeIn(300)

        @renderModel.camera = @currentCamera
        
        if @currentCamera == @camera && realTime < 169.0
          $("#container canvas").addClass("interactive")
        else
          $("#container canvas").removeClass("interactive")

        @camera.position.z = 200.0 - realTime * 18.0 + cameraOffsetZ
        @thing.update()
        @thing.position.z = 240.0 - realTime * 18.0 + walkerOffsetZ

        @cameraIntro2.lookAt(@thing.position)
        @cameraCityTop1.position.z -= 0.1
        
        @camera.position.y = 4 + Math.sin(time * 0.5) * 0.6
        rx = @mouse.x * -0.8
        ry = @mouse.y * -0.4 + 0.4
        @camera.rotation.y += (rx - @camera.rotation.y) * 0.2
        @camera.rotation.x += (ry - @camera.rotation.x) * 0.2

        @cameraCity2.lookAt(new THREE.Vector3(0,0,-4100 + 2000))

        cars_offset_z = 50
        if @currentCamera == @cameraCity1 || @currentCamera == @cameraCity2
          cars_offset_z = -300

        @cars1.position.z = @currentCamera.position.z - cars_offset_z
        @cars2.position.z = @currentCamera.position.z - cars_offset_z
        
        @buildings.update(@audio.bass > 0.32 && Math.random() > 0.82)

        if @mainShader
          @mainShader.uniforms[ 'time' ].value = time / 10
          @mainShader.uniforms[ 'resolution' ].value = new THREE.Vector3(window.innerWidth, window.innerHeight, 0)
