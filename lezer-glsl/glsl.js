import {
  LRLanguage,
  LanguageSupport,
  continuedIndent,
  foldInside,
  foldNodeProp,
  indentNodeProp,
} from '@codemirror/language'
import { parser } from './glsl-parser.js'

export const glslLanguage = LRLanguage.define({
  name: 'glsl',
  parser: parser.configure({
    props: [
      indentNodeProp.add({
        IfStatement: continuedIndent({ except: /^\s*({|else\b)/ }),
        CaseStatement: context => context.baseIndent + context.unit,
        BlockComment: () => null,
        Statement: continuedIndent({ except: /^{/ }),
      }),
      foldNodeProp.add({
        CompoundStatement: foldInside,
        BlockComment(tree) {
          return { from: tree.from + 2, to: tree.to - 2 }
        },
      }),
    ],
  }),
  languageData: {
    commentTokens: { line: '//', block: { open: '/*', close: '*/' } },
    indentOnInput: /^\s*(?:case |default:|\{|\})$/,
  },
})

/// Language support for glsl.
export function glsl() {
  return new LanguageSupport(glslLanguage)
}
