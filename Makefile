default: all

SRC = $(shell find src -name "*.coffee" -type f | sort)
LIB = $(shell find lib -name "*.js" -type f | sort)
TESTS = $(shell find test -name "*.coffee" -type f | sort)

COFFEE = node_modules/coffee-script/bin/coffee
MOCHA = node_modules/mocha/bin/mocha --compilers coffee:coffee-script -u tdd

all: build test

build: $(SRC)
	$(COFFEE) -o lib -c src

test: $(LIB) $(TEST)
	$(MOCHA) -R spec

# obviously, this is not ideal
coverage:
	@which jscoverage || (echo "install node-jscoverage"; exit 1)
	rm -rf instrumented
	jscoverage -v lib instrumented
	$(MOCHA) -r instrumented/cscodegen -R html-cov > coverage.html
	@xdg-open coverage.html &> /dev/null

clean:
	rm -rf instrumented
	rm coverage.html

.PHONY: test clean
