$(document).ready(function() {
    var my_id = Math.random();

    $("#my_word").keyup( function(e) {
        var my_word = $("#my_word").attr('value');
        jQuery.get('/game/update', { word: my_word, id: my_id});
    });
});

