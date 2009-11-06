package Games::Pieces::State;
use MooseX::Singleton;
use namespace::clean -except => 'meta';

has '_state' => (is => 'ro', isa => 'HashRef', lazy_build => 1);

sub _build__state {
    return {};
}

sub client_count {
    my $self = shift;
    return scalar keys %{ $self->_state };
}

sub clients {
    my $self = shift;
    return [ keys %{ $self->_state } ];
}

sub clients_by_time {
    my $self = shift;
    my $clients = $self->clients;
    my $s = $self->_state;
    return [ sort { $s->{$b}{update_time} <=> $s->{$a}{update_time} }
                @$clients ];
}

sub by_host {
    my $self = shift;
    my $host = shift;
    return $self->_state->{$host}{data} || {};
}

sub host_exists {
    my $self = shift;
    my $host = shift;
    return exists $self->_state->{ $host };
}

sub update_host {
    my $self = shift;
    my $host = shift;
    my %new_opts = @_;

    my $existing_opts = $self->_state->{ $host } || {};
    my $new_opts = {
        %$existing_opts,
        %new_opts
    };
    $self->_state->{ $host } = {
        data => $new_opts,
        update_time => time,
    };
}

__PACKAGE__->meta->make_immutable;

