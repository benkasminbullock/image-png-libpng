# This tests setting text in a PNG image.

use warnings;
use strict;
use utf8;
use Test::More;
my $builder = Test::More->builder;
binmode $builder->output,         ":utf8";
binmode $builder->failure_output, ":utf8";
binmode $builder->todo_output,    ":utf8";
binmode STDOUT, ":encoding(utf8)";
binmode STDERR, ":encoding(utf8)";

use FindBin '$Bin';

use Image::PNG::Const ':all';
use Image::PNG::Libpng ':all';

plan skip_all => "tEXt is not supported" unless libpng_supports ('iTXt');

my $file = "$Bin/set-text.png";
if (-f $file) {
    unlink $file;
}
my $png = create_write_struct ();
$png->set_verbosity (1);
$png->set_IHDR ({width => 1, height => 1, bit_depth => 8, color_type => PNG_COLOR_TYPE_GRAY});
$png->set_rows (['X']);
my $text = [
	{key => 'baba', lang => 'binkers', lang_key => 'ばば', text => 'ぶぶ',
	 compression => PNG_ITXT_COMPRESSION_NONE},
	{key => 'bobo', lang => 'bonkers', lang_key => 'ぼぼ', text => 'びび',
	 compression => PNG_ITXT_COMPRESSION_zTXt},
    ];
$png->set_text ($text);
$png->write_png_file ($file);
my $check = read_png_file ($file);
my $check_text = $check->get_text ();
for my $i (0..$#$text) {
    my $x = $text->[$i];
    my $y = $check_text->[$i];
    for my $k (keys %$x) {
	ok (defined $y->{$k}, "Got key $k back for text chunk $i");
	is ($y->{$k}, $x->{$k}, "Value for $k is the same for text chunk $i");
    }
}



if (-f $file) {
    unlink $file;
}
my $longfile = "$Bin/long-set-text.png";
my $longtext = [
    {lang => 'verylonglanguageindeed', key => 'bonkers', lang_key => 'binkers',
     text => 'plonkers', compression => PNG_ITXT_COMPRESSION_NONE},
];
round_trip ($longfile, $longtext);

done_testing ();
exit;

sub rmfile
{
    my ($file) = @_;
    if (-f $file) {
	unlink $file or warn "Can't unlink $file: $!";
    }
}

sub round_trip
{
    my ($longfile, $longtext) = @_;
    rmfile ($longfile);
    my $longpng = create_write_struct ();
    $longpng->set_IHDR ({width => 1, height => 1, bit_depth => 8,
			 color_type => PNG_COLOR_TYPE_GRAY});
    $longpng->set_rows (['X']);
    $longpng->set_text ($longtext);
    $longpng->write_png_file ($longfile);
    my $longcheck = read_png_file ($longfile);
    rmfile ($longfile);
    my $longcheck_text = $longcheck->get_text ();
    for my $i (0..$#$longtext) {
	my $x = $longtext->[$i];
	my $y = $longcheck_text->[$i];
	for my $k (keys %$x) {
	    ok (defined $y->{$k}, "Got key $k back for text chunk $i");
	    is ($y->{$k}, $x->{$k},
		"Value for $k is the same for text chunk $i");
	}
    }
}
