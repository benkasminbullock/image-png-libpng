package Build;
require Exporter;
@ISA = qw(Exporter);
@EXPORT_OK = qw//;
use warnings;
use strict;

my $base = "$FindBin::Bin/..";
my $tmpl_dir = "$base/tmpl";

sub read_config
{
    my $config_file = "$tmpl_dir/config";
    my %config;
    open my $config_fh, "<", $config_file;
    while (<$config_fh>) {
        if (/^(\w+):\s*(.*?)\s*$/) {
            $config{$1} = $2;
        } else {
            die "Bad line '$_' in $config_file";
        }
    }
    close $config_fh;
    $config{out_dir} = "$config{base}";
    $config{base_underscore} = $config{base};
    $config{base_underscore} =~ s/:/_/g;
    $config{out_dir} =~ s/::/\//g;
    print "Output directory is $config{out_dir}.\n";
    $config{submodule_dir} = "$base/lib/$config{out_dir}";
    $config{main_module_out} = "$base/lib/$config{out_dir}.pm";
    $config{base_slash} = "$config{out_dir}.pm";
    $config{main_module} = $config{base_slash};
    $config{main_module} =~ s!.*/!!;
    $config{base_dir} = $base;
    $config{tmpl_dir} = $tmpl_dir;
    return %config;
}

1;
