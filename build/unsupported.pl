#!/home/ben/software/install/bin/perl
use warnings;
use strict;
use utf8;
use FindBin '$Bin';
use File::Slurper qw!read_text write_text!;
my $in = read_text ("$Bin/unsupported.txt");
$in =~ s!=item (png_.*)\n\n(?:([A-Z\[](?:.|\n)*?)\n\n)?!item: $1\n\%\%desc:\n$2\n\%\%\n\n!g;
write_text ("$Bin/unsupported-table.txt", $in);
exit;

