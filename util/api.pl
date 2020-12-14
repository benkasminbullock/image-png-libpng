#!/home/ben/software/install/bin/perl

# This script extracts the functions labelled with PNGAPI from the
# source code of libpng.

use warnings;
use strict;
use utf8;
use FindBin '$Bin';
use File::Slurper qw!read_text write_text!;
use Convert::Moji 'make_regex';
use Table::Readable 'read_table';

use lib "$Bin";
use LibpngUtil ':all';

my $dir = libpngdir ();
my @files = <$dir/*.[ch]>;
my @api;
my $api_re = qr!PNGAPI\s*\n(\w+)(\s*)\(.*?\)!sm;
my $example = <<EOF;
void PNGAPI
png_set_chunk_cache_max (png_structrp png_ptr, png_uint_32 user_chunk_cache_max)
{
   if (png_ptr != NULL)
      png_ptr->user_chunk_cache_max = user_chunk_cache_max;
}
EOF
for my $file (@files) {
    my $text = read_text ($file);
    while ($text =~ /$api_re/g) {
	push @api, $1;
	# if (length ($2) > 0) {
	#     print "Extra space in $1\n";
	# }
    }
}
my $alltext = alltext ();
@api = sort @api;
my $re = make_regex (@api);
my %api;
while ($alltext =~ /($re)/g) {
    $api{$1} = 1;
}
my @known = read_table ("$Bin/../build/unsupported-table.txt");
for (@known) {
    my $item = $_->{item};
    if ($api{$item}) {
	warn "Function $item appears to be in source code.\n";
    }
    $api{$item} = 1;
}

for (@api) {
    if (! $api{$_}) {
	print "item: $_\n%%desc:\n%%\ncat: unimplemented\n\n";
    }
}

