OPAM_DEPENDS="ocamlfind ounit"

case "$OCAML_VERSION,$OPAM_VERSION" in
    4.01.0,1.2.0) ppa=avsm/ocaml41+opam12 ;;
    4.02.1,1.2.0) ppa=avsm/ocaml42+opam12 ;;
    *) error "Unknown ocaml or opam version: $OCAML_VERSION,$OPAM_VERSION";;
esac

echo "yes" | sudo add-apt-repository ppa:$ppa
sudo apt-get update -qq
sudo apt-get install -qq ocaml ocaml-native-compilers camlp4-extra opam

export OPAMYES=1
export OPAMVERBOSE=1
opam init

git clone https://github.com/sagotch/ISO8601.ml.git
opam pin add -k git -n ISO8601 ISO8601
opam install ${OPAM_DEPENDS}

eval `opam config env`
make build run
