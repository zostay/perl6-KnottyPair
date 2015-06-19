use v6;

=NAME KnottyPair - A subclass of Pair with bindable values

=begin SYNOPSIS

    my 
    my %hash = a => 4, b => 5, c =

=end SYNOPSIS

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
        $!knotty-key.gist ~ ' =o> ' ~ $!knotty-value.gist;
    }

    multi method perl(KnottyPair:D: :$arglist) {
        $!knotty-key.perl ~ ' =O> ' ~ $!knotty-value.perl;
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

