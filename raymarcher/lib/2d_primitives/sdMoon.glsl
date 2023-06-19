float sdMoon(vec2 p, float d, float ra, float rb) {
  p.y = abs(p.y);
  float a = (ra * ra - rb * rb + d * d) / (2.0 * d);
  float b = sqrt(max(ra * ra - a * a, 0.0));
  if(d * (p.x * b - p.y * a) > d * d * max(b - p.y, 0.0))
    return length(p - vec2(a, b));
  return max((length(p) - ra), -(length(p - vec2(d, 0)) - rb));
}
