uniform float offset;

uniform sampler2D tDiffuse;

varying vec2 vUv;


uniform float v;
// 1 / width or height, don't touch
uniform float r;


void main() {
  vec4 sum = vec4( 0.0 );
  float diff = (abs( r - vUv.y ) + abs( r - vUv.x )) / 2.0;
  //float vv = v * abs( r - vUv.y );
	float vv = v * diff;

	sum += texture2D( tDiffuse, vec2( vUv.x, vUv.y - 4.0 * vv ) ) * 0.051;
	sum += texture2D( tDiffuse, vec2( vUv.x, vUv.y - 3.0 * vv ) ) * 0.0918;
	sum += texture2D( tDiffuse, vec2( vUv.x, vUv.y - 2.0 * vv ) ) * 0.12245;
	sum += texture2D( tDiffuse, vec2( vUv.x, vUv.y - 1.0 * vv ) ) * 0.1531;
	sum += texture2D( tDiffuse, vec2( vUv.x, vUv.y			   ) ) * 0.1633;
	sum += texture2D( tDiffuse, vec2( vUv.x, vUv.y + 1.0 * vv ) ) * 0.1531;
	sum += texture2D( tDiffuse, vec2( vUv.x, vUv.y + 2.0 * vv ) ) * 0.12245;
	sum += texture2D( tDiffuse, vec2( vUv.x, vUv.y + 3.0 * vv ) ) * 0.0918;
	sum += texture2D( tDiffuse, vec2( vUv.x, vUv.y + 4.0 * vv ) ) * 0.051;
	
	gl_FragColor = sum;
}
