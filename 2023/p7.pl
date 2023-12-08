use v5.20;
use autodie;
use Data::Dumper;

package Card1 {
    use Moo;
    has bid => (is => 'ro');
    has hand => (is => 'ro');
    has comparable_hand => (is => 'lazy');
    has type => (is => 'lazy');

    sub calc_type {
        my ($self, $hand) = @_;
        my $c = join '', sort split '', $hand;
        return 7 if $c =~ /(.)\1\1\1\1/; # 5 of a kind
        return 6 if $c =~ /(.)\1\1\1/; # 4 oak
        return 5 if $c =~ /(.)\1\1(.)\2/ || $c =~ /(.)\1(.)\2\2/; # full house
        return 4 if $c =~ /(.)\1\1/; # 3 oak
        return 3 if $c =~ /(.)\1.?(.)\2/; # 2 pair
        return 2 if $c =~ /(.)\1/; # pair
        return 1;
    }
    sub _build_type {
        my $self = shift;
        return $self->calc_type($self->hand);
    }
    sub _build_comparable_hand {
        my $self = shift;
        return $self->hand =~ tr/23456789TJQKA/ABCDEFGHIJKLM/r;
    }
    sub compare {
        my ($self, $card) = @_;
        return $self->type <=> $card->type || $self->comparable_hand cmp $card->comparable_hand;
    }
}

package Card2 {
    use Moo;
    extends 'Card1';
    sub max { $_[0] < $_[1] ? $_[1] : $_[0] }
    sub _build_type {
        my $self = shift;
        my $type = 1;

        my %cards = map { $_ => 1 } split '', $self->hand;
        delete $cards{J};

        my $count_j = $self->hand =~ tr/J/J/;
        return 7 if $count_j == 5;

        my @perms = keys %cards;
        for my $i (2..$count_j) {
            @perms = map { my $p = $_; map { "$p$_" } keys %cards } @perms;
        }
        for my $perm (@perms) {
            my @letter = split '', $perm;
            my $h = $self->hand;
            $h =~ s/J/$_/ for @letter;
            $type = max($type, $self->calc_type($h));
        }
        return $type;
    }
    sub _build_comparable_hand {
        my $self = shift;
        return $self->hand =~ tr/J23456789TQKA/ABCDEFGHIJKLM/r;
    }
}

open my $f, "< p7-0.txt";
my ($exp1, $exp2, @lines0a);
($exp1, $exp2, @lines0a) = <$f>;
chomp ($exp1, $exp2);
close $f;
my $r = p(1,\@lines0a);
die "1 got: $r, expected: $exp1\n" if $r != $exp1;
$r = p(2,\@lines0a);
#die "2 got: $r, expected: $exp2\n" if $r != $exp2;
open $f, "< p7-1.txt";
my (@lines) = <$f>;
close $f;
$r = p(1,\@lines);
say $r;
$r = p(2,\@lines);
say $r;

sub p {
    my ($q, $l) = @_;

    my @cards;
    for my $line (@$l) {
        chomp $line;
        my @c = split ' ', $line;
        push @cards, "Card$q"->new(hand => $c[0], bid => $c[1]);
    }
    my @sorted = sort { $a->compare($b) } @cards;
    my $res = 0;
    for my $i (0..$#sorted) {
        $res += $sorted[$i]->bid * ($i + 1);
    }
    $res;
}
