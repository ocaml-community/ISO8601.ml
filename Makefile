LIB=ISO8601
LIB_FILES=$(addprefix $(LIB)., a cmxa cma cmi)

all: $(LIB_FILES)

$(LIB_FILES):
	ocamlbuild -I src $@

install: META $(LIB_FILES)
	ocamlfind install $(LIB) META $(addprefix _build/src/, $(LIB_FILES))

uninstall:
	ocamlfind remove $(LIB)

clean:
	ocamlbuild -clean
