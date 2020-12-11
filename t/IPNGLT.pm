package IPNGLT;
require Exporter;
our @ISA = qw(Exporter);
our @EXPORT = qw/skip_itxt skip_old/;
use warnings;
use strict;
use utf8;
use Test::More;
use Image::PNG::Libpng ':all';

sub skip_itxt
{
    if (! libpng_supports ('iTXt') ||
	! libpng_supports ('zTXt') ||
	! libpng_supports ('tEXt')) {
	plan skip_all => 'your libpng does not support iTXt/zTXt/tEXt',
    }
}

# The most recent faulty response is for libpng version 1.6.12.
# http://www.cpantesters.org/cpan/report/f7295c1a-6bf5-1014-a07d-70c0b928df0

# Skip testing of set-text.t and compress-level.t for versions older
# than these.

my $oldmajor = 0; # Reject 0.*
my $oldminor = 5; # Reject 1.[0-5]
my $oldpatch = 12; # Reject 1.6.[0-12]

sub skip_old
{
    my $libpngver = Image::PNG::Libpng::get_libpng_ver ();
    if ($libpngver !~ /^([0-9]+)\.([0-9]+)\.([0-9]+)/) {
	plan skip_all => "Incomprehensible libpng version $libpngver";
    }
    my ($major, $minor, $patch) = ($1, $2, $3);
    if ($major > 1 || $minor > 6) {
	# Get out of here, since the test for $minor or $patch will be
	# tripped by 1.7.1 or 2.1.3 or something.
	return;
    }
    if ($major <= $oldmajor) {
	plan skip_all =>
	"Skipping: libpng major version $libpngver <= $oldmajor";
	return;
    }
    if ($minor <= $oldminor) {
	plan skip_all =>
	"Skipping: libpng minor version $libpngver <= $oldminor";
	return;
    }

    if ($patch <= $oldpatch) {
	plan skip_all =>
	"Skipping: libpng patch $libpngver <= $oldpatch";
	return;
    }
}

1;
