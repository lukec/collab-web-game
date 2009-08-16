$(document).ready(function() {
    var my_id = Math.random();

    $("#my_word").keypress( function(e) {
        var my_word = $("#my_word").attr('value');
        console.log(my_word);
        jQuery.get('/game/update', { word: my_word, id: my_id});
    });
});

