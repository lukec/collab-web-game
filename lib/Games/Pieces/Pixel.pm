package Games::Pieces::Pixel;
use Moose;
use Games::Pieces::State;
use Algorithm::Numerical::Shuffle qw/shuffle/;
use namespace::clean -except => 'meta';

with 'Games::Pieces::Game';

has 'port' => (is => 'ro', isa => 'Int', required => 1);
has 'host' => (is => 'ro', isa => 'Str', required => 1);
has 'state' => (is => 'ro', isa => 'Games::Pieces::State', lazy_build => 1);

has 'hosts' => (is => 'rw', isa => 'ArrayRef[Str]', default => sub { [] });

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
    my $body = '<table class="pixels">';
    my $side = $self->canvas_size();
    my $hosts = [ @{$self->hosts} ];

    if (@$hosts == 0) {
        return 'Nobody connected yet!';
    }

    for my $x (1 .. $side) {
        $body .= '<tr>';
        for my $y (1 .. $side) {
            my $host = shift @$hosts;
            my $class = 'yellow';
            if ($host) {
                my $host_state = $self->state->by_host($host);
                $class = $host_state->{pixel} ? 'white' : 'black';
            }
            $body .= qq{<td class="$class"></td>};
        }
        $body .= "</tr>";
    }
    $body .= "</table>";
    return $body;
}

sub handle_update {
    my $self = shift;
    my $req_params = shift;

    my $pixel = $req_params->{pixel};
    my $client_id = $req_params->{id};
    if ($client_id and defined $pixel) {
        my $new_host = $self->state->host_exists($client_id) ? 0 : 1;
        my $new_value = $pixel eq 'on' ? 1 : 0;
        print STDERR $new_value;
        $self->state->update_host(
            $client_id => (
                pixel => $new_value,
            ),
        );

        # Shuffle the board everytime someone new joins
        $self->shuffle_host_list() if $new_host;
    }
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

sub shuffle_host_list {
    my $self = shift;
    my $side = $self->canvas_size;
    my $min = $side * $side;

    my @host_order = @{ $self->state->clients };
    push @host_order, '' while @host_order < $min;

    @host_order = shuffle @host_order;
    $self->hosts(\@host_order);
}

sub player_js_uri { '/static/game.js' }
sub player_css_uri { '/static/game.css' }
sub admin_js_uri { '/static/game-show.js' }
sub admin_css_uri { '/static/game.css' }

sub _build_state { Games::Pieces::State->new }

__PACKAGE__->meta->make_immutable;
1;
