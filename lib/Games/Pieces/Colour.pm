package Games::Pieces::Colour;
use Moose;
use namespace::clean -except => 'meta';

extends 'Games::Pieces::Pixel';

sub player_js_uri { 
    [
        '/static/colour-player.js',
        '/static/farbtastic/farbtastic.js',
    ]
}

sub player_css_uri { 
    [
        '/static/game.css',
        '/static/farbtastic/farbtastic.css',
    ]
}

sub player_html {
    my $self = shift;

    return <<EOT;
    <center>
        <h1>Colour Game</h1>
        Choose your color:<br />

<form action="" style="width: 400px;">
  <div class="form-item"><input type="text" id="color" name="color" value="#123456" /></div><div id="picker"></div>
</form>
    </center>
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
    return undef unless $key eq 'colour';
    return undef unless $value =~ m/^#?\w{6}$/;
    return $value;
}

__PACKAGE__->meta->make_immutable;
1;
