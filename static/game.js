$(document).ready(function() {
    var my_id = Math.random();

    $("#gameboard").click( function() {
        if ($(this).hasClass('black')) {
            $(this).removeClass('black');
            $(this).addClass('white');
            jQuery.get('/game/update', { pixel: "on", id: my_id});
        }
        else {
            $(this).removeClass('white');
            $(this).addClass('black');
            jQuery.get('/game/update', { pixel: "off", id: my_id});
        }
    });
});

