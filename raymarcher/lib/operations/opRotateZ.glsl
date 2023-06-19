vec3 opRotateZ(in vec3 p, in float theta) {
  float c = cos(theta);
  float s = sin(theta);
  p.xy *= mat2(c, -s, s, c);
  return p;
}
