#!/home/ben/software/install/bin/perl
use warnings;
use strict;
use utf8;
use FindBin '$Bin';
use Image::PNG::Libpng ':all';
use Image::PNG::Const ':all';
my $file = "$Bin/../lib/Image/PNG/Libpng.pod";
die unless -f $file;
my $size = -s $file;
my $ct = PNG_COLOR_TYPE_GRAY;
my $channels = color_type_channels ($ct);
my $pixels = $size/$channels;
my $width = int (sqrt ($pixels));
my $height = $pixels / $width;
if ($height != int ($height)) {
    $height = int($height) + 1;
}
my $header = {
    height => $height,
    width => $width,
    bit_depth => 8,
    color_type => $ct,
};
my $wpng = create_writer ("steganography.png");
$wpng->set_IHDR ($header);
my @rows;
open my $in, "<", $file or die $!;
my $bytes = $width*$channels;
for (0..$height-1) {
    my $r = read ($in, $rows[$_], $bytes);
    if ($r < $width) {
	my $pack = pack ("C", 0) x ($bytes - $r);
	$rows[$_] .= $pack;
	if ($_ != $height - 1) {
	    die "Short read: $!";
	}
	last;
    }
}
$wpng->set_rows (\@rows);
$wpng->write_png ();
