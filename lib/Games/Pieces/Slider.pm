package Games::Pieces::Slider;
use Moose;
use Statistics::Basic qw(:all);
use namespace::clean -except => 'meta';

extends 'Games::Pieces::Base';

override 'html_head' => sub {
    my $self = shift;
    my $who  = shift;
    my $extra_js = '';
    $extra_js = <<EOT if $who eq 'player';
<script type="text/javascript" src="/static/slider-player.js"></script>
EOT
    return <<EOT;
<script type="text/javascript" src="http://jqueryui.com/latest/jquery-1.3.2.js"></script>
<script type="text/javascript" src="http://jqueryui.com/latest/ui/ui.core.js"></script>
<script type="text/javascript" src="http://jqueryui.com/latest/ui/ui.slider.js"></script>
<script type="text/javascript" src="/static/game-admin.js"></script>
$extra_js

<link rel="stylesheet" type="text/css" href="http://jqueryui.com/latest/themes/base/ui.all.css" />
<link rel="stylesheet" type="text/css" href="/static/game.css" />
EOT
};

sub player_html {
    my $self = shift;

    return <<EOT;
    <center>
        <h1>Slider Game</h1>
        Choose a position on the slider:<br />

        <div id="slider"></div>
EOT
}

sub to_html {
    my $self = shift;

    my $hosts = $self->hosts;
    return unless @$hosts;

    my @values = map { $self->state->by_host($_)->{value} } @$hosts;
    my %stats = _calc_stats(\@values);
    my $body = "";
    for my $key (keys %stats) {
        my $value = $stats{$key};
        my $name = ucfirst $key;
        $body .= qq{<strong class="bigtext">$name: $value</strong><br />};
    }
    $body .= qq{<hr /><h2>Values</h2><div>};
    for my $v (sort @values) {
        $body .= qq{<span class="slider_value">$v</span>};
    }
    $body .= qq{</div>};
    return $body;
}

sub _calc_stats {
    my $values = shift;
    my $v = vector($values);
    return (
        average => mean($v),
        median => median($v),
        mode => mode($v),
        stddev => stddev($v),
    );
}

sub _validate_update {
    my $self = shift;
    my ($key, $value) = @_;
    return undef unless $key eq 'value';
    return undef unless $value =~ m/^\d+$/;
    return undef if $value > 100;
    return $value;
}

__PACKAGE__->meta->make_immutable;
1;
