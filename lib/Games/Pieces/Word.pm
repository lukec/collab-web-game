package Games::Pieces::Word;
use Moose;
use namespace::clean -except => 'meta';

extends 'Games::Pieces::Base';

sub player_html {
    my $self = shift;

    return <<'EOT';
    <center>
        <h1>Word Game</h1>
        Choose your word, but you only get 1! (no spaces)<br />
        <p><input type="text" id="my_word" length="12" /></p>
    </center>

    <style>
        #my_word { font-size: 240%; }
    </style>

    <script>
$(document).ready(function() {
    var my_id = Math.random();

    $("#my_word").keyup( function(e) {
        var my_word = $("#my_word").attr('value');
        jQuery.get('/game/update', { word: my_word, id: my_id});
    });
});
    </script>
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
    my $sentence = ucfirst join ' ', @words;
    my $content = <<EOT;
    <style>
.our_sentence { font-size: 240%; }
    </style>
    <div class="our_sentence">
      <p>Our sentence so far:</p>
      <div>$sentence</div>
    </div>
EOT
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
