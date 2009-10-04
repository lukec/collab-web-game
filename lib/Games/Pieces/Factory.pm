package Games::Pieces::Factory;
use MooseX::Singleton;
use namespace::clean -except => 'meta';

has 'game_name' => (is => 'ro', isa => 'Str', required => 1);
has 'game_opts' => (is => 'ro', isa => 'HashRef', required => 1);
has 'game' => (is => 'ro', does => 'Games::Pieces::Game', lazy_build => 1);

sub _build_game {
    my $self = shift;

    my $game_class = 'Games::Pieces::' . ucfirst $self->game_name;
    eval "require $game_class";
    die "Can't load $game_class: $@" if $@;

    return $game_class->new($self->game_opts);
}


__PACKAGE__->meta->make_immutable;
