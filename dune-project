(lang dune 3.15)

(name bcm)
(version 0.0.1)

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
 (depends ocaml dune Alcotest unix test_bcm))

(using menhir 3.0)
