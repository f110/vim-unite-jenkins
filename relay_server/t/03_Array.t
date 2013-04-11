use strict;
use warnings;

use Test::More;
use Data::VimScript;

subtest 'pass array ref' => sub {
    my $array = [qw/foo bar/];

    is(Data::VimScript->new->to_vimscript($array), '["foo","bar"]');
};

subtest 'array in array' => sub {
    my $array = [
        'foo',
        ['ihara', 'IHR'],
        'bar',
    ];

    is(Data::VimScript->new->to_vimscript($array), '["foo",["ihara","IHR"],"bar"]');
};

subtest 'hash in array' => sub {
    my $array = [
        'foo',
        {
            'foo' => 'bar',
            'ihara' => 'IHR',
        },
        'bar',
    ];

    is(
        Data::VimScript->new->to_vimscript($array),
        '["foo",{"foo":"bar","ihara":"IHR"},"bar"]'
    );
};

done_testing;
