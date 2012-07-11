default: all

all: build test

build: src/*.coffee
	node_modules/coffee-script/bin/coffee -o lib -c src

test: lib/*.js test/*.coffee
	node_modules/mocha/bin/mocha --compilers coffee:coffee-script -u tdd -R spec

clean:
	rm lib/*.js

.PHONY: test clean
