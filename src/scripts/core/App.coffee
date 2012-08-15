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
  'cs!core/objects/Bird',
  'cs!core/shaders/Glitch',
  'cs!core/utils/AudioManager',
  'cs!core/utils/Rc4Random',
  'cs!core/utils/LensFlareContainer',
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

        $("body").mousemove (e) =>
          maxW = document.width
          maxH = document.height
          dx = e.pageX
          dy = e.pageY
          @mouse.x = dx / maxW - 0.5
          @mouse.y = dy / maxH - 0.5

        document.addEventListener("webkitvisibilitychange", @handleVisibilityChange, false)

      createWorld: () =>
        @scene.fog = new THREE.FogExp2( 0x101213, 0.0035 )

        @sunLight = new THREE.DirectionalLight( 0xfbf5d2, 0 )
        @sunLight.position.set( 0, -200, -7220 )
        @scene.add( @sunLight )

        sphere = new THREE.SphereGeometry(200, 20, 20)
        sunMaterial = new THREE.MeshBasicMaterial({color: 0xfbf5d2, fog: false})
        @sun = new THREE.Mesh(sphere, sunMaterial)
        @sun.position.set(0, -200, -8000)
        @scene.add(@sun)
        @lensFlare = new Next.utils.LensFlareContainer(@scene, @sunLight)

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
        @cars3.position.z = -4170 + 2000 + 50
        @cars3.rotation.y = Math.PI * 0.5
        @scene.add(@cars3)

        @cars4 = new Next.objects.Cars(materialTrail2, cube2)
        @cars4.scale.x = 0.6
        @cars4.position.x = -300
        @cars4.position.z = -4320 + 2000 + 40 + 10
        @cars4.rotation.y = Math.PI * -0.5
        @scene.add(@cars4)

        treeGeometries = []
        # Create 10 different tree geometries
        for num in [0..10]
          treeGeometries.push(new Next.objects.Tree(plane, materialTree, materialTree2))

        # Create trees
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
        #materialSimple = new THREE.MeshBasicMaterial( { color: 0xffffff, fog: true } )
        materialSimple = new THREE.MeshLambertMaterial( { color: 0xffffff, fog: true } )
        materialWire = new THREE.MeshBasicMaterial( { color: 0xffffff, fog: true, wireframe: true } )
        @thing = new Next.shapes.Biped(this, materialSimple, materialWire)
        walker_scale = 0.3
        @thing.scale.set(walker_scale, walker_scale, walker_scale)
        @scene.add(@thing)
        @thing.position.y = 0
        @thing.position.z = 240

        # Create a bird
        @bird = new Next.objects.Bird()
        @bird.position.z = -3000
        birdscale = 0.02
        @bird.scale.set(birdscale, birdscale, birdscale)
        @bird.position.y = 12
        # Hide bird
        @bird.position.x = 300
        @scene.add(@bird)

        # Create sunrise sky texture
        @textureRise = THREE.ImageUtils.loadTexture("textures/sunrise.png")
        @materialSky = new THREE.MeshBasicMaterial( { map: @textureRise, fog: false, transparent: true, opacity: 0 } )
        skyPlane = new THREE.PlaneGeometry( 1, 1, 1, 1 )
        @sky = new THREE.Mesh(skyPlane, @materialSky)
        @sky.position.z = -10900
        @sky.position.y = 5000
        @sky.rotation.x = Math.PI * 0.5
        @sky.scale.set(10000,1,10000)
        @scene.add(@sky)

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

      componentToHex: (c) =>
        hex = c.toString(16)
        return hex.length == 1 ? "0" + hex : hex

      rgbToHex: (r, g, b) =>
        return "#" + @componentToHex(r) + @componentToHex(g) + @componentToHex(b)

      updateWorld: (time, delta) =>
        @time = time
        if @is_paused == true then return
        if @playing == false then return
        if !@audio then return

        realTime = @audio.now
        @audio.update()

        if realTime > 16.0
          @cars1.update(delta)
          @cars2.update(delta)
          @cars3.update(delta)
          @cars4.update(delta)
          if @audio.bass > 0.32 && Math.random() > 0.89
            @cars1.createMesh()
          if @audio.high > 0.37 && Math.random() > 0.86
            @cars2.createMesh()
          if @audio.bass > 0.32 && Math.random() > 0.80
            @cars3.createMesh()
          if @audio.mid > 0.33 && Math.random() > 0.52
            @cars4.createMesh()

        # Update city lights
        if realTime > 80.0
          @planes1.update(@audio.high > 0.37 && Math.random() > 0.82)

        # Offset walker position
        walkerOffsetZ = 0.0
        if realTime > 112.0 && realTime < 120.0
          walkerOffsetZ = -1210.0
        if realTime > 144.0
          walkerOffsetZ = 1000.0
          # Also more glitch near the end
          @mainShader.uniforms.offset_color.value.x = 0.02
          @mainShader.uniforms.glitch_intensity.value = 0.3

        # Update sky & sun near the end
        if realTime > 137
          @materialSky.opacity = (realTime - 137) * 0.01
        if realTime > 140.0
          @sun.position.y += delta * 10
          @sunLight.position.y = @sun.position.y + 100
          @sunLight.intensity = (realTime - 140) / 10
          col = new THREE.Color()
          colspeed = 0.001
          col.setRGB(.06667 + (realTime - 140) * colspeed, 0.08235 + (realTime - 144) * colspeed * 0.1, 0.090196 + (realTime - 144) * colspeed * 0.3)
          @renderer.setClearColor(col)
          @scene.fog.color = col

        # Update the bird
        if realTime > 133
          @bird.update(delta)
          @bird.position.x = 3
          @bird.position.z = -3260 + (realTime - 133) * 30

        # Update the walker
        @thing.update(time)
        @thing.position.z = 240.0 - realTime * 18.0 + walkerOffsetZ

        # Update cameras
        @cameras.update(realTime, @thing, @mouse)
        @renderModel.camera = @cameras.currentCamera

        # This is the end
        if realTime > 162.0 && @outro == false
          @outro = true
          $("body").css("background-color", "#fff")
          _gaq.push(["_trackEvent", "Animation", "completed"])
          $("#container canvas").fadeOut 7000, () =>
            @finished = true
            $("body").append('<a href="/" id="replay">Replay</a>')
            $("#replay").hide().fadeIn(300)

            $("footer .right").addClass("finished")
            $("body").append($("footer .right"))

        # Update the 2 main cars lines
        cars_offset_z = 50
        if @cameras.currentCamera == @cameras.cameraCity1 || @cameras.currentCamera == @cameras.cameraCity2
          cars_offset_z = -300
        @cars1.position.z = @cameras.currentCamera.position.z - cars_offset_z
        @cars2.position.z = @cameras.currentCamera.position.z - cars_offset_z

        # Update buildings texture (high quality settings)
        @buildings.update(@audio.bass > 0.32 && Math.random() > 0.82)

        if @mainShader
          @mainShader.uniforms[ 'time' ].value = time / 10
          @mainShader.uniforms[ 'resolution' ].value = new THREE.Vector3(window.innerWidth, window.innerHeight, 0)
