float sdRoundedCross(in vec2 p, in float h) {
  float k = 0.5 * (h + 1.0 / h); // k should be const at modeling time
  p = abs(p);
  return (p.x < 1.0 && p.y < p.x * (k - h) + h) ? k - sqrt(dot2(p - vec2(1, k))) : sqrt(min(dot2(p - vec2(0, h)), dot2(p - vec2(1, 0))));
}
