float sdCoolS(in vec2 p) {
  float six = (p.y < 0.0) ? -p.x : p.x;
  p.x = abs(p.x);
  p.y = abs(p.y) - 0.2;
  float rex = p.x - min(round(p.x / 0.4), 0.4);
  float aby = abs(p.y - 0.2) - 0.6;

  float d = dot2(vec2(six, -p.y) - clamp(0.5 * (six - p.y), 0.0, 0.2));
  d = min(d, dot2(vec2(p.x, -aby) - clamp(0.5 * (p.x - aby), 0.0, 0.4)));
  d = min(d, dot2(vec2(rex, p.y - clamp(p.y, 0.0, 0.4))));

  float s = 2.0 * p.x + aby + abs(aby + 0.4) - 0.4;

  return sqrt(d) * sign(s);
}
