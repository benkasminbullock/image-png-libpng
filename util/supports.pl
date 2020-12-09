#!/home/ben/software/install/bin/perl
use warnings;
use strict;
use utf8;
use FindBin '$Bin';
use File::Slurper qw!read_text write_text!;

use lib "$Bin";
use LibpngUtil ':all';
my $dir = libpngdir ();
my @files = <$dir/*.[ch]>;
my %supports;
for my $file (@files) {
    my $text = read_text ($file);
    while ($text =~ m!PNG_(\w+)_SUPPORTED!g) {
	$supports{$1}++;
    }
}
for my $k (sort keys %supports) {
    print "$k\n";
}
