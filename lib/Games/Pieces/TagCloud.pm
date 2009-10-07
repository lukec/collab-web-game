package Games::Pieces::Tagcloud;
use Moose;
use HTML::TagCloud;
use namespace::clean -except => 'meta';

extends 'Games::Pieces::Word';


sub to_html {
    my $self = shift;
    my $hosts = [ @{$self->hosts} ];

    if (@$hosts == 0) {
        return 'Nobody connected yet!';
    }

    my %words;
    for my $host (@$hosts) {
        my $host_state = $self->state->by_host($host);
        $words{ uc $host_state->{word} }++;
    }

    my $cloud = HTML::TagCloud->new;
    $cloud->add($_, '', $words{$_}) for keys %words;

    return q{<div class="tagcloud">}
        . $cloud->html_and_css(8)
        . q{</div>};
}

# We override this to make our own damn css!
*HTML::TagCloud::css = sub {
  my ($self) = @_;
  my $css = q(
#htmltagcloud {
  text-align:  center; 
  line-height: 1; 
}
);
  my $mult = 5;
  foreach my $level (0 .. $self->{levels}) {
    my $font = 32 + $level * $mult;
    $css .= "span.tagcloud$level { font-size: ${font}px;}\n";
    $css .= "span.tagcloud$level a {text-decoration: none;}\n";
  }
  return $css;
};

__PACKAGE__->meta->make_immutable;
1;
