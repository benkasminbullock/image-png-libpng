#!/home/ben/software/install/bin/perl

# This turns the template files into their distribution-ready forms.

use warnings;
use strict;
use Template;
use Perl::Build 'get_commit';
use Perl::Build::Pod ':all';
BEGIN {
    use FindBin '$Bin';
    use lib "$Bin";
    use ImagePNGBuild;
    use LibpngInfo 'template_vars', '@chunks';
};
use autodie;
use Getopt::Long;

#my $verbose = 1;
my $verbose;

# Read the configuration file "tmpl/config".

my %config = ImagePNGBuild::read_config ();

# Start the template up

my $tt = Template->new (
    ABSOLUTE => 1,
    INCLUDE_PATH => [
	$config{tmpl_dir},
	"$Bin/../examples",
	pbtmpl (),
    ],
    FILTERS => {
        xtidy => [
            \& xtidy,
            0,
        ],
    },
    STRICT => 1,
);

# The output files from this script.

my @files = qw/
                  Libpng.pm
                  Libpng.pod
                  Libpng.t
                  Libpng.xs
                  Makefile.PL
                  PLTE.t
                  perl-libpng.c
                  typemap
              /;

# This holds the variables passed to $tt.

my %vars;

my @libpng_diagnostics = ImagePNGBuild::libpng_diagnostics (\%config);
$vars{config} = \%config;

# Extract the git commit from the log, via Perl::Build.

my %pbv = (base => $Bin);
my $commit = get_commit (%pbv);
$vars{commit} = $commit;

my $functions = ImagePNGBuild::get_functions (\%config);
for my $chunk (@chunks) {
    if ($chunk->{auto_type}) {
        my $name = $chunk->{name};
        push @$functions, ("get_$name", "set_$name");
    }
}
$vars{functions} = $functions;
$vars{self} = $0;
$vars{date} = scalar gmtime ();
$vars{libpng_diagnostics} = \@libpng_diagnostics;

# Get lots of stuff about libpng from the module LibpngInfo in the
# same directory as this script, used to build documentation etc.

template_vars (\%vars);

# These files go in the top directory

my %top_dir = (
    'Makefile.PL' => 1,
    'Libpng.xs' => 1,
    'typemap' => 1,
    'perl-libpng.c' => 1,
);

my @outputs;

for my $file (@files) {
    my $template = "$file.tmpl";
    my $output;
    if ($top_dir{$file}) {
        $output = $file;
    }
    elsif ($file eq 'Libpng.pm') {
        $output = $config{main_module_out};
    }
    elsif ($file eq 'Libpng.pod') {
        $output = $config{main_pod_out};
    }
    elsif ($file =~ /.t$/) {
        $output = "t/$file";
    }
    else {
        $output = "$config{submodule_dir}/$file";
    }
    $output = "$Bin/../$output";
    push @outputs, $output;
    if ($verbose) {
	print "Processing $template into $output.\n";
    }
    $vars{input} = $template;
    $vars{output} = $output;
    if (-f $output) {
	if ($verbose) {
	    print "Overwriting existing $output.\n";
	}
        chmod 0644, $output;
    }
    # Add line numbers to C file.
    if ($template eq 'perl-libpng.c.tmpl') {
	my $text = '';
	open my $in, "<:encoding(utf8)", "$config{tmpl_dir}/$template"
	    or die $!;
	while (<$in>) {

# This is better but causes errors on SunOS/Solaris compilers:
# http://www.cpantesters.org/cpan/report/f25ae7b0-94c3-11e3-ae04-8631d666d1b8

#	    s/^(#line)$/sprintf "$1 %d \"tmpl\/%s\"", $. + 1, $template/e; 

	    s/^(#line)$/sprintf "$1 %d \"%s\"", $. + 1, $template/e; 
	    $text .= $_;
	}
	my $outtext;
	$tt->process (\$text, \%vars, \$outtext)
            or die "Error processing $template: " . $tt->error ();
	my @olines = split /\n/, $outtext;
	my $n = 0;
	for (@olines) {
	    $n++;
	    s/^#oline$/#line $n "$output"/;
	}
	$outtext = join "\n", @olines;
	open my $o, ">:encoding(utf8)", $output or die $!;
	print $o $outtext, "\n";
	close $o or die $!;
    }
    else {
	if ($verbose) {
	    print "Writing $output\n";
	}
	$tt->process ($template, \%vars, $output)
            or die "Error processing $template: " . $tt->error ();
	die unless -f $output;
    }
    chmod 0444, $output;
}

# These PNGs are used in the tests. Many of them are from
# http://libpng.org/pub/png/pngsuite.html.

my @test_pngs = qw!
t/test.png
t/with-text.png
t/with-time.png
t/tantei-san.png
t/bgyn6a16.png
t/xlfn0g04.png
t/ccwn2c08.png
t/cdun2c08.png
t/saru-fs8.png
!;

# Other files which aren't made from templates.

my @extras = qw!
my-xs.c
tmpl/author
tmpl/config
tmpl/examples_doc
tmpl/generated
tmpl/libpng_doc
tmpl/other_modules
tmpl/png_doc
tmpl/pngspec
tmpl/version
tmpl/warning
build/ImagePNGBuild.pm
build/LibpngInfo.pm
build/make-files.pl
MANIFEST
MANIFEST.SKIP
my-xs.h
perl-libpng.h
t/bKGD.t
t/cHRM.t
t/pHYs.t
t/tRNS.t
t/tIME.t
README
!;
my @mani;
push @mani, map {"tmpl/$_.tmpl"} @files;
push @mani, @outputs;
push @mani, @test_pngs;
push @mani, @extras;
push @mani, 'makeitfile';

exit;
