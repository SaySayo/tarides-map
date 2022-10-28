type entry = { latitude : float; longitude : float; description : string }
[@@deriving yojson]

type locations = entry list [@@deriving yojson]

let lagos =
  { latitude = 6.465422; longitude = 3.406448; description = "This is Lagos" }

let paris =
  { latitude = 48.864716; longitude = 2.349014; description = "This is Paris" }

let spain =
  { latitude = 39.466667; longitude = -0.375000; description = "This is Spain" }

let denmark =
  { latitude = 56.2639; longitude = 9.5018; description = "This is Denmark" }

let load_locations () = Yojson.Safe.from_file "location.json" 
  |> locations_of_yojson

let locations = ref [ lagos; paris; spain; denmark ]

let _ = load_locations ()
let add_locations entry = 
  locations := entry :: !locations;
  !locations |> yojson_of_locations  
  |> Yojson.Safe.to_file "location.json"


let () =
  Dream.run @@ Dream.logger
  @@ Dream.router
       [
         Dream.get "/location" (fun _ ->
             !locations |> yojson_of_locations |> Yojson.Safe.to_string
             |> Dream.json);
         Dream.get "/**" (Dream.static "src/htdocs");
         Dream.post "/location" (fun request ->
             let%lwt body = Dream.body request in
             let entry = body |> Yojson.Safe.from_string |> entry_of_yojson in
             entry |> yojson_of_entry |> Yojson.Safe.to_string |> Dream.json);
         Dream.post "/add-entry" (fun request ->
             match%lwt Dream.form ~csrf:false request with
             | `Ok
                 ([
                    ("description", description);
                    ("latitude", latitude);
                    ("longitude", longitude);
                  ] as form_data) ->
                 let formatter =
                   Fmt.Dump.(
                     list (Fmt.Dump.pair Fmt.Dump.string Fmt.Dump.string))
                 in
                 Dream.log "%a\n" formatter form_data;
                 let latitude = float_of_string latitude in
                 let longitude = float_of_string longitude in
                 let entry = { latitude; longitude; description } in
                 add_locations entry;
                 Dream.redirect request "/index.html"
             | _ -> Dream.empty `Bad_Request);
       ]
