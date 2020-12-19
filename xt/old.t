use warnings;
use strict;
use utf8;
use FindBin '$Bin';
use Test::More;
use Deploy 'do_system';
use lib "$Bin/../build";
use LibpngInfo 'oldversions';

my $builder = Test::More->builder;
binmode $builder->output,         ":utf8";
binmode $builder->failure_output, ":utf8";
binmode $builder->todo_output,    ":utf8";
binmode STDOUT, ":encoding(utf8)";
binmode STDERR, ":encoding(utf8)";
my $top = '/home/ben/projects/image-png-libpng';
my $old = "$top/util/old";
#my $verbose = 1;
my $verbose;
my $devnull = '';
if (! $verbose) {
    # To make these tests run reasonably quietly, because this script
    # repeatedly calls "make" followed by "prove", 2>&1 must be added,
    # because both "make" and "prove" print a lot of non-error
    # messages onto stderr.
    $devnull = '> /dev/null 2>&1';
}
my @versions = oldversions ();
for my $version (@versions) {
    eval {
	do_system ("$old -v $version $devnull", $verbose);
    };
    ok (! $@, "Tested OK against old version, $version");
    do_system ("cd $top;./build.pl -c $devnull", $verbose);
}
# Rebuild because we deleted everything.
do_system ("./build.pl -d");
done_testing ();
