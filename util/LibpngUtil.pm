package LibpngUtil;
require Exporter;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw/
		       alltext
		       libpngdir
		   /;
our %EXPORT_TAGS = (all => \@EXPORT_OK);
use warnings;
use strict;
use utf8;
use Carp;
use JSON::Parse 'json_file_to_perl';
use File::Slurper qw!read_text write_text!;

my $config = json_file_to_perl ("config.txt");

sub libpngdir
{
    my $dir = $config->{dir};
    if (! -d $dir) {
	die "No directory in config.txt";
    }
    return $dir;
}

sub alltext
{
    my $dir = $config->{perldir};
    my @files = qw!Libpng.xs.tmpl perl-libpng.c.tmpl!;
    my $alltext = '';
    for my $file (@files) {
	$alltext .= read_text ("$dir/$file");
    }
    return $alltext;
}

1;
