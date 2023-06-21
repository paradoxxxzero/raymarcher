import { styleTags, tags as t } from '@lezer/highlight'

export const glslHighlighting = styleTags({
  'typedef struct union enum class typename decltype auto template operator friend noexcept namespace using requires concept import export module __attribute__ __declspec __based':
    t.definitionKeyword,
  'extern MsCallModifier MsPointerModifier extern static register thread_local inline const volatile restrict _Atomic mutable constexpr constinit consteval virtual explicit VirtualSpecifier Access':
    t.modifier,
  'if else switch for while do case default return break continue goto throw try catch':
    t.controlKeyword,
  'co_return co_yield co_await': t.controlKeyword,
  'new sizeof delete static_assert': t.operatorKeyword,
  'NULL nullptr': t.null,
  this: t.self,
  'True False': t.bool,
  'TypeSize PrimitiveType': t.standard(t.typeName),
  TypeIdentifier: t.typeName,
  FieldIdentifier: t.propertyName,
  'CallExpression/FieldExpression/FieldIdentifier': t.function(t.propertyName),
  'ModuleName/Identifier': t.namespace,
  PartitionName: t.labelName,
  StatementIdentifier: t.labelName,
  'Identifier DestructorName': t.variableName,
  'CallExpression/Identifier': t.function(t.variableName),
  'CallExpression/ScopedIdentifier/Identifier': t.function(t.variableName),
  'FunctionDeclarator/Identifier FunctionDeclarator/DestructorName': t.function(
    t.definition(t.variableName)
  ),
  NamespaceIdentifier: t.namespace,
  OperatorName: t.operator,
  ArithOp: t.arithmeticOperator,
  LogicOp: t.logicOperator,
  BitOp: t.bitwiseOperator,
  CompareOp: t.compareOperator,
  AssignOp: t.definitionOperator,
  UpdateOp: t.updateOperator,
  LineComment: t.lineComment,
  BlockComment: t.blockComment,
  Number: t.number,
  String: t.string,
  'RawString SystemLibString': t.special(t.string),
  CharLiteral: t.character,
  EscapeSequence: t.escape,
  'UserDefinedLiteral/Identifier': t.literal,
  PreProcArg: t.meta,
  'PreprocDirectiveName #include #ifdef #ifndef #if #define #else #endif #elif':
    t.processingInstruction,
  MacroName: t.special(t.name),
  '( )': t.paren,
  '[ ]': t.squareBracket,
  '{ }': t.brace,
  '< >': t.angleBracket,
  '. ->': t.derefOperator,
  ', ;': t.separator,
})
