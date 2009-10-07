#!/usr/bin/env perl
# @COPYRIGHT@
use warnings;
use strict;

use EV;
use Coro;
use AnyEvent;
use Coro::AnyEvent;
use AnyEvent::HTTP;
# use AnyEvent::AIO ();
# use Coro::AIO;
# use Coro::LWP;
use Coro::Channel;
use Guard;
use JSON::XS qw/encode_json decode_json/;
use Data::Dumper;
use URI::Escape qw/uri_escape_utf8/;
use List::Util qw/sum/;
use Coro::Debug;

my $UNPARSEABLE_CRUFT = "throw 1; < don't be evil' >";

$AnyEvent::HTTP::MAX_PER_HOST = $AnyEvent::HTTP::MAX_PERSISTENT_PER_HOST = 9999;

my $all_done = AE::cv;
our $phase_display = sub {print "nothing to report\n"};
my $ticker = AE::timer 2,2, unblock_sub {
    print "-" x 30,AnyEvent->now," ",$AnyEvent::HTTP::ACTIVE,"\n";
    $phase_display->();
    #Coro::Debug::command('ps');
};

sub run_for_user ($$&) {
    my $user = shift;
    my $desc = shift;
    my $code = shift;

    async {
        $Coro::current->{desc} = $desc;
        $code->($user);
    };
}

sub update_the_game {
    my $phase = AE::cv;
    my $phase_timeout = AE::timer 3600, 0, sub {
        $all_done->send;
        $phase->croak('timed-out fetching stuff');
    };

    my %in_progress;
    my %plan;
    my $failed = 0;
    my $timeout = 0;
    local $phase_display = sub {
        my $total_u = scalar keys %in_progress;
        my $outstanding = sum values %plan;
        print "fetching, remaining: $total_u users, ".
            "$outstanding requests. ($failed failed)\n";
    };

    for my $user (1 .. 500) {
        $phase->begin;
        run_for_user $user, "fetcher for $user", sub {
            scope_guard { $phase->end if $phase };

            $plan{$user} = 10;
            $in_progress{$user} = {};
            Coro::AnyEvent::sleep rand(8); # fuzz offsets

            for (1..20) {
                my $fetches = AE::cv;
                my @fetch_guards;

                $fetches->begin;
                my $colour = '';
                my @colours = ((0 .. 9), ('A' .. 'F'));
                for (1 .. 6) {
                    $colour .= $colours[ rand(@colours) ];
                }
                my $uri = "/game/update?id=$user&colour=$colour";
                my $SERVER_ROOT = 'http://localhost:9090';
                my $url = $SERVER_ROOT.$uri;
                print "Requesting $url\n";
                my $cb = sub { 
                    my ($body, $headers) = @_;
                    $failed++ unless $headers->{Status} =~ /^200/;
                    $timeout++ if $headers->{Status} =~ /time/i;
                    delete $in_progress{$user}{$url};
                    $fetches->end;
                };
                my $fg = http_get $url,
                    recurse => 0,
                    timeout => 2,
                    $cb;
                $in_progress{$user}{$url} = $fg;
                $plan{$user}--;
#                     print "sent $user\n";
                $fetches->recv;
#                 print "pausing $user";
                Coro::AnyEvent::sleep 1 if $plan{$user}; # simulate polling
            }
#             print "+ phase done for $user\n";
            delete $in_progress{$user};
        };
    }
    $phase->recv;
#     print "++ phase all done\n";
    $phase_display->();
}

async { $Coro::current->{desc} = 'main schedule';
    eval { 
        update_the_game();
    };
    if ($@) {
        warn "death! $@\n";
    }
    $all_done->send;
}

my $main_start = AnyEvent->time;
print "main: waiting...\n";
$all_done->recv;
my $main_elapsed = AnyEvent->time - $main_start;
print "done in $main_elapsed seconds\n";
