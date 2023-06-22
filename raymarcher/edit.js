import {
  autocompletion,
  closeBrackets,
  closeBracketsKeymap,
  completionKeymap,
} from '@codemirror/autocomplete'
import {
  defaultKeymap,
  history,
  historyKeymap,
  indentWithTab,
} from '@codemirror/commands'
import {
  defaultHighlightStyle,
  syntaxHighlighting,
  bracketMatching,
  foldGutter,
  foldKeymap,
  indentOnInput,
  HighlightStyle,
} from '@codemirror/language'
import { lintKeymap, linter } from '@codemirror/lint'
import { highlightSelectionMatches, searchKeymap } from '@codemirror/search'
import { EditorState } from '@codemirror/state'
import {
  EditorView,
  crosshairCursor,
  drawSelection,
  dropCursor,
  highlightActiveLine,
  highlightActiveLineGutter,
  highlightSpecialChars,
  keymap,
  lineNumbers,
  rectangularSelection,
} from '@codemirror/view'
import { tags } from '@lezer/highlight'
import { oneDark } from '@codemirror/theme-one-dark'
import { glsl } from '../lezer-glsl/glsl'
import fragmentSource from './fragment.glsl?raw'
import { getShader, setShader, sizeGL } from './gl'
import { getPref, setPref } from './local'
import { foldEffect } from '@codemirror/language'
import { unfoldCode } from '@codemirror/language'
import { syntaxTree } from '@codemirror/language'
import { foldAll } from '@codemirror/language'
import { ensureSyntaxTree } from '@codemirror/language'

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
      let from, to
      try {
        from = doc.line(+line + 1 - shift).from + +column
        to = doc.line(+line + 2 - shift).from - 1
      } catch (e) {
        from = 0
        to = doc.toString().length
      }
      diagnostics.push({
        from,
        to,
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
      glsl(),
      lineNumbers(),
      highlightActiveLineGutter(),
      highlightSpecialChars(),
      history(),
      foldGutter(),
      drawSelection(),
      dropCursor(),
      EditorState.allowMultipleSelections.of(true),
      indentOnInput(),
      // syntaxHighlighting(defaultHighlightStyle, { fallback: true }),
      bracketMatching(),
      closeBrackets(),
      autocompletion(),
      rectangularSelection(),
      crosshairCursor(),
      highlightActiveLine(),
      highlightSelectionMatches(),
      keymap.of([
        ...closeBracketsKeymap,
        ...defaultKeymap,
        ...searchKeymap,
        ...historyKeymap,
        ...foldKeymap,
        ...completionKeymap,
        ...lintKeymap,
      ]),
      keymap.of([indentWithTab]),
      syntaxHighlighting(
        HighlightStyle.define([
          {
            tag: tags.modifier,
            color: '#d19a66',
          },
          {
            tag: tags.integer,
            color: '#79c3ba',
          },
          {
            tag: tags.float,
            color: '#79c37f',
          },
        ])
      ),
      oneDark,
      EditorView.lineWrapping,
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

  ensureSyntaxTree(codemirror.state, codemirror.state.doc.length, 1000)
  // codemirror.dispatch({})
  const tree = syntaxTree(codemirror.state)
  const effects = []

  tree.iterate({
    enter: node => {
      if (node.name == 'FunctionDefinition') {
        const nameNode = node.node
          .getChild('FunctionPrototype')
          ?.node.getChild('Identifier')
        if (!nameNode) {
          return
        }
        const name = codemirror.state.doc.sliceString(
          nameNode.from,
          nameNode.to
        )
        // if (['mainImage', 'map', 'shade'].includes(name)) {
        //   unfoldCode(codemirror, functionNode.from, functionNode.to)
        // }
        if (!['mainImage', 'map', 'shade'].includes(name)) {
          const compoundStatementNode = node.node.getChild('CompoundStatement')
          if (!compoundStatementNode) {
            return
          }
          effects.push(
            foldEffect.of({
              from: compoundStatementNode.from,
              to: compoundStatementNode.to,
            })
          )
        }
      }
    },
  })

  codemirror.dispatch({
    effects,
  })
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
