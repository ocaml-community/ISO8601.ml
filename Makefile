
build:
	jbuilder build @install

doc:
	jbuilder build @doc

gh-pages: doc
	commitmsg="Documentation for $(VERSION) version." \
	docdir="_build/default/_doc/_html/" \
	upstream="origin" \
	ghpup

clean:
	jbuilder clean

