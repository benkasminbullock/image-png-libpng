package LibpngInfo;
require Exporter;
@ISA = qw(Exporter);
@EXPORT_OK = qw/template_vars @chunks/;
use warnings;
use strict;
use Table::Readable 'read_table';

my @ihdr_fields = (
{
    name => 'width',
    c => 'png_uint_32',
    text => <<EOF,
The width of the image in pixels.
EOF
    set => 'This cannot be zero, negative, or omitted.',
},
{
    name => 'height',
    c => 'png_uint_32',
    text => <<EOF,
The height of the image in pixels. 
EOF
    set => 'This cannot be zero, negative, or omitted.',
},
{
    name => 'bit_depth',
    c => 'int',
    text => <<EOF,
The bit depth of the image (the number of bits used for each color in
a pixel).
EOF
    set => 'This cannot be omitted.',
    retvalues => [1, 2, 4, 8, 16],
},
{
    name => 'color_type',
        c => 'int',
            text => <<EOF,
The color type.
EOF
    set => 'This cannot be omitted.',
    retvalues => [qw/
                    PNG_COLOR_TYPE_GRAY
                    PNG_COLOR_TYPE_GRAY_ALPHA
                    PNG_COLOR_TYPE_PALETTE
                    PNG_COLOR_TYPE_RGB
                    PNG_COLOR_TYPE_RGB_ALPHA
                /],
            }
,
{
    name => 'interlace_method',
    c => 'int',
    text => <<EOF,
The method of interlacing.
EOF
    set => "If this is omitted, it's set to PNG_INTERLACE_NONE.",
    retvalues => [qw/
                    PNG_INTERLACE_NONE
                    PNG_INTERLACE_ADAM7
                /],
},
{
    name => 'compression_method',
    c => 'int',
    unused => 1,
    retvalues => [qw/
                    PNG_COMPRESSION_TYPE_BASE
                /],
},
{
    name => 'filter_method',
    c => 'int',
    unused => 1,
    retvalues => qw/
                    PNG_FILTER_TYPE_BASE
                /,
},
);

my @unknown_chunk_fields = (
{
    name => 'name',
    c => 'png_byte',
    description => <<EOF,
The name of the unknown chunk, in the PNG chunk format (four bytes).
EOF
},
{
    name => 'location',
    c => 'png_byte',
    description => <<EOF,
The location of the unknown chunk.
EOF
    values => [
    {
        value => 0, 	
        meaning => "do not write the chunk",
    }, {
        value => "PNG_HAVE_IHDR",
        meaning => "insert chunk before PLTE",
    }, {
        value => 'PNG_HAVE_PLTE',	 	
        meaning => 'insert chunk before IDAT',
    }, {
        value => 'PNG_AFTER_IDAT',
        meaning => 'insert chunk after IDAT',
    },
    ],
},
{
    name => 'data',
    c => 'png_bytep',
    description => <<EOF,
The data of the unknown chunk
EOF
},
);

my $input_file = '/usr/local/include/png.h';
my @macros;
my %macros;
{
    local $/;
    open my $input, "<", $input_file;
    my $text = <$input>;
    close $input;
    while ($text =~ /^\#define\s+
                     (PNG_\w+)\s+
                     (
                         (?:0[xX]|-)?
                         [0-9a-fA-F]+|
                         \w+|
                         \(
                         (?:\(png_.*?\))?[^\)]+
                         \)
                     )
                    /gxsm) {
        my ($macro, $value) = ($1, $2);
        $value =~ s/\(png.*\)//;

        # Now we reject constants which aren't necessary for Perl.

        if ($macro =~ /_LAST$/) {
            next;
        }
        if ($macro =~ /_LIBPNG_/) {
            next;
        }
        if ($macro =~ /_MAX$/) {
            next;
        }

        # The following heebie jeebies turns values of the form (X |
        # Y) into numbers like (1 | 4). It also removes newlines and
        # tidies spaces in the values.

        $macros{$macro} = $value;
        for my $k (keys %macros) {
            $value =~ s/\b$k\b/$macros{$k}/g;
        }
        $value =~ s/\\\n//g;
        $value =~ s/\s+/ /g;
        $macros{$macro} = $value;
        push @macros, {macro => $macro, value => $value};
    }
}

my @filter_macros = (qw/
PNG_NO_FILTERS
PNG_FILTER_NONE
PNG_FILTER_SUB
PNG_FILTER_UP
PNG_FILTER_AVG
PNG_FILTER_PAETH
PNG_ALL_FILTERS
/);
my @filters;
for (@filter_macros) {
    push @filters, {macro => $_};
}


my @rtransforms = read_table (dirfile ("transforms.txt"));

for (@rtransforms) {
    $_->{read} = 0;
    $_->{write} = 0;
    if ($_->{type} =~ /r/) {
	$_->{read} = 1;
    }
    if ($_->{type} =~ /w/) {
	$_->{write} = 1;
    }
    if ($_->{equiv}) {
	$_->{equiv_ok} = 1;
    }
    if (! $_->{equiv}) {
	$_->{equiv} = lc $_->{trans};
	$_->{equiv} =~ s/^png_transform_/set_/;
	$_->{equiv_ok} = 1;
    }
    if ($_->{trans} =~ /identity|strip_(alpha|filler)|shift/i) {
	$_->{equiv_ok} = 0;
    }
}

@rtransforms = sort {$a->{trans} cmp $b->{trans}} @rtransforms;

my @transforms = (
{
    name => 'PNG_TRANSFORM_IDENTITY',
    text => 'No transformation',
},

{
    name => 'PNG_TRANSFORM_STRIP_16',
    text => 'Strip 16-bit samples to 8 bits',
},

{
    name => 'PNG_TRANSFORM_STRIP_ALPHA',
    text => 'Discard the alpha channel',
},

{
    name => 'PNG_TRANSFORM_PACKING',
    text => 'Expand 1, 2 and 4-bit samples to bytes',
},

{
    name => 'PNG_TRANSFORM_PACKSWAP',
    text => 'Change order of packed pixels to LSB first',
},

{
    name => 'PNG_TRANSFORM_EXPAND',
    text => 'Expand paletted images to RGB, grayscale to 8-bit images and tRNS chunks to alpha channels',
},

{
    name => 'PNG_TRANSFORM_INVERT_MONO',
    text => 'Invert monochrome images',
},

{
    name => 'PNG_TRANSFORM_SHIFT',
    text => 'Normalize pixels to the sBIT depth',
},

{
    name => 'PNG_TRANSFORM_BGR',
    text => 'Flip RGB to BGR, RGBA to BGRA',
},

{
    name => 'PNG_TRANSFORM_SWAP_ALPHA',
    text => 'Flip RGBA to ARGB or GA to AG',
},

{
    name => 'PNG_TRANSFORM_INVERT_ALPHA',
    text => 'Change alpha from opacity to transparency',
},

{
    name => 'PNG_TRANSFORM_SWAP_ENDIAN',
    text => 'Byte-swap 16-bit samples'
},
);


# Known chunks. Here "in_valid" means the chunk is one of the ones
# which is returned by the libpng routine "png_get_valid".

our @chunks = (
{
    name => 'gAMA',
    in_valid => 1,
    auto_type => 'double',
},

{
    name => 'sBIT',
    in_valid => 1,
    auto_type => 'hv',
},

{
    name => 'cHRM',
    in_valid => 1,
    auto_type => 'hv',
    fields => [],
    pro => 'PNG_cHRM_SUPPORTED',
},

{
    name => 'cHRM_XYZ',
    in_valid => 0,
    auto_type => 'hv',
    fields => [],
    # http://www.cpantesters.org/cpan/report/0722432c-3f18-11eb-9d08-9e4a1f24ea8f
    
    pro => 'PNG_cHRM_XYZ_SUPPORTED',
},

{
    name => 'PLTE',
    in_valid => 1,
    auto_type => 'av',
},

{
    name => 'tRNS',
    in_valid => 1,
    auto_type => 'sv',
},

{
    name => 'bKGD',
    in_valid => 1,
    auto_type => 'hv',
},

{
    name => 'hIST',
    in_valid => 1,
},

{
    name => 'pHYs',
    in_valid => 1,
    auto_type => 'hv',
},

{
    name => 'oFFs',
    in_valid => 1,
    auto_type => 'hv',
},

{
    name => 'tIME',
    in_valid => 1,
    auto_type => 'sv',
    default => "0",
},

{
    name => 'pCAL',
    in_valid => 1,
    auto_type => 'hv',
},

{
    name => 'sRGB',
    in_valid => 1,
},

{
    name => 'iCCP',
    in_valid => 1,
    auto_type => 'hv',
},

{
    name => 'sPLT',
    in_valid => 1,
    auto_type => 'av',
},

{
    name => 'sCAL',
    in_valid => 1,
    auto_type => 'hv',
},

{
    name => 'IDAT',
    in_valid => 1,
    redirect => 'Image data',
},
{
    name => 'tEXt',
    is_text => 1,
},
{
    name => 'zTXt',
    is_text => 1,
},
{
    name => 'iTXt',
    is_text => 1,
},
{
    name => 'IHDR',
    auto_type => 'hv',
    redirect => 'The image header',
},
{
    name => 'hIST',
    auto_type => 'av',
},
{
    name => 'eXIf',
    auto_type => 'sv',
},


);

@chunks = sort {(uc $a->{name}) cmp (uc $b->{name})} @chunks;

my %chunks;

for my $chunk (@chunks) {
    $chunks{$chunk->{name}} = $chunk;
}

# The order of these is important since the libpng function doesn't
# use a struct but a long list of arguments.

for my $color (qw/white red green blue/) {
    for my $coord (qw/x y/) {
        push @{$chunks{cHRM}{fields}}, "${color}_$coord"
    }
}

# The order of these is important since the libpng function doesn't
# use a struct but a long list of arguments. There is no "white" in
# the xyz case.

for my $color (qw/red green blue/) {
    for my $coord (qw/x y z/) {
        push @{$chunks{cHRM_XYZ}{fields}}, "${color}_$coord"
    }
}

# List of colors which are in png_color_8 or png_color_16.

my @colors = qw/red green blue gray alpha/;
my @noalpha = qw/red green blue gray/;

my $supports_file = dirfile ('supports.txt');
my @supports_list = read_table ($supports_file);
@supports_list = sort {uc($a->{c}) cmp uc($b->{c})} @supports_list;
for (@supports_list) {
    if (! defined ($_->{d})) {
	my $d = '';
	if (length ($_->{c}) == 4) {
	    $d = "Does the libpng support the L</$_->{c}> chunk?";
	}
	$_->{d} = $d;
    }
}

my $uns_file = dirfile ('unsupported-table.txt');
my @unsupported = read_table ($uns_file);
for (@unsupported) {
    # Template toolkit STRICT mode cannot deal with undefined values
    # very well so set them here.
    if (! $_->{desc}) {
	$_->{desc} = '';
    }
    if (! $_->{cat}) {
	$_->{cat} = 'unknown';
    }
    if ($_->{cat} eq 'unimplemented' && $_->{item} =~ /_fixed$/) {
	$_->{cat} = 'fixed';
    }
}

@unsupported = sort {$a->{item} cmp $b->{item}} @unsupported;

# Valid chunks, removing cHRM_XYZ

my @vchunks = grep {$_->{name} !~ /_XYZ/} @chunks;

sub template_vars
{
    my ($vars_ref) = @_;
    $vars_ref->{ihdr_fields} = \@ihdr_fields;
    $vars_ref->{macros} = \@macros;
    $vars_ref->{filters} = \@filters;
    $vars_ref->{transforms} = \@transforms;
    $vars_ref->{rtransforms} = \@rtransforms;
    $vars_ref->{chunks} = \@chunks;
    $vars_ref->{vchunks} = \@vchunks;
    $vars_ref->{chunk_hash} = \%chunks;
    $vars_ref->{colors} = \@colors;
    $vars_ref->{noalpha} = \@noalpha;
#    for my $name (keys %{$vars_ref->{chunk}}) {
#        print "$name.\n";
#    }
    $vars_ref->{unknown_chunk_fields} = \@unknown_chunk_fields;
    $vars_ref->{supports_list} = \@supports_list;
    $vars_ref->{unsupported} = \@unsupported;
}

sub dirfile
{
    my ($file) = @_;
    my $dfile = __FILE__;
    $dfile =~ s!LibpngInfo\.pm!$file!;
    return $dfile;
}


1;
