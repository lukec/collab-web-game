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

sub player_js_uri { 
    my $self = shift;
    (my $class = ref($self)) =~ s/.+::(.+)/lc($1)/e;
    return "/static/$class-player.js";
}

sub player_css_uri { '/static/game.css' }
sub admin_js_uri { '/static/game-admin.js' }
sub admin_css_uri { '/static/game.css' }

sub host_list_size {
    my $self = shift;
    return $self->state->client_count;
}

sub _build_state { Games::Pieces::State->new }

sub standby_html {
    return '<div class="bigtext">Go here in your web browser!</div>';
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

        # Shuffle the board everytime someone new joins
        $self->shuffle_host_list() if $new_host;
    }
}

sub shuffle_host_list {
    my $self = shift;
    my $side = $self->host_list_size;

    my @host_order = @{ $self->state->clients };
    push @host_order, '' while @host_order < $side;

    @host_order = shuffle @host_order;
    $self->hosts(\@host_order);
}

__PACKAGE__->meta->make_immutable;
1;
