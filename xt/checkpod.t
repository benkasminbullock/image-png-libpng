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
use Perl::Build::Pod ':all';
use File::Slurper 'read_text';
for my $filepath (
    "$Bin/../lib/Image/PNG/Libpng.pod",
    "$Bin/../lib/Image/PNG/Const.pm",
) {
    my $errors = pod_checker ($filepath);
    ok (@$errors == 0, "$filepath - No errors");
    ok (pod_encoding_ok ($filepath), "$filepath - Pod encoding ok");
}
use Perl::Build::Pod ':all';
for my $filepath (
    "$Bin/../lib/Image/PNG/Libpng.pod",
) {
    ok (pod_no_cut ($filepath), "$filepath - No =cut in POD");
}

my $pod = "$Bin/../lib/Image/PNG/Libpng.pod";
my $text = read_text ($pod);
unlike ($text, qr!http://mikan!, "no local images in pod");

done_testing ();
