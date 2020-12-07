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

# these are mappings in the PngSuite of filename to compression level used
my %levels = (
    z00n2c08 => 0,
    z03n2c08 => 1,
    z06n2c08 => 2,
    z09n2c08 => 9
);

# read the example file
foreach my $file (keys %levels) {
    my $ffile = sprintf("%02s/libpng/%s.png", $Bin, $file);
    my $src_size = -s $ffile;
    my $src_png = read_png_file ($ffile);
    ok ($src_png);

    my $src_level = $levels{$file};
    foreach my $target_level (values %levels) {
	next if $src_level == $target_level;
	my $dest_png = copy_png($src_png);
	$dest_png->set_compression_level($target_level);
	my $output = $dest_png->write_to_scalar();
	my $dest_size = length $output;
	if ($src_level < $target_level) {
	    ok( $src_size >= $dest_size,
		"source $file (level: $src_level, $src_size bytes) larger than target (level: $target_level, $dest_size bytes)" );
	}
	else {
	    ok( $src_size <= $dest_size,
		"source $file (level: $src_level, $src_size bytes) smaller than target (level: $target_level, $dest_size bytes)" );
	}
    }
}
done_testing ();
