define [
  'Underscore',
  'libs/namespace',
  'Three',
], (_) ->
  #### BuildingBlock

  namespace "Next.objects",

    BuildingBlock: class BuildingBlock
      constructor: (@materials, @material, @cubeRoof, @plane, @random) ->
        @cubeWidth = parseInt(100 + @random.getRandom() * 100)
        @cubeDepth = parseInt(100 + @random.getRandom() * 100)
        @cubeHeight = parseInt(50 + @random.getRandom() * 200)

        @combined = new THREE.Geometry()
        # create the main cube
        cube = new THREE.CubeGeometry( @cubeWidth, @cubeHeight, @cubeDepth, 1, 1, 1, @materials )
        @setObjectUV(cube)
        @setFacesIndices(cube)
        @object = new THREE.Mesh( cube, @material )
        @object.position.y = @cubeHeight / 2
        THREE.GeometryUtils.merge(@combined, @object)

        dy = @cubeHeight / 2
        w2 = @cubeWidth
        d2 = @cubeDepth

        # create top separation
        obj = new THREE.Mesh( @cubeRoof, @material )
        obj.scale.set(@cubeWidth * 1.01, 2 + @random.getRandom() * 10, @cubeDepth * 1.01)
        obj.position.y = @cubeHeight
        THREE.GeometryUtils.merge(@combined, obj)

        if @random.getRandom() > 0.7
          for num in [0..parseInt(@random.getRandom() * 2)]
            cubeHeight2 = parseInt(50 + @random.getRandom() * 200)
            w2 = w2 * (@random.getRandom() * 0.5 + 0.5)
            d2 = d2 * (@random.getRandom() * 0.5 + 0.5)
            cube = new THREE.CubeGeometry( w2, cubeHeight2, d2, 1, 1, 1, @materials )
            @setObjectUV(cube)
            @setFacesIndices(cube)
            object = new THREE.Mesh( cube, @material )
            object.position.y = cubeHeight2 / 2 + dy

            THREE.GeometryUtils.merge(@combined,object)

            dy += cubeHeight2

            obj = new THREE.Mesh( @cubeRoof, @material )
            obj.scale.set(w2 * 1.01, 2 + @random.getRandom() * 10, d2 * 1.01)
            obj.position.y = dy
            THREE.GeometryUtils.merge(@combined, obj)

        # add the pseudo reflection
        @ref = new THREE.Mesh(@plane, @materials[2])
        rndref = @random.getRandom() * 0.5
        multref = 1.3
        @ref.scale.set(@cubeWidth * multref + rndref, 1, @cubeDepth * multref + rndref)
        @ref.position.y = @random.getRandom() + 0.1
        #THREE.GeometryUtils.merge(@combined, ref)

        @mesh = new THREE.Mesh( @combined, @material )

      setFacesIndices: (ob) =>
        ob.faces[0].materialIndex = 0
        ob.faces[1].materialIndex = 0
        ob.faces[2].materialIndex = 1 # top
        ob.faces[3].materialIndex = 1 # bottom
        ob.faces[4].materialIndex = 0
        ob.faces[5].materialIndex = 0

      setObjectUV: (ob) =>
        scaleTexture = 0.4
        offsetX = Math.random()
        offsetY = Math.random()
        for num in [0..5]
          ob.faceVertexUvs[0][num][0].u = offsetX
          ob.faceVertexUvs[0][num][0].v = offsetY
          ob.faceVertexUvs[0][num][1].u = offsetX
          ob.faceVertexUvs[0][num][1].v = scaleTexture + offsetY
          ob.faceVertexUvs[0][num][2].u = scaleTexture + offsetX
          ob.faceVertexUvs[0][num][2].v = scaleTexture + offsetY
          ob.faceVertexUvs[0][num][3].u = scaleTexture + offsetX
          ob.faceVertexUvs[0][num][3].v = offsetY
