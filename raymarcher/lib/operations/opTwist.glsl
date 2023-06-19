vec3 opTwist(in vec3 p, float k) {
  return opRotateY(p, k * p.y);
}
