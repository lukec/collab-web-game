  $(document).ready(function(){
    var my_id = Math.random();

    $("#slider").slider({
        max: 100,
        min: 0,
        orientation: 'vertical',
        step: 1,
        change: function(event, ui) {
           var new_value = ui.value;
           console.log(new_value);
           jQuery.get('/game/update', { value: new_value, id: my_id});
        }
    });
  });

