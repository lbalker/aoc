use v5.20;
use autodie;
use Data::Dumper;

open my $f, "< p6-0.txt";
my (@lines0) = <$f>;
close $f;
for my $i (0..$#lines0) {
    my ($input, $exp1, $exp2) = split ' ', $lines0[$i];
    my $r = p1($input);
    say "1 line $i got: $r, expected: $exp1" if $r ne $exp1;
    $r =  p2($input);
    say "2 line $i got: $r, expected: $exp2" if $r ne $exp2;
}

open $f, "< p6-1.txt";
my $input = <$f>;
close $f;

say p1($input);
say p2($input);

sub gen {
    my $i = shift;
    my (@i, $r);
    for (2..$i) {
        push @i, $_;
        my $n = join '|', map { '\\' . $_ } @i;
        $r .= "((?!$n).)";
    }
    qr/^(.*?)(.)$r/;
}

sub p1 {
    my ($input) = @_;
    return length($1) + 4 if $input =~ gen(4);
    die;
}

sub p2 {
    my ($input) = @_;
    return length($1) + 14 if $input =~ gen(14);
    die;
}

__DATA__
The generated regex is practically a christmas tree!

                     ^
                   (.*?)
                    (.)
                 ((?!\2).)
                ((?!\2|\3).)
               ((?!\2|\3|\4).)
              ((?!\2|\3|\4|\5).)
             ((?!\2|\3|\4|\5|\6).)
            ((?!\2|\3|\4|\5|\6|\7).)
           ((?!\2|\3|\4|\5|\6|\7|\8).)
          ((?!\2|\3|\4|\5|\6|\7|\8|\9).)
        ((?!\2|\3|\4|\5|\6|\7|\8|\9|\10).)
       ((?!\2|\3|\4|\5|\6|\7|\8|\9|\10|\11).)
     ((?!\2|\3|\4|\5|\6|\7|\8|\9|\10|\11|\12).)
   ((?!\2|\3|\4|\5|\6|\7|\8|\9|\10|\11|\12|\13).)
 ((?!\2|\3|\4|\5|\6|\7|\8|\9|\10|\11|\12|\13|\14).)
