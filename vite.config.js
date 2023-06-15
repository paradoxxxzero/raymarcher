import glsl from 'vite-plugin-glsl'

export default {
  plugins: [glsl()],
  build: {
    outDir: 'docs',
  },
  server: {
    port: 17171,
  },
}
