import raymarch2dPrimitives from './raymarch_2d_primitives.glsl'
import raymarch3dPrimitives from './raymarch_3d_primitives.glsl'
import raymarchTransformations from './raymarch_transformations.glsl'
import raymarchRendering from './raymarch_rendering.glsl'
import raymarch from './raymarch.glsl'

const mark = (source, name) => `// BEGIN ${name}\n${source}\n// END ${name}`

export const preprocessShader = plug =>
  plug
    .replace(
      '#include raymarch_2d_primitives',
      mark(raymarch2dPrimitives, 'raymarch_2d_primitives')
    )
    .replace(
      '#include raymarch_3d_primitives',
      mark(raymarch3dPrimitives, 'raymarch_3d_primitives')
    )
    .replace(
      '#include raymarch_transformations',
      mark(raymarchTransformations, 'raymarch_transformations')
    )
    .replace(
      '#include raymarch_rendering',
      mark(raymarchRendering, 'raymarch_rendering')
    )
    .replace('#include raymarch', mark(raymarch, 'raymarch'))

export const insertShader = (fragmentShader, plug) =>
  fragmentShader.replace('##SHADER##', preprocessShader(plug))
