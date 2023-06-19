float sdEgg(in vec2 p, in float ra, in float rb) {
  const float k = sqrt(3.0);
  p.x = abs(p.x);
  float r = ra - rb;
  return ((p.y < 0.0) ? length(vec2(p.x, p.y)) - r : (k * (p.x + r) < p.y) ? length(vec2(p.x, p.y - k * r)) : length(vec2(p.x + r, p.y)) - 2.0 * r) - rb;
}
