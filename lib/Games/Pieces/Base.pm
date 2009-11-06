package Games::Pieces::Base;
use Moose;
use Games::Pieces::State;
use Algorithm::Numerical::Shuffle qw/shuffle/;
use namespace::clean -except => 'meta';

with 'Games::Pieces::Game';

has 'port' => (is => 'ro', isa => 'Int', required => 1);
has 'host' => (is => 'ro', isa => 'Str', required => 1);
has 'state' => (is => 'ro', isa => 'Games::Pieces::State', lazy_build => 1);
has 'hosts' => (is => 'rw', isa => 'ArrayRef[Str]', default => sub { [] });

sub player_css_uri { '/static/game.css' }
sub admin_css_uri { '/static/game.css' }

sub standby_html {
    return <<'EOT';
<div class="bigtext">Go here in your web browser!</div>
EOT
}

sub admin_html {
    my $self = shift;
    my $body = $self->to_html || $self->standby_html;
    my $host = $self->host;
    my $port = $self->port;
    my $content = <<EOT;
    <h1 class="connect">Connect to http://$host:$port</h1>
    <div id="game_canvas">
        $body
    </div>

    <style>
    .bigtext {
        font-size: 240%;
    }
    .connect {
        font-family: 'Courier';
        font-size: 400%;
        border: 2px;
    }

    </style>

    <script>
    \$(document).ready(function() {
        setInterval(function() { 
            \$("#game_canvas").load('/show/fragment');
        }, 100);
    });
    </script>
EOT
}

sub handle_update {
    my $self = shift;
    my $req_params = shift;
    my $client_id = delete $req_params->{id};

    if ($client_id) {
        my $new_host = $self->state->host_exists($client_id) ? 0 : 1;
        warn "New host $client_id" if $new_host and $self->debug;

        for my $key (keys %$req_params) {
            my $value = $req_params->{$key};
            warn "Validating $key: '$value'\n" if $self->debug;
            my $new_value = $self->_validate_update( $key => $value );
            next unless defined $new_value;

            print STDERR $new_value;
            $self->state->update_host(
                $client_id => (
                    $key => $new_value,
                ),
            );
        }

        $self->new_host_joined() if $new_host;
    }
}

sub new_host_joined {
    my $self = shift;

    # Shuffle the board everytime someone new joins
    $self->shuffle_host_list();
}

sub shuffle_host_list {
    my $self = shift;
    my @host_order = @{ $self->state->clients };
    @host_order = shuffle @host_order;
    $self->hosts(\@host_order);
}

sub _build_state { Games::Pieces::State->new }

__PACKAGE__->meta->make_immutable;
1;
