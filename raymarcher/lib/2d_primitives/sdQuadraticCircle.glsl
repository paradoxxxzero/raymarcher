float sdQuadraticCircle(in vec2 p) {
  p = abs(p);
  if(p.y > p.x)
    p = p.yx;

  float a = p.x - p.y;
  float b = p.x + p.y;
  float c = (2.0 * b - 1.0) / 3.0;
  float h = a * a + c * c * c;
  float t;
  if(h >= 0.0) {
    h = sqrt(h);
    t = sign(h - a) * pow(abs(h - a), 1.0 / 3.0) - pow(h + a, 1.0 / 3.0);
  } else {
    float z = sqrt(-c);
    float v = acos(a / (c * z)) / 3.0;
    t = -z * (cos(v) + sin(v) * 1.732050808);
  }
  t *= 0.5;
  vec2 w = vec2(-t, t) + 0.75 - t * t - p;
  return length(w) * sign(a * a * 0.5 + b - 1.5);
}
