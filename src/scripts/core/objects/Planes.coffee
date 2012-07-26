define [
  'Underscore',
  'libs/namespace',
  'Three',
], (_) ->
  #"use strict"
  
  namespace "Next.objects",
    # this is more vertical lines than planes, but why not...
    Planes: class Planes extends THREE.Object3D
      constructor: (@mat, @plane) ->
        super
        @random = new Next.utils.Rc4Random("dLorem ipusm dolor sit amet.")
        @maxLines = 100
        @rndSpacing = 2400
        @rndSpacingX = 18000
        @createMesh()

      update: (hasBeat) =>
        childs = @children.slice(0, @children.length)
        for k, obj of childs
          if obj.scale.x > 4.0
            obj.scale.x *= 0.96
          else
            obj.scale.x = 0.0001
            if hasBeat && obj.scale.x < 4.0 && Math.random() < 0.2
              obj.scale.x = 20 + @random.getRandom() * 189

      createMesh: () =>
        if @children.length >= @maxLines then return

        mesh = new THREE.Mesh(@plane, @mat)
        mesh.doubleSided = true
        #mesh.scale.set(10 + @random.getRandom() * 29, 1, 90000)
        mesh.scale.set(0.001, 1, 130000)
        mesh.position.y = 2000
        mesh.position.x = @random.getRandom() * @rndSpacingX - @rndSpacingX * 0.5
        #mesh.position.z = Math.random() * @rndSpacing - @rndSpacing * 0.5
        #mesh.position.z = 300 + Math.random() * 100
        #mesh.rotation.z = Math.PI / 2
        mesh.rotation.x = Math.PI * 0.5
        #mesh.rotation.y = Math.random() * 1.5 - 0.75
        mesh.rotation.y = mesh.position.x * -0.00015
        

        if @reverse == true
          mesh.position.x *= -1
          mesh.position.z -= 1200
          mesh.rotation.z *= -1
        @add(mesh)

        #if Math.random() < 0.9
        @createMesh()
