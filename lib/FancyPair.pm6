use v6;

class FancyPair is Pair {
    has $.fancy-key;
    has $.fancy-value is rw;

    method key() { $!fancy-key }
    method value() is rw { $!fancy-value }

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
        $!fancy-key.gist ~ ' =o> ' ~ $!fancy-value.gist;
    }

    multi method perl(FancyPair:D: :$arglist) {
        $!fancy-key.perl ~ ' =O> ' ~ $!fancy-value.perl;
    }

    method fmt($format = "%s\t%s") {
        sprintf($format, $!fancy-key, $!fancy-value);
    }

    multi method EXISTS-KEY(FancyPair:D: $key) { $key eqv $!fancy-key }

    method FLATTENABLE_HASH() { 
        my %h;
        %h{ $!fancy-key } := $!fancy-value;
        %h
    }

    method hash() { 
        my %h;
        %h{ $!fancy-key } := $!fancy-value;
        %h
    }

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
