fs = require 'fs'
path = require 'path'
util = require 'util'
{exec} = require 'child_process'
CoffeeScript = require 'coffee-script'

inspect = (o) -> util.inspect o, no, 2, yes

execCallback = (err, stdout, stderr) ->
  if err? then console.error "exec error: #{err}"
  if stdout.toString() then console.log stdout
  if stderr.toString() then console.error stderr

task 'build', ->
  exec 'coffee -sc < src/cscodegen.coffee > lib/cscodegen.js', execCallback
  0

task 'test', ->

  global[name] = func for name, func of require 'assert'
  {generate: global.generate} = require './lib/cscodegen'

  # See http://wiki.ecmascript.org/doku.php?id=harmony:egal
  egal = (a, b) ->
    if a is b
      a isnt 0 or 1/a is 1/b
    else
      a isnt a and b isnt b

  # A recursive functional equivalence helper; uses egal for testing equivalence.
  arrayEgal = (a, b) ->
    if egal a, b then yes
    else if a instanceof Array and b instanceof Array
      return no unless a.length is b.length
      return no for el, idx in a when not arrayEgal el, b[idx]
      yes

  global.eq      = (a, b, msg) -> ok egal(a, b), msg ? "#{inspect a} === #{inspect b}"
  global.arrayEq = (a, b, msg) -> ok arrayEgal(a,b), msg ? "#{inspect a} === #{inspect b}"

  # Run every test in the `test` folder, recording failures.
  files = fs.readdirSync 'test'
  for file in files when file.match /\.coffee$/i
    code = fs.readFileSync filename = path.join 'test', file
    CoffeeScript.run code.toString(), {filename}

  0
