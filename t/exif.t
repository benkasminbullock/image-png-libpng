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

# This file doesn't contain an exif chunk

my $png = read_png_file ("$Bin/test.png");
my $noexif = $png->get_eXIf ();
ok (! defined $noexif, "Got undefined from file with no exif");

# Copy the file, add an exif chunk

my $wpng = copy_png ($png);
my $exif = "MM random garbage";
$wpng->set_eXIf ($exif);

# Now write the file out, then read it back in.

my $file = "$Bin/exif.png";
rmfile ();
$wpng->write_png_file ($file);
my $rpng = read_png_file ($file);
rmfile ();

# Check the exif chunk of the read-in file.

my $roundtrip = $rpng->get_eXIf ();
is ($roundtrip, $exif, "Round trip of eXIf chunk");
done_testing ();
exit;

sub rmfile
{
    unlink $file;
}
