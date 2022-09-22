   // Map initialization
  var map = L.map("map").setView([51.505, -0.09], 13);
    // OSM Layer
  var osm = L.tileLayer("https://tile.openstreetmap.org/{z}/{x}/{y}.png", {
    maxZoom: 19,
    attribution:
      '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
  });
  osm.addTo(map);
  var googleStreets = L.tileLayer('http://{s}.google.com/vt/lyrs=m&x={x}&y={y}&z={z}',{
    maxZoom: 20,
    subdomains:['mt0','mt1','mt2','mt3']
});
  googleStreets.addTo(map);

  // marker

  var myIcon = L.icon({
        iconUrl: 'img/red_marker.png',
        iconSize: [40, 40],
    });
 var marker = L.marker([6.465422, 3.406448], { icon: myIcon, draggable: false}).addTo(map);
 var popup = marker.bindPopup("This is lagos").openPopup()
    popup.addTo(map);

    console.log(marker.toGeoJSON())
 // geojson

 var pointData = L.geoJSON(pointJson, {
        onEachFeature: function (feature, layer) {
            layer.bindPopup(`<b>Name: </b>` + feature.properties.name)
        },
        style: {
            fillColor: 'red',
            fillOpacity: 1,
            color: '#c0c0c0',
        }
    }).addTo(map);
