varying vec3 vNormal;

uniform float amplitude;
uniform float time;
float rand(vec2 co){
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

void main() {
  vNormal = normal;
  float noise_scale = 0.01;
  //float rnd = rand(vec2(position.x, position.z));
  float rnd = rand(vec2(position.x * noise_scale, (position.z + time * 0.01) * noise_scale));
  vec3 p2 = position + normal * vec3(amplitude) * rnd;
  gl_Position = projectionMatrix * modelViewMatrix * vec4(p2,1.0);
}
