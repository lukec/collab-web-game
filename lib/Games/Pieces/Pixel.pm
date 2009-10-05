package Games::Pieces::Pixel;
use Moose;
use namespace::clean -except => 'meta';

extends 'Games::Pieces::Base';

sub player_js_uri { '/static/pixel-player.js' }

sub player_html {
    my $self = shift;

    return <<EOT;
    <center>
        <h1>Pixel Game</h1>
        Choose your color:<br />
        <div id="gameboard"></div>
    </center>
EOT
}

sub to_html {
    my $self = shift;
    my $body = '<table class="pixels" width="100%" height="90%">';
    my $side = $self->canvas_size();
    my $hosts = [ @{$self->hosts} ];

    if (@$hosts == 0) {
        return 'Nobody connected yet!';
    }

    my $cell_size = int(100 / $side);
    for my $x (1 .. $side) {
        $body .= qq{<tr style="height:$cell_size%">};
        for my $y (1 .. $side) {
            my $host = shift @$hosts;
            my $class = 'yellow';
            if ($host) {
                my $host_state = $self->state->by_host($host);
                $class = $host_state->{pixel} ? 'white' : 'black';
            }
            $body .= qq{<td class="$class" style="width:$cell_size%"></td>};
        }
        $body .= "</tr>";
    }
    $body .= "</table>";
    return $body;
}

sub canvas_size {
    my $self = shift;
    my $num = $self->state->client_count;
    my $i = 0;
    while($i*$i < $num) {
        $i++;
    }
    return 2 if $i == 1; # special case
    return $i;
}

sub host_list_size {
    my $self = shift;
    return $self->canvas_size ^ 2;
}

sub _validate_update {
    my $self = shift;
    my ($key, $value) = @_;
    return undef unless $key eq 'pixel';
    return $value eq 'on' ? 1 : 0;
}

__PACKAGE__->meta->make_immutable;
1;
