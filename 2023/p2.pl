use v5.20;
use autodie;

open my $f, "< p2-0.txt";
my ($exp1, $exp2, @lines0a) = <$f>;
chomp ($exp1, $exp2);
close $f;
my $r = p(\@lines0a);
die "1 got: $r, expected: $exp1\n" if $r != $exp1;
$r = p2(\@lines0a);
die "2 got: $r, expected: $exp2\n" if $r != $exp2;

open $f, "< p2-1.txt";
my (@lines) = <$f>;
close $f;
$r = p(\@lines);
say $r;
$r = p2(\@lines);
say $r;

sub p {
    my $l = shift;
    my %possible = qw/ red 12 green 13 blue 14 /;

    my $res = 0;
    LINE: for my $line (@$l) {
        if ($line =~ /Game (\d+):\s*(.*)/) {
            my $game = $1;
            my @t = split /[,;]\s*/, $2;
            for (@t) {
                if (/(\d+) (\w+)/) {
                    next LINE if $1 > $possible{$2};
                }
            }
            $res += $game;
        }
    }
    $res;
}

sub p2 {
    my $l = shift;

    my $res = 0;
    for my $line (@$l) {
        if ($line =~ /Game (\d+):\s*(.*)/) {
            my $game = $1;
            my %max;
            for my $set (split /[;]\s*/, $2) {
                my @t = split /[,]\s*/, $set;
                for (@t) {
                    if (/(\d+) (\w+)/) {
                        $max{$2} = $1 if $max{$2} < $1;
                    }
                }
            }
            my $power = 1;
            $power *= $_ for values %max;
            $res += $power;
        }
    }
    $res;
}

