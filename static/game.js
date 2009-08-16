$(document).ready(function() {
    document.my_id = Math.random();

    $("#my_word").keypress( function(e) {
        setTimeout( function () { send_word() }, 1);
    });
    function send_word () {
        var my_word = $("#my_word").attr('value');
        console.log(my_word);
        jQuery.get('/game/update', { word: my_word, id: document.my_id});
    };
});

