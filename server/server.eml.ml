let () =
  Dream.run
  @@ Dream.logger
  @@ Dream.router [
    
    Dream.get "/src/htdocs/data/location.json"
    (fun _ ->
      let%lwt body = Lwt_io.open_file ~mode:Input "/src/htdocs/data/location.json" in
      let%lwt body_to_string = Lwt_io.read body in
        Dream.json body_to_string)
      ]