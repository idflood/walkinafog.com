define [
  'Underscore',
  'libs/namespace',
  'Three',
], (_) ->
  #"use strict"

  namespace "Next.utils",
    LensFlareContainer: class LensFlareContainer
      constructor: (@scene, @sunLight) ->
        textureFlare0 = THREE.ImageUtils.loadTexture("textures/flare0.png")
        textureFlare2 = THREE.ImageUtils.loadTexture( "textures/flare2.png" )
        textureFlare3 = THREE.ImageUtils.loadTexture( "textures/flare3.png" )
        flareColor = new THREE.Color( 0xffffff )

        @lensFlare = new THREE.LensFlare( textureFlare0, 512, 0.0, THREE.AdditiveBlending, flareColor )
        @lensFlare.add( textureFlare2, 512, 0.0, THREE.AdditiveBlending )
        @lensFlare.add( textureFlare2, 1024, 0.0, THREE.AdditiveBlending )
        @lensFlare.add( textureFlare2, 512, 0.0, THREE.AdditiveBlending )
        @lensFlare.add( textureFlare3, 60, 0.6, THREE.AdditiveBlending )
        @lensFlare.add( textureFlare3, 70, 0.7, THREE.AdditiveBlending )
        @lensFlare.add( textureFlare3, 120, 0.9, THREE.AdditiveBlending )
        @lensFlare.add( textureFlare3, 70, 1.0, THREE.AdditiveBlending )

        @lensFlare.position = @sunLight.position
        @lensFlare.customUpdateCallback = @updateLensFlare
        @scene.add( @lensFlare )

      updateLensFlare: (object) =>
        @lensFlare.position.y = @sunLight.position.y
        vecX = -object.positionScreen.x * 2
        vecY = -object.positionScreen.y * 2
        for f in [0..object.lensFlares.length-1]
          flare = object.lensFlares[f]
          flare.x = object.positionScreen.x + vecX * flare.distance
          flare.y = object.positionScreen.y + vecY * flare.distance
          flare.rotation = 0
          if f == 0
            #flare.scale = 0.15
            flare.scale = @sunLight.position.y * 0.004
          else
            flare.scale = 0.7
        object.lensFlares[ 2 ].y += 0.025
        object.lensFlares[ 1 ].rotation = object.positionScreen.x * 0.4 - 15 * Math.PI / 180
        object.lensFlares[ 3 ].rotation = object.positionScreen.x * 0.5 + 45 * Math.PI / 180
