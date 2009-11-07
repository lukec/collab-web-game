package Games::Pieces::GameServer;
use Moose;
use Games::Pieces::Factory;
use namespace::clean -except => 'meta';

has 'game_name' => (is => 'ro', isa => 'Str', required => 1);
has 'ip'    => (is => 'ro', isa => 'Str', lazy_build => 1);
has 'port'  => (is => 'ro', isa => 'Int',  default => sub { 9090 });
has 'debug' => (is => 'ro', isa => 'Bool', default => sub { 0 });
has 'game'  => (is => 'ro', isa => 'Object', lazy_build => 1,
                handles => ['run']);

sub _build_game {
    my $self = shift;
    my $host = $self->ip;
    my $port = $self->port;

    print "Players use:          http://$host:$port\n";
    print "Main display is at:   http://$host:$port/show\n";
    return Games::Pieces::Factory->new(
        game_name => $self->game_name, 
        game_opts => {
            host => $host,
            port => $port,
            debug => $self->debug,
        },
    )->game;
}

sub _build_ip {
    my $self = shift;
    my @ips = grep { !m/\Q127.0.0.1/ }
              qx(ifconfig|grep 'inet ' | awk '{print \$2}');
    chomp @ips;
    return shift @ips;
}

__PACKAGE__->meta->make_immutable;
1;
