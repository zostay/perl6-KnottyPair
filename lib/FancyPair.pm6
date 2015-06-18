use v6;

class FancyPair is Pair {
    has $.fancy-key;
    has $.fancy-value is rw;

    submethod BUILD($key, $value) {
        $!fancy-key   = $key;
        $!fancy-value = $value;
        self;
    }

    method antipair(FancyPair:D:) { self.new(key => $!fancy-value, value => $!fancy-key) }

    multi method keys(FancyPair:D:)      { ($!fancy-key,).list }
    multi method kv(FancyPair:D:)        { $!fancy-key, $!fancy-value }
    multi method values(FancyPair:D:)    { ($!fancy-value,).list }
    multi method pairs(FancyPair:D:)     { (self,).list }
    multi method antipairs(FancyPair:D:) { self.new(key => $!fancy-value, value => $!fancy-key) }
    multi method invert(FancyPair:D:)    { (FancyPair.new($!fancy-value, $!fancy-key),).list }

    multi method Str(FancyPair:D:) { $!fancy-key ~ "\t" ~ $!fancy-value }

    multi method gist(FancyPair:D:) {
        if $!fancy-key ~~ Enum {
            '(' ~ $!fancy-key.gist ~ ') =o> ' ~ $!fancy-value.gist;
        } 
        else {
            $!fancy-key.gist ~ ' =o> ' ~ $!fancy-value.gist;
        }
    }

    multi method perl(FancyPair:D: :$arglist) {
        if $!fancy-key ~~ Enum {
            '(' ~ $!fancy-key.perl ~ ') =o> ' ~ $!fancy-value.perl;
        } elsif $!fancy-key ~~ Str and !$arglist and $!fancy-key ~~ /^ [<alpha>\w*] +% <[\-']> $/ {
            if $!fancy-value ~~ Bool {
                ':' ~ '!' x !$!fancy-value ~ $!fancy-key;
            } 
            else {
                ':' ~ $!fancy-key ~ '(' ~ $!fancy-value.perl ~ ')';
            }
        } 
        else {
            $!fancy-key.perl ~ ' =o> ' ~ $!fancy-value.perl;
        }
    }

    method fmt($format = "%s\t%s") {
        sprintf($format, $!fancy-key, $!fancy-value);
    }

    multi method EXISTS-KEY(Enum:D: $key) { $key eqv $!fancy-key }

    method FLATTENABLE_LIST() { (self,).list }
    method FLATTENABLE_HASH() { (self,).hash }

    multi method ACCEPTS(FancyPair:D: %h) {
        $.fancy-value.ACCEPTS(%h{$.fancy-key});
    }

    multi method ACCEPTS(FancyPair:D: Mu $other) {
        $other."$.fancy-key"().Bool === $.fancy-value.Bool
    }

    multi method AT-KEY(FancyPair:D: $key) { 
        $key eqv $.fancy-key ?? $!fancy-value !! Any
    }

    multi method ASSIGN-KEY(FancyPair:D: $key, $value) {
        if $key eqv $.fancy-key {
            $!fancy-value = $value;
        }
    }

    multi method BIND-KEY(FancyPair:D: $key, $value is rw) {
        if $key eqv $.fancy-key {
            $!fancy-value := $value;
        }
    }

    method bind-value($new is rw) {
        $!fancy-value := $new;
    }
}

sub infix:«=o>» ($key, $value) is export {
    FancyPair.new(:$key, :$value);
}

sub infix:«=O>» ($key, $value is rw) is export {
    my $pair = FancyPair.new(:$key, value => Any);
    $pair.bind-value($value);
    $pair;
}
