(lang dune 3.15)

(name bcm)

(generate_opam_files true)

(source
 (github bartex00001/better-c-macros))

(authors "Bartlomiej Stefanski")

(maintainers "Bartlomiej Stefanski")

(license LICENSE)

(documentation https://url/to/documentation)

(package
 (name bcm)
 (synopsis "Better macros for C")
 (description "A longer description")
 (depends ocaml dune test_bcm))

(using menhir 3.0)