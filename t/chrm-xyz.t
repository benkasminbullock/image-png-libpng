use warnings;
use strict;
use Test::More;
use Image::PNG::Libpng ':all';
use FindBin '$Bin';

BEGIN: {
    use lib "$Bin";
    use IPNGLT;
};

chunk_ok ('cHRM');

my $wpng = fake_wpng ();
my %chrm;
for my $color (qw!red blue green!) {
    for my $dim (qw!x z!) {
	$chrm{"${color}_$dim"} = rand ();
    }
    # The y values need to sum to 1.
    $chrm{"${color}_y"} = 1/3.0;
}
$wpng->set_cHRM_XYZ (\%chrm);
my $rpng = round_trip ($wpng, "$Bin/chrm-xyz.png");
my $valid = $rpng->get_valid ();
ok ($valid->{'cHRM'}, "got a cHRM chunk");
my $rt = $rpng->get_cHRM_XYZ ();
my $eps = 0.01;
for my $k (keys %chrm) {
    cmp_ok (abs ($rt->{$k} - $chrm{$k}), '<', $eps,
	    "round trip of $k ($rt->{$k}, $chrm{$k}) of cHRM_XYZ");
}
done_testing ();
