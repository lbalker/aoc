use v5.20;
use autodie;
use Data::Dumper;

open my $f, "< p9-0.txt";
my @lines0 = <$f>;
chomp @lines0;
close $f;
my @tests;
my $i = 0;
while (@lines0) {
    my %t;
    $t{exp1} = shift @lines0;
    $t{exp2} = shift @lines0;
    my $l;
    while ($l = shift(@lines0) and $l =~ /\w/) {
        push @{$t{lines}}, $l
    }
    push @tests, \%t;
}
for my $test (@tests) {
    if ($test->{exp1}) {
        my $r = p(1, $test->{lines});
        die "1 got: $r, expected: $test->{exp1}\n" if $r != $test->{exp1};
    }
    if ($test->{exp2}) {
        my $r = p(2, $test->{lines});
        die "2 got: $r, expected: $test->{exp2}\n" if $r != $test->{exp2};
    }
}

open $f, "< p9-1.txt";
my (@lines) = <$f>;
chomp @lines;
close $f;
my $r = p(1,\@lines);
say $r;
$r = p(2,\@lines);
say $r;

sub p {
    my ($q, $l) = @_;
    my @histories;
    push @histories, [ split(' ') ] for @$l;
    my $res = 0;
    foreach my $history (@histories) {
        my $current = [ @$history ];
        my @stack;
        while (1) {
            my $next = [];
            push @stack, $current;
            for my $i (0 .. $#$current - 1) {
                push @$next, $current->[$i + 1] - $current->[$i];
            }
            if (all_zeros($next)) {
                push @stack, $next;
                if ($q == 1) {
                    push @$next, 0;
                }
                else {
                    unshift @$next, 0;
                }
                $res += calc($q, \@stack);
                last;
            }
            else {
                $current = $next;
            }
        }
    }
    $res;
}

sub all_zeros {
    my $a = shift;
    return 0 if grep { $_ != 0 } @$a;
    return 1;
}

sub calc {
    my ($q, $stack) = @_;
    if ($q == 1) {
        for (my $i = $#$stack; $i > 0; --$i) {
            push @{ $stack->[$i - 1] }, $stack->[$i][ -1 ] + $stack->[$i - 1][ -1 ];
        }
        return $stack->[0][-1];
    }
    else {
        for (my $i = $#$stack; $i > 0; --$i) {
            unshift @{ $stack->[$i - 1] }, $stack->[$i - 1][ 0 ] - $stack->[$i][ 0 ];
        }
        return $stack->[0][0];
    }
}
