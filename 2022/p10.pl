use v5.20;
use autodie;
use Data::Dumper;

open my $f, "< p10-0.txt";
my ($exp1, $exp2, @lines0) = <$f>;
chomp ($exp1);
close $f;
while ($lines0[0] =~ /^#/) {
    $exp2 .= shift @lines0;
}
my $r = p1(\@lines0);
say "1 got: $r, expected: $exp1" if $r ne $exp1;
$r =  p2(\@lines0);
say "2 got:\n$r, expected:\n$exp2" if $r ne $exp2;

open $f, "< p10-1.txt";
my (@lines) = <$f>;
close $f;

say p1(\@lines);
say p2(\@lines);

sub loop {
    my ($l, $check) = @_;
    my $x = 1;
    my $cycle = 0;
    for my $line (@$l) {
        if (my ($delta) = ($line =~ /^addx (-?\d+)/)) {
            $cycle += 1;
            $check->($cycle,$x);
            $cycle += 1;
            $check->($cycle,$x);
            $x += $delta;
        }
        elsif ($line =~ /^noop/) {
            $cycle += 1;
            $check->($cycle,$x);
        }
        else {
            die;
        }
    }
}

sub p1 {
    my ($l) = @_;
    my $sum = 0;
    my $check = sub {
        my ($cycle, $x) = @_;
        if (($cycle-20) % 40 == 0) {
            $sum += $x * $cycle;
        }
    };
    loop($l, $check);
    $sum;
}

sub p2 {
    my ($l) = @_;
    my $output = '';
    my $check = sub {
        my ($cycle, $x) = @_;
        my $pos = ($cycle-1) % 40;
        $output .= ($pos == $x || $pos == $x-1 || $pos == $x+1) ? "#" : ".";
        if (($cycle) % 40 == 0) {
            $output .= "\n";
        }
    };
    loop($l, $check);
    $output;
}
