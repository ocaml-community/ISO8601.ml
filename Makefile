
build:
	@dune build @install

doc:
	@dune build @doc

gh-pages: doc
	commitmsg="Documentation for $(VERSION) version." \
	docdir="_build/default/_doc/_html/" \
	upstream="origin" \
	ghpup

clean:
	@dune clean

