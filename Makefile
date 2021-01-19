all: build test

build:
	@dune build @install

doc:
	@dune build @doc

test:
	@dune runtest --force --no-buffer

clean:
	@dune clean

.PHONY: test build clean
