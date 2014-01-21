# Test "get_internals"

use warnings;
use strict;
use Test::More;
use FindBin;
use Image::PNG::Libpng ':all';
my $png = read_png_file ("$FindBin::Bin/tantei-san.png");
my ($x, $y) = get_internals ($png);
is (ref $x, 'Image::PNG::Libpng::png_struct');
is (ref $y, 'Image::PNG::Libpng::png_info');
done_testing ();
exit;

