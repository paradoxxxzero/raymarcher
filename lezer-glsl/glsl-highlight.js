import { styleTags, tags as t } from '@lezer/highlight'

export const glslHighlighting = styleTags({
  'if else switch for while do case default return break continue discard':
    t.controlKeyword,
  'struct precision layout subroutine': t.definitionKeyword,
  'uniform attribute in out inout const flat invariant precise shared':
    t.modifier,
  struct: t.definitionKeyword,
  TypeQualifier: t.modifier,
  StorageQualifier: t.modifier,
  LayoutQualifier: t.modifier,
  PrecisionQualifier: t.unit,
  InterpolationQualifier: t.modifier,
  InvariantQualifier: t.modifier,
  'true false': t.bool,
  TypeSpecifier: t.typeName,
  'CallExpression/Identifier': t.function(t.variableName),
  StatementIdentifier: t.labelName,
  'Declaration/FunctionPrototype/Identifier': t.function(
    t.definition(t.variableName)
  ),
  'FunctionPrototype/Identifier': t.function(t.variableName),
  UnaryOperator: t.operator,
  ArithOp: t.arithmeticOperator,
  LogicOp: t.logicOperator,
  BitOp: t.bitwiseOperator,
  CompareOp: t.compareOperator,
  AssignOp: t.definitionOperator,
  UpdateOp: t.updateOperator,
  Type: t.typeName,
  LineComment: t.lineComment,
  BlockComment: t.blockComment,
  Integer: t.integer,
  Float: t.float,
  Boolean: t.bool,

  VariableIdentifier: t.variableName,
  'FieldIdentifier/Swizzle': t.string,
  'FieldIdentifier/Field': t.special(t.propertyName),
  Identifier: t.literal,

  PreProcArg: t.meta,
  'PreprocDirectiveName #ifdef #ifndef #if #define #else #endif #elif':
    t.processingInstruction,
  '( )': t.paren,
  '[ ]': t.squareBracket,
  '{ }': t.brace,
  ', ;': t.separator,
})
