package Data::VimScript;
use strict;
use warnings;

use constant {
    QUOTE => '"',
};

my $instance;

sub to_vimscript {
    my $self = shift;

    $self->dispatch(shift);
}

sub dispatch {
    my $self = shift;
    my $data = shift;

    if (ref $data eq "ARRAY") {
        return $self->array_to_string($data);
    } elsif (ref $data eq "HASH") {
        return $self->hash_to_string($data);
    } else {
        return $self->string_to_string($data);
    }
}

sub array_to_string($) {
    my $self = shift;

    my $result = "";
    for my $value (@{$_[0]}) {
        $result .= $self->dispatch($value).",";
    }

    chop $result;
    '['.$result.']';
}

sub hash_to_string($)  {
    my $self = shift;

    my @pair;
    for my $key (sort keys %{$_[0]}) {
        my $value = $_[0]->{$key};
        push @pair, QUOTE().$key.QUOTE().":".$self->dispatch($value);
    }

    '{'.join(",", @pair).'}';
}

sub string_to_string($) {
    shift;
    QUOTE().shift.QUOTE();
}

sub new {
    shift->_instance;
}

sub _instance {
    my $class = shift;

    unless ($instance) {
        $instance = $class->_create_instance;
    }

    $instance;
}

sub _create_instance {
    my $class = shift;
    return bless {}, $class;
}

1;
