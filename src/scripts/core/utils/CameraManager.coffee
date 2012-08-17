define [
  'Underscore',
  'libs/namespace',
  'Three',
], (_) ->
  #"use strict"

  namespace "Next.utils",
    CameraManager: class CameraManager
      constructor: (@scene) ->
        @items = []

        @camera = new THREE.PerspectiveCamera( 60, window.innerWidth / window.innerHeight, 1, 20000 )
        @cameraContainer = new THREE.Object3D()
        @cameraContainer.add(@camera)
        @scene.add( @cameraContainer )
        @currentCamera = @camera
        @camera.position.set(0, 2, 200)
        @camera.lookAt(new THREE.Vector3(0,1480,0 - 3800))

        @cameraSide1 = new THREE.PerspectiveCamera( 60, window.innerWidth / window.innerHeight, 1, 20000 )
        @cameraSide1.position.set(500, 2, 200)
        @cameraSide1.lookAt(new THREE.Vector3(0,50,200))
        @scene.add(@cameraSide1)
        @items.push(@cameraSide1)

        @cameraSide2 = new THREE.PerspectiveCamera( 60, window.innerWidth / window.innerHeight, 1, 20000 )
        @cameraSide2.position.set(100, 2, 200)
        @cameraSide2.lookAt(new THREE.Vector3(0,30,150 + 35))
        @scene.add(@cameraSide2)
        @items.push(@cameraSide2)

        @cameraIntro2 = new THREE.PerspectiveCamera( 60, window.innerWidth / window.innerHeight, 1, 20000 )
        @cameraIntro2.position.set(89, 5, -250)
        @cameraIntro2.lookAt(new THREE.Vector3(0,10,-280))
        @scene.add(@cameraIntro2)
        @items.push(@cameraIntro2)

        @cameraIntro3 = new THREE.PerspectiveCamera( 60, window.innerWidth / window.innerHeight, 1, 20000 )
        @cameraIntro3.position.set(70, 2, -280)
        @cameraIntro3.lookAt(new THREE.Vector3(0,15,-270))
        @scene.add(@cameraIntro3)
        @items.push(@cameraIntro3)

        @cameraCity1 = new THREE.PerspectiveCamera( 60, window.innerWidth / window.innerHeight, 1, 20000 )
        @cameraCity1.position.set(160 - 50, 220, -5070 + 2000 + 260)
        @cameraCity1.lookAt(new THREE.Vector3(0,0,-4980 + 2000))
        @scene.add(@cameraCity1)
        @items.push(@cameraCity1)
        oz = 140
        @cameraCity2 = new THREE.PerspectiveCamera( 60, window.innerWidth / window.innerHeight, 1, 20000 )
        @cameraCity2.position.set(160, 320, -4500 + 2000 + oz)
        @cameraCity2.lookAt(new THREE.Vector3(0,0,-4100 + 2000 + oz))
        @scene.add(@cameraCity2)
        @items.push(@cameraCity2)

        @cameraCityTop1 = new THREE.PerspectiveCamera( 80, window.innerWidth / window.innerHeight, 1, 20000 )
        @cameraCityTop1.position.set(0, 250, -2180)
        @cameraCityTop1.lookAt(new THREE.Vector3(0,0,-2200))
        @scene.add(@cameraCityTop1)
        @items.push(@cameraCityTop1)

        @currentCamera = @cameraSide1

      update: (realTime, @target, mouse) =>
        cameraOffsetZ = 0.0

        @cameraSide1.position.x = 500 - realTime * 14.0
        @cameraSide1.position.z = 200.0 - realTime * 18.0 + 20
        @cameraSide2.position.z = 200.0 - realTime * 18.0 + 10
        cameraTop_speedY = 0

        if realTime > 25.0
          @currentCamera = @cameraIntro2
        if realTime > 28.0
          @currentCamera = @cameraIntro3
          @cameraIntro3.position.z = 200.0 - realTime * 12.0 - 150.0
        if realTime > 32.0
          @cameraSide1.position.x = 150
          @cameraSide1.position.y = 10 - 2
          @cameraSide1.lookAt(@target.position)
          @currentCamera = @cameraSide1

        if realTime > 41.0
          @currentCamera = @cameraSide2
        if realTime > 45.0
          @currentCamera = @cameraSide1
          @cameraSide1.position.y = 1
          @cameraSide1.position.x = 65
          @cameraSide1.lookAt(new THREE.Vector3(@target.position.x, @target.position.y + 30, @target.position.z + 10))
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
          @cameraCity1.lookAt(@target.position)
        if realTime > 120.0 && realTime <= 133.0
          @currentCamera = @cameraCity2
          @cameraCity2.position.y += (120 - @cameraCity2.position.y) * 0.002
          # position camera top for next frame
          @cameraCityTop1.position.z = -2180

        if realTime > 133.0
          @currentCamera = @camera
          cameraOffsetZ = -700.0

        if @currentCamera == @camera && realTime < 169.0
          $("#container canvas").addClass("interactive")
        else
          $("#container canvas").removeClass("interactive")

        @camera.position.z = 200.0 - realTime * 18.0 + cameraOffsetZ
        @cameraIntro2.lookAt(@target.position)
        @cameraCityTop1.position.z = -600 - realTime * 7.0
        @cameraCity2.lookAt(new THREE.Vector3(0,0,-4100 + 2000))

        @camera.position.y = 4 + Math.sin(realTime * 0.5) * 0.6
        rx = mouse.x * -0.8
        ry = mouse.y * -0.4 + 0.4
        @camera.rotation.y += (rx - @camera.rotation.y) * 0.2
        @camera.rotation.x += (ry - @camera.rotation.x) * 0.2
