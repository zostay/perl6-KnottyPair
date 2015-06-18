#!perl6

use v6;

use Test;
use FancyPair;

my $x = 42;
my $p := 'Y' => $x;
my $f := 'X' =O> $x;

is $p{'Y'}, 42;
is $f{'X'}, 42;

$x++;

is $p{'Y'}, 42;
is $f{'X'}, 43;

diag ($p, $f).hash.perl;
diag ($f, $p).hash.perl;

my %h = ($f, $p).hash;
diag %h.perl;

is %h{'X'}, 43;
is %h{'Y'}, 42;
diag %h.perl;

$x++;

is $f{'X'}, 44;
is $p{'Y'}, 42;
is %h{'X'}, 43; # I WANT THIS TO BE 44
is %h{'Y'}, 42;
diag %h.perl;

