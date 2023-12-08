use v5.20;
use autodie;
use Data::Dumper;
use Math::AnyNum;

open my $f, "< p8-0.txt";
my @lines0 = <$f>;
chomp @lines0;
close $f;
my @tests;
my $i = 0;
while (@lines0) {
    my %t;
    $t{exp1} = shift @lines0;
    $t{exp2} = shift @lines0;
    $t{dir} = shift @lines0;
    shift @lines0;
    my $l;
    while ($l = shift(@lines0) and $l =~ /\w/) {
        push @{$t{lines}}, $l
    }
    push @tests, \%t;
}
for my $test (@tests) {
    my $r;
    if ($test->{exp1}) {
        my $r = p(1, $test->{dir}, $test->{lines});
        die "1 got: $r, expected: $test->{exp1}\n" if $r != $test->{exp1};
    }
    if ($test->{exp2}) {
        $r = p(2, $test->{dir}, $test->{lines});
        die "2 got: $r, expected: $test->{exp2}\n" if $r != $test->{exp2};
    }
}

open $f, "< p8-1.txt";
my ($dir,undef,@lines) = <$f>;
chomp $dir;
chomp @lines;
close $f;
my $r = p(1,$dir,\@lines);
say $r;
$r = p(2,$dir,\@lines);
say $r;

sub p {
    my ($q, $dir, $l) = @_;
    my %nodes;
    for my $line (@$l) {
        if (my ($node, $left, $right) = $line =~ /(\w+)\s*=\s*\((\w+),\s*(\w+)\)/) {
            $nodes{$node} = { L => $left, R => $right };
        }
    }
    my $steps = 0;
    if ($q == 1) {
        my $cur = 'AAA';
        my $nextdir;
        while ($cur ne 'ZZZ') {
            $nextdir = $dir unless $nextdir;
            $nextdir =~ s/(.)//;
            my $step = $1;
            $cur = $nodes{$cur}{$step};
            ++$steps;
        }
    }
    else {
        my @starts = grep /A$/, sort keys %nodes;
        my @depths;
        for my $try (@starts) {
            my $nextdir;
            my $steps1 = 0;
            do {
                $nextdir = $dir unless $nextdir;
                $nextdir =~ s/(.)//;
                my $step = $1;
                $try = $nodes{$try}{$step};
                ++$steps1;
            } while $try !~ /Z$/;
            my $steps2 = 0;
            do { 
                $nextdir = $dir unless $nextdir;
                $nextdir =~ s/(.)//;
                my $step = $1;
                $try = $nodes{$try}{$step};
                ++$steps2;
            } while $try !~ /Z$/;
            die unless $steps1 == $steps2; # just sanity whether there is as far from A to Z as Z to Z...
            push @depths, $steps1;
        }
        $steps = Math::AnyNum::lcm(@depths);
    }
    $steps;
}
