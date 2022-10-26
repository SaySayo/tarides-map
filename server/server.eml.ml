type entry = { latitude : float; longitude : float; description : string } [@@deriving yojson]

type locations = entry list [@@ deriving yojson]

let lagos =
  { latitude = 6.465422; longitude = 3.406448; description = "This is Lagos" }
let paris =
  { latitude = 48.864716; longitude = 2.349014; description = "This is Paris" }
let spain =
  { latitude = 39.466667; longitude = -0.375000; description = "This is Spain" }
let denmark =
  { latitude = 56.2639; longitude = 9.5018; description = "This is Denmark" }
let locations = ref [lagos; paris; spain; denmark]

let () =
  Dream.run
  @@ Dream.logger
  @@ Dream.router [
    
    Dream.get "/location"
    (fun _ ->
        !locations
        |> yojson_of_locations
        |> Yojson.Safe.to_string 
        |> Dream.json

       );
    Dream.get "/**" (Dream.static "src/htdocs");

    Dream.post "/location" 
    (fun request ->  
      let%lwt body = Dream.body request in
        let entry = body
        |> Yojson.Safe.from_string
        |> entry_of_yojson in
      
       entry
      |> yojson_of_entry
      |> Yojson.Safe.to_string
      |> Dream.json);

    (* Dream.get "/add-entry" (fun _ -> Dream.html "Hello World") *)

    Dream.post "/add-entry" (fun request -> 
     match%lwt Dream.form ~csrf:false request with
     | `Ok [("description", _); ("latitude", _); ("longitude", _) ] -> 
      let formatter = Fmt.Dump.(list (Fmt.Dump.pair Fmt.Dump.string Fmt.Dump.string)) in Format.printf "%a\n" formatter [("description", _); ("latitude", _); ("longitude", _) ]; Dream.html "Hello World"
     | _ ->
      Dream.empty `Bad_Request)
      ]
  