package Games::Pieces::Colour;
use Moose;
use namespace::clean -except => 'meta';

extends 'Games::Pieces::Pixel';

sub player_html {
    my $self = shift;

    return <<'EOT';
    <center>
        <h1>Colour Game</h1>
        Choose your color:<br />

<form action="" style="width: 400px;">
  <div class="form-item"><input type="text" id="color" name="color" value="#123456" /></div><div id="picker"></div>
</form>
    </center>

    <style>
    </style>

    <script>
    $("head").append("<link>");
    css = $("head").children(":last");
    css.attr({
      rel:  "stylesheet",
      type: "text/css",
      href: "/static/farbtastic/farbtastic.css"
    });

    $.getScript('/static/farbtastic/farbtastic.js', function () {
        var my_id = Math.random();
        $('#picker').farbtastic( function(new_colour) {
            jQuery.get('/game/update', 
                { colour: new_colour, id: my_id});
            $('#color').css({ "background-color": new_colour });
            $('#color').val(new_colour);
        });
        $.farbtastic('#picker').setColor('#0a22ff');
    });
    </script>

EOT
}

sub _cell_html_for_host {
    my $self = shift;
    my $host = shift;
    my $host_state = $self->state->by_host($host);
    my $colour = $host_state->{colour} || '#888888';
    return qq{style="background-color: $colour"};
}

sub _validate_update {
    my $self = shift;
    my ($key, $value) = @_;
    return $value if $key eq 'colour' and $value =~ m/^#?\w{6}$/;
    return undef;
}

__PACKAGE__->meta->make_immutable;
1;
