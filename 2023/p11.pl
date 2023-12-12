use v5.20;
use strict;
use warnings;
use autodie;
use Data::Dumper;

package Map {
    use Moo;
    has 'map' => ( is => 'ro', default => sub { [] } );
    sub add_galaxy {
        my ($self, $j, $i, $galaxy) = @_;
        push @{ $self->map }, [$j, $i, $galaxy];
    }
    sub max_j {
        my $self = shift;
        my $max = 0;
        my $map = $self->map;
        for my $pos (@$map) {
            $max = $pos->[0] if $max < $pos->[0];
        }
        $max;
    }
    sub max_i {
        my $self = shift;
        my $max = 0;
        my $map = $self->map;
        for my $pos (@$map) {
            $max = $pos->[1] if $max < $pos->[1];
        }
        $max;
    }
    sub expand {
        my ($self, $expansion) = @_;
        my $map = $self->map;
        my (@i, @j);
        for my $pos (@$map) {
            $j[ $pos->[0] ] += $pos->[2];
            $i[ $pos->[1] ] += $pos->[2];
        }
        for (my $x = $#i; 0 <= $x; --$x) {
            next if $i[$x];
            for my $pos (@$map) {
                $pos->[1] = $pos->[1] + $expansion if $x < $pos->[1];
            }
        }
        for (my $y = $#j; 0 <= $y; --$y) {
            next if $j[$y];
            for my $pos (@$map) {
                $pos->[0] = $pos->[0] + $expansion if $y < $pos->[0];
            }
        }
    }
    sub sum_all_distances {
        my $self = shift;
        my $sum = 0;
        my $map = $self->map;
        for my $i (0.. $#$map) {
            for my $j ($i+1.. $#$map) {
                $sum += abs($map->[$j][0] - $map->[$i][0]) + abs($map->[$j][1] - $map->[$i][1]);
            }
        }
        return $sum;
    }
    sub print {
        my $self = shift;
        my $j = $self->max_j;
        my $i = $self->max_i;
        my @row = (".") x ($i+1);
        my @map;
        for my $y (0 .. $j) {
            $map[$y] = [ @row ];
        }
        for my $n (@{$self->map}) {
            $map[ $n->[0] ][ $n->[1] ] = $n->[2];
        }
#        say Data::Dumper::Dumper $self->map, \@map;
        for my $row (@map) {
            say @$row;
        }
    }
}

open my $f, "< p11-0.txt";
my @lines0 = <$f>;
chomp @lines0;
close $f;
my @tests;
while (@lines0) {
    my %t;
    $t{exp1} = shift @lines0;
    $t{exp2} = shift @lines0;
    my $l;
    while ($l = shift(@lines0) and $l =~ /\S/) {
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

open $f, "< p11-1.txt";
my (@lines) = <$f>;
chomp @lines;
close $f;
my $r = p(1,\@lines);
say $r;
$r = p(2,\@lines);
say $r;

sub p {
    my ($q, $l) = @_;
    my $map = Map->new();
    my $j = 0;
    my $galaxy = 1;
    for my $line (@$l) {
        my @chr = split '', $line;
        my $i = 0;
        for my $chr (@chr) {
            if ($chr eq '#') {
                $map->add_galaxy($j, $i, $galaxy);
                ++$galaxy;
            }
            ++$i;
        }
        ++$j;
    }
#    $map->print;
    $map->expand($q == 1 ? 1 : 999_999);
#    $map->print;
    return $map->sum_all_distances;
}
