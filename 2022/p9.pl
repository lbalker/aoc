use v5.20;
use autodie;
use Data::Dumper;

open my $f, "< p9-0.txt";
my ($exp1, $exp2, @lines0) = <$f>;
chomp ($exp1, $exp2);
close $f;
my $r = p1(\@lines0);
say "1 got: $r, expected: $exp1" if $r ne $exp1;
$r =  p2(\@lines0);
say "2 got: $r, expected: $exp2" if $r ne $exp2;

open $f, "< p9-1.txt";
my (@lines) = <$f>;
close $f;

say p1(\@lines);
say p2(\@lines);

sub move {
    my ($l,$cnt) = @_;

    my %visited;
    my @r = map { { x => 0, y => 0 } } 0..$cnt-1;

    my $step = sub {
        my ($v, $d) = @_;
        $r[0]{$v} += $d;
        for my $i (1..$#r) {
            if ($r[$i-1]{x} == $r[$i]{x} and $r[$i-1]{y} == $r[$i]{y}) {
                # overlap;
            }
            elsif ($r[$i]{x} == $r[$i-1]{x}) {
                if (abs($r[$i]{y} - $r[$i-1]{y}) > 1) {
                    $r[$i]{y} += ($r[$i-1]{y} > $r[$i]{y} ? 1 : -1);
                }
            }
            elsif ($r[$i]{y} == $r[$i-1]{y}) {
                if (abs($r[$i]{x} - $r[$i-1]{x}) > 1) {
                    $r[$i]{x} += ($r[$i-1]{x} > $r[$i]{x} ? 1 : -1);
                }
            }
            else {
                if (abs($r[$i]{x} - $r[$i-1]{x}) + abs($r[$i]{y} - $r[$i-1]{y}) > 2) {
                    $r[$i]{x} += ($r[$i-1]{x} > $r[$i]{x} ? 1 : -1);
                    $r[$i]{y} += ($r[$i-1]{y} > $r[$i]{y} ? 1 : -1);
                }
            }
        }
    };

    for my $line (@$l) {
        my ($dir, $count) = split ' ', $line;
        while ($count--) {
            $step->('x',  1) if $dir eq "R";
            $step->('x', -1) if $dir eq "L";
            $step->('y',  1) if $dir eq "U";
            $step->('y', -1) if $dir eq "D";
            $visited{$r[-1]{x}}{$r[-1]{y}} = 1;
        }
    }
    my $count = 0;
    for my $x (keys %visited) {
        $count++ for keys %{$visited{$x}};
    }
    $count;
}

sub p1 {
    my ($l) = @_;
    my $visited = move($l,2);
    $visited;
}

sub p2 {
    my ($l) = @_;
    my $visited = move($l,10);
    $visited;
}
