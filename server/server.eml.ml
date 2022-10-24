type entry = { latitude : float; longitude : float; description : string } [@@deriving yojson]

let lagos =
  { latitude = 6.465422; longitude = 3.406448; description = "This is Lagos" }
let paris =
  { latitude = 48.864716; longitude = 2.349014; description = "This is Paris" }
let spain =
  { latitude = 39.466667; longitude = -0.375000; description = "This is Spain" }
let denmark =
  { latitude = 56.2639; longitude = 9.5018; description = "This is Denmark" }
let _list_of_locations = [lagos; paris; spain; denmark]

let () =
  Dream.run
  @@ Dream.logger
  @@ Dream.router [
    
    Dream.get "src/htdocs/data/location.json"
    (fun _ ->
      let%lwt body = Lwt_io.open_file ~mode:Input "src/htdocs/data/location.json" in
      let%lwt body_to_string = Lwt_io.read body in
        Dream.json body_to_string)
      ]