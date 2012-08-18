define [
  'Underscore',
  'libs/namespace',
  'cs!core/objects/BuildingBlock',
  'cs!core/utils/Rc4Random',
  'Three',
], (_) ->
  #### Buildings

  namespace "Next.objects",
    Buildings: class Buildings extends THREE.Object3D
      constructor: () ->
        super

        @numWindows = 60
        @spacing = 1
        @windowsOn = []

        @createReflections = false

        # create main random generators
        @random = new Next.utils.Rc4Random("Lorem ipusm dolor sit amet.")
        @randomBuildings = new Next.utils.Rc4Random("rBPvyBA1MUhvJVT4kNH6sLsAz6dRfwL6")
        @randomTexture = new Next.utils.Rc4Random("6s13LsAz6drBPvsdfayBAJVT4kNHRfwL1MUhv6")

        @createShaders()
        @buildingsGeom = new THREE.Geometry()
        if @createReflections == true
          @reflectionsGeom = new THREE.Geometry()

        @cubeRoof = new THREE.CubeGeometry( 1, 1, 1, 1, 1, 1, @materials )
        @cubeRoof.dynamic = false
        # all roof cube faces use the same material
        for face, i in @cubeRoof.faces
          face.materialIndex = 1

        if @createReflections == true
          # plane for some kind of "road reflection"
          @plane = new THREE.PlaneGeometry( 1, 1, 1, 1 )
          @plane.materials = @materials
          @plane.faces[0].materialIndex = 2
        @buildingCount = 0
        # create some cubes
        for num in [0..10]
          @createBuildingLine(num * 220 + 135, num)

        for num in [0..10]
          @createBuildingLine(num * -220 - 290, num)

        @buildings = new THREE.Mesh(@buildingsGeom, @material)
        @add(@buildings)
        @buildingsGeom.dynamic = false

        if @createReflections == true
          @reflections = new THREE.Mesh(@reflectionsGeom, @reflectionMaterial)
          @add(@reflections)

      updateWindow: (num, num2, triggerLight) =>
        if @windowsOn[num][num2] == -1.0 then return
        # fade values to 0
        @windowsOn[num][num2] *= 0.98

        # reset value to 0 if small enough
        if @windowsOn[num][num2] <= 0.05 then @windowsOn[num][num2] = 0
        # if value == 0 and trigger light put some lights on
        if triggerLight && @windowsOn[num][num2] == 0 && Math.random() < 0.4
          @windowsOn[num][num2] = 1.0

        # 1.0 means light on so we need to reverse the value
        alpha = 1.0 - @windowsOn[num][num2]
        dx = @spacing + num * (@windowSize + @spacing) - 1
        dy = num2 * (@windowSize + @spacing) - 1
        dw = @windowSize + 2 - @spacing
        dh = (@windowSize + 2 - @spacing)

        @contextCopy.fillStyle = "rgba(0, 0, 0, " + alpha + ")"
        @contextCopy.fillRect(dx, dy, dw, dh)

      update: (triggerLight) =>
        if window.highQuality == false then return

        @contextCopy.drawImage(@canvas, 0, 0)
        @texture.needsUpdate = true

        for num in [0..@numWindows - 1]
          for num2 in [0..@numWindows - 1]
            @updateWindow(num, num2, triggerLight)

      createBuildingLine: (dx, i) =>
        dz = -2000
        if dx > 0 then dz = -1640
        #if dx > 0 then dz = -1820
        #if dx > 0 then dz = -2400
        for num in [0..40]
          if i < 3 || (num < 3 || num > 37)
            building = new Next.objects.BuildingBlock( @materials, @material, @cubeRoof, @plane, @randomBuildings, @createReflections )
            building.mesh.position.x = parseInt(0 - building.cubeWidth / 2 - dx + @random.getRandom() * 30)
            if dx == 0 && @random.getRandom() < 0.4
              building.mesh.position.x *= @random.getRandom() * 50
            dz += building.cubeDepth / 2
            building.mesh.position.z = dz
            dz += parseInt(building.cubeDepth / 2 + 10 + @random.getRandom() * 20)

            THREE.GeometryUtils.merge(@buildingsGeom, building.mesh)
            if @createReflections == true
              building.ref.position.x = building.mesh.position.x
              building.ref.position.z = building.mesh.position.z
              THREE.GeometryUtils.merge(@reflectionsGeom, building.ref)
            @buildingCount++

      createShaders: () =>
        @wallcolor = '#050505'
        @createTexture()
        @createRoofTexture()

        if @createReflections == true
          @reflectionMaterial = new THREE.MeshBasicMaterial
            map: THREE.ImageUtils.loadTexture("textures/building_road_reflection4.png"),
            fog: true,
            transparent: true,
            blending: THREE.AdditiveBlending,
            depthWrite: false,
            color: 0x000000
            opacity: 0.7,
            #overdraw: true
        @materialCube = new THREE.MeshPhongMaterial( { map: @texture, emissive: 0x777777, fog: true, wireframe: false } )
        @materialCubeRoof = new THREE.MeshPhongMaterial( { map: @roofTexture, fog: true, wireframe: false } )
        @materialWire = new THREE.MeshBasicMaterial( { color: 0xeeeeee, fog: true, doubleSided: true, wireframe: true } )

        @materials = []
        @materials.push(@materialCube)
        @materials.push(@materialCubeRoof)
        @materials.push(@reflectionMaterial)

        @material = new THREE.MeshFaceMaterial()

      rndColor: (ofr = 0, ofg = 0, ofb = 0, ampR = 1.0, ampG = 1.0, ampB = 1.0) =>
        r = ('0' + Math.floor(Math.random() * (256 - ofr) * ampR + ofr).toString(16)).substr(-2)
        g = ('0' + Math.floor(Math.random() * (256 - ofg) * ampG + ofg).toString(16)).substr(-2)
        b = ('0' + Math.floor(Math.random() * (256 - ofb) * ampB + ofb).toString(16)).substr(-2)
        return '#' + r + g + b
      rndGray: (ofr = 0, ampR = 1.0) =>
        r = ('0' + Math.floor(Math.random() * (256 - ofr) * ampR + ofr).toString(16)).substr(-2)
        return '#' + r + r + r

      createRoofTexture: () =>
        @textureSize = 32
        canvas = document.createElement("canvas")
        context = canvas.getContext("2d")
        canvas.width = @textureSize
        canvas.height = @textureSize

        context.fillStyle = @wallcolor
        context.fillRect(0,0,@textureSize,@textureSize)
        @roofTexture = new THREE.Texture(canvas)
        @roofTexture.needsUpdate = true

      drawWindow: (context, dx, dy, dw, dh) =>
        hasLight = @randomTexture.getRandom() > 0.7
        if hasLight
          context.fillStyle = @rndColor(240, 230, 160, 1.0, 0.9, 0.6)
        else
          context.fillStyle = @rndGray(5, 0.4)
        context.fillRect(dx, dy, dw, dh)
        context.fillStyle = @rndGray(5, 0.2)
        for num in [0..parseInt(Math.random() * 5)]
          dw2 = dw - parseInt(Math.random() * dw)
          dh2 = parseInt(dh / 2 - (Math.random() * (dh / 2)))
          dx2 = parseInt(Math.random() * (dw - dw2)) + dx
          dy2 = parseInt(dh - dh2) + dy
          context.fillRect(dx2, dy2, dw2, dh2)

      createTexture: () =>
        @textureSize = 512
        # build the original canvas
        canvas = document.createElement("canvas")
        context = canvas.getContext("2d")
        canvas.width = @textureSize
        canvas.height = @textureSize

        # create a copy where the original canvas will be processed
        canvasCopy = document.createElement("canvas")
        @contextCopy = canvasCopy.getContext("2d")
        canvasCopy.width = @textureSize
        canvasCopy.height = @textureSize

        maxW = @textureSize - 2 * @spacing
        @windowSize = (maxW / @numWindows) - @spacing

        context.fillStyle = @wallcolor
        context.fillRect(0,0,@textureSize,@textureSize)

        for num in [0..@numWindows - 1]
          @windowsOn[num] = []
          # add some bright rooms vertically
          for num2 in [0..@numWindows - 1]
            @windowsOn[num][num2] = -1.0
            if @randomTexture.getRandom() < 0.5
              @windowsOn[num][num2] = 1.0
              # some windows always on
              if Math.random() < 0.05 then @windowsOn[num][num2] = -1.0

              dx = @spacing + num * (@windowSize + @spacing)
              dy = num2 * (@windowSize + @spacing)
              dw = @windowSize - @spacing
              dh = (@windowSize - @spacing)
              @drawWindow(context, dx, dy, dw, dh)

        @canvasCopy = canvasCopy
        @canvas = canvas
        @contextCopy.drawImage(@canvas, 0, 0)

        @texture = new THREE.Texture(@canvasCopy)
        @texture.wrapS = THREE.RepeatWrapping
        @texture.wrapT = THREE.RepeatWrapping
        #@texture.generateMipmaps = false
        #@texture.magFilter = THREE.LinearFilter
        #@texture.minFilter = THREE.LinearFilter
        @texture.needsUpdate = true
