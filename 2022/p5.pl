use v5.20;
use autodie;
use Data::Dumper;

open my $f, "< p5-0.txt";
my ($exp1, $exp2, @lines0) = <$f>;
chomp ($exp1, $exp2);
close $f;
my $r = p1(\@lines0);
say "1 got: $r, expected: $exp1" if $r ne $exp1;
$r =  p2(\@lines0);
say "2 got: $r, expected: $exp2" if $r ne $exp2;

open $f, "< p5-1.txt";
my (@lines) = <$f>;
close $f;

say p1(\@lines);
say p2(\@lines);

sub doit {
    my ($l, $mover) = @_;
    my @crates;

    for my $line (@$l) {
        my $i = 0;
        while ($line =~ /.([A-Z ])..?/g) {
            push @{ $crates[$i] }, $1 if $1 ne ' ';
            ++$i;
        }
        last if $line =~ /^$/;
    }
    for my $line (@$l) {
        if (my ($amount, $from, $to) = $line =~ /move (\d+) from (\d+) to (\d+)/) {
            $mover->(\@crates, $to - 1, $from - 1, $amount);
        }
    }
    join "", map { $_->[0] } @crates;
}

sub p1 {
    my ($l) = @_;
    doit($l, sub {
        my ($crates,$to,$from,$amount) = @_;
        while ($amount--) {
            unshift @{ $crates->[ $to ] }, shift @{ $crates->[ $from ] };
        }
    });
}

sub p2 {
    my ($l) = @_;
    doit($l, sub {
        my ($crates,$to,$from,$amount) = @_;
        unshift @{ $crates->[ $to ] }, splice @{ $crates->[ $from ] }, 0, $amount;
    });
}
