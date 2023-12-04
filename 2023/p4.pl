use v5.20;
use autodie;
use Data::Dumper;

open my $f, "< p4-0.txt";
my ($exp1, $exp2, @lines0a);
($exp1, $exp2, @lines0a) = <$f>;
chomp ($exp1, $exp2);
close $f;
my $r = p1(\@lines0a);
die "1 got: $r, expected: $exp1\n" if $r != $exp1;
$r = p2(\@lines0a);
die "2 got: $r, expected: $exp2\n" if $r != $exp2;
open $f, "< p4-1.txt";
my (@lines) = <$f>;
close $f;
$r = p1(\@lines);
say $r;
$r = p2(\@lines);
say $r;

sub p1 {
    my ($l) = @_;

    my $res = 0;

    for my $line (@$l) {
        if (my ($card, $win, $have) = $line =~ /Card\s+(\d+): ([\d\s]+)\|([\d\s]+)/) {
            my %win = map { $_ => 1 } split ' ', $win;
            my @have = split ' ', $have;
            my $score = 0;
            for my $v (@have) {
                if ($win{$v}) {
                    if ($score) {
                        $score *= 2;
                    }
                    else {
                        $score = 1;
                    }
                }
            }
            $res += $score;
        }
        else {
            die $line;
        }
    }
    $res;
}

sub p2 {
    my ($l) = @_;

    my %cards;
    my $last;

    for my $line (@$l) {
        if (my ($card, $win, $have) = $line =~ /Card\s+(\d+): ([\d\s]+)\|([\d\s]+)/) {
            $cards{$card} = {
                win   => { map { $_ => 1 } split ' ', $win },
                have  => [ split ' ', $have ],
                count => 1,
            };
            $last = $card;
        }
        else {
            die $line;
        }
    }
    for my $card (1..$last) {
        my $score = 0;
        for my $v (@{ $cards{$card}{have} }) {
            ++$score if $cards{$card}{win}{$v};
        }
        for (1..$score) {
            last if $last < $card + $_;
            $cards{$card + $_}{count} += $cards{$card}{count};
        }
    }
    my $res = 0;
    for (keys %cards) {
        $res += $cards{$_}{count};
    }
    $res;
}
