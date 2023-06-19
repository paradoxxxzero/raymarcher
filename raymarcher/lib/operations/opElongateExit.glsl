float opElongateExit(in float d, in vec3 p, in float h) {
  vec3 q = abs(p) - h;
  return d + min(max(q.x, max(q.y, q.z)), 0.0);
}
