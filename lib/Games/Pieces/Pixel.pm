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
    my $hosts = [ @{$self->hosts} ];

    if (@$hosts == 0) {
        return 'Nobody connected yet!';
    }

    my $side = $self->canvas_size();
    my $cell_size = int(100 / $side);
    for my $x (1 .. $side) {
        $body .= qq{<tr style="height:$cell_size%">};
        for my $y (1 .. $side) {
            my $host = shift @$hosts;
            my $cell_html = q{class="yellow"};
            $cell_html = $self->_cell_html_for_host($host) if $host;
            $body .= qq{<td $cell_html style="width:$cell_size%"></td>};
        }
        $body .= "</tr>";
    }
    $body .= "</table>";
    return $body;
}

sub _cell_html_for_host {
    my $self = shift;
    my $host = shift;
    my $host_state = $self->state->by_host($host);
    return q{class="} . ($host_state->{pixel} ? 'white' : 'black') . q{"};
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
    return $self->canvas_size * $self->canvas_size;
}

sub _validate_update {
    my $self = shift;
    my ($key, $value) = @_;
    return undef unless $key eq 'pixel';
    return $value eq 'on' ? 1 : 0;
}

__PACKAGE__->meta->make_immutable;
1;
