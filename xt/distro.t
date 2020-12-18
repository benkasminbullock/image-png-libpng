use warnings;
use strict;
use Test::More;
use FindBin '$Bin';

# # Check that OPTIMIZE is not defined in Makefile.PL.

# my $file = "$Bin/../Makefile.PL";
# open my $in, "<", $file or die $!;
# while (<$in>) {
#     if (/-Wall/) {
# 	like ($_, qr/^\s*#/, "Commented out -Wall in Makefile.PL");
#     }
# }
# close $in or die $!;

# Check that MESSAGE is defined to a blank in perl-libpng.c

my $file2 = "$Bin/../perl-libpng.c";
open my $in2, "<", $file2 or die $!;
my $isundef = 0;
while (<$in2>) {
    if (/^#undef PERL_PNG_MESSAGES/) {
	$isundef = 1;
	next;
    }
    if ($isundef && /PERL_PNG_MESSAGES/) {
	if (! /#ifdef\s+PERL_PNG_MESSAGES/) {
	    die "PERL_PNG_MESSAGES altered: $_";
	}
	last;
    }
}
close $in2 or die $!;

ok ($isundef, "PERL_PNG_MESSAGES is undefined.\n");

done_testing ();
