package Games::Pieces::Game;
use Moose::Role;
use AnyEvent::HTTPD;
use namespace::clean -except => 'meta';

has 'debug' => (is => 'ro', isa => 'Bool', default => sub {0});
has 'httpd' => (is => 'ro', isa => 'AnyEvent::HTTPD', lazy_build => 1,
                handles => ['run']);

requires 'player_js_uri';
requires 'player_css_uri';
requires 'admin_js_uri';
requires 'admin_css_uri';

has 'html_footer' => (is => 'ro', isa => 'Str', lazy_build => 1);

sub _build_httpd {
    my $self = shift;

    my $httpd = AnyEvent::HTTPD->new (port => $self->port);
    $httpd->reg_cb (
       '/' => sub {
          my ($httpd, $req) = @_;
          $httpd->stop_request;

          my $content = $self->player_html;
          return $self->_respond(
              req => $req, 
              who => 'player',
              content => $content,
          );
       },
       '/show' => sub {
          my ($httpd, $req) = @_;
          $httpd->stop_request;

          my $body = $self->to_html();
          my $host = $self->host;
          my $port = $self->port;
          my $content = <<EOT;
    <h1 class="big">Connect to http://$host:$port</h1>
    <div id="game_canvas">
        $body
    </div>
EOT
          return $self->_respond(
              req => $req, 
              who => 'admin',
              content => $content,
          );
       },
       '/show/fragment' => sub {
          my ($httpd, $req) = @_;
          $httpd->stop_request;

          $req->respond({ content => ['text/html', $self->to_html ]});
       },
       '/game/update' => sub {
          my ($httpd, $req) = @_;
          $httpd->stop_request;

          if ($self->debug) {
              use Data::Dumper;
              warn Dumper {$req->vars};
          }

          $self->handle_update( { $req->vars } );
          $req->respond({ content => ['text/html', 'Thanks' ]});
       },
       '/static' => sub { $self->_serve_static(@_) },
       '' => sub {
           my ($httpd, $req) = @_;
           my $url = $req->url;
           warn "Unknown path!! $url" unless $url =~ m/favicon\.ico/;
           return $req->respond([404, 'Not Found', {}, '']);
       },
    );
    return $httpd;
}

sub _serve_static {
    my ($self, $httpd, $req, $file) = @_;
    $self->httpd->stop_request;

    my $url = $req->url;
    $url =~ s#.+/(.+)#$1#;
    my $filename = "static/$url";
    die "Can't find $filename!" unless -e $filename;
    open(my $fh, $filename) or $req->respond (
        [404, 'not found', { 'Content-Type' => 'text/plain' }, 'not found']
    );

    my $content = do { local $/; <$fh> };
    $req->respond({ content => ['text/javascript', $content ]});
}

sub html_header {
    my $self = shift;
    my $who  = shift or die "who is mandatory!";

    no strict 'refs';
    my $js_method = $who . '_js_uri';
    my $css_method = $who . '_css_uri';
    my $js_uri = $self->$js_method;
    my $js = join "\n", 
        map { qq{<script type="text/javascript" src="$_"></script>} }
            @{ ref($js_uri) eq 'ARRAY' ? $js_uri : [$js_uri] };
    my $css_uri = $self->$css_method;
    my $css = join "\n", 
        map { qq{<link rel="stylesheet" type="text/css" href="$_" />} }
            @{ ref($css_uri) eq 'ARRAY' ? $css_uri : [$css_uri] };
    return <<eot;
<html>
  <head>
    <script type="text/javascript" src="http://jqueryui.com/latest/jquery-1.3.2.js"></script>
    $js
    $css
  </head>
  <body>
eot
}

sub _build_html_footer {
    my $self = shift;
    return <<eot;
  </body>
</html>
eot
}

sub _respond {
    my $self = shift;
    my %opts = @_;
    my $req  = $opts{req};

    my $content = $self->html_header($opts{who})
                  . $opts{content} . $self->html_footer;
    return $req->respond({ content => ['text/html', $content ]});
}

1;
