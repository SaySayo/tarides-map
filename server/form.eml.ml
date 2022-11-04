let show_form request =
  <html>
    <body>
      <form action="/add-entry" method="POST">
        <%s! Dream.csrf_tag request %>
        <label  for="latitude">Enter Latitude</label>
        <input name="latitude" type="number" id="latitude" step="0.000000000001" min="-90" max="90"><br>
        <label for="longitude">Enter Longitude</label>
        <input name="longitude" type="number" id="longitude" step="0.000000000001" min="-180" max="180"><br>
        <label for="description">Enter Description</label>
        <input name="description" type="text" id="description"><br>
        <input type="submit" value="Submit">
      </form>
    </body>
  </html>