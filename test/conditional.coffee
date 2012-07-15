suite 'Conditionals', ->

  test 'basic', ->
    eq 'if 0 then 1', generate new Conditional (new Int 0), new Block [new Int 1]
    eq 'if 0 then 1', generate new Conditional (new Int 0), new Int 1

  test 'basic with else', ->
    eq 'if 0 then 1 else 2', generate new Conditional (new Int 0), (new Block [new Int 1]), new Block [new Int 2]
    eq 'if 0 then 1 else 2', generate new Conditional (new Int 0), (new Int 1), new Int 2

  test 'multiline', ->
    eq '''
    if 0
      1
      2
    ''', generate new Conditional (new Int 0), new Block [(new Int 1), new Int 2]

  test 'multiline with else', ->
    eq '''
    if 0
      1
      2
    else
      3
      4
    ''', generate new Conditional (new Int 0), (new Block [(new Int 1), new Int 2]), new Block [(new Int 3), new Int 4]

  test 'multiline with basic else', ->
    eq '''
    if 0
      1
      2
    else
      3
    ''', generate new Conditional (new Int 0), (new Block [(new Int 1), new Int 2]), new Block [new Int 3]

    eq '''
    if 0
      1
      2
    else
      3
    ''', generate new Conditional (new Int 0), (new Block [(new Int 1), new Int 2]), new Int 3

  test 'basic with multiline else', ->
    eq '''
    if 0
      1
    else
      2
      3
    ''', generate new Conditional (new Int 0), (new Block [new Int 1]), new Block [(new Int 2), new Int 3]

    eq '''
    if 0
      1
    else
      2
      3
    ''', generate new Conditional (new Int 0), (new Int 1), new Block [(new Int 2), new Int 3]
