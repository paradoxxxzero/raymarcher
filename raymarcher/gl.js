import vertexSource from './vertex.glsl'
import fragmentSource from './fragment.glsl'
import example from './example.glsl'
import { getSourceFromUrl, setUrlFromSource, updateTitle } from './browser'
import { setEditSource } from './edit'

let gl = null
let program = null
let vertexShader = null
let fragmentShader = null
const uniforms = {}
let shader = getSourceFromUrl() || example

export const getShader = () => shader
export const setShader = newShader => {
  console.log('setting shader')
  const compilationError = compileShader(
    plugFragment(fragmentSource, newShader),
    fragmentShader
  )
  if (compilationError) {
    return compilationError
  }
  const linkError = linkProgram()
  if (linkError) {
    return linkError
  }
  setUrlFromSource(newShader)
  shader = newShader
  sizeGL()
}

window.addEventListener('popstate', () => {
  const shader = getSourceFromUrl()
  if (shader) {
    setEditSource(shader)
    setShader(shader)
  }
})

const compileShader = (shaderSource, shader) => {
  gl.shaderSource(shader, shaderSource)
  gl.compileShader(shader)
  const success = gl.getShaderParameter(shader, gl.COMPILE_STATUS)
  if (!success) {
    const error = gl.getShaderInfoLog(shader)
    console.error(`An error occurred compiling the shaders: ${error}`)
    return error
  }
}

const linkProgram = () => {
  gl.linkProgram(program)

  const success = gl.getProgramParameter(program, gl.LINK_STATUS)
  if (!success) {
    const error = gl.getProgramInfoLog(program)
    console.error(`Unable to initialize the shader program: ${error}`)
    return error
  }

  uniforms.iTime = gl.getUniformLocation(program, 'iTime')
  uniforms.iTimeDelta = gl.getUniformLocation(program, 'iTimeDelta')
  uniforms.iResolution = gl.getUniformLocation(program, 'iResolution')
}

const plugFragment = (fragmentShader, plug) =>
  fragmentShader.replace('##SHADER##', plug)

export const initGL = canvas => {
  gl = canvas.getContext('webgl2')

  vertexShader = gl.createShader(gl.VERTEX_SHADER)
  fragmentShader = gl.createShader(gl.FRAGMENT_SHADER)

  compileShader(vertexSource, vertexShader)
  compileShader(plugFragment(fragmentSource, shader), fragmentShader)

  program = gl.createProgram()
  gl.attachShader(program, vertexShader)
  gl.attachShader(program, fragmentShader)

  linkProgram()

  gl.useProgram(program)

  gl.drawArrays(gl.TRIANGLES, 0, 3)
  sizeGL()
}

export const sizeGL = () => {
  if (!gl) {
    return
  }
  gl.canvas.width = window.innerWidth
  gl.canvas.height = window.innerHeight
  gl.canvas.style.width = window.innerWidth + 'px'
  gl.canvas.style.height = window.innerHeight + 'px'
  gl.viewport(0, 0, gl.canvas.width, gl.canvas.height)
  gl.uniform3fv(uniforms.iResolution, [
    gl.canvas.width,
    gl.canvas.height,
    window.devicePixelRatio,
  ])

  gl.drawArrays(gl.TRIANGLES, 0, 3)
}

let sma = 0
const k = 25
const dts = new Array(k).fill(0)
let t0 = performance.now() / 1000
let raf = null
export const render = () => {
  const t = performance.now() / 1000
  dts.push(t - t0)
  t0 = t
  sma += (dts[dts.length - 1] - dts.shift()) / k
  gl.uniform1f(uniforms.iTime, t)
  gl.uniform1f(uniforms.iTimeDelta, dts[dts.length - 1])
  gl.drawArrays(gl.TRIANGLES, 0, 3)
  raf = requestAnimationFrame(render)
}

setInterval(() => {
  updateTitle(`FPS: ${(1 / sma).toFixed(2)}`)
}, 250)
