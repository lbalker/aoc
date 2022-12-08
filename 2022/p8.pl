use v5.20;
use autodie;
use Data::Dumper;

open my $f, "< p8-0.txt";
my ($exp1, $exp2, @lines0) = <$f>;
chomp ($exp1, $exp2);
close $f;
my $r = p1(\@lines0);
say "1 got: $r, expected: $exp1" if $r ne $exp1;
$r =  p2(\@lines0);
say "2 got: $r, expected: $exp2" if $r ne $exp2;

open $f, "< p8-1.txt";
my (@lines) = <$f>;
close $f;

say p1(\@lines);
say p2(\@lines);

sub gen {
    my $l = shift;
    my @trees;
    for my $line (@$l) {
        chomp $line;
        my @t = split //, $line;
        push @trees, \@t;
    }
    \@trees;
}

sub look {
    my ($t, $x, $y) = @_;
    my %trees;
    $trees{north} = [reverse map { $t->[$_][$x] } 0..$y-1];
    $trees{east}  = [map { $t->[$y][$_] } $x+1..$#$t];
    $trees{south} = [map { $t->[$_][$x] } $y+1..$#$t];
    $trees{west}  = [reverse map { $t->[$y][$_] } 0..$x-1];
    \%trees;
}

sub visible {
    my ($t, $x, $y) = @_;
    return 1 if $x == 0 or $y == 0 or $x == $#$t or $y == $#$t;
    my $me = $t->[$y][$x];
    my $dirs = look($t, $x, $y);
    while (my ($dir, $trees) = each %$dirs) {
        my $visible = 1;
        for my $tree (@$trees) {
            $visible = 0 if $tree >= $me;
        }
        return 1 if $visible;
    }
    return 0;
}

sub scenic {
    my ($t, $x, $y) = @_;
    return 0 if $x == 0 or $y == 0 or $x == $#$t or $y == $#$t;
    my $me = $t->[$y][$x];
    my $dirs = look($t, $x, $y);
    my $score = 1;
    while (my ($dir, $trees) = each %$dirs) {
        my $dist = 0;
        for my $tree (@$trees) {
            $dist += 1;
            last if $tree >= $me;
        }
        $score *= $dist;
    }
    return $score;
}

sub p1 {
    my ($l) = @_;
    my $trees = gen($l);
    my $visible = 0;
    for my $x (0..$#$trees) {
        for my $y (0..$#$trees) {
            $visible += visible($trees, $x, $y);
        }
    }
    $visible;
}

sub p2 {
    my ($l) = @_;
    my $trees = gen($l);
    my $scenic = 0;
    for my $x (0..$#$trees) {
        for my $y (0..$#$trees) {
            my $s = scenic($trees, $x, $y);
            $scenic = $s if $scenic < $s;
        }
    }
    $scenic;
}
