use v5.20;
use strict;
use warnings;
use autodie;
use Data::Dumper;

package Node {
    use Moo;
    has 'dirs' => (is => 'ro');
    has 'animal' => (is => 'ro');
    has 'i' => (is => 'rw');
    has 'j' => (is => 'rw');
    has 'map' => (is => 'rw');
    has 'distance' => (is => 'rw');
    sub is_legal {
        my ($self) = @_;
        return 1 if $self->animal;
        my $map = $self->map;
        if ($self->dirs->{n}) {
            my $n = $self->north;
            return 0 unless $n;
        }
        if ($self->dirs->{e}) {
            my $n = $self->east;
            return 0 unless $n;
        }
        if ($self->dirs->{s}) {
            my $n = $self->south;
            return 0 unless $n;
        }
        if ($self->dirs->{w}) {
            my $n = $self->west;
            return 0 unless $n;
        }
        return 1;
    }

    sub north {
        my $self = shift;
        my $n = $self->map->get_node($self->i, $self->j - 1);
        return $self->dirs->{n} && $n && $n->dirs->{s} && $n;
    }
    sub east {
        my $self = shift;
        my $n = $self->map->get_node($self->i + 1, $self->j);
        return $self->dirs->{e} && $n && $n->dirs->{w} && $n;
    }
    sub south {
        my $self = shift;
        my $n = $self->map->get_node($self->i, $self->j + 1);
        return $self->dirs->{s} && $n && $n->dirs->{n} && $n;
    }
    sub west {
        my $self = shift;
        my $n = $self->map->get_node($self->i - 1, $self->j);
        return $self->dirs->{w} && $n && $n->dirs->{e} && $n;
    }

    sub add_distance {
        my ($self,$val) = @_;

        my @todo = ([$self, $val]);
        while (@todo) {
            my $p = shift @todo;
            my ($node, $val) = @$p;
            next unless $node;
            next if defined $node->distance;
            $node->distance($val);
            for my $n ( $node->north, $node->east, $node->south, $node->west ) {
                push @todo, [ $n, $val+1 ];
            }
        }
    }
}

package Map {
    use Moo;
    has 'map' => ( is => 'rw', default => sub { [] } );
    sub add_node {
        my ($self, $i, $j, $node) = @_;
        $self->map->[$j][$i] = $node;
        $node->i($i);
        $node->j($j);
        $node->map($self);
    }

    sub get_node {
        my ($self, $i, $j) = @_;
        my $map = $self->map;
        return undef if $j < 0 or $j > @$map;
        my $row = $map->[$j];
        return undef if !$row or $i < 0 or $i > @$row;
        return $row->[$i];
    }

    sub del_node {
        my ($self, $i, $j) = @_;
        my $map = $self->map;
        return undef if $j < 0 or $j > @$map;
        my $row = $map->[$j];
        return undef if $i < 0 or $i > @$row;
        $row->[$i] = undef;
    }

    sub clean {
        my $self = shift;

        my $map = $self->map;
        my $dels = 0;
        while (1) {
            for my $j (0.. $#$map) {
                for my $i (0 .. $#{ $map->[$j] }) {
                    my $node = $self->get_node($i, $j);
                    if ($node and not defined $node->distance) {
                        $self->del_node($i,$j);
                        ++$dels;
                    }
                }
            }
            last if $dels == 0;
            $dels = 0;
        }
    }

    sub max_distance {
        my $self = shift;

        my $map = $self->map;
        my $max = 0;
        for my $j (0.. $#$map) {
            for my $i (0 .. $#{ $map->[$j] }) {
                my $node = $self->get_node($i, $j);
                $max = $node->distance if $node && defined $node->distance && $node->distance > $max;
            }
        }
        return $max;
    }

    sub internal_tiles {
        my $self = shift;
        my $map = $self->map;
        my $tiles = 0;
        my $inside = 0;
        for my $j (0.. $#$map) {
            my $row = $map->[$j];
            for my $i (0 .. $#$row) {
                my $node = $self->get_node($i, $j);
                ++$tiles if $inside && !$node;
                $inside = !$inside if $node && $node->north;
            }
        }
        return $tiles;
    }
}

open my $f, "< p10-0.txt";
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

open $f, "< p10-1.txt";
my (@lines) = <$f>;
chomp @lines;
close $f;
my $r = p(1,\@lines);
say $r;
$r = p(2,\@lines);
say $r;

sub p {
    my ($q, $l) = @_;
    my %dir = qw/
        | ns
        - ew
        L ne
        J nw
        7 sw
        F se
        . .
        S S
    /;
    my $map = Map->new();
    my $animal;
    my $j = 0;
    for my $line (@$l) {
        my @chr = split '', $line;
        my $i = 0;
        for my $chr (@chr) {
            my $dir = $dir{$chr};
            my @dir = split '', $dir;
            my $node;
            if (@dir > 1) {
                $node = Node->new(dirs => { map { $_ => 1 } @dir });
            }
            elsif ($dir eq 'S') {
                $animal = $node = Node->new(dirs => { map { $_ => 1 } qw/n e s w/ }, animal => 1);
            }
            $map->add_node($i, $j, $node) if $node;
            ++$i;
        }
        ++$j;
    }
    $animal->add_distance(0);
    $map->clean;
    return $q == 1 ? $map->max_distance : return $map->internal_tiles;
}
