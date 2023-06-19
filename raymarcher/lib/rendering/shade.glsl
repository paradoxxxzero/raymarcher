vec3 shade(in vec3 color, in vec3 p, in bool inside) {
  vec3 col = vec3(0.0);

  if(inside) {
    vec3 normal = calcNormal(p);
    // vec3 ao = calcAO(p, normal);

    vec3 lamp = vec3(2., -1., 3.);
    lamp = opRotateY(lamp, iTime * 2.);
    vec3 light = normalize(p - lamp);

    float ambient = .1;
    float diffuse = clamp(dot(normal, light), 0., 1.);
    float specular = clamp(pow(dot(normal, normalize(light + p)), 100.0), 0., 1.);
    col = color * (ambient + diffuse + specular);

    col = sqrt(col);
  }
  return col;
}
