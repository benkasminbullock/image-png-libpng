#!/home/ben/software/install/bin/perl

# This script is to check all the chunk getters and setters inside
# libpng as declared in png.h and make sure that all of them are
# included in Image::PNG::Libpng. As of the writing of this script,
# all 16 chunks are included.

use warnings;
use strict;
my $file = '/home/ben/software/libpng/install/libpng-1.6.8/include/png.h';
if (! -f $file) {
    die "No $file\n";
}
open my $in, "<", $file or die $!;
my %chunks;
while (<$in>) {
    if (/(png_[gs]et_([a-zA-Z]{4}))\b/) {
	my $fun = $1;
	my $chunk = $2;
	if ($chunk =~ /[A-Z]/) {
	    $chunks{$chunk} = 1;
	    print "$fun\n";
	}
    }
}
close $in or die $!;
print "there are ".scalar keys (%chunks)." Chunks\n";

