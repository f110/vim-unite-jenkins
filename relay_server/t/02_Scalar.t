use strict;
use warnings;

use Test::More;
use Data::Dumper;
use Data::VimScript;

subtest 'pass scalar included string' => sub {
    my $string = 'base string object';

    is(Data::VimScript->new->to_vimscript($string), '"base string object"');
};

#subtest 'pass some scalar args' => sub {
    #my $string = 'base string object';

    #is(Data::VimScript->new->to_vimscript($string, $string), '["base string object","base string object"]');
#};

done_testing;
