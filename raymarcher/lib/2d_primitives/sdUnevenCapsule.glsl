float sdUnevenCapsule(vec2 p, float r1, float r2, float h) {
  p.x = abs(p.x);
  float b = (r1 - r2) / h;
  float a = sqrt(1.0 - b * b);
  float k = dot(p, vec2(-b, a));
  if(k < 0.0)
    return length(p) - r1;
  if(k > a * h)
    return length(p - vec2(0.0, h)) - r2;
  return dot(p, vec2(a, b)) - r1;
}
