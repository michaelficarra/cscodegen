suite 'Function Literals', ->

  setup ->
    @emptyBlock = new Block []
    @x = new Identifier 'x'
    @y = new Identifier 'y'

  test 'basic function literals', ->
    eq '->', generate new CSFunction [], @emptyBlock
    eq '=>', generate new BoundFunction [], @emptyBlock

  test 'basic parameter lists', ->
    eq '(x) ->', generate new CSFunction [@x], @emptyBlock
    eq '(x, y) ->', generate new CSFunction [@x, @y], @emptyBlock

  test 'basic function bodies', ->
    eq '-> x', generate new CSFunction [], new Block [@x]

  test 'less basic function bodies', ->
    eq '->\n  x\n  y', generate new CSFunction [], new Block [@x, @y]
