void mainImage(out vec4 fragColor, in vec2 fragCoord) {
  vec2 uv = (fragCoord * 2.0 - iResolution.xy) / iResolution.y;

  float an = 0.7 * iTime;
  vec3 ro = vec3(1.0 * cos(an), 0.2, -5.0 + sin(an));

  vec3 ta = vec3(0.0, 0.0, 0.0);
  vec3 ww = normalize(ta - ro);
  vec3 uu = normalize(cross(ww, vec3(0.0, 1.0, 0.0)));
  vec3 vv = (cross(uu, ww));

  vec3 rd = normalize(uv.x * uu + uv.y * vv + 5. * ww);

  vec3 color = rayMarch(ro, rd); // This use the map function defined above
  fragColor = vec4(color, 1.0);
}
