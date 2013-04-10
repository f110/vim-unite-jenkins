use strict;
use warnings;
use Plack::Request;
use Plack::Response;

my @jenkins_projects = ('full', 'recent', 'part');

sub {
    my $req = Plack::Request->new(shift);
    my $res = Plack::Response->new;

    my $path = $req->path;
    $res->status(200);
    $res->headers({
        'Content-Type' => 'text/plain',
    });

    if ($path =~ m#\A/[0-9a-zA-Z]+/[0-9]+\z#) {
        $res->body("project job");
    } elsif ($path =~ m#\A/[0-9a-zA-Z]+\z#) {
        #$res->body("
            #[
                #{
                    #'id': '1',
                    #'status': 'success',
                    #'repository': 'main.git',
                    #'branch': 'IHR',
                #},
                #{
                    #'id': '2',
                    #'status': 'fail',
                    #'repository': 'main.git',
                    #'branch': 'y_ihara',
                #}
                #{
                    #'id': '3',
                    #'status': 'running',
                    #'repository': 'main.git',
                    #'branch': 'diet',
                #},
            #]"
        #);
        $res->body(" [ { 'id': '1', 'status': 'success', 'repository': 'main.git', 'branch': 'IHR', }, { 'id': '2', 'status': 'fail', 'repository': 'main.git', 'branch': 'y_ihara', }, { 'id': '3', 'status': 'running', 'repository': 'main.git', 'branch': 'diet', }, ]");
    } else {
        $res->body(
            sprintf(
                '[%s]',
                join(
                    ',',
                    map {'"'.$_.'"'} @jenkins_projects
                )
            )
        );
    }

    return $res->finalize;
}
