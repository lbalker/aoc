use v5.20;
use autodie;
use Data::Dumper;

open my $f, "< p6-0.txt";
my ($exp1, $exp2, @lines0a);
($exp1, $exp2, @lines0a) = <$f>;
chomp ($exp1, $exp2);
close $f;
my $r = p(1,\@lines0a);
die "1 got: $r, expected: $exp1\n" if $r != $exp1;
$r = p(2,\@lines0a);
die "2 got: $r, expected: $exp2\n" if $r != $exp2;
open $f, "< p6-1.txt";
my (@lines) = <$f>;
close $f;
$r = p(1,\@lines);
say $r;
$r = p(2,\@lines);
say $r;

sub p {
    my ($q, $l) = @_;

    my (@time, @distance);
    if ($q == 1) {
         @time     = split ' ', $l->[0];
         @distance = split ' ', $l->[1];
    }
    else {
        @time = ( 0,join("", split ' ', $l->[0]) =~ s/.*://r );
        @distance = ( 0,join("", split ' ', $l->[1]) =~ s/.*://r );
        say Dumper \@time;
    }

    my $res = 1;
    for my $i ( 1 .. $#time) {
        my $t = $time[$i];
        my $d = $distance[$i];
        my $wins = 0;
        for my $j ( 1 .. $t - 1) {
            my $travel = $j * ($t - $j);
            ++$wins if $travel > $d;
        }
        $res *= $wins;
    }
    $res;
}



# we know holding the button for half the time is a winning strategy,
# so we can binary search for the first loser in either direction

sub find_lowest_time_that_wins {
    my ($time, $distance) = @_;
    
    return 2 if $time == 7;
    return 0 if $time == 15;
    return 0 if $time == 30;
}
sub find_highest_time_that_wins {
    my ($time, $distance) = @_;
    return 5 if $time == 7;
    return 7 if $time == 15;
    return 8 if $time == 30;
}


#        my $lo = find_lowest_time_that_wins($time[$i],$distance[$i]);
#        my $hi = find_highest_time_that_wins($time[$i],$distance[$i]);
#        $res *= $hi - $lo + 1;
