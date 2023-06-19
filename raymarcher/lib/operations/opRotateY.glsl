vec3 opRotateY(in vec3 p, in float theta) {
  float c = cos(theta);
  float s = sin(theta);

  p.xz *= mat2(c, s, -s, c);
  return p;
}
