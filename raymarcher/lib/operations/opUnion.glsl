vec4 opUnion(vec4 d1, vec4 d2) {
  return d1.x < d2.x ? d1 : d2;
}
