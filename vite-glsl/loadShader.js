import { dirname, resolve, extname, posix, sep } from 'path'
import { emitWarning, cwd } from 'process'
import { readFileSync } from 'fs'

let recursiveChunk = ''
const allChunks = new Set()
const dependentChunks = new Map()
const duplicatedChunks = new Map()

function resetSavedChunks() {
  const chunk = recursiveChunk
  duplicatedChunks.clear()
  dependentChunks.clear()

  recursiveChunk = ''
  allChunks.clear()
  return chunk
}

function getRecursionCaller() {
  const dependencies = [...dependentChunks.keys()]
  return dependencies[dependencies.length - 1]
}

function checkDuplicatedImports(path) {
  if (!allChunks.has(path)) return
  const caller = getRecursionCaller()

  const chunks = duplicatedChunks.get(caller) ?? []
  if (chunks.includes(path)) return

  chunks.push(path)
  duplicatedChunks.set(caller, chunks)

  emitWarning(`'${path}' was included multiple times.`, {
    code: 'vite-plugin-glsl',
    detail:
      'Please avoid multiple imports of the same chunk in order to avoid' +
      ` recursions and optimize your shader length.\nDuplicated import found in file '${caller}'.`,
  })
}

function checkRecursiveImports(path, warn) {
  warn && checkDuplicatedImports(path)
  return checkIncludedDependencies(path, path)
}

function checkIncludedDependencies(path, root) {
  const dependencies = dependentChunks.get(path)
  let recursiveDependency = false

  if (dependencies?.includes(root)) {
    recursiveChunk = root
    return true
  }

  dependencies?.forEach(
    dependency =>
      (recursiveDependency =
        recursiveDependency || checkIncludedDependencies(dependency, root))
  )

  return recursiveDependency
}
function loadChunks(source, path, extension, warn, root) {
  const unixPath = path.split(sep).join(posix.sep)

  if (checkRecursiveImports(unixPath, warn)) {
    return recursiveChunk
  }

  let directory = dirname(unixPath)
  allChunks.add(unixPath)

  if (recursiveChunk) {
    const caller = getRecursionCaller()
    const recursiveChunk = resetSavedChunks()

    throw Error(
      `Recursion detected when importing '${recursiveChunk}' in '${caller}'.`
    )
  }

  return source.trim().replace(/(\r\n|\r|\n){3,}/g, '$1\n')
}

export default function (source, shader, options) {
  const { warnDuplicatedImports, defaultExtension, root } = options

  resetSavedChunks()
  const output = loadChunks(
    source,
    shader,
    defaultExtension,
    warnDuplicatedImports,
    root
  )

  return {
    dependentChunks,
    outputShader: output,
  }
}
