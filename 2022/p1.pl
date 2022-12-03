use v5.20;
use autodie;

open my $f, "< p1-0.txt";
my ($exp1, $exp2, @lines0) = <$f>;
chomp ($exp1, $exp2);
close $f;
my $r = p(1,\@lines0);
die "1 got: $r, expected: $exp1\n" if $r != $exp1;
$r = p(3,\@lines0);
die "2 got: $r, expected: $exp2\n" if $r != $exp2;

open $f, "< p1-1.txt";
my (@lines) = <$f>;
close $f;
$r = p(1,\@lines);
say $r;

$r = p(3,\@lines);
say $r;

sub p {
    my ($cnt,$l) = @_;

    my $i = 0;
    my @cal;
    for my $line (@$l) {
        chomp $line;
        if ($line eq '') {
            $i++;
            next;
        }
        $cal[$i] += $line;
    }

    my @sort = sort { $b <=> $a } @cal;
    my $r = 0;
    $r += shift @sort while $cnt--;
    $r;
}
