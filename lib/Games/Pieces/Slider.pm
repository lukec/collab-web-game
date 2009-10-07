package Games::Pieces::Slider;
use Moose;
use namespace::clean -except => 'meta';

extends 'Games::Pieces::Base';

sub player_js_uri { 
    [
        '/static/slider-player.js',
        'http://jqueryui.com/latest/ui/ui.core.js',
        'http://jqueryui.com/latest/ui/ui.slider.js',
    ]
}

sub player_css_uri { 
    [
        '/static/game.css',
        'http://jqueryui.com/latest/themes/base/ui.all.css',
    ]
}

sub player_html {
    my $self = shift;

    return <<EOT;
    <center>
        <h1>Slider Game</h1>
        Choose a position on the slider:<br />

        <div id="slider"></div>
EOT
}

sub to_html {
    my $self = shift;

    my $hosts = $self->hosts;
    if (@$hosts == 0) {
        return 'Nobody connected yet!';
    }

    my @values = map { $self->state->by_host($_)->{value} } @$hosts;

    my $sum = 0;
    $sum += $_ for @values;
    my $average = $sum / @$hosts;

    my $body = "<strong>Average: $average</strong><br /><ul>";
    $body .= qq{<li>$_</li>} for @values;
    $body .= "</ul>";
    return $body;
}

sub _validate_update {
    my $self = shift;
    my ($key, $value) = @_;
    warn "Validating $key: '$value'\n" if $self->debug;
    return undef unless $key eq 'value';
    return undef unless $value =~ m/^\d+$/;
    return undef if $value > 100;
    return $value;
}

__PACKAGE__->meta->make_immutable;
1;
