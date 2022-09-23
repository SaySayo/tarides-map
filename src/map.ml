open Js_of_ocaml
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

let tile_layer =
  let url = Some("http://{s}.google.com/vt/lyrs=m&x={x}&y={y}&z={z}") in  
    Layer.create_tile_osm url

let () = Layer.add_to map tile_layer

let marker = 
  let lat_lng = Latlng.create 6.465422 3.406448 in
  Layer.create_marker lat_lng 

let () = Layer.add_to map marker

let () = 
  let str = El.txt' "This is a popup" in
    Layer.bind_popup str tile_layer
let get_popup = Layer.get_popup marker
