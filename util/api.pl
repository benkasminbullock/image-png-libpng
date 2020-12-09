#!/home/ben/software/install/bin/perl

# This script extracts the functions labelled with PNGAPI from the
# source code of libpng.

use warnings;
use strict;
use utf8;
use FindBin '$Bin';
use File::Slurper qw!read_text write_text!;
use lib "$Bin";
use LibpngUtil ':all';
use Convert::Moji 'make_regex';

my $dir = libpngdir ();
my @files = <$dir/*.[ch]>;
my @api;
for my $file (@files) {
    my $text = read_text ($file);
    while ($text =~ /PNGAPI\s*\n(\w+)\(.*?\)/gsm) {
	push @api, $1;
    }
}
my $alltext = alltext ();
@api = sort @api;
my $re = make_regex (@api);
my %api;
while ($alltext =~ /($re)/g) {
    $api{$1} = 1;
}
for (@api) {
    if (! $api{$_}) {
	print "$_\n";
    }
}

