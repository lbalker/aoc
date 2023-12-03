use v5.20;
use autodie;
use Data::Dumper;

open my $f, "< p3-0.txt";
my ($exp1, $exp2, @lines0a);
($exp1, $exp2, @lines0a) = <$f>;
chomp ($exp1, $exp2);
close $f;
my $r = p(1,\@lines0a);
die "1 got: $r, expected: $exp1\n" if $r != $exp1;
$r = p(2,\@lines0a);
die "2 got: $r, expected: $exp2\n" if $r != $exp2;

open $f, "< p3-1.txt";
my (@lines) = <$f>;
close $f;
$r = p(1,\@lines);
say $r;
$r = p(2,\@lines);
say $r;

sub max {
    my ($i,$j) = @_;
    $j < $i ? $i : $j;
}

sub hassymbol {
    my ($i, $j, $len, $symbol) = @_;
    if (0 < $i) {
        for my $x (max(0, $j - 1) .. $j + $len) {
            return [$i-1,$x] if $symbol->[$i - 1][$x];
        }
    }
    return [$i,$j-1] if $j > 0 and $symbol->[$i][$j - 1];
    return [$i,$j+$len] if $symbol->[$i][$j + $len];
    for my $x (max(0, $j - 1) .. $j + $len) {
        return [$i + 1,$x] if $symbol->[$i + 1][$x];
    }
    return 0;
}

sub p {
    my ($q,$l) = @_;

    my @numbers;
    my @symbol;
    my @gear;
    my ($i,$j)=(0,0);
    for my $line (@$l) {
        chomp $line;
        my $n = '';
        my $n_j;
        for my $char (split //, $line) {
            $symbol[$i][$j] = 0;
            if ($char =~ /\d/) {
                $n_j //= $j;
                $n .= $char;
            }
            else {
                if ($n) {
                    push @numbers, { i => $i, j => $n_j, v => $n };
                    $n = '';
                    $n_j = undef;
                }
                if ($char ne '.') {
                    $symbol[$i][$j] = $char;
                }
                if ($char eq '*') {
                    $gear[$i][$j] = $char;
                }
            }
            ++$j;
        }
        if ($n) {
            push @numbers, { i => $i, j => $n_j, v => $n };
        }
        $j = 0;
        ++$i;
    }
    my $res = 0;
    if ($q == 1) {
        for my $number (@numbers) {
            if (hassymbol($number->{i}, $number->{j}, length($number->{v}), \@symbol)) {
                $res += $number->{v};
            }
        }
    }
    else {
        my @gears;
        for my $number (@numbers) {
            if (my $coord = hassymbol($number->{i}, $number->{j}, length($number->{v}), \@gear)) {
                my ($i, $j) = @$coord;
                if ($gears[$i][$j]) {
                    $gears[$i][$j] = [ $gears[$i][$j][0] + 1, $gears[$i][$j][1] * $number->{v} ];
                }
                else {
                    $gears[$i][$j] = [1, $number->{v}];
                }
            }
        }
        for my $g (@gears) {
            next unless $g;
            for my $gear (@$g) {
                $res += $gear->[1] if $gear and $gear->[0] == 2;
            }
        }
    }
    $res;
}
