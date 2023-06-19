float sdCutDisk(in vec2 p, in float r, in float h) {
  float w = sqrt(r * r - h * h); // constant for any given shape
  p.x = abs(p.x);
  float s = max((h - r) * p.x * p.x + w * w * (h + r - 2.0 * p.y), h * p.x - w * p.y);
  return (s < 0.0) ? length(p) - r : (p.x < w) ? h - p.y : length(p - vec2(w, h));
}
