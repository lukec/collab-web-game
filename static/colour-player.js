$(document).ready(function() {
    var my_id = Math.random();

    $('#picker').farbtastic( function(new_colour) {
        console.log(new_colour);
        jQuery.get('/game/update', { colour: new_colour, id: my_id});

        $('#color').css({
            "background-color": new_colour,
        });
        $('#color').val(new_colour);
    });
});
