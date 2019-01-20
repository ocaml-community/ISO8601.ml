.PHONY: build test doc ISO8601.install install clean

build:
	dune build @install

test:
	dune build @runtest

doc:
	dune build @doc

ISO8601.install:
	dune build @install

install: ISO8601.install
	dune install ISO8601

gh-pages: doc
	commitmsg="Documentation for $(VERSION) version." \
	docdir="_build/default/_doc/_html/" \
	upstream="origin" \
	ghpup

clean:
	dune clean
