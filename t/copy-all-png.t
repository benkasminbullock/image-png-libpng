use warnings;
use strict;
use Test::More;
use FindBin;
use lib '../blib/lib';
use lib '../blib/arch';
use Image::PNG::Libpng qw/read_png_file copy_png image_data_diff/;
my $dir = "$FindBin::Bin/../t/libpng";
my @files = <$dir/*.png>;

# Files beginning with an x are corrupted.
# http://www.schaik.com/pngsuite/#corrupted
@files = map {s!$dir/!!r} @files;
@files = grep !/^x/, @files;

for my $file (@files) {
    copytest ("$dir/$file");
}

done_testing ();

sub copytest
{
    my ($infile) = @_;
    my $copytest = "$FindBin::Bin/copy-png-test.png";
    my $png1 = read_png_file ($infile);
    my $png2 = $png1->copy_png ();
    $png2->write_file ($copytest);
    my $diff = image_data_diff ($copytest, $infile);
    my $tinfile = $infile;
    $tinfile =~ s!.*/!!;
    ok (! $diff, "$tinfile copied OK");
    if ($diff) {
	note ($diff);
    }
    if (-f $copytest) {
	unlink $copytest;
    }
}

