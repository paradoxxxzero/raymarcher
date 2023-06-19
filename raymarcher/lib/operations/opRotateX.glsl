vec3 opRotateX(in vec3 p, in float theta) {
  float c = cos(theta);
  float s = sin(theta);
  p.yz *= mat2(c, s, -s, c);
  return p;
}
