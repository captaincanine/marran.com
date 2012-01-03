var geocoder;
var map;

function initialize(lat, lng) {
  geocoder = new google.maps.Geocoder();
  var latlng = new google.maps.LatLng(lat, lng);
  var myOptions = {
    zoom: 15,
    center: latlng,
    mapTypeControl: false,
    mapTypeId: google.maps.MapTypeId.ROADMAP
  }
  map = new google.maps.Map(document.getElementById("map"), myOptions);
  map.setCenter(latlng);
}

$(document).ready ( function() {

  $("#map").each(function() {
  
    latitude = $(this).attr('latitude');
    longitude = $(this).attr('longitude');

    initialize(latitude, longitude);
    
    var latlng = new google.maps.LatLng(latitude, longitude);
    
    var marker = new google.maps.Marker({
      map: map,
      position: latlng 
    });

    map.setCenter(latlng);

  });

});