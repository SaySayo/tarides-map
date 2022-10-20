(lang dune 3.0)
(generate_opam_files true)
(name tarides-map)

(authors "Sayo Bamigbade")

(source (github saysayo/tarides-map))

(package
 (name tarides-map)
 (synopsis "Map of Tarides Collaborators")
 (description "This projects intends to show the locations of all Tarides's 
  employees and collaborators around the world")
 (allow_empty)
 (depends 
  leaflet
  brr
  js_of_ocaml
  dream
  yojson
  ppx_yojson_conv))