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
});