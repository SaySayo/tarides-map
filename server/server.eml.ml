let () =
  Dream.run
  @@ Dream.logger
  @@ Dream.router [
    
    Dream.get "/src/htdocs/data/location.json"
      (fun _ ->
        Dream.html "Good morning, world!"); 
      ]