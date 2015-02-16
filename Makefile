TEST=ISO8601_TEST.byte

build: $(TEST)

$(TEST):
	ocamlbuild -pkgs oUnit,ISO8601 $(TEST)

run: $(TEST)
	./$<

clean:
	ocamlbuild -clean
