# This module builds the Perl distribution from the templates. This
# module is not installed

package ImagePNGBuild;
use warnings;
use strict;
use autodie;
use Carp;
use FindBin '$Bin';
use File::Slurper 'read_text';
use List::Util 'uniq';

my $base = "$Bin/..";
my $tmpl_dir = "$base/tmpl";

sub read_config
{
    my $config_file = "$tmpl_dir/config";
    my %config;
    open my $config_fh, "<", $config_file;
    while (<$config_fh>) {
        if (/^(\w+):\s*(.*?)\s*$/) {
            $config{$1} = $2;
        }
	else {
            die "Bad line '$_' in $config_file";
        }
    }
    close $config_fh;
    $config{out_dir} = "$config{base}";
    $config{base_hyphen} = $config{base};
    $config{base_hyphen} =~ s/::/-/g;
    $config{base_underscore} = $config{base};
    $config{base_underscore} =~ s/:/_/g;
    $config{out_dir} =~ s/::/\//g;
#    print "Output directory is $config{out_dir}.\n";
    $config{main_module_out} = "lib/$config{out_dir}.pm";
    $config{const_out} = "lib/Image/PNG/Const.pm";
    $config{main_pod_out} = "lib/$config{out_dir}.pod";
    $config{base_slash} = "$config{out_dir}.pm";
    $config{main_module} = $config{base_slash};
    $config{main_module} =~ s!.*/!!;
    $config{base_dir} = $base;
    $config{tmpl_dir} = $tmpl_dir;
    return %config;
}

# Make a list of the functions in the module by reading the XS file
# and return them as a list reference.

sub get_functions
{
    my ($config_ref) = @_;
    if (! $config_ref) {
        croak "No configuration supplied";
    }
    my $file = "$config_ref->{tmpl_dir}/Libpng.xs.tmpl";
    my $text = read_text ($file);
    my @functions;
    while ($text =~ /^\S+.*?perl_png_(\w+)\s*\(/gsm) {
	my $f = $1;
	if ($f !~ /DESTROY/) {
	    push @functions, $1;
	}
    }
    @functions = uniq (@functions);
    return \@functions;
}

# Extract a list of diagnostics for the Libpng part of the module for
# use in the documentation.

sub libpng_diagnostics
{
    my ($config_ref, $verbose) = @_;
    my @diagnostics;
    my $text = `cat tmpl/perl-libpng.c.tmpl`;
    while ($text =~ m@
                         # Comment describing the diagnostic
                         (?:/\*\s*((?:[^\*]|\*[^/])+?)\s*\*/)?[\s|\\]+
                         # Diagnostic call
                         (warn|croak)\s*
                         \(
			 \s*
                         # Text message
                         (
			     (?:"[^"]*"[\s\\]*)+
			 )
                     @xgsm) {
        my $comment = $1;
        my $type = $2;
        my $message = $3;
        $message =~ s/"[\s\\]+"//g;
        $message =~ s/^"(.*?)(?:\\n)?"$/$1/;
        if ($comment) {
            $comment =~ s/[\s|\\]+/ /g;
        }
        if ($verbose) {
            if ($comment) {
                print "$comment\n";
            }
            else {
                print "No comment.\n";
            }
            print "$message\n";
        }
        push @diagnostics, {
            message => $message,
            type => $type,
            comment => $comment,
        };
    }
    if (! wantarray) {
        die;
    }
    return @diagnostics;
}

1;
