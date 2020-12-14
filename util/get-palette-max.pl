#!/home/ben/software/install/bin/perl
use warnings;
use strict;
use utf8;
use FindBin '$Bin';
use Image::PNG::Libpng '0.52_01', ':all';
my @files = <$Bin/../t/libpng/*.png>;
for my $file (@files) {
    my $tfile = $file;
    $tfile =~ s!.*/!!;
    if ($tfile =~ /^x/) {
	next;
    }
    my $png = read_png_file ($file);
    my $valid = $png->get_valid ();
    my $copy = copy_png ($png);
    my $copyfile = "$Bin/guff.png";
    $copy->write_png_file ($copyfile);
    unlink ($copyfile);
    if ($valid->{PLTE}) {
	print $tfile, " ", $png->get_palette_max ()," ", $copy->get_palette_max (), " ";
	my $plte = $png->get_PLTE ();
	print scalar (@$plte), "\n";
    }
}

