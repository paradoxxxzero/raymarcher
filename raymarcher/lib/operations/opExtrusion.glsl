float opExtrusion(in vec3 p, in float dxy, in float h) {
  // dxy = sdf2dShape(p.xy)
  vec2 w = vec2(dxy, abs(p.z) - h);
  return min(max(w.x, w.y), 0.0) + length(max(w, 0.0));
}
