float sdHyberbola(in vec2 p, in float k, in float he) // k in (0,inf)
{
  p = abs(p);
  p = vec2(p.x - p.y, p.x + p.y) / sqrt(2.0);

  float x2 = p.x * p.x / 16.0;
  float y2 = p.y * p.y / 16.0;
  float r = k * (4.0 * k - p.x * p.y) / 12.0;
  float q = (x2 - y2) * k * k;
  float h = q * q + r * r * r;
  float u;
  if(h < 0.0) {
    float m = sqrt(-r);
    u = m * cos(acos(q / (r * m)) / 3.0);
  } else {
    float m = pow(sqrt(h) - q, 1.0 / 3.0);
    u = (m - r / m) / 2.0;
  }
  float w = sqrt(u + x2);
  float b = k * p.y - x2 * p.x * 2.0;
  float t = p.x / 4.0 - w + sqrt(2.0 * x2 - u + b / w / 4.0);

  t = max(t, sqrt(he * he * 0.5 + k) - he / sqrt(2.0));

  float d = length(p - vec2(t, k / t));
  return p.x * p.y < k ? d : -d;
}
