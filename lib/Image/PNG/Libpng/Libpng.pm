# This file is just a list of exports and documentation. The source
# code for this file is in Libpng.xs in the top directory.

package Image::PNG::Libpng::Libpng;
require Exporter;
require DynaLoader;
use Carp;
@ISA = qw(Exporter);
@EXPORT_OK = qw/
	create_read_struct
	create_write_struct
	destroy_read_struct
	destroy_write_struct
	write_png
	init_io
	read_info
	read_update_info
	read_image
	read_png
	get_text
	set_text
	sig_cmp
	scalar_as_input
	read_from_scalar
	color_type_name
	text_compression_name
	get_libpng_ver
	access_version_number
	get_row_pointers
	get_rows
	get_rowbytes
	get_channels
	get_valid
	set_row_pointers
	set_tRNS_pointer
	set_rows
	write_to_scalar
	set_filter
	set_verbosity
	set_unknown_chunks
	get_unknown_chunks
	supports
	set_keep_unknown_chunks
	get_tRNS_palette
	set_PLTE_pointer
	set_expand
	set_gray_to_rgb
	set_filler
	get_sRGB
	set_sRGB
	set_packing
	set_strip_16
	DESTROY
	get_bKGD
	set_bKGD
	get_cHRM
	set_cHRM
	get_gAMA
	set_gAMA
	get_iCCP
	set_iCCP
	get_IHDR
	set_IHDR
	get_oFFs
	set_oFFs
	get_pCAL
	set_pCAL
	get_pHYs
	set_pHYs
	get_PLTE
	set_PLTE
	get_sBIT
	set_sBIT
	get_sCAL
	set_sCAL
	get_sPLT
	set_sPLT
	get_tIME
	set_tIME
	get_tRNS
	set_tRNS
read_file
/;

%EXPORT_TAGS = (
    all => \@EXPORT_OK,
);

require XSLoader;
our $VERSION = '0.21';

XSLoader::load('Image::PNG::Libpng', $VERSION);

sub read_file
{
    my ($file_name) = @_;
    my $png = create_read_struct ();
    open my $in, "<:raw", $file_name or croak $!;
    $png->init_io ($in);
    $png->read_png ();
    close $in or croak $!;
    return $png;
}

sub write_file
{
    my ($png, $file_name) = @_;
    open my $in, ">:raw", $file_name or croak $!;
    $png->init_io ($in);
    $png->write_png ();
    close $in or croak $!;
}

1;

# Local Variables:
# mode: perl
# End:
