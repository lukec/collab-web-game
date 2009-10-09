package Games::Pieces::Word;
use Moose;
use namespace::clean -except => 'meta';

extends 'Games::Pieces::Base';

sub player_html {
    my $self = shift;

    return <<EOT;
    <center>
        <h1>Word Game</h1>
        Choose your word, but you only get 1! (no spaces)<br />
        <p><input type="text" id="my_word" length="12" /></p>
    </center>
EOT
}

sub to_html {
    my $self = shift;
    my $hosts = [ @{$self->hosts} ];
    return unless @$hosts;

    my @words;
    for my $host (@$hosts) {
        my $host_state = $self->state->by_host($host);
        my $word = $host_state->{word} || '____';
        push @words, $word;
    }
    my $sentence = join ' ', @words;
    my $content = q{<p>Our sentence so far:</p>}
                . q{<p id="our_sentence">} . ucfirst($sentence) . q{.</p>};

    return $content;
}

sub _validate_update {
    my $self = shift;
    my ($key, $value) = @_;
    return undef unless $key eq 'word';
    $value =~ s/^(\S+).*/$1/;
    return $value;
}

__PACKAGE__->meta->make_immutable;
1;
