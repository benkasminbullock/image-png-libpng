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

# these are levels in the PngSuite of filename and compression level used
my @levels = ( 0, 3, 6, 9 );

my $filesizes_changed = 0;

# read the example file
foreach my $src_level (@levels) {
    my $ffile = sprintf("%s/libpng/z%02dn2c08.png", $Bin, $src_level);
    my $src_size = -s $ffile;
    my $src_png = read_png_file ($ffile);
    ok ($src_png);

    foreach my $target_level (@levels) {
	my $dest_png = copy_png($src_png);
	$dest_png->set_compression_level($target_level);
	my $output = $dest_png->write_to_scalar();
	my $dest_size = length $output;
	if ($src_level == $target_level) {
	    ok( $src_size == $dest_size,
		"source $ffile (level: $src_level, $src_size bytes) equal to target (level: $target_level, $dest_size bytes)" );
	}
	elsif ($src_level < $target_level) {
	    ok( $src_size >= $dest_size,
		"source $ffile (level: $src_level, $src_size bytes) larger than target (level: $target_level, $dest_size bytes)" );
	    $filesizes_changed ++;
	}
	else {
	    ok( $src_size <= $dest_size,
		"source $ffile (level: $src_level, $src_size bytes) smaller than target (level: $target_level, $dest_size bytes)" );
	    $filesizes_changed ++;
	}
    }
}

ok($filesizes_changed > 0, "At least one file changed size because of compress_level");
done_testing ();
