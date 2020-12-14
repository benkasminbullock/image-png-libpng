use warnings;
use strict;
use utf8;
use FindBin '$Bin';
use Test::More;
my $builder = Test::More->builder;
binmode $builder->output,         ":utf8";
binmode $builder->failure_output, ":utf8";
binmode $builder->todo_output,    ":utf8";
binmode STDOUT, ":encoding(utf8)";
binmode STDERR, ":encoding(utf8)";
use Image::PNG::Libpng ':all';
use Image::PNG::Const ':all';

BEGIN: {
    use lib "$Bin";
    use IPNGLT;
};

my $png = read_png_file ("$Bin/tantei-san.png",
			 transforms => PNG_TRANSFORM_EXPAND);
my $ihdr = $png->get_IHDR ();
is ($ihdr->{color_type}, PNG_COLOR_TYPE_RGB);
is ($ihdr->{bit_depth}, 8);

my $png2 = read_png_file ("$Bin/tantei-san.png",
			 transforms => PNG_TRANSFORM_EXPAND |
			 PNG_TRANSFORM_EXPAND_16);
my $ihdr2 = $png2->get_IHDR ();
is ($ihdr2->{color_type}, PNG_COLOR_TYPE_RGB);
is ($ihdr2->{bit_depth}, 16);
# my $wpng2 = copy_png ($png2);
# $wpng2->set_scale_16 ();
# my $rpng2 = round_trip ($wpng2, "$Bin/tantei-rgb.png");
# my $rihdr2 = $rpng2->get_IHDR ();
# is ($rihdr2->{color_type}, PNG_COLOR_TYPE_RGB);
# is ($rihdr2->{bit_depth}, 8);

done_testing ();
