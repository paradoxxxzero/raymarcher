float sdRhombus(in vec2 p, in vec2 b) {
  p = abs(p);
  float a = b - 2.0 * p;
  float h = clamp((a.x * b.x - a.y * b.y) / dot(b, b), -1.0, 1.0);
  float d = length(p - 0.5 * b * vec2(1.0 - h, 1.0 + h));
  return d * sign(p.x * b.y + p.y * b.x - b.x * b.y);
}
