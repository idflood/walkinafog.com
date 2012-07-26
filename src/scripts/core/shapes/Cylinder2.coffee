define [
  'Underscore',
  'libs/namespace',
  'Three',
], (_) ->
  
  namespace "Next.shapes",
    Cylinder3: class Cylinder3 extends THREE.Geometry
      constructor: (@width = 10, diffRad = 60, diffRadMax = 300) ->
        super
        openEnded = true
        
        phiStart = Math.random() * Math.PI * 2
        phiLength = Math.max(0.1, Math.PI * 2 * Math.random())
        
        # looks like portals
        #phiStart = Math.PI - Math.PI * 0.2
        #phiLength = Math.max(0.1, Math.PI * 1 * Math.random())
        
        vertices = []
        uvs = []
        
        radiusTop = @width
        
        if Math.random() > 0.9
          diffRad = diffRadMax
        radiusBottom = radiusTop + (Math.random() + 0.1) * diffRad - diffRad * 0.5
        if Math.random() > 0.9
          radiusTop *= 2
          radiusBottom *= 2
          
        height = 4 + Math.random() * 170
        heightHalf = height / 2
        segmentsX = parseInt(Math.random() * 20 + 5)
        segmentsY = 1
        
        y = 0
        while y <= segmentsY
          verticesRow = []
          uvsRow = []
          v = y / segmentsY
          radius = v * (radiusBottom - radiusTop) + radiusTop
          x = 0
          while x <= segmentsX
            u = x / segmentsX
            vertex = new THREE.Vector3()
            vertex.x = radius * Math.sin(phiStart + u * phiLength)
            vertex.y = -v * height + heightHalf
            vertex.z = radius * Math.cos(phiStart + u * phiLength)
            @vertices.push vertex
            verticesRow.push @vertices.length - 1
            uvsRow.push new THREE.UV(u, v)
            x++
          vertices.push verticesRow
          uvs.push uvsRow
          y++
        tanTheta = (radiusBottom - radiusTop) / height
        x = 0
        while x < segmentsX
          if radiusTop isnt 0
            na = @vertices[vertices[0][x]].clone()
            nb = @vertices[vertices[0][x + 1]].clone()
          else
            na = @vertices[vertices[1][x]].clone()
            nb = @vertices[vertices[1][x + 1]].clone()
          na.setY(Math.sqrt(na.x * na.x + na.z * na.z) * tanTheta).normalize()
          nb.setY(Math.sqrt(nb.x * nb.x + nb.z * nb.z) * tanTheta).normalize()
          y = 0
          while y < segmentsY
            v1 = vertices[y][x]
            v2 = vertices[y + 1][x]
            v3 = vertices[y + 1][x + 1]
            v4 = vertices[y][x + 1]
            n1 = na.clone()
            n2 = na.clone()
            n3 = nb.clone()
            n4 = nb.clone()
            uv1 = uvs[y][x].clone()
            uv2 = uvs[y + 1][x].clone()
            uv3 = uvs[y + 1][x + 1].clone()
            uv4 = uvs[y][x + 1].clone()
            @faces.push new THREE.Face4(v1, v2, v3, v4, [ n1, n2, n3, n4 ])
            @faceVertexUvs[0].push [ uv1, uv2, uv3, uv4 ]
            y++
          x++
        
        
        @computeCentroids()
        @computeFaceNormals()
        
    Cylinder2: class Cylinder2 extends THREE.Geometry
      constructor: (@width = 10) ->
        super
        openEnded = true
        
        vertices = []
        uvs = []
        
        radiusTop = @width
        diffRad = 60
        if Math.random() > 0.9
          diffRad = 300
        radiusBottom = radiusTop + (Math.random() + 0.1) * diffRad - diffRad * 0.5
        if Math.random() > 0.9
          radiusTop *= 2
          radiusBottom *= 2
          
        height = 4 + Math.random() * 170
        heightHalf = height / 2
        segmentsX = parseInt(Math.random() * 30 + 5)
        segmentsY = 1
        
        y = 0
        while y <= segmentsY
          verticesRow = []
          uvsRow = []
          v = y / segmentsY
          radius = v * (radiusBottom - radiusTop) + radiusTop
          x = 0
          while x <= segmentsX
            u = x / segmentsX
            vertex = new THREE.Vector3()
            vertex.x = radius * Math.sin(u * Math.PI * 2)
            vertex.y = -v * height + heightHalf
            vertex.z = radius * Math.cos(u * Math.PI * 2)
            @vertices.push vertex
            verticesRow.push @vertices.length - 1
            uvsRow.push new THREE.UV(u, v)
            x++
          vertices.push verticesRow
          uvs.push uvsRow
          y++
        tanTheta = (radiusBottom - radiusTop) / height
        x = 0
        while x < segmentsX
          if radiusTop isnt 0
            na = @vertices[vertices[0][x]].clone()
            nb = @vertices[vertices[0][x + 1]].clone()
          else
            na = @vertices[vertices[1][x]].clone()
            nb = @vertices[vertices[1][x + 1]].clone()
          na.setY(Math.sqrt(na.x * na.x + na.z * na.z) * tanTheta).normalize()
          nb.setY(Math.sqrt(nb.x * nb.x + nb.z * nb.z) * tanTheta).normalize()
          y = 0
          while y < segmentsY
            v1 = vertices[y][x]
            v2 = vertices[y + 1][x]
            v3 = vertices[y + 1][x + 1]
            v4 = vertices[y][x + 1]
            n1 = na.clone()
            n2 = na.clone()
            n3 = nb.clone()
            n4 = nb.clone()
            uv1 = uvs[y][x].clone()
            uv2 = uvs[y + 1][x].clone()
            uv3 = uvs[y + 1][x + 1].clone()
            uv4 = uvs[y][x + 1].clone()
            @faces.push new THREE.Face4(v1, v2, v3, v4, [ n1, n2, n3, n4 ])
            @faceVertexUvs[0].push [ uv1, uv2, uv3, uv4 ]
            y++
          x++
        
        # Top cap
        if not openEnded and radiusTop > 0
          @vertices.push new THREE.Vector3(0, heightHalf, 0)
          x = 0
          while x < segmentsX
            v1 = vertices[0][x]
            v2 = vertices[0][x + 1]
            v3 = @vertices.length - 1
            n1 = new THREE.Vector3(0, 1, 0)
            n2 = new THREE.Vector3(0, 1, 0)
            n3 = new THREE.Vector3(0, 1, 0)
            uv1 = uvs[0][x].clone()
            uv2 = uvs[0][x + 1].clone()
            uv3 = new THREE.UV(uv2.u, 0)
            @faces.push new THREE.Face3(v1, v2, v3, [ n1, n2, n3 ])
            @faceVertexUvs[0].push [ uv1, uv2, uv3 ]
            x++
        
        # Bottom cap
        if not openEnded and radiusBottom > 0
          @vertices.push new THREE.Vector3(0, -heightHalf, 0)
          x = 0
          while x < segmentsX
            v1 = vertices[y][x + 1]
            v2 = vertices[y][x]
            v3 = @vertices.length - 1
            n1 = new THREE.Vector3(0, -1, 0)
            n2 = new THREE.Vector3(0, -1, 0)
            n3 = new THREE.Vector3(0, -1, 0)
            uv1 = uvs[y][x + 1].clone()
            uv2 = uvs[y][x].clone()
            uv3 = new THREE.UV(uv2.u, 1)
            @faces.push new THREE.Face3(v1, v2, v3, [ n1, n2, n3 ])
            @faceVertexUvs[0].push [ uv1, uv2, uv3 ]
            x++
        
        @computeCentroids()
        @computeFaceNormals()
        