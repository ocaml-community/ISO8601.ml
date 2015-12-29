.PHONY: build test install uninstall doc gh-pages clean

LIB=ISO8601
LIB_FILES=$(addprefix $(LIB)., a cmxa cma cmi)
VERSION=0.2.4

OCAMLBUILD=ocamlbuild -use-ocamlfind -classic-display

.INTERMEDIATE: $(LIB).odocl

build: $(LIB_FILES)

$(LIB_FILES):
	$(OCAMLBUILD) $@

test:
	$(OCAMLBUILD) test.native
	./test.native

install: META $(LIB_FILES)
	ocamlfind install $(LIB) META $(addprefix _build/src/, $(LIB_FILES))

uninstall:
	ocamlfind remove $(LIB)

$(LIB).odocl:
	echo 'ISO8601' > $@

doc: $(LIB).odocl
	$(OCAMLBUILD) $(LIB).docdir/index.html

gh-pages: doc
	commitmsg="Documentation for $(VERSION) version." \
	docdir="$(LIB).docdir" \
	upstream="origin" \
	ghpup

clean:
	$(OCAMLBUILD) -clean
