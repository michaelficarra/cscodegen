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

  needsParensWhenOnLeft = (ast) ->
    switch ast.className
      when 'Function', 'BoundFunction', 'FunctionApplication' then yes
      when 'PreIncrementOp', 'PreDecrementOp', 'UnaryPlusOp', 'UnaryNegateOp', 'LogicalNotOp', 'BitNotOp', 'DoOp', 'TypeofOp', 'DeleteOp'
        needsParensWhenOnLeft ast.expr
      when 'NewOp' then ast.arguments.length > 0
      else no

  levels = [
    ['SeqOp'] # Sequence
    ['Conditional', 'ForIn', 'ForOf', 'While'] # Control Flow
    ['FunctionApplication', 'SoakedFunctionApplication'] # Application
    ['AssignOp', 'CompoundAssignOp', 'ExistsAssignOp'] # Assignment
    ['LogicalOrOp'] # Logical OR
    ['LogicalAndOp'] # Logical AND
    ['BitOrOp'] # Bitwise OR
    ['BitXorOp'] # Bitwise XOR
    ['BitAndOp'] # Bitwise AND
    ['ExistsOp'] # Existential
    ['EQOp', 'NEQOp'] # Equality
    ['LTOp', 'LTEOp', 'GTOp', 'GTEOp', 'InOp', 'OfOp', 'InstanceofOp'] # Relational
    ['LeftShiftOp', 'SignedRightShiftOp', 'UnsignedRightShiftOp'] # Bitwise Shift
    ['AddOp', 'SubtractOp'] # Additive
    ['MultiplyOp', 'DivideOp', 'RemOp'] # Multiplicative
    ['UnaryPlusOp', 'UnaryNegateOp', 'LogicalNotOp', 'BitNotOp', 'DoOp', 'TypeofOp', 'PreIncrementOp', 'PreDecrementOp', 'DeleteOp'] # Unary
    ['UnaryExistsOp', 'ShallowCopyArray', 'PostIncrementOp', 'PostDecrementOp', 'Spread'] # Postfix
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
      when 'Int'
        ast.data
      when 'String'
        "'#{formatStringData ast.data}'"
      when 'Function', 'BoundFunction'
        options.precedence = precedence['AssignmentExpression']
        parameters = (generate p, options for p in ast.parameters)
        options.precedence = 0
        block = generate ast.block, options
        paramList = if ast.parameters.length > 0 then "(#{parameters.join ', '}) " else ''
        body = switch ast.block.statements.length
          when 0 then ""
          when 1 then " #{block}"
          else "\n#{indent block}"
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
      when 'LeftShiftOp', 'SignedRightShiftOp', 'UnsignedRightShiftOp', 'AddOp', 'SubtractOp', 'MultiplyOp', 'DivideOp', 'RemOp', 'ExistsOp'
        op = operators[ast.className]
        prec = precedence[ast.className]
        needsParens = prec < options.precedence
        options.precedence = prec
        left = generate ast.left, options
        left = "(#{left})" if needsParensWhenOnLeft ast.left
        right = generate ast.right, options
        "#{left} #{op} #{right}"
      when 'UnaryPlusOp', 'UnaryNegateOp', 'LogicalNotOp', 'BitNotOp', 'DoOp', 'TypeofOp', 'PreIncrementOp', 'PreDecrementOp'
        op = operators[ast.className]
        prec = precedence[ast.className]
        needsParens = prec < options.precedence
        options.precedence = prec
        "#{op}#{generate ast.expr, options}"
      when 'UnaryExistsOp', 'PostIncrementOp', 'PostDecrementOp', 'Spread'
        op = operators[ast.className]
        prec = precedence[ast.className]
        needsParens = prec < options.precedence
        options.precedence = prec
        expr = generate ast.expr, options
        expr = "(#{expr})" if needsParensWhenOnLeft ast.expr
        "#{expr}#{op}"
      when 'PreIncrementOp', 'PreDecrementOp', 'UnaryPlusOp', 'UnaryNegateOp', 'LogicalNotOp', 'BitNotOp', 'DoOp', 'TypeofOp', 'DeleteOp'
        op = operators[ast.className]
        prec = precedence[ast.className]
        needsParens = prec < options.precedence
        options.precedence = prec
        "#{op}#{generate ast.expr, options}"
      when 'NewOp'
        op = operators[ast.className]
        prec = precedence[ast.className]
        needsParens = prec < options.precedence
        options.precedence = prec
        ctor = generate ast.ctor, options
        ctor = "(#{ctor})" if ast.arguments.length > 0 and needsParensWhenOnLeft ast.ctor
        options.precedence = precedence['AssignOp']
        args = for a, i in ast.arguments
          arg = generate a, options
          arg = "(#{arg})" if (needsParensWhenOnLeft a) and i + 1 isnt ast.arguments.length
          arg
        args = args.join ', '
        args = " #{args}" if ast.arguments.length > 0
        "#{op}#{ctor}#{args}"
      when 'FunctionApplication', 'SoakedFunctionApplication'
        op = operators[ast.className]
        options.precedence = precedence[ast.className]
        fn = generate ast.function, options
        fn = "(#{fn})" if needsParensWhenOnLeft ast.function
        args = for a, i in ast.arguments
          arg = generate a, options
          arg = "(#{arg})" if (needsParensWhenOnLeft a) and i + 1 isnt ast.arguments.length
          arg
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
        throw new Error "Non-exhaustive patterns in case: #{ast.className}"
    if needsParens then (parens src) else src
