
build:
	dune build @install

doc:
	dune build @doc

ISO8601.install:
	dune build @install
.PHONY: ISO8601.install

install: ISO8601.install
	dune install ISO8601

gh-pages: doc
	commitmsg="Documentation for $(VERSION) version." \
	docdir="_build/default/_doc/_html/" \
	upstream="origin" \
	ghpup

clean:
	dune clean
