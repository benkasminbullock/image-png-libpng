#!/home/ben/software/install/bin/perl
use warnings;
use strict;
use utf8;
use FindBin '$Bin';
use Image::PNG::Libpng ':all';
use Image::PNG::Const ':all';

my $png = create_reader ("/home/ben/life_before_the_pandemic.png");
$png->read_info ();
$png->set_rgb_to_gray ();
print "poo: ", $png->get_rgb_to_gray_status (), "\n";
$png->read_image ();
$png->read_end ();
my $wpng = $png->copy_png ();
my $ihdr = $wpng->get_IHDR ();
$ihdr->{color_type}  = PNG_COLOR_TYPE_GRAY_ALPHA;
$wpng->set_IHDR ($ihdr);
$wpng->write_png_file ("/home/ben/life-gray.png");
