type entry = { latitude : float; longitude : float; description : string }
[@@deriving yojson]

type locations = entry list [@@deriving yojson]

let load_locations () = 
match Yojson.Safe.from_file "location.json" with
| json -> json |> locations_of_yojson
| exception Sys_error _ -> []

let locations = ref (load_locations ())
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
                 let validate_to_float ~min:float ~max:float data = 
                  match data with
                  | Some data -> float_of_string data
                  | None -> 0.0
                  in
                 add_locations entry;
                 Dream.redirect request "/index.html"
             | _ -> Dream.empty `Bad_Request);
       ]
