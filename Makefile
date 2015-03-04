LIB=ISO8601
LIB_FILES=$(addprefix $(LIB)., a cmxa cma cmi)
VERSION=0.2.1

.INTERMEDIATE: $(LIB).odocl

build: $(LIB_FILES)

$(LIB_FILES):
	ocamlbuild -I src $@

install: META $(LIB_FILES)
	ocamlfind install $(LIB) META $(addprefix _build/src/, $(LIB_FILES))

uninstall:
	ocamlfind remove $(LIB)

$(LIB).odocl:
	echo 'ISO8601' > $@

doc: $(LIB).odocl
	ocamlbuild -I src $(LIB).docdir/index.html

gh-pages: doc
	commitmsg="Documentation for $(VERSION) version." \
	docdir="$(LIB).docdir" \
	upstream="origin" \
	ghpup

clean:
	ocamlbuild -clean

clean:
	ocamlbuild -clean
