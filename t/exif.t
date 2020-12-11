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

if (! libpng_supports ('eXIf')) {
    plan skip_all => "This libpng doesn't support the eXIf chunk"
}
my $png = read_png_file ("$Bin/test.png");
my $noexif = $png->get_eXIf ();
ok (! defined $noexif, "Got undefined from file with no exif");
my $wpng = copy_png ($png);
my $exif = "MM random garbage";
$wpng->set_eXIf ($exif);
my $file = "$Bin/exif.png";
rmfile ();
$wpng->write_png_file ($file);
my $rpng = read_png_file ($file);
#rmfile ();
my $roundtrip = $rpng->get_eXIf ();
is ($roundtrip, $exif, "Round trip of eXIf chunk");
ok(1);
done_testing ();
exit;
sub rmfile
{
    unlink $file;
}
