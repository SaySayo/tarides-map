open Leaflet
open Brr

let map = 
  let map_id = (Document.find_el_by_id G.document) (Jstr.v "map") in 
    match map_id with 
      | Some map_id -> Map.create map_id
      | None -> Map.of_jv (Jv.of_error (Jv.Error.v (Jstr.v "Map ID not found")))

let () = 
  let lat_lng = Latlng.create 51.505 (-0.09) in
  let zoom = Some 13 in
  Map.set_view lat_lng ~zoom map

  (* Tile layer *)
let osm_layer =
  let url = Some("https://tile.openstreetmap.org/{z}/{x}/{y}.png") in  
    Layer.create_tile_osm url

let () = Layer.add_to map osm_layer

(* Lagos Marker *)
let lagos_marker = 
  let lat_lng = Latlng.create 6.465422 3.406448 in
  Layer.create_marker lat_lng 

let () = Layer.add_to map lagos_marker

(* Lagos Popup *)
let () = 
  let str = El.txt' "This is Lagos" in
  let () = Layer.bind_popup str lagos_marker in
  Layer.open_popup lagos_marker

(* Paris Marker *)
let paris_marker = 
  let lat_lng = Latlng.create 48.864716 2.349014 in
  Layer.create_marker lat_lng 

let () = Layer.add_to map paris_marker

(* Paris Popup *)
let () = 
  let str = El.txt' "This is Paris" in
  let () = Layer.bind_popup str paris_marker in
  Layer.open_popup paris_marker

(* Spain Marker *)
let spain_marker = 
  let lat_lng = Latlng.create 39.466667 (-0.375000) in
  Layer.create_marker lat_lng 

let () = Layer.add_to map spain_marker

(* Spain Popup *)
let () = 
  let str = El.txt' "This is Valencia" in
  let () = Layer.bind_popup str spain_marker in
  Layer.open_popup spain_marker

  (*Denmark Popup*)
let denmark_marker = 
  let lat_lng = Latlng.create 56.2639 9.5018 in
  Layer.create_marker lat_lng 

let () = Layer.add_to map denmark_marker

(* Denmark Popup *)
let () = 
  let str = El.txt' "This is Denmark" in
  let () = Layer.bind_popup str denmark_marker in
  Layer.open_popup denmark_marker


