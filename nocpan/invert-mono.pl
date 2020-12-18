#!/home/ben/software/install/bin/perl
use warnings;
use strict;
use utf8;
use FindBin '$Bin';
use Image::PNG::Libpng ':all';
use Image::PNG::Const ':all';
my $png = read_png_file ('chess-font-fixed.png', transforms => PNG_TRANSFORM_INVERT_MONO);
my $wpng = copy_png ($png);
$wpng->write_file ('winning.png');
