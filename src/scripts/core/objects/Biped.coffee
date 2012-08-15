define [
  'Underscore',
  'libs/namespace',
  'cs!core/utils/Skeleton',
  'Three',
], (_) ->

  namespace "Next.shapes",
    Biped: class Biped extends THREE.Object3D
      constructor: (@app, @material, @materialWire) ->
        super

        @time_offset = Math.random() * 2000
        @legs_height = Math.random() * 15 + 30
        @torso_height = Math.random() * 7 + 22
        @arms_height = Math.random() * 10 + 22
        @step_height = Math.random() * 4 + 5
        @width = 4 + Math.random() * 5


        @left_leg = new Next.utils.Skeleton2(@material, @materialWire, new THREE.Vector3(0,@legs_height,-@width),new THREE.Vector3(0,0,-@width - 0.2), 3, 1)
        @add(@left_leg)

        @right_leg = new Next.utils.Skeleton2(@material, @materialWire, new THREE.Vector3(0,@legs_height,@width),new THREE.Vector3(0,0,@width + 0.2), 3, 1)
        @add(@right_leg)

        @torso = new Next.utils.Skeleton2(@material, @materialWire, new THREE.Vector3(0,@legs_height,0), new THREE.Vector3(0,@legs_height + @torso_height,0), 5, 3, new THREE.Vector3(-1, 0, 0))
        @add(@torso)

        @head = new THREE.Object3D()
        c = new THREE.CubeGeometry( 5, 6.5, 5 )
        ob = new THREE.Mesh( c, @material )
        ob.doubleSided = true
        @head.add(ob)
        @add(@head)

        @left_arm = new Next.utils.Skeleton2(@material, @materialWire, new THREE.Vector3(@torso.b.x,@torso.b.y,-@width), new THREE.Vector3(0, @torso.b.y - @arms_height,-@width - 1.5), 3, 1, new THREE.Vector3(-1, 0, 0))
        @add(@left_arm)

        @right_arm = new Next.utils.Skeleton2(@material, @materialWire, new THREE.Vector3(@torso.b.x,@torso.b.y,@width), new THREE.Vector3(0, @torso.b.y - @arms_height,@width + 1.5), 3, 1, new THREE.Vector3(-1, 0, 0))
        @add(@right_arm)

        @rotation.y = Math.PI * 0.5

      update: () =>
        speed = 0.0072
        step_length = -13
        body_displace = -0.2

        time = Date.now() + @time_offset
        #@rotation.y = time * 0.0004 + @time_offset

        @left_leg.a.y = @legs_height * 0.8 + Math.sin(time * speed) * body_displace
        @left_leg.b.y = Math.max(0, Math.sin(time * speed) * @step_height)
        @left_leg.b.x = Math.cos(time * speed) * step_length
        @left_leg.update()

        @right_leg.a.y = @legs_height * 0.8 + Math.sin(time * speed + Math.PI) * body_displace
        @right_leg.b.y = Math.max(0, Math.sin(time * speed + Math.PI) * @step_height)
        @right_leg.b.x = Math.cos(time * speed + Math.PI) * step_length
        @right_leg.update()

        @torso.a.y = (@right_leg.a.y + @left_leg.a.y) / 2
        @torso.b.y = Math.cos(time * speed + Math.PI) * .5 + @legs_height + @torso_height - 10
        @torso.b.x = Math.sin(time * speed + Math.PI) * .5 + 5
        #@torso.b.z = Math.sin(time * speed + Math.PI) * 0.3
        @torso.update()

        @left_arm.a.y = @torso.b.y - 2
        @left_arm.a.x = @torso.b.x
        @left_arm.b.x = Math.sin(time * speed + Math.PI) * 1 + 4
        @left_arm.b.y = @torso.b.y - @arms_height + 2 + Math.sin(time * speed + Math.PI) * 0.3
        @left_arm.update()

        @right_arm.a.y = @torso.b.y - 2
        @right_arm.a.x = @torso.b.x
        @right_arm.b.x = Math.sin(time * speed) * 1 + 4
        @right_arm.b.y = @torso.b.y - @arms_height + 2 + Math.sin(time * speed) * 0.3
        @right_arm.update()

        @head.position.y = @torso.b.y + 6
        @head.position.x = @torso.b.x + 3 + Math.sin(time * speed + Math.PI) * 0.5
        @head.rotation.z = Math.sin(time * speed) * 0.05 - 0.3
