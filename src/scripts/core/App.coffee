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

      updateLensFlare: (object) =>
        @lensFlare.position.y = @sunLight.position.y
        vecX = -object.positionScreen.x * 2
        vecY = -object.positionScreen.y * 2
        for f in [0..object.lensFlares.length-1]
          flare = object.lensFlares[f]
          flare.x = object.positionScreen.x + vecX * flare.distance
          flare.y = object.positionScreen.y + vecY * flare.distance
          flare.rotation = 0
          flare.scale = 0.5
        object.lensFlares[ 2 ].y += 0.025
        object.lensFlares[ 3 ].rotation = object.positionScreen.x * 0.5 + 45 * Math.PI / 180

      createLensFlare: () =>
        textureFlare0 = THREE.ImageUtils.loadTexture("textures/flare0.png")
        textureFlare2 = THREE.ImageUtils.loadTexture( "textures/flare2.png" )
        textureFlare3 = THREE.ImageUtils.loadTexture( "textures/flare3.png" )
        flareColor = new THREE.Color( 0xffffff )

        @lensFlare = new THREE.LensFlare( textureFlare0, 700, 0.0, THREE.AdditiveBlending, flareColor )
        @lensFlare.add( textureFlare2, 512, 0.0, THREE.AdditiveBlending )
        @lensFlare.add( textureFlare2, 512, 0.0, THREE.AdditiveBlending )
        @lensFlare.add( textureFlare2, 512, 0.0, THREE.AdditiveBlending )
        @lensFlare.add( textureFlare3, 60, 0.6, THREE.AdditiveBlending )
        @lensFlare.add( textureFlare3, 70, 0.7, THREE.AdditiveBlending )
        @lensFlare.add( textureFlare3, 120, 0.9, THREE.AdditiveBlending )
        @lensFlare.add( textureFlare3, 70, 1.0, THREE.AdditiveBlending )

        @lensFlare.position = @sunLight.position
        @lensFlare.customUpdateCallback = @updateLensFlare
        @scene.add( @lensFlare )

      createWorld: () =>
        @scene.fog = new THREE.FogExp2( 0x101213, 0.0035 )

        @sunLight = new THREE.DirectionalLight( 0xfbf5d2, 0 )
        @sunLight.position.set( 0, -150, -7220 )
        @scene.add( @sunLight )
        console.log @sunLight

        sphere = new THREE.SphereGeometry(200, 20, 20)
        sunMaterial = new THREE.MeshBasicMaterial({color: 0xfbf5d2, fog: false})
        @sun = new THREE.Mesh(sphere, sunMaterial)
        @sun.position.set(0, -150, -8000)
        @scene.add(@sun)
        @createLensFlare()

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
        @cars5.position.y = 100
        @cars5.position.z = -7170 + 2000
        @cars5.rotation.y = Math.PI * -0.5
        #@scene.add(@cars5)

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
        #@materialPlane = new THREE.MeshLambertMaterial( { color: 0x111111, fog: true } )
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
        if !@audio then return

        realTime = @audio.now
        @audio.update()

        walkerOffsetZ = 0.0

        if realTime > 16.0
          @cars1.update()
          @cars2.update()
          @cars3.update()
          @cars4.update()
          @cars5.update()
          if @audio.bass > 0.32 && Math.random() > 0.89
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

        if realTime > 112.0 && realTime < 120.0
          walkerOffsetZ = -1210.0
        if realTime > 144.0
          walkerOffsetZ = 1000.0
          @mainShader.uniforms.offset_color.value.x = 0.02
          @mainShader.uniforms.glitch_intensity.value = 0.3

        if realTime > 144.0
          @sun.position.y += delta * 15
          @sunLight.position.y = @sun.position.y + 100
          @sunLight.intensity = (realTime - 144) / 10

        @thing.update()
        @thing.position.z = 240.0 - realTime * 18.0 + walkerOffsetZ

        # update cameras
        @cameras.update(realTime, @thing, @mouse)
        @renderModel.camera = @cameras.currentCamera

        # This is the end
        if realTime > 169.0 && @outro == false
          @outro = true
          $("body").css("background-color", "#fff")
          _gaq.push(["_trackEvent", "Animation", "completed"])
          $("#container canvas").fadeOut 5000, () =>
            @finished = true
            $("body").append('<a href="/" id="replay">Replay</a>')
            $("#replay").hide().fadeIn(300)

        cars_offset_z = 50
        if @cameras.currentCamera == @cameras.cameraCity1 || @cameras.currentCamera == @cameras.cameraCity2
          cars_offset_z = -300

        @cars1.position.z = @cameras.currentCamera.position.z - cars_offset_z
        @cars2.position.z = @cameras.currentCamera.position.z - cars_offset_z

        @buildings.update(@audio.bass > 0.32 && Math.random() > 0.82)

        if @mainShader
          @mainShader.uniforms[ 'time' ].value = time / 10
          @mainShader.uniforms[ 'resolution' ].value = new THREE.Vector3(window.innerWidth, window.innerHeight, 0)
