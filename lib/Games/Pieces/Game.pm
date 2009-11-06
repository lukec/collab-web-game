package Games::Pieces::Game;
use Moose::Role;
use AnyEvent::HTTPD;
use namespace::clean -except => 'meta';

has 'debug' => (is => 'ro', isa => 'Bool', default => sub {0});
has 'httpd' => (is => 'ro', isa => 'AnyEvent::HTTPD', lazy_build => 1,
                handles => ['run']);

requires 'player_css_uri';
requires 'admin_css_uri';
requires 'standby_html';
requires 'admin_html';

sub _build_httpd {
    my $self = shift;

    my $httpd = AnyEvent::HTTPD->new (port => $self->port);
    $httpd->reg_cb (
       '/' => sub {
          my ($httpd, $req) = @_;
          $httpd->stop_request;

          my $content = $self->player_html;
          return $self->_respond( req => $req, content => $content );
       },
       '/show' => sub {
          my ($httpd, $req) = @_;
          $httpd->stop_request;

          my $content = $self->admin_html;
          return $self->_respond( req => $req, content => $content );
       },
       '/show/fragment' => sub {
          my ($httpd, $req) = @_;
          $httpd->stop_request;

          $req->respond({ content => ['text/html', 
                  $self->to_html || $self->standby_html ]});
       },
       '/game/update' => sub {
          my ($httpd, $req) = @_;
          $httpd->stop_request;

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
    return <<eot;
<html>
  <head>
    <script type="text/javascript" src="/static/jquery-1.3.2.min.js"></script>
  </head>
  <body>
eot
}

sub html_footer { '</body></html>' }

sub _respond {
    my $self = shift;
    my %opts = @_;
    my $req  = $opts{req};

    my $content = $self->html_header()
                  . $opts{content} . $self->html_footer;
    return $req->respond({ content => ['text/html', $content ]});
}

1;
