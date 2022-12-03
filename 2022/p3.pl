use v5.20;
use autodie;

my %prio = map { $_ => ord($_) - 64 + 26 } 'A'..'Z';
my %prio2 = map { $_ => ord($_) - 96 } 'a'..'z';
@prio{keys %prio2} = values %prio2;

open my $f, "< p3-0.txt";
my ($exp1, $exp2, @lines0) = <$f>;
chomp ($exp1, $exp2);
close $f;
my $r = p1(\@lines0);
print "1 got: $r, expected: $exp1\n" if $r != $exp1;
$r =  p2(\@lines0);
print "2 got: $r, expected: $exp2\n" if $r != $exp2;

open $f, "< p3-1.txt";
my (@lines) = <$f>;
close $f;

say p1(\@lines);
say p2(\@lines);

sub p1 {
    my ($l) = @_;
    my $score = 0;

    for my $line (@$l) {
        chomp $line;
        my @l = split //, $line;
        my @l1 = @l[0..(@l/2-1)];
        my @l2 = @l[(@l/2)..(@l-1)];
        
        my (%s1,%s2);
        $s1{$_}++ for @l1;
        $s2{$_}++ for @l2;
        for my $k (keys %s1) {
            if ($s2{$k}) {
                $score += $prio{$k};
            }
        }
    }
    $score;
}

sub p2 {
    my ($l) = @_;
    my $score = 0;

    while (@$l) {
        my $l1 = shift @$l;
        my $l2 = shift @$l;
        my $l3 = shift @$l;
        chomp($l1,$l2,$l3);
        my %in1 = map { $_ => 1 } split //, $l1;
        my %in2 = map { $_ => 1 } split //, $l2;
        my %in3 = map { $_ => 1 } split //, $l3;
        for my $k ( keys %in3 ) {
            if ($in1{$k} and $in2{$k}) {
                $score += $prio{$k}
            }
        }
    }
    $score;
}
