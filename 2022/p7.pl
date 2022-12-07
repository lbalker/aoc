use v5.20;
use autodie;
use Data::Dumper;

open my $f, "< p7-0.txt";
my ($exp1, $exp2, @lines0) = <$f>;
chomp ($exp1, $exp2);
close $f;
my $r = p1(\@lines0);
say "1 got: $r, expected: $exp1" if $r ne $exp1;
$r =  p2(\@lines0);
say "2 got: $r, expected: $exp2" if $r ne $exp2;

open $f, "< p7-1.txt";
my (@lines) = <$f>;
close $f;

say p1(\@lines);
say p2(\@lines);

sub sizeup {
    my $dir = shift;
    return $dir unless ref $dir;
    my $s = 0;
    foreach my $f (keys %$dir) {
        next unless $f =~ /[a-z]/; # ignore special dirs
        $s += sizeup($dir->{$f});
    }
    $dir->{_} = $s;
    $s;
}
sub dirs {
    my $dir = shift;
    my @dirs = ($dir);
    foreach my $f (keys %$dir) {
        next unless $f =~ /[a-z]/;
        next unless ref $dir->{$f};
        push @dirs, dirs($dir->{$f});
    }
    @dirs;
}
sub cmd {
    my ($l) = @_;
    my $top = {};
    $top->{"/"} = $top;
    $top->{".."} = $top;
    my $cwd = $top;

    for my $line (@$l) {
        if ($line =~ /^\$ cd (\S+)/) {
            $cwd = $cwd->{$1};
            next;
        }
        elsif ($line =~ /^dir (\S+)/) {
            $cwd->{$1} = { "/" => $top, ".." => $cwd };
        }
        elsif ($line =~ /^(\d+) (\S+)/) {
            $cwd->{$2} = $1;
        }
    }
    sizeup($top);
    $top;
}

sub p1 {
    my ($l) = @_;
    my $root = cmd($l);
    my $sum = 0;
    for my $dir (sort { $a->{_} <=> $b->{_} } dirs($root)) {
        $sum += $dir->{_} if $dir->{_} < 100_000;
    }
    $sum;
}

sub p2 {
    my ($l) = @_;
    my $root = cmd($l);
    my $total = 70_000_000;
    my $free = $total - $root->{_};
    my $need = 30_000_000;

    for my $dir (sort { $a->{_} <=> $b->{_} } dirs($root)) {
        return $dir->{_} if $free + $dir->{_} > $need;
    }
    die;
}
