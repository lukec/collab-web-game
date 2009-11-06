package Games::Pieces::Question;
use Moose;
use namespace::clean -except => 'meta';

extends 'Games::Pieces::Base';

sub player_html {
    my $self = shift;

    return <<'EOT';
    <center>
        <h1>Question Game</h1>
        Ask a question, then press enter!
        <p><input type="text" id="my_question" length="40" /></p>
    </center>

    <style>
        #my_question { font-size: 200%; }
    </style>

    <script>
$(document).ready(function() {
    var my_id = Math.random();

    $("#my_question").keypress( function(e) {
        if (e.which == 13) {
            var my_q = $("#my_question").attr('value');
            jQuery.get('/game/update', { question: my_q, id: my_id});
        }
    });
});
    </script>
EOT
}

sub to_html {
    my $self = shift;

    my $hosts = $self->state->clients_by_time;
    return unless @$hosts;

    my $content = <<EOT;
    <style>
        .our_questions { font-size: 200%; }
    </style>
    <ul class="our_questions">
EOT

    my @questions;
    for my $host (@$hosts) {
        my $host_state = $self->state->by_host($host);
        my $q = $host_state->{question} or next;

        $content .= "<li>$q</li>\n";
        last if @questions > 5;
    }
    $content .= '</ul>';
    return $content;
}

sub _validate_update {
    my $self = shift;
    my ($key, $value) = @_;
    return $value if $key eq 'question';
    return undef;
}

__PACKAGE__->meta->make_immutable;
1;
