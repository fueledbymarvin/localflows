$(document).ready(function() {
    $.get("/users.json", function(data) {

        var users_list = []

        for (var i=0; i < data.length; i++) {
            users_list.push(data[i].name + ' (' + data[i].email + ')');
        }

        $('#search_users-typeahead').tokenfield({
            typeahead: {
                name: 'tags',
                local: users_list
            },
            allowDuplicates: false
        });
    });

    $(".invitebutton").click(function() {
        setTimeout(alert("Email invitations successfully sent!"), 3000);
    });

    function getPosition() {
        if (navigator.geolocation) {
            navigator.geolocation.getCurrentPosition(function(position) {

                geocoder = new google.maps.Geocoder();

                var lat = position.coords.latitude
                var lng = position.coords.longitude

                var latlng = new google.maps.LatLng(lat, lng)

                geocoder.geocode({'latLng': latlng}, function(results, status) {
                    if (status == google.maps.GeocoderStatus.OK) {
                        results_string = results[3].formatted_address.split(', ')
                        city = results_string[0]
                        state = results_string[1]
                        $("#city-field").val(city)
                        $("#state-field").val(state)
                        // console.log(city)
                        return results[4]
                    }
                })
            })
        }
    }

    getPosition()

});