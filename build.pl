#!/home/ben/software/install/bin/perl
use warnings;
use strict;
use Perl::Build;
use FindBin '$Bin';
perl_build (
    makefile => 'makeitfile',
    pre => "/home/ben/projects/check4libpng/copy2inc.pl $Bin/inc",
);
