vec3 opBend(in vec3 p, float k) {
  return opRotateZ(p, k * p.x);
}
