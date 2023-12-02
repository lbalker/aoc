use v5.20;
use autodie;

open my $f, "< p1-0a.txt";
my ($exp1, @lines0a) = <$f>;
chomp ($exp1);
close $f;
open my $f, "< p1-0b.txt";
my ($exp2, @lines0b) = <$f>;
chomp ($exp2);
close $f;
my $r = p1(\@lines0a);
die "1 got: $r, expected: $exp1\n" if $r != $exp1;
$r = p2(\@lines0b);
die "2 got: $r, expected: $exp2\n" if $r != $exp2;

open $f, "< p1-1.txt";
my (@lines) = <$f>;
close $f;
$r = p1(\@lines);
say $r;

$r = p2(\@lines);
say $r;

sub p1 {
    my ($l) = @_;

    my $sum = 0;
    for my $line (@$l) {
        if ($line =~ /(\d).*(\d)/a) {
            $sum += "$1$2";
        }
        elsif ($line =~ /(\d)/a) {
            $sum += "$1$1";
        }
    }

    $sum;
}

sub p2 {
    my ($l) = @_;
    my @n = qw/ 0 one two three four five six seven eight nine /;
    my %n = ((map{ $n[$_] => $_ } 0 .. 9), (map { $_ => $_ } 1..9));
    my $n = join "|", keys %n;
    my $sum = 0;
    for my $line (@$l) {
        if ($line =~ /($n).*($n)/a) {
            $sum += $n{$1} . $n{$2};
        }
        elsif ($line =~ /($n)/a) {
            $n{$1} . $n{$1};
            $sum += $n{$1} . $n{$1};
        }
    }
    $sum;
}
