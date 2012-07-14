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
      when 'Function', 'BoundFunction', 'NewOp' then yes
      when 'Conditional', 'Switch', 'While', 'Block' then yes
      when 'PreIncrementOp', 'PreDecrementOp', 'UnaryPlusOp', 'UnaryNegateOp', 'LogicalNotOp', 'BitNotOp', 'DoOp', 'TypeofOp', 'DeleteOp'
        needsParensWhenOnLeft ast.expr
      when 'FunctionApplication' then ast.arguments.length > 0
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
    ['PlusOp', 'SubtractOp'] # Additive
    ['MultiplyOp', 'DivideOp', 'RemOp'] # Multiplicative
    ['UnaryPlusOp', 'UnaryNegateOp', 'LogicalNotOp', 'BitNotOp', 'DoOp', 'TypeofOp', 'PreIncrementOp', 'PreDecrementOp', 'DeleteOp', 'Undefined'] # Unary
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
    LogicalOrOp: 'or', LogicalAndOp: 'and'
    BitOrOp: '|', BitXorOp: '^', BitAndOp: '&'
    EQOp: 'is', NEQOp: 'isnt', LTOp: '<', LTEOp: '<=', GTOp: '>', GTEOp: '>='
    InOp: 'in', OfOp: 'of', InstanceofOp: 'instanceof'
    LeftShiftOp: '<<', SignedRightShiftOp: '>>', UnsignedRightShiftOp: '>>>'
    PlusOp: '+', SubtractOp: '-', MultiplyOp: '*', DivideOp: '/', RemOp: '%'
    # Prefix
    UnaryPlusOp: '+', UnaryNegateOp: '-', LogicalNotOp: 'not ', BitNotOp: '~'
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

  # TODO: DRY this function
  exports.generate = generate = (ast, options = {}) ->
    needsParens = no
    options.precedence ?= 0
    options.ancestors ?= []
    parent = options.ancestors[0]
    parentClassName = parent?.className
    usedAsExpression = parent? and parentClassName isnt 'Block'
    src = switch ast.className

      when 'Program'
        options.ancestors.unshift ast
        generate ast.block, options

      when 'Block'
        options.ancestors.unshift ast
        if ast.statements.length is 0 then generate (new Undefined).g(), options
        else
          sep = if parentClassName is 'Program' then '\n\n' else '\n'
          (generate s, options for s in ast.statements).join sep

      when 'Conditional'
        options.ancestors.unshift ast
        options.precedence = 0

        hasElseBlock = ast.block? and ast.elseBlock?
        _block = generate (ast.block ? (new Undefined).g()), options
        _elseBlock = if hasElseBlock then generate ast.elseBlock, options else ""

        isMultiline =
          _block.length > 90 or
          _elseBlock.length > 90 or
          (_elseBlock.indexOf '\n') > -1 or
          (_block.indexOf '\n') > -1

        _block = if isMultiline then "\n#{indent _block}" else " then #{_block}"
        if hasElseBlock
          _elseBlock =
            if isMultiline then "\nelse\n#{indent _elseBlock}"
            else " else #{_elseBlock}"
        "if #{generate ast.condition, options}#{_block}#{_elseBlock}"

      when 'Identifier' then ast.data

      when 'Null' then 'null'

      when 'Undefined'
        prec = precedence[ast.className]
        needsParens = prec < options.precedence
        'void 0'

      when 'Int'
        absNum = if ast.data < 0 then -ast.data else ast.data
        # if number is a power of two (at least 2^4) or hex is a shorter
        # representation, represent it as hex
        if absNum >= 1e12 or (absNum >= 0x10 and 0 is (absNum & (absNum - 1)))
          "0x#{ast.data.toString 16}"
        else
          ast.data.toString 10

      when 'String'
        "'#{formatStringData ast.data}'"

      when 'Function', 'BoundFunction'
        options.ancestors.unshift ast
        options.precedence = precedence.AssignmentExpression
        parameters = (generate p, options for p in ast.parameters)
        options.precedence = 0
        _block = generate ast.block, options
        _paramList = if ast.parameters.length > 0 then "(#{parameters.join ', '}) " else ''
        _body = switch ast.block.statements.length
          when 0 then ""
          when 1 then " #{_block}"
          else "\n#{indent _block}"
        switch ast.className
          when 'Function' then "#{_paramList}->#{_body}"
          when 'BoundFunction' then "#{_paramList}=>#{_body}"

      when 'AssignOp'
        prec = precedence[ast.className]
        needsParens = prec < options.precedence
        options.precedence = prec
        options.ancestors.unshift ast
        _assignee = generate ast.assignee, options
        _expr = generate ast.expr, options
        "#{_assignee} = #{_expr}"

      when 'CompoundAssignOp'
        prec = precedence[ast.className]
        needsParens = prec < options.precedence
        options.precedence = prec
        options.ancestors.unshift ast
        _op = operators[ast.op::className]
        _assignee = generate ast.assignee, options
        _expr = generate ast.expr, options
        "#{_assignee} #{_op}= #{_expr}"

      when 'SeqOp'
        prec = precedence[ast.className]
        needsParens = prec < options.precedence
        options.precedence = prec
        options.ancestors.unshift ast
        _left = generate ast.left, options
        _right = generate ast.right, options
        "#{_left}; #{_right}"

      when 'LogicalOrOp', 'LogicalAndOp', 'BitOrOp', 'BitXorOp', 'BitAndOp', 'LeftShiftOp', 'SignedRightShiftOp', 'UnsignedRightShiftOp', 'EQOp', 'NEQOp', 'LTOp', 'LTEOp', 'GTOp', 'GTEOp', 'InOp', 'OfOp', 'InstanceofOp', 'PlusOp', 'SubtractOp', 'MultiplyOp', 'DivideOp', 'RemOp', 'ExistsOp'
        _op = operators[ast.className]
        if ast.className in ['InOp', 'OfOp', 'InstanceofOp'] and parentClassName is 'LogicalNotOp'
          _op = "not #{_op}"
        prec = precedence[ast.className]
        needsParens = prec < options.precedence
        options.precedence = prec
        options.ancestors.unshift ast
        _left = generate ast.left, options
        _left = parens _left if needsParensWhenOnLeft ast.left
        _right = generate ast.right, options
        "#{_left} #{_op} #{_right}"

      when 'UnaryPlusOp', 'UnaryNegateOp', 'LogicalNotOp', 'BitNotOp', 'DoOp', 'TypeofOp', 'PreIncrementOp', 'PreDecrementOp'
        _op = operators[ast.className]
        prec = precedence[ast.className]
        if ast.className is 'LogicalNotOp'
          if ast.expr.className in ['InOp', 'OfOp', 'InstanceofOp']
            _op = '' # these will be treated as negated variants
            prec = precedence[ast.expr.className]
          if 'LogicalNotOp' in [parentClassName, ast.expr.className]
            _op = '!'
        needsParens = prec < options.precedence
        needsParens = yes if parentClassName is ast.className and ast.className in ['UnaryPlusOp', 'UnaryNegateOp']
        options.precedence = prec
        options.ancestors.unshift ast
        "#{_op}#{generate ast.expr, options}"

      when 'UnaryExistsOp', 'PostIncrementOp', 'PostDecrementOp', 'Spread'
        _op = operators[ast.className]
        prec = precedence[ast.className]
        needsParens = prec < options.precedence
        options.precedence = prec
        options.ancestors.unshift ast
        _expr = generate ast.expr, options
        _expr = parens _expr if needsParensWhenOnLeft ast.expr
        "#{_expr}#{_op}"

      when 'NewOp'
        _op = operators[ast.className]
        prec = precedence[ast.className]
        #needsParens = prec < options.precedence
        options.precedence = prec
        options.ancestors.unshift ast
        _ctor = generate ast.ctor, options
        _ctor = parens _ctor if ast.arguments.length > 0 and needsParensWhenOnLeft ast.ctor
        options.precedence = precedence['AssignOp']
        args = for a, i in ast.arguments
          arg = generate a, options
          arg = parens arg if (needsParensWhenOnLeft a) and i + 1 isnt ast.arguments.length
          arg
        _args = if ast.arguments.length is 0 then '' else " #{args.join ', '}"
        "#{_op}#{_ctor}#{_args}"

      when 'FunctionApplication', 'SoakedFunctionApplication'
        if ast.className is 'FunctionApplication' and ast.arguments.length is 0 and not usedAsExpression
          generate (new DoOp ast.function), options
        else
          _op = operators[ast.className]
          options.precedence = precedence[ast.className]
          options.ancestors.unshift ast
          _fn = generate ast.function, options
          _fn = parens _fn if needsParensWhenOnLeft ast.function
          args = for a, i in ast.arguments
            arg = generate a, options
            arg = parens arg if (needsParensWhenOnLeft a) and i + 1 isnt ast.arguments.length
            arg
          _argList = if ast.arguments.length is 0 then '()' else " #{args.join ', '}"
          "#{_fn}#{_op}#{_argList}"

      when 'MemberAccessOp', 'SoakedMemberAccessOp', 'ProtoMemberAccessOp', 'SoakedProtoMemberAccessOp'
        _op = operators[ast.className]
        prec = precedence[ast.className]
        needsParens = prec < options.precedence
        options.precedence = prec
        options.ancestors.unshift ast
        _expr = generate ast.expr, options
        _expr = parens _expr if needsParensWhenOnLeft ast.expr
        "#{_expr}#{_op}#{ast.memberName}"

      when 'DynamicMemberAccessOp', 'SoakedDynamicMemberAccessOp', 'DynamicProtoMemberAccessOp', 'SoakedDynamicProtoMemberAccessOp'
        _op = operators[ast.className]
        prec = precedence[ast.className]
        needsParens = prec < options.precedence
        options.precedence = prec
        options.ancestors.unshift ast
        _expr = generate ast.expr, options
        _expr = parens _expr if needsParensWhenOnLeft ast.expr
        options.precedence = 0
        _indexingExpr = generate ast.indexingExpr, options
        "#{_expr}#{_op}[#{_indexingExpr}]"

      when 'ConcatOp'
        _left = formatInterpolation ast.left, options
        _right = formatInterpolation ast.right, options
        "\"#{_left}#{_right}\""

      else
        throw new Error "Non-exhaustive patterns in case: #{ast.className}"

    if needsParens then (parens src) else src
