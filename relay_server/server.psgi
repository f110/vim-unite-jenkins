use strict;
use warnings;
use Plack::Request;
use Plack::Response;
use Net::Jenkins;
use Data::VimScript;

sub {
    my $req = Plack::Request->new(shift);
    my $res = Plack::Response->new;

    my $jenkins = Net::Jenkins->new(host => 'ci.jenkins-ci.org', port => 80);
    my $converter = Data::VimScript->new;

    my $path = $req->path;
    $res->status(200);
    $res->headers({
        'Content-Type' => 'text/plain',
    });

    if ($path =~ m#\A/[0-9a-zA-Z-_]+\z#) {
        (my $target_project = $path) =~ s#\A/(.+)\z#$1#;
        my $target_job;

        my @projects = $jenkins->jobs;
        for (@projects) {
            if ($_->name eq $target_project) {
                $target_job = $_;
                last;
            }
        }
        my @builds = $target_job->builds;
        my @jobs = reverse sort { $a->{id} <=> $b->{id} }
        map {
            {
                id => $_->number,
                status => $_->result,
                repository => 'test',
                branch => 'test',
            }
        } @builds;

        $res->body($converter->to_vimscript(\@jobs));
    } else {
        my @jobs = $jenkins->jobs;
        my @projects = map {
            $_->name;
        } @jobs;

        $res->body($converter->to_vimscript(\@projects));
    }

    return $res->finalize;
}
