suite 'Function Literals', ->

  test 'basic function literals', ->
    eq '->', generate new CSFunction [], new Block []
    eq '=>', generate new BoundFunction [], new Block []
