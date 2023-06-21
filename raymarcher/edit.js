import { basicSetup } from 'codemirror'
import { cpp } from '@codemirror/lang-cpp'
import { EditorState } from '@codemirror/state'
import { autocompletion } from '@codemirror/autocomplete'
import { indentWithTab } from '@codemirror/commands'
// import { foldAll, ensureSyntaxTree } from '@codemirror/language'
import { EditorView, keymap } from '@codemirror/view'
import { getShader, setShader, sizeGL } from './gl'
import { oneDark } from '@codemirror/theme-one-dark'
import { linter } from '@codemirror/lint'
import fragmentSource from './fragment.glsl?raw'
import { getPref, setPref } from './local'

const lib = import.meta.glob('./lib/*/*.glsl', { as: 'raw', eager: true })

let codemirror = null
let currentError = null
const shift = fragmentSource.split('##SHADER##')[0].split('\n').length

function libComplete(context) {
  let word = context.matchBefore(/\w*/)
  if (word.from == word.to && !context.explicit) {
    return null
  }

  return {
    from: word.from,
    options: Object.entries(lib).map(([fn, src]) => {
      const [, libName, libFn] = fn.match(/\.\/lib\/(.*)\/(.*)\.glsl/)
      return {
        label: libFn,
        type: 'function',
        info: libName.replace(/_/g, ' '),
        apply: src,
      }
    }),
  }
}

const compilerLinter = linter(view => {
  const { doc } = view.state
  const diagnostics = []
  if (currentError) {
    const errorRE = /ERROR: (\d+):(\d+): (.*)/g
    let parsed
    while ((parsed = errorRE.exec(currentError))) {
      const [, column, line, message] = parsed
      diagnostics.push({
        from: doc.line(+line + 1 - shift).from + +column,
        to: doc.line(+line + 2 - shift).from - 1,
        severity: 'error',
        message,
      })
    }
  }
  return diagnostics
})

const onChange = EditorView.updateListener.of(v => {
  if (v.docChanged && !v.transactions.some(t => t.isUserEvent('url'))) {
    currentError = setShader(v.state.doc.toString())
  }
})

const closeOnEscape = keymap.of([
  {
    key: 'Escape',
    run: () => {
      const editor = document.getElementById('editor')
      editor.style.display = 'none'
    },
  },
])

const initCodeMirror = () => {
  const startState = EditorState.create({
    doc: getShader(),
    extensions: [
      basicSetup,
      keymap.of([indentWithTab]),
      oneDark,
      EditorView.lineWrapping,
      cpp(),
      autocompletion({ override: [libComplete] }),
      onChange,
      compilerLinter,
      closeOnEscape,
    ],
  })

  codemirror = new EditorView({
    state: startState,
    parent: document.getElementById('editor'),
  })

  //   ensureSyntaxTree(codemirror.state, codemirror.state.doc.length, 5000)
  //   codemirror.dispatch({})
  //   foldAll(codemirror)
}

const layouts = {
  cover: '🖥️',
  vside: '📖',
  hside: '🗒️',
}

export const initEdit = () => {
  const editor = document.getElementById('editor')
  const toggler = document.getElementById('edit')
  const layout = document.getElementById('layout')
  toggler.addEventListener('click', () => {
    if (!codemirror) {
      initCodeMirror()
    }
    editor.style.display = editor.style.display !== 'block' ? 'block' : 'none'
    toggler.innerHTML = editor.style.display === 'block' ? '❌' : '✏️'
    layout.style.display = editor.style.display

    const [cls, icon] = Object.entries(layouts).find(
      ([_, icon]) => layout.innerHTML === icon
    )
    if (editor.style.display === 'block') {
      codemirror.focus()

      setPref('edit', cls)
      document.body.classList.add(cls)
    } else {
      document.body.classList.remove(cls)
      setPref('edit', false)
    }
    sizeGL()
  })
  layout.addEventListener('click', () => {
    const layoutIcons = Object.entries(layouts)
    const idx = layoutIcons.findIndex(([_, icon]) => layout.innerHTML === icon)
    const [cls, icon] = layoutIcons[idx]
    const [nextCls, nextIcon] = layoutIcons[(idx + 1) % layoutIcons.length]

    document.body.classList.remove(cls)
    document.body.classList.add(nextCls)
    setPref('edit', nextCls)
    layout.innerHTML = nextIcon

    sizeGL()
  })
  if (getPref('edit')) {
    layout.innerHTML = layouts[getPref('edit')]
    toggler.click()
  }
}

export const setEditSource = source => {
  if (codemirror) {
    codemirror.dispatch({
      changes: {
        from: 0,
        to: codemirror.state.doc.length,
        insert: source,
      },
      userEvent: 'url',
    })
  }
}
