float sdPie(in vec2 p, in vec2 c, in float r) {
  p.x = abs(p.x);
  float l = length(p) - r;
  float m = length(p - c * clamp(dot(p, c), 0.0, r)); // c=sin/cos of aperture
  return max(l, m * sign(c.y * p.x - c.x * p.y));
}
