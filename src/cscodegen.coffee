do (exports = exports ? this.cscodegen = {}) ->

  TAB = '  '
  indent = (code) -> ("#{TAB}#{line}" for line in code.split '\n').join '\n'
  parens = (code) -> "(#{code})"

  formatStringData = (data) ->
    data.replace /[^\x20-\x7e]|['\\]/, (c) ->
      switch c
        when '\0' then '\\0'
        when '\b' then '\\b'
        when '\t' then '\\t'
        when '\n' then '\\n'
        when '\f' then '\\f'
        when '\r' then '\\r'
        when '\'' then '\\\''
        when '\\' then '\\\\'
        else
          escape = (c.charCodeAt 0).toString 16
          pad = "0000"[escape.length...]
          "\\u#{pad}#{escape}"

  formatInterpolation = (ast, options) ->
    switch ast.className
      when "ConcatOp"
        left = formatInterpolation ast.left, options
        right = formatInterpolation ast.right, options
        "#{left}#{right}"
      when "String"
        formatStringData ast.data
      else
        "\#{#{generate ast, options}}"

  levels = [
    ['Function', 'BoundFunction'] # Arrow
    ['SeqOp'] # Sequence
    ['Conditional', 'ForIn', 'ForOf', 'While'] # ControlFlow
    ['AssignOp', 'CompoundAssignOp', 'ExistsAssignOp'] # Assignment
    ['LogicalOrOp'] # LogicalOR
    ['LogicalAndOp'] # LogicalAND
    ['BitOrOp'] # BitwiseOR
    ['BitXorOp'] # BitwiseXOR
    ['BitAndOp'] # BitwiseAND
    ['EQOp', 'NEQOp'] # Equality
    ['LTOp', 'LTEOp', 'GTOp', 'GTEOp', 'InOp', 'OfOp', 'InstanceofOp'] # Relational
    ['LeftShiftOp', 'SignedRightShiftOp', 'UnsignedRightShiftOp'] # BitwiseSHIFT
    ['AddOp', 'SubtractOp'] # Additive
    ['MultiplyOp', 'DivideOp', 'RemOp'] # Multiplicative
    ['Spread'] # Spread
    ['UnaryPlusOp', 'UnaryNegateOp', 'LogicalNotOp', 'BitNotOp', 'DoOp', 'TypeofOp', 'PreIncrementOp', 'PreDecrementOp'] # Unary
    ['UnaryExistsOp', 'ShallowCopyArray', 'PostIncrementOp', 'PostDecrementOp'] # Postfix
    ['FunctionApplication', 'SoakedFunctionApplication'] # Application
    ['NewOp'] # New
    ['MemberAccessOp', 'SoakedMemberAccessOp', 'DynamicMemberAccessOp', 'SoakedDynamicMemberAccessOp', 'ProtoMemberAccessOp', 'DynamicProtoMemberAccessOp', 'SoakedProtoMemberAccessOp', 'SoakedDynamicProtoMemberAccessOp'] # Member
  ]

  precedence = {}
  do ->
    for ops, level in levels
      for op in ops
        precedence[op] = level

  operators =
    # Binary
    SeqOp: ';'
    LogicalOrOp: '||', LogicalAndOp: '&&'
    BitOrOp: '|', BitXorOp: '^', BitAndOp: '&'
    EQOp: 'is', NEQOp: 'isnt', LTOp: '<', LTEOp: '<=', GTOp: '>', GTEOp: '>='
    InOp: 'in', OfOp: 'of', InstanceofOp: 'instanceof'
    LeftShiftOp: '<<', SignedRightShiftOp: '>>', UnsignedRightShiftOp: '>>>'
    AddOp: '+', SubtractOp: '-', MultiplyOp: '*', DivideOp: '/', RemOp: '%'
    # Prefix
    UnaryPlusOp: '+', UnaryNegateOp: '-', LogicalNotOp: '!', BitNotOp: '~'
    DoOp: 'do ', NewOp: 'new ', TypeofOp: 'typeof '
    PreIncrementOp: '++', PreDecrementOp: '--'
    # Postfix
    UnaryExistsOp: '?'
    ShallowCopyArray: '[..]'
    PostIncrementOp: '++'
    PostDecrementOp: '--'
    Spread: '...'
    # Application
    FunctionApplication: ''
    SoakedFunctionApplication: '?'
    # Member
    MemberAccessOp: '.'
    SoakedMemberAccessOp: '?.'
    ProtoMemberAccessOp: '::'
    SoakedProtoMemberAccessOp: '?::'
    DynamicMemberAccessOp: ''
    SoakedDynamicMemberAccessOp: '?'
    DynamicProtoMemberAccessOp: '::'
    SoakedDynamicProtoMemberAccessOp: '?::'

  exports.generate = generate = (ast, options = {}) ->
    needsParens = no
    options.precedence ?= 0
    src = switch ast.className
      when 'Program'
        generate ast.block, options
      when 'Block'
        (generate s, options for s in ast.statements).join '\n\n'
      when 'Identifier'
        ast.data
      when 'String'
        "'#{formatStringData ast.data}'"
      when 'Function', 'BoundFunction'
        prec = precedence[ast.className]
        needsParens = prec < options.precedence
        options.precedence = prec
        parameters = (generate p, options for p in ast.parameters)
        block = generate ast.block, options
        paramList = if ast.parameters.length > 0 then "(#{parameters.join ', '}) " else ''
        body = if ast.block.length > 0 then "\n#{indent block}" else " #{block}"
        switch ast.className
          when 'Function' then "#{paramList}->#{body}"
          when 'BoundFunction' then "#{paramList}=>#{body}"
      when 'AssignOp'
        prec = precedence[ast.className]
        needsParens = prec < options.precedence
        options.precedence = prec
        assignee = generate ast.assignee, options
        expr = generate ast.expr, options
        "#{assignee} = #{expr}"
      when 'SeqOp'
        prec = precedence[ast.className]
        needsParens = prec < options.precedence
        options.precedence = prec
        left = generate ast.left, options
        right = generate ast.right, options
        "#{left}; #{right}"
      when 'LeftShiftOp', 'SignedRightShiftOp', 'UnsignedRightShiftOp', 'AddOp', 'SubtractOp', 'MultiplyOp', 'DivideOp', 'RemOp'
        op = operators[ast.className]
        prec = precedence[ast.className]
        needsParens = prec < options.precedence
        options.precedence = prec
        left = generate ast.left, options
        right = generate ast.right, options
        "#{left} #{op} #{right}"
      when 'UnaryPlusOp', 'UnaryNegateOp', 'LogicalNotOp', 'BitNotOp', 'DoOp', 'TypeofOp', 'PreIncrementOp', 'PreDecrementOp'
        op = operators[ast.className]
        prec = precedence[ast.className]
        needsParens = prec < options.precedence
        options.precedence = prec
        "#{op}#{generate ast.expr, options}"
      when 'UnaryExistsOp', 'ShallowCopyArray', 'PostIncrementOp', 'PostDecrementOp', 'Spread'
        op = operators[ast.className]
        prec = precedence[ast.className]
        needsParens = prec < options.precedence
        options.precedence = prec
        "#{generate ast.expr, options}#{op}"
      when 'FunctionApplication', 'SoakedFunctionApplication'
        op = operators[ast.className]
        options.precedence = precedence[ast.className]
        needsParens = prec < options.precedence
        fn = generate ast.function, options
        args = (generate a, options for a in ast.arguments)
        argList = if ast.arguments.length is 0 then '()' else " #{args.join ', '}"
        "#{fn}#{op}#{argList}"
      when 'MemberAccessOp', 'SoakedMemberAccessOp', 'ProtoMemberAccessOp', 'SoakedProtoMemberAccessOp'
        op = operators[ast.className]
        prec = precedence[ast.className]
        needsParens = prec < options.precedence
        options.precedence = prec
        expr = generate ast.expr, options
        memberName = generate ast.memberName, options
        "#{expr}#{op}#{memberName}"
      when 'DynamicMemberAccessOp', 'SoakedDynamicMemberAccessOp', 'DynamicProtoMemberAccessOp', 'SoakedDynamicProtoMemberAccessOp'
        op = operators[ast.className]
        prec = precedence[ast.className]
        needsParens = prec < options.precedence
        options.precedence = prec
        expr = generate ast.expr, options
        options.precedence = 0
        indexingExpr = generate ast.indexingExpr, options
        "#{expr}#{op}[#{indexingExpr}]"
      when 'ConcatOp'
        left = formatInterpolation ast.left, options
        right = formatInterpolation ast.right, options
        "\"#{left}#{right}\""
      else
        throw new Error 'Non-exhaustive patterns in case: #{ast.className}'
    if needsParens then (parens src) else src
