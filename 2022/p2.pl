use v5.20;
use autodie;

my %score = (
    AX => 1 + 3,
    AY => 2 + 6,
    AZ => 3 + 0,
    BX => 1 + 0,
    BY => 2 + 3,
    BZ => 3 + 6,
    CX => 1 + 6,
    CY => 2 + 0,
    CZ => 3 + 3,
);

my %calc = (
    X => { qw/ A Z  B X  C Y / }, # lose
    Y => { qw/ A X  B Y  C Z / }, # draw
    Z => { qw/ A Y  B Z  C X / }, # win
);

open my $f, "< p2-0.txt";
my ($exp1, $exp2, @lines0) = <$f>;
chomp ($exp1, $exp2);
close $f;
my $r = p(\@lines0);
die "1 got: $r, expected: $exp1\n" if $r != $exp1;
$r = p2(\@lines0);
die "2 got: $r, expected: $exp2\n" if $r != $exp2;

open $f, "< p2-1.txt";
my (@lines) = <$f>;
close $f;
$r = p(\@lines);
say $r;

$r = p2(\@lines);
say $r;


sub p {
    my ($l) = @_;
    my $score = 0;
    for my $line (@$l) {
        if ($line =~ /(\w)\s+(\w)/) {
            $score += $score{$1.$2};
        }
    }
    $score;
}

sub p2 {
    my ($l) = @_;
    my $score = 0;
    for my $line (@$l) {
        if ($line =~ /(\w)\s+(\w)/) {
            $score += $score{$1 . $calc{$2}{$1}};
        }
    }
    $score;
}
