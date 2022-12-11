use v5.20;
use autodie;

my $prime_ring = 2*3*5*7*11*13*17*19*23;
my @monkeys;

package Monkey {
    use Moo;

    has items => ( is => 'rw', );
    has operation => ( is => 'ro' );
    has test => ( is => 'ro' );
    has true_to => ( is => 'ro' );
    has false_to => ( is => 'ro' );
    has divide => ( is => 'ro' );
    has inspections => ( is => 'rw' );

    sub do_op {
        my ($self, $item) = @_;
        my $op = $self->operation;
        if ($op eq 'old * old') {
            return $item * $item;
        }
        elsif ($op =~ /old \+ (\d+)/){
            return $item + $1;
        }
        elsif ($op =~ /old \* (\d+)/){
            return $item * $1;
        }
        die $op;
    }
    sub do_test {
        my ($self, $item) = @_;
        $self->inspections( $self->inspections + 1 );
        if ($self->test =~ /^divisible by (\d+)$/) {
            return $item % $1 == 0;
        }
        die;
    }
    sub process_items {
        my $self = shift;
        for my $item (@{$self->items}) {
            my $pre = $item;
            $item = $self->do_op($item);
            if (!defined $item) {
                die "$pre -> ". $self->operation . " go boom";
            }
            $item = int($item / 3) if $self->divide;
            $item = $item % $prime_ring;
            $monkeys[ $self->do_test($item) ? $self->true_to : $self->false_to ]->get_item($item);
        }
        $self->items([]);
    }
    sub get_item {
        my ($self, $item) = @_;
        push @{$self->items}, $item;
    }
}

open my $f, "< p11-0.txt";
my ($exp1, $exp2, @lines0) = <$f>;
chomp ($exp1);
chomp ($exp2);
close $f;

my $r = p1(\@lines0);
say "1 got: $r, expected: $exp1" if $r ne $exp1;
$r =  p2(\@lines0);
say "2 got: $r, expected: $exp2" if $r ne $exp2;
open $f, "< p11-1.txt";
my (@lines) = <$f>;
close $f;

say p1(\@lines);
say p2(\@lines);

sub init {
    my ($l, $divide) = @_;
    @monkeys = ();
    my ($idx, $items, $operation, $test, $true_to, $false_to);
    for my $line (@$l) {
        $idx = $1                    if $line =~ /^\s*Monkey (\d+)/;
        $items = [ split /, */, $1 ] if $line =~ /^\s*Starting items: (.*)/;
        $operation = $1              if $line =~ /^\s*Operation: new = (.*)/;
        $test = $1                   if $line =~ /^\s*Test: (.*)/;
        $true_to = $1                if $line =~ /^\s*If true: throw to monkey (\d+)/;
        if ($line =~ /^\s*If false: throw to monkey (\d+)/) {
            $false_to = $1;
            $monkeys[$idx] = Monkey->new(
                items       => [],
                operation   => $operation,
                test        => $test,
                true_to     => $true_to,
                false_to    => $false_to,
                inspections => 0,
                divide      => $divide,
            );
            for my $item (@$items) {
                $monkeys[$idx]->get_item($item);
            }
        }
    }
}

sub p1 {
    my ($l) = @_;
    init($l, 1);
    for (1..20) {
        for my $monkey (@monkeys) {
            $monkey->process_items;
        }
    }
    my @inspections = sort { $b <=> $a } map { $_->inspections } @monkeys;
    return $inspections[0] * $inspections[1];
}

sub p2 {
    my ($l) = @_;
    init($l, 0);
    for (1..10000) {
        for my $monkey (@monkeys) {
            $monkey->process_items;
        }
    }
    my @inspections = sort { $b <=> $a } map { $_->inspections } @monkeys;
    return $inspections[0] * $inspections[1];
}
