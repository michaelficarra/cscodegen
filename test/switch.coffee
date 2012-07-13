suite 'Switch', ->

  #test 'basic switch', ->
  #  eq """
  #  switch a
  #    when b then c
  #  """, generate new Switch (new Identifier 'a'), [[(new Identifier 'b'), new Identifier 'c']], null
