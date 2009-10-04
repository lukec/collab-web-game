package Games::Pieces::Base;
use Moose;
use Games::Pieces::State;
use Algorithm::Numerical::Shuffle qw/shuffle/;
use namespace::clean -except => 'meta';

with 'Games::Pieces::Game';

has 'port' => (is => 'ro', isa => 'Int', required => 1);
has 'host' => (is => 'ro', isa => 'Str', required => 1);
has 'state' => (is => 'ro', isa => 'Games::Pieces::State', lazy_build => 1);

sub player_js_uri { '/static/game.js' }
sub player_css_uri { '/static/game.css' }
sub admin_js_uri { '/static/game-show.js' }
sub admin_css_uri { '/static/game.css' }

sub host_list_size {
    my $self = shift;
    return $self->state->client_count;
}

sub _build_state { Games::Pieces::State->new }

sub handle_update {
    my $self = shift;
    my $req_params = shift;
    my $client_id = delete $req_params->{id};

    my $pixel = $req_params->{pixel};
    if ($client_id) {
        my $new_host = $self->state->host_exists($client_id) ? 0 : 1;

        for my $key (keys %$req_params) {
            my $value = $req_params->{$key};
            my $new_value = $self->_validate_update( $key => $value );
            next unless defined $new_value;

            print STDERR $new_value;
            $self->state->update_host(
                $client_id => (
                    pixel => $new_value,
                ),
            );
        }

        # Shuffle the board everytime someone new joins
        $self->shuffle_host_list() if $new_host;
    }
}

sub shuffle_host_list {
    my $self = shift;
    my $side = $self->host_list_size;
    my $min = $side * $side;

    my @host_order = @{ $self->state->clients };
    push @host_order, '' while @host_order < $min;

    @host_order = shuffle @host_order;
    $self->hosts(\@host_order);
}

__PACKAGE__->meta->make_immutable;
1;

