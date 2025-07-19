(lang dune 3.15)

(name bcm)

(version 0.1.0)

(generate_opam_files true)

(source
 (github bartex00001/better-c-macros))

(authors "Bartlomiej Stefanski")

(maintainers "Bartlomiej Stefanski")

(license MIT)

(package
 (name bcm)
 (synopsis "Better macros for C")
 (description "Rust-like macros for C. Compatible with C ABI.")
 (depends
  ocaml
  dune
  (alcotest :with-test)
  menhir))

(using menhir 3.0)
