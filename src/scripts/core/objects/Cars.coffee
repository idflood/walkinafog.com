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
        @availableMeshes = []
        for num in [0..@maxLines - 1]
          mesh = new THREE.Mesh(@plane, @mat)
          mesh.doubleSided = true
          mesh.scale.set(1 + Math.random() * 2, 1, 100 + Math.random() * 150)
          # hide mesh
          mesh.position.y = -400

          mesh.position.x = Math.random() * @rndSpacing - @rndSpacing * 0.5
          mesh.rotation.z = Math.PI / 2

          if @reverse == true
            mesh.position.x *= -1
            mesh.rotation.z *= -1
          @availableMeshes.push(mesh)
          @add(mesh)

      createMesh: () =>
        if @availableMeshes.length == 0 then return
        mesh = @availableMeshes.splice(0,1)
        mesh = mesh[0]
        mesh.position.y = 4
        mesh.position.z = 300 + Math.random() * 100
        if @reverse == true
          mesh.position.z -= 1200
        if Math.random() < 0.4
          @createMesh()

      dispose: (obj) =>
        obj.position.y = -400
        @availableMeshes.push(obj)

      update: () =>
        speed = 40
        #childs = @children.slice(0, @children.length)
        #console.log childs.length
        for k, obj of @children
          if @reverse == true
            obj.position.z += speed
            if obj.position.z > 300 then @dispose(obj)
          else
            obj.position.z -= speed
            if obj.position.z < -1000 then @dispose(obj)
