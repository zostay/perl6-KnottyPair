use v6;

=NAME KnottyPair - A subclass of Pair with binding on values

=begin SYNOPSIS

    use KnottyPair;

    # Like a Pair a => 1, but you must quote the left hand side. This usage is
    # basically equivalent to a regular Pair.
    my $kp = 'a' =x> 1;
    say "TRUE" if $kp ~~ KnottyPair; #> TRUE
    say "TRUE" if $kp ~~ Pair;       #> TRUE

    # Uppercase =X> version performs a binding operaiton
    my $x = 41;
    my $answer = 'Life, Universe, Everything' =X> $x;
    $x++;
    say "The answer to {$answer.key} is {$answer.value}.";
    #> The answer to Life, Universe, Everything is 42.

    sub slurpy-test(*@a, *%h) {
        say "a = ", @a.perl;
        say "h = ", %h.perl;
    }

    # Normal pairs are passed through as named args
    slurpy-test(a => 1, b => 2, c => 3);
    #> a = []<>
    #> h = {:a(1), :b(2), :c(3)}<>

    # Knotty pairs are pass through as positional args
    slurpy-test('a' =x> 1, 'b' =x> 2, 'c' =x> 3);
    #> a = ["a" =x> 1, "b" =x> 2, "c" =x> 3]<>
    #> h = {}<>

=end SYNOPSIS

=begin DESCRIPTION

For certain data structures, I find some aspects of the built-in L<Pair> to be inconvenient. Pairs are closely tied to L<Associative> data structures and there are several ways in which the Perl 6 language treats them specially. This is fine. This is good, but sometimes, I want a Pair that's exempt from some of that and sometimes I want a Pair that can be bound to a value in the same way a L<Hash> key may be bound. The built-in Pairs cannot do that.

=end DESCRIPTION

=begin pod

=head1 METHODS

=head2 method new

    method new(:$key, :$value) returns KnottyPair:D;

This is the constructor for creating a new KnottyPair. However, you will probably use the C<< =x> >> and C<< =X> >> operators instead most of the time.

=head2 method key

    method key(KnottyPair:D:) returns Mu

Returns the key value. This can be any kind of object. It is not assumed to be a string.

=head2 method value

    method value(KnottyPair:D:) is rw returns Mu

Returns the value of the pair. This can be any kind of object. You may also assign to this value. (However, if you want to bind, you need to see L<#method bind-value>.

=head2 method antipair

    method antipair(KnottyPair:D:) returns KnottyPair:D

Returns a new KnottyPair object with the key and value swapped.

=head2 method keys

    method keys(KnottyPair:D:) returns Mu

Returns a single value list containing the key.

=head2 method kv

=head2 method values

=head2 method pairs

=head2 method antipairs

=head2 method invert

=head2 method Str

=head2 method gist

=head2 method perl

=head2 method fmt

=head2 adverb :exists

=head2 method ACCEPTS

=head2 method postcircumfix:<[ ]>

=head2 method bind-value

=head1 OPERATORS

=head2 method infix:«=x>»

=head2 method infix:«=X>»

=end pod

class KnottyPair is Pair {
    has $.knotty-key;
    has $.knotty-value is rw;

    method key() { $!knotty-key }
    method value() is rw { $!knotty-value }

    submethod BUILD($key, $value) {
        $!knotty-key   = $key;
        $!knotty-value = $value;
        self;
    }

    method antipair(KnottyPair:D:) { self.new(key => $!knotty-value, value => $!knotty-key) }

    multi method keys(KnottyPair:D:)      { ($!knotty-key,).list }
    multi method kv(KnottyPair:D:)        { $!knotty-key, $!knotty-value }
    multi method values(KnottyPair:D:)    { ($!knotty-value,).list }
    multi method pairs(KnottyPair:D:)     { (self,).list }
    multi method antipairs(KnottyPair:D:) { self.new(key => $!knotty-value, value => $!knotty-key) }
    multi method invert(KnottyPair:D:)    { (KnottyPair.new($!knotty-value, $!knotty-key),).list }

    multi method Str(KnottyPair:D:) { $!knotty-key ~ "\t" ~ $!knotty-value }

    multi method gist(KnottyPair:D:) {
        $!knotty-key.gist ~ ' =x> ' ~ $!knotty-value.gist;
    }

    multi method perl(KnottyPair:D: :$arglist) {
        $!knotty-key.perl ~ ' =x> ' ~ $!knotty-value.perl;
    }

    method fmt($format = "%s\t%s") {
        sprintf($format, $!knotty-key, $!knotty-value);
    }

    multi method EXISTS-KEY(KnottyPair:D: $key) { $key eqv $!knotty-key }

    multi method ACCEPTS(KnottyPair:D: %h) {
        $.knotty-value.ACCEPTS(%h{$.knotty-key});
    }

    multi method ACCEPTS(KnottyPair:D: Mu $other) {
        $other."$.knotty-key"().Bool === $.knotty-value.Bool
    }

    multi method AT-KEY(KnottyPair:D: $key) { 
        $key eqv $.knotty-key ?? $!knotty-value !! Any
    }

    multi method ASSIGN-KEY(KnottyPair:D: $key, $value) {
        if $key eqv $.knotty-key {
            $!knotty-value = $value;
        }
    }

    multi method BIND-KEY(KnottyPair:D: $key, $value is rw) {
        if $key eqv $.knotty-key {
            $!knotty-value := $value;
        }
    }

    method bind-value($new is rw) {
        $!knotty-value := $new;
    }
}

sub infix:«=x>» ($key, $value) is export {
    KnottyPair.new(:$key, :$value);
}

sub infix:«=X>» ($key, $value is rw) is export {
    my $pair = KnottyPair.new(:$key, value => Any);
    $pair.bind-value($value);
    $pair;
}

