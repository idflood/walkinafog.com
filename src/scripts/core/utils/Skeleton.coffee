define [
  'Underscore',
  'libs/namespace',
  'Three',
], (_) ->

  namespace "Next.utils",

    Skeleton: class Skeleton extends THREE.Object3D
      constructor: (@materialSimple, @materialWire, @a, @b, @count = 3, @radius = 1, @direction = new THREE.Vector3(1, 0, 0)) ->
        super

        @objects = []
        @mids = []
        cube_width = 2
        @cube = new THREE.CubeGeometry( cube_width, cube_width, cube_width )
        @maxdiff = @b.clone().subSelf(@a).length()

        @object = new THREE.Mesh( @cube, @materialSimple )
        @object.doubleSided = true
        @object.position = @a
        @add(@object)

        @mid = @count - 2
        spacing = @b.clone().subSelf(@a).divideScalar(@count - 1)
        @spacing = spacing
        @spacing_length = spacing.length()

        ob = new THREE.Object3D()
        ob.position = @a
        @objects.push(ob)

        ip = 1 / (@count - 1)
        for num in [@mid..1]
          p = num * ip
          # p goes from 0 to 1, but we want 0 = 0.5 / 0.5 = 1 / 1 = 0.5
          if p > 0.5 then p =  ((p - 0.5) * -1) + 0.5
          # now goes from 0.25 to 0.5
          p = p * 2
          #console.log p + " / " + ip
          obj1 = @addMiddlePart(@a.clone().addSelf(spacing.clone().multiplyScalar(num)))
          # we add an object on the @b object so skip last child (should fix possible issue with no middle parts)
          #if num > 1
          ob = new THREE.Object3D()
          ob.position = obj1.position
          @objects.push(ob)

        for ob in @objects
          @add(ob)
        @object2 = new THREE.Mesh( @cube, @materialSimple )
        @object2.position = @b
        @object2.doubleSided = true
        @add(@object2)


      addMiddlePart: (pos) =>
        obj = new THREE.Mesh( @cube, @materialSimple )
        obj.position = pos
        @add(obj)
        @mids.push(obj)
        return obj

      update: () =>
        ln = @objects.length
        for i in [ln - 1..1]
          @objects[i - 1].lookAt(@objects[i].position)
        @objects[@objects.length - 1].lookAt(@b)
        currentdiff = @b.clone().subSelf(@a)
        if currentdiff.length() > @maxdiff
          dir = @b.clone().subSelf(@a)
          r = 1 - currentdiff.length() / @maxdiff
          @b.addSelf(dir.multiplyScalar(r*0.65))

        spacing = @b.clone().subSelf(@a).divideScalar(@count - 1)
        diff_spacing = spacing.clone().subSelf(@spacing)
        # want to move the total difference in the @direction
        #diff = @direction.clone().multiplyScalar(diff_spacing.length())
        diff = @direction.clone().multiplyScalar(diff_spacing.length())

        ip = 1 / (@count - 1)
        for num in [@mid..1]
          # p = magnitude of d
          p = num * ip
          # p goes from 0 to 1, but we want 0 = 0.5 / 0.5 = 1 / 1 = 0.5
          if p > 0.5 then p =  ((p - 0.5) * -1) + 0.5
          # now goes from 0.25 to 0.5
          #p = p * 2.2
          @mids[num - 1].position = @a.clone().addSelf(spacing.clone().multiplyScalar(num)).addSelf(diff.clone().multiplyScalar(p))

    Skeleton2: class Skeleton2 extends Skeleton
      constructor: (@materialSimple, @materialWire, @a, @b, @count = 3, @radius = 2, @direction = new THREE.Vector3(1, 0, 0)) ->
        super
        dy = @spacing_length
        #@material2 = new THREE.MeshBasicMaterial( { color: 0x00aaff } )
        #@cube2 = new THREE.CubeGeometry( 0.6, 0.6, 0.6 )
        #return
        for ob, i in @objects
          max = 5
          dy2 = dy / (max + 1)

          for num in [max..1]
            #c2 = new Next.shapes.Cylinder3((40 + Math.random() * 10) * @radius, 5, 7)
            ob2 = new THREE.Mesh( @cube, @materialSimple )
            ob2.doubleSided = true
            ds = 0.2
            ob2.scale = new THREE.Vector3(ds, ds, ds)
            ob2.position.z = num * dy2
            ob2.rotation.x = Math.PI * 0.5
            #console.log num
            ob.add(ob2)
      update: () =>
        for ob, i in @objects
          # needs to update childs position expect for [0] which is linked to @a
          if i > 0
            ob.position = @mids[i - 1].position
        super
