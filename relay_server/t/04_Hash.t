use strict;
use warnings;

use Test::More;
use Data::VimScript;

subtest 'pass hash ref' => sub {
    my $hash = {
        'foo' => 'bar',
        'ihara' => 'IHR',
    };

    is(Data::VimScript->new->to_vimscript($hash), '{"foo":"bar","ihara":"IHR"}');
};

subtest 'hash in hash' => sub {
    my $hash = {
        'foo' => 'bar',
        'ihara' => 'IHR',
        'jk' => {
            'foo' => 'bar',
            'ihara' => 'IHR',
        },
    };

    is(Data::VimScript->new->to_vimscript($hash), '{"foo":"bar","ihara":"IHR","jk":{"foo":"bar","ihara":"IHR"}}');
};

subtest 'array in hash' => sub {
    my $hash = {
        'foo' => 'bar',
        'ihara' => 'IHR',
        'jk' => ['bob', 'alice']
    };

    is(
        Data::VimScript->new->to_vimscript($hash),
        '{"foo":"bar","ihara":"IHR","jk":["bob","alice"]}'
    );
};

done_testing;
