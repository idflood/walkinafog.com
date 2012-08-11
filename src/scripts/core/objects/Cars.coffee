define [
  'Underscore',
  'libs/namespace',
  'Three',
], (_) ->
  #"use strict"

  namespace "Next.objects",
    Cars: class Cars extends THREE.Object3D
      constructor: (@mat, @plane, @reverse = false) ->
        super
        @maxLines = 40
        @rndSpacing = 20

      createMesh: () =>
        if @children.length >= @maxLines then return

        mesh = new THREE.Mesh(@plane, @mat)
        mesh.doubleSided = true
        mesh.scale.set(1 + Math.random() * 2, 1, 100 + Math.random() * 150)
        mesh.position.y = 4
        mesh.position.x = Math.random() * @rndSpacing - @rndSpacing * 0.5
        mesh.position.z = 300 + Math.random() * 100
        mesh.rotation.z = Math.PI / 2

        if @reverse == true
          mesh.position.x *= -1
          mesh.position.z -= 1200
          mesh.rotation.z *= -1
        @add(mesh)

        if Math.random() < 0.4
          @createMesh()

      update: () =>
        #return
        speed = 40
        childs = @children.slice(0, @children.length)
        #console.log childs.length
        for k, obj of childs
          if @reverse == true
            obj.position.z += speed
            if obj.position.z > 300 then @remove(obj)
          else
            obj.position.z -= speed
            if obj.position.z < -1000 then @remove(obj)
