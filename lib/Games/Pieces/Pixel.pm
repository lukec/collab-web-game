package Games::Pieces::Pixel;
use Moose;
use Algorithm::Numerical::Shuffle qw/shuffle/;
use namespace::clean -except => 'meta';

extends 'Games::Pieces::Base';

sub player_html {
    my $self = shift;

    return <<'EOT';
    <center>
        <h1>Pixel Game</h1>
        Choose your color:<br />
        <div id="gameboard" class="yellow"></div>
    </center>

    <style>
#gameboard {
    border: 3px black solid;
    height: 400px;
    width: 400px;
}
.black { background: black; }
.white { background: white; }
.yellow { background: yellow; }
    </style>

    <script>
    $(document).ready(function() {
        var my_id = Math.random();

        $("#gameboard").click( function() {
            $(this).removeClass('yellow');
            if ($(this).hasClass('black')) {
                $(this).removeClass('black').addClass('white');
                jQuery.get('/game/update', { pixel: "on", id: my_id});
            }
            else {
                $(this).removeClass('white').addClass('black');
                jQuery.get('/game/update', { pixel: "off", id: my_id});
            }
        });
    });
    </script>
EOT
}

sub to_html {
    my $self = shift;
    my $body = <<EOT;
    <style>
.pixels {
    border: 2px black solid;
    width: 100%
    height: 100%
}
.pixels td { border: 1px; }
.black { background: black; }
.white { background: white; }
.yellow { background: yellow; }

    </style>
EOT
    $body .= '<table class="pixels" width="100%" height="85%">';
    my $hosts = [ @{$self->hosts} ];

    return unless @$hosts;

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

# Make sure the host list includes some undefs 
override 'shuffle_host_list' => sub {
    my $self = shift;

    my $side = $self->canvas_size * $self->canvas_size;
    my @host_order = @{ $self->state->clients };
    push @host_order, '' while @host_order < $side;
    @host_order = shuffle @host_order;
    $self->hosts(\@host_order);
};

sub _validate_update {
    my $self = shift;
    my ($key, $value) = @_;
    return undef unless $key eq 'pixel';
    return $value eq 'on' ? 1 : 0;
}

__PACKAGE__->meta->make_immutable;
1;
