use warnings;
use strict;
use Test::More;
use FindBin;
use Image::PNG::Libpng ':all';
use Data::Dumper;

my @files = qw/
ps1n0g08
ps1n2c16
ps2n0g08
ps2n2c16
/;

for my $file (@files) {
    my $ffile = "$FindBin::Bin/libpng/$file.png";
    my $png = read_png_file ($ffile);
    ok ($png);
#    print Dumper ($png);
#    $png->set_verbosity (1);
    my $splt = $png->get_sPLT ();
    ok ($splt);
#    print Dumper ($splt);
}
done_testing ();
