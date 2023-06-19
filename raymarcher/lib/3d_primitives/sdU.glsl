float sdU(in vec3 p, in float r, in float le, vec2 w) {
  p.x = (p.y > 0.0) ? abs(p.x) : length(p.xy);
  p.x = abs(p.x - r);
  p.y = p.y - le;
  float k = max(p.x, p.y);
  vec2 q = vec2((k < 0.0) ? -k : length(max(p.xy, 0.0)), abs(p.z)) - w;
  return length(max(q, 0.0)) + min(max(q.x, q.y), 0.0);
}
