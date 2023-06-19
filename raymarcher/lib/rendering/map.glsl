vec4 map(in vec3 p) {
  const vec3 boxColor = vec3(1.0, 0.32, 0.32);
  float box = sdBox(p, vec3(.1));

  return vec4(box, boxColor);
}
