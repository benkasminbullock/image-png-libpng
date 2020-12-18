#!/home/ben/software/install/bin/perl
use warnings;
use strict;
use utf8;
use FindBin '$Bin';
use Image::PNG::Libpng ':all';
my $file = "wave.png";
my $ncolors = 20;
my $palette = randompalette ($ncolors);
my $rpng = create_reader ($file);
$rpng->set_quantize ($palette, $ncolors, [], 1);
$rpng->read_png ();
print scalar (@$palette), "\n";
my $wpng = copy_png ($rpng);
$wpng->set_PLTE ($palette);
$wpng->write_png_file ('wave-quant.png');
exit;

sub points
{
    my ($png, $ncolors) = @_;
    my $rows = $png->get_rows ();
    my $h = $png->height ();
    my $w = $png->width ();
    my $ch = $png->get_channels ();
    my @p;
    for (0..$ncolors-1) {
	my $x = int (rand ($w));
	my $y = int (rand ($h));
	my $row = $rows->[$y];
	my @pix = split ('', substr ($row, $x*$ch, $ch));
	push @p, {
	    red => ord ($pix[0]),
	    green => ord ($pix[1]),
	    blue => ord ($pix[2]),
	};
    }
    return \@p;
}

sub randompalette
{
    my ($n) = @_;
    my @p;
    for (0..$n-1) {
	my %color;
	for my $c (qw!red green blue!) {
	    $color{$c} = int (rand (256))
	}
	push @p, \%color;
    }
    return \@p;
}
