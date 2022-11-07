type entry = { latitude : float; longitude : float; description : string }
[@@deriving yojson]

type locations = entry list [@@deriving yojson]
type account = string * string
type _accounts = account list

let load_locations () =
  match Yojson.Safe.from_file "location.json" with
  | json -> json |> locations_of_yojson
  | exception Sys_error _ -> []
  | exception Yojson.Json_error _ ->
      Dream.log
        "location.json file is not valid thus the input is being ignored";
      []

let validate_to_float ~min ~max data =
  match float_of_string_opt data with
  | Some flt -> if flt <= max && flt >= min then Some flt else None
  | None -> None

let locations = ref (load_locations ())

let add_locations entry =
  locations := entry :: !locations;
  !locations |> yojson_of_locations |> Yojson.Safe.to_file "location.json"

let handle_auth valid_users f request =
  let authenticated =
    match Dream.header request "Authorization" with
    | None -> false
    | Some content -> (
        match String.split_on_char ' ' content with
        | [ "Basic"; t ] -> (
            let decode = Base64.decode t in
            match decode with
            | Ok decoded -> (
                match String.split_on_char ':' decoded with
                | [ username; password ] ->
                    let account_user = (username, password) in
                    List.mem account_user valid_users
                | _ -> false)
            | Error _ -> false)
        | _ -> false)
  in
  match authenticated with
  | true -> f request
  | false ->
      Dream.empty
        ~headers:
          [
            ("WWW-Authenticate", "Basic realm=\"Access to update entry site\"");
          ]
        `Unauthorized

let hash_pword pword = 
  let password = Cstruct.of_string pword in
  let salt = Cstruct.of_string "bisheeh7" in
  let dk_len = String.length pword in
  let hash_cstruct = Pbkdf.pbkdf1 ~hash:`SHA1 ~password ~salt ~count:1024 ~dk_len in
  hash_cstruct

let user_ids =
  let name = "admin" in
  let password = "fc1bdf27" in
  let account = (name, password) in
  [ account ]

let () =
  Dream.run @@ Dream.logger @@ Dream.memory_sessions
  @@ Dream.router
       [
         Dream.get "/location" (fun _ ->
             !locations |> yojson_of_locations |> Yojson.Safe.to_string
             |> Dream.json);
         Dream.get "/form"
           (handle_auth user_ids (fun request ->
                Dream.html (Form.show_form request)));
         Dream.get "/**" (Dream.static "src/htdocs");
         Dream.post "/location" (fun request ->
             let%lwt body = Dream.body request in
             let entry = body |> Yojson.Safe.from_string |> entry_of_yojson in
             entry |> yojson_of_entry |> Yojson.Safe.to_string |> Dream.json);
         Dream.post "/add-entry"
           (handle_auth user_ids (fun request ->
                match%lwt Dream.form ~csrf:true request with
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
                | _ -> Dream.empty `Bad_Request));
       ]
