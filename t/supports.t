use warnings;
use strict;
use Test::More;
use Image::PNG::Libpng 'libpng_supports';

my @values = (qw/
sCAL
tEXt
zTXt
iTXt
/);

for my $value (@values) {
    my $supported = libpng_supports ($value);
    ok ($supported == 0 || $supported == 1,
	"$value is known to Image::PNG::Libpng");
}

done_testing ();
