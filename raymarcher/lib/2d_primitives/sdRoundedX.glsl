float sdRoundedX(in vec2 p, in float w, in float r) {
  p = abs(p);
  return length(p - min(p.x + p.y, w) * 0.5) - r;
}
