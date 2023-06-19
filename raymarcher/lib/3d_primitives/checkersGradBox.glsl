float checkersGradBox(in vec2 p, in vec2 dpdx, in vec2 dpdy) {
    // filter kernel
  vec2 w = abs(dpdx) + abs(dpdy) + 0.001;
    // analytical integral (box filter)
  vec2 i = 2.0 * (abs(fract((p - 0.5 * w) * 0.5) - 0.5) - abs(fract((p + 0.5 * w) * 0.5) - 0.5)) / w;
    // xor pattern
  return 0.5 - 0.5 * i.x * i.y;
}
