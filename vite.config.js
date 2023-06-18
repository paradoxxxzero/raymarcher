import glsl from './vite-glsl'

export default {
  base: '',
  plugins: [
    glsl({
      compress: false,
    }),
  ],
  build: {
    outDir: 'docs',
  },
  server: {
    port: 17171,
  },
}
