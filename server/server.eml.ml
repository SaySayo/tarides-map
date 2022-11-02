type entry = { latitude : float; longitude : float; description : string }
[@@deriving yojson]

type locations = entry list [@@deriving yojson]

let load_locations () =
  match Yojson.Safe.from_file "location.json" with
  | json -> json |> locations_of_yojson
  | exception Sys_error _ -> []

let validate_to_float ~min ~max data =
  match float_of_string_opt data with
  | Some flt -> if flt <= max && flt >= min then Some flt else None
  | None -> None

let locations = ref (load_locations ())

let add_locations entry =
  locations := entry :: !locations;
  !locations |> yojson_of_locations |> Yojson.Safe.to_file "location.json"

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
                  ] as form_data) -> (
                 let formatter =
                   Fmt.Dump.(
                     list (Fmt.Dump.pair Fmt.Dump.string Fmt.Dump.string))
                 in
                 Dream.log "%a\n" formatter form_data;
                 let validate_latitude =
                   validate_to_float ~min:(-90.0) ~max:90.0 latitude
                 in
                 let validate_longitude =
                   validate_to_float ~min:(-180.0) ~max:180.0 longitude
                 in
                 match (validate_latitude, validate_longitude) with
                 | Some latitude, Some longitude ->
                     let entry = { latitude; longitude; description } in
                     add_locations entry;
                     Dream.redirect request "/index.html"
                 | _, _ -> Dream.empty `Bad_Request)
             | _ -> Dream.empty `Bad_Request);
       ]
