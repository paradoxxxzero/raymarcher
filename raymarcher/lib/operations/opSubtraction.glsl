vec4 opSubtraction(vec4 d1, vec4 d2) {
  d1.x *= -1.;
  return opIntersection(d1, d2);
}
