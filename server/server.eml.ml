open Yojson

type entry = { latitude : float; longitude : float; description : string } [@@deriving yojson]

let () =
  Dream.run
  @@ Dream.logger
  @@ Dream.router [
    
    Dream.post "/src/htdocs/data/location.json"
    (fun request ->
      let%lwt body = Dream.body request in

      let entry_object =
        body
        |> Yojson.Safe.from_string
        |> entry_object_of_yojson
      in

      `String entry_object.description
      |> Yojson.Safe.to_string
      |> Dream.json);
      ]