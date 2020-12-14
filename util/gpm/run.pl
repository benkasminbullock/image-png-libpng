#!/home/ben/software/install/bin/perl
use warnings;
use strict;
use utf8;
use FindBin '$Bin';
my $dir = "$Bin/../../t/libpng";
my @files = <$dir/*.png>;
@files = grep {!m!/x!} @files;
my $out = `./gpm @files`;
$out =~ s!$dir/!!g;
print $out;

