use v5.20;
use autodie;

open my $f, "< p4-0.txt";
my ($exp1, $exp2, @lines0) = <$f>;
chomp ($exp1, $exp2);
close $f;
my $r = p1(\@lines0);
say "1 got: $r, expected: $exp1" if $r != $exp1;
$r =  p2(\@lines0);
say "2 got: $r, expected: $exp2" if $r != $exp2;

open $f, "< p4-1.txt";
my (@lines) = <$f>;
close $f;

say p1(\@lines);
say p2(\@lines);

sub p1 {
    my ($l) = @_;
    my $score = 0;

    for my $line (@$l) {
        chomp $line;
        my @l = split /[-,]/, $line;
        if (($l[0] >= $l[2] && $l[1] <= $l[3]) || ($l[2] >= $l[0] && $l[3] <= $l[1])) {
            $score++;
        }
    }
    $score;
}

sub p2 {
    my ($l) = @_;
    my $score = 0;

    for my $line (@$l) {
        chomp $line;
        my @l = split /[-,]/, $line;
        if (   ($l[0] >= $l[2] && $l[0] <= $l[3])
            || ($l[1] >= $l[2] && $l[1] <= $l[3])
            || ($l[2] >= $l[0] && $l[2] <= $l[1])
            || ($l[3] >= $l[0] && $l[3] <= $l[1]))
        {
            $score++;
        }
    }
    $score;
}
