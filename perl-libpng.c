#include <stdarg.h>
#include <png.h>

#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "perl-libpng.h"

#ifdef HEADER

typedef png_structp Image__PNG__Libpng__Png;
typedef png_infop Image__PNG__Libpng__Info;

#endif

/* The following time fields are used in "perl_png_timep_to_hash" for
   converting the PNG modification time structure ("png_time") into a
   Perl associative array. */

static const char * time_fields[] = {
    "year",
    "month",
    "day",
    "hour",
    "minute",
    "second"
};

#define N_TIME_FIELDS (sizeof (time_fields) / sizeof (const char *))

/* "perl_png_timep_to_hash" converts a PNG time structure to a Perl
   associative array with named fields of the same name as the members
   of the C structure. */

void perl_png_timep_to_hash (const png_timep mod_time, HV * time_hash)
{
    int i;
    SV * f[N_TIME_FIELDS];
    f[0] = newSViv (mod_time->year);
    f[1] = newSViv (mod_time->month);
    f[2] = newSViv (mod_time->day);
    f[3] = newSViv (mod_time->hour);
    f[4] = newSViv (mod_time->minute);
    f[5] = newSViv (mod_time->second);
    for (i = 0; i < N_TIME_FIELDS; i++) {
        if (!hv_store (time_hash, time_fields[i],
                       strlen (time_fields[i]), f[i], 0)) {
            fprintf (stderr, "hv_store failed.\n");
        }
    }
}

/* Print a warning message. */

static void perl_png_warn (const char * format, ...)
{
    va_list ap;
    va_start (ap, format);
    vfprintf (stderr, "format", ap);
    va_end (ap);
}

/* Create a scalar value from the "text" field of the PNG text chunk
   contained in "text_ptr". */

static SV * make_text_sv (const png_textp text_ptr)
{
    SV * sv;
    char * text = 0;
    int length = 0;

    if (text_ptr->text) {
        text = text_ptr->text;
        if (text_ptr->text_length != 0) {
            length = text_ptr->text_length;
        }
        else if (text_ptr->itxt_length != 0) {
            length = text_ptr->itxt_length;
        }
    }
    if (text && length) {

        /* "is_itxt" contains a true value if the text claims to be
           ITXT (international text) and also validates as UTF-8
           according to Perl. The PNG specifications require that ITXT
           text is UTF-8 encoded, but this routine checks that here
           using Perl's "is_utf8_string" function. */

        int is_itxt = 0;

        sv = newSVpvn (text, length);
        
        if (text_ptr->compression == PNG_ITXT_COMPRESSION_NONE ||
            text_ptr->compression == PNG_ITXT_COMPRESSION_zTXt) {

            is_itxt = 1;

            if (! is_utf8_string ((unsigned char *) text, length)) {
                perl_png_warn ("According to its compression type, a text chunk in the current PNG file claims to be ITXT but Perl's 'is_utf8_string' says that its encoding is invalid.");
                is_itxt = 0;
            }
        }
        if (is_itxt) {
            SvUTF8_on (sv);
        }
    }
    else {
        sv = newSV (0);
    }
    return sv;
}

/* Convert the "lang_key" field of a "png_text" structure into a Perl
   scalar. */

static SV * lang_key_to_sv (const char * lang_key)
{
    SV * sv;
    if (lang_key) {
        int length;
        /* "lang_key" is supposed to be UTF-8 encoded. */
        int is_itxt = 1;

        length = strlen (lang_key);
        sv = newSVpv (lang_key, length);
        if (! is_utf8_string ((unsigned char *) lang_key, length)) {
            perl_png_warn ("A language key 'lang_key' member of a 'png_text' structure in the file failed Perl's 'is_utf8_string' test, which says that its encoding is invalid.");
            is_itxt = 0;
        }
        if (is_itxt) {
            SvUTF8_on (sv);
        }
    }
    else {
        sv = newSV (0);
    }
    return sv;
}

/* "text_fields" contains the names of the various fields in a
   "png_text" structure. The following routine uses these names to put
   the values of the png_text structure into a Perl hash. */

static const char * text_fields[] = {
    "compression",
    "key",
    "text",
    "lang",
    "lang_key",
    "text_length",
    "itxt_length",
};

/* "N_TEXT_FIELDS" is the number of text fields in a "png_text"
   structure which we want to preserve. */

#define N_TEXT_FIELDS (sizeof (text_fields) / sizeof (const char *))

/* "perl_png_textp_to_hash" creates a new Perl associative array from
   the PNG text values in "text_ptr". */

static HV *
perl_png_textp_to_hash (const png_textp text_ptr)
{
    int i;
    /* Scalar values which will be added to elements of "text_hash". */
    SV * f[N_TEXT_FIELDS];
    HV * text_hash;

    text_hash = newHV ();
    f[0] = newSViv (text_ptr->compression);
    f[1] = newSVpv (text_ptr->key, strlen (text_ptr->key));
    /* Depending on whether the "text" field of "text_ptr" is a string
       or a null value, create an SV copy of it or create an SV which
       contains the undefined value. */
    f[2] = make_text_sv (text_ptr);
    if (text_ptr->lang) {
        /* According to section 4.2.3.3 of the PNG specification, the
           "lang" field of the "png_text" structure contains a
           language code according to the conventions of RFC 1766 (now
           superceded by RFC 3066), which is an ASCII based standard
           for describing languages, so it is not necessary to mark
           this as being in UTF-8. */
        f[3] = newSVpv (text_ptr->lang, strlen (text_ptr->lang));
    }
    else {
        /* The language code may be empty. */
        f[3] = newSV (0);
    }
    f[4] = lang_key_to_sv (text_ptr->lang_key);
    f[5] = newSViv (text_ptr->text_length);
    f[6] = newSViv (text_ptr->itxt_length);

    for (i = 0; i < N_TEXT_FIELDS; i++) {
        //printf ("%d:%s\n", i, text_fields[i]);
        if (!hv_store (text_hash, text_fields[i],
                       strlen (text_fields[i]), f[i], 0)) {
            fprintf (stderr, "hv_store failed.\n");
        }
    }

    return text_hash;
}

/*
  This is the C part of Image::PNG::get_text.
 */

int
perl_png_get_text (png_structp png_ptr, png_infop info_ptr, SV * text_ref)
{
    int num_text = 0;
    if (SvROK (text_ref)) {
        if (SvTYPE (SvRV (text_ref)) == SVt_PVAV) {
            AV * text_chunks = (AV *) SvRV (text_ref);
            png_textp text_ptr;
            int i;

            png_get_text (png_ptr, info_ptr, & text_ptr, & num_text);
            for (i = 0; i < num_text; i++) {
                HV * hash;
                SV * hash_ref;
                
                //                printf ("%d %s\n", i, text_ptr[i].key);
                hash = perl_png_textp_to_hash (text_ptr + i);
                hash_ref = newRV_inc ((SV *) hash);
                av_push (text_chunks, hash_ref);
            }
        }
        else {
            fprintf (stderr, "Not an AV ref\n");
        }
    }
    else {
        fprintf (stderr, "Not a ref\n");
    }
    return num_text;
}

/* If the PNG contains a valid time, put the time into a Perl
   associative array described by "time_ref". */

int
perl_png_get_time (png_structp png_ptr, png_infop info_ptr, SV * time_ref)
{
    png_timep mod_time = 0;
    int status;
    status = png_get_tIME (png_ptr, info_ptr, & mod_time);
    if (status && mod_time) {
        if (SvROK (time_ref)) {
            if (SvTYPE (SvRV (time_ref)) == SVt_PVHV) {
                HV * time = (HV *) SvRV (time_ref);
                perl_png_timep_to_hash (mod_time, time);
            }
            else {
                fprintf (stderr, "Not a hash reference.\n");
            }
        }
        else {
            fprintf (stderr, "Not a reference.\n");
        }
    }
    else {
        fprintf (stderr, "No time info in PNG file.\n");
    }
    return status;
}

int
perl_png_sig_cmp (SV * png_header, int start, int num_to_check)
{
    unsigned char * header;
    unsigned int length;
    int ret_val;
    header = (unsigned char *) SvPV (png_header, length);
    ret_val = png_sig_cmp (header, start, num_to_check);
    return ret_val;
}

typedef struct {
    SV * png_image;
    const char * data; 
    int read_position;
    unsigned int length;
}
scalar_as_image_t;

/* Read some bytes from a Perl scalar into a png_ptr as requested. */

static void
perl_png_scalar_read (png_structp png_ptr, png_bytep out_bytes,
                      png_size_t byte_count_to_read)
{
    scalar_as_image_t * si;
    const char * read_point;

    si = png_get_io_ptr (png_ptr);
#if 0
    fprintf (stderr, "Reading %d bytes from image at position %d.\n",
             byte_count_to_read, si->read_position);
#endif
    if (si->read_position + byte_count_to_read > si->length) {
        fprintf (stderr, "Request for too many bytes %d on an image "
                 "of length %d at read position %d.\n",
                 byte_count_to_read, si->length, si->read_position);
        return;
    }
    read_point = si->data + si->read_position;
    memcpy (out_bytes, read_point, byte_count_to_read);
    si->read_position += byte_count_to_read;
}

/* Make the Perl scalar "image_data" into the image data to be read. */

void
perl_png_scalar_as_image (png_structp png_ptr,
                          SV * image_data)
{
    scalar_as_image_t * si;
    si = calloc (1, sizeof (scalar_as_image_t));

    fprintf (stderr, "Settign up the image.\n");
    /* We don't need the following anywhere. However we probably
       should keep track of where the data comes from. */
    si->png_image = image_data;
    si->data = SvPV (si->png_image, si->length);
    /* Check it is a valid PNG here using png_sig_cmp. */

    /* Set the reader for png_ptr to our function. */
    png_set_read_fn (png_ptr, si, perl_png_scalar_read);
}

int
perl_png_get_IHDR (png_structp png_ptr, png_infop info_ptr, HV * IHDR_ref)
{
    png_uint_32 width;
    png_uint_32 height;
    int bit_depth;
    int color_type;
    int interlace_method;
    int compression_method;
    int filter_method;
    /* The return value. */
    int status;

    status = png_get_IHDR (png_ptr, info_ptr, & width, & height,
                           & bit_depth, & color_type, & interlace_method,
                           & compression_method, & filter_method);
#define STORE(x) {                                                      \
        if (!hv_store (IHDR_ref, #x, strlen (#x), newSViv (x), 0)) {    \
            fprintf (stderr, "hv_store failed.\n");                     \
        }                                                               \
    }
    STORE (width);
    STORE (height);
    STORE (bit_depth);
    STORE (color_type);
    STORE (interlace_method);
    STORE (compression_method);
    STORE (filter_method);
#undef STORE

    return status;
}

#define PERL_PNG_COLOR_TYPE(x)                  \
 case PNG_COLOR_TYPE_ ## x:                     \
     name = #x;                                 \
     break

/* Convert a PNG colour type number into its name. */

const char * perl_png_color_type_name (int color_type)
{
    const char * name;

    switch (color_type) {
        PERL_PNG_COLOR_TYPE (GRAY);
        PERL_PNG_COLOR_TYPE (PALETTE);
        PERL_PNG_COLOR_TYPE (RGB);
        PERL_PNG_COLOR_TYPE (RGB_ALPHA);
        PERL_PNG_COLOR_TYPE (GRAY_ALPHA);
    default:
        /* Moan about not knowing this colour type. */
        name = "";
    }
    return name;
}

#define PERL_PNG_TEXT_COMP(x,y)                  \
    case PNG_ ## x ## _COMPRESSION_ ## y:        \
    name = #x "_" #y;                            \
    break

/* Convert a libpng text compression number into its name. */

const char * perl_png_text_compression_name (int text_compression)
{
    const char * name;
    switch (text_compression) {
        PERL_PNG_TEXT_COMP(TEXT,NONE);
        PERL_PNG_TEXT_COMP(TEXT,zTXt);
        PERL_PNG_TEXT_COMP(ITXT,NONE);
        PERL_PNG_TEXT_COMP(ITXT,zTXt);
    default:
        /* Moan about not knowing this text compression type. */
        name = "";
    }
    return name;
}

#undef PERL_PNG_COLOR_TYPE

AV *
perl_png_get_rows (png_structp png_ptr, png_infop info_ptr)
{
    png_bytepp rows;
    int rowbytes;
    int height;
    SV ** row_svs;
    int r;
    AV * perl_rows;

    /* Get the information from the PNG. */

    height = png_get_image_height (png_ptr, info_ptr);
    if (height == 0) {
        fprintf (stderr, "Image has no height.\n");
        return 0;
        /* We are shafted. */
    }
    else {
        //        printf ("Image has height %d\n", height);
    }
    rows = png_get_rows (png_ptr, info_ptr);
    if (rows == 0) {
        fprintf (stderr, "Image has no rows.\n");
        return 0;
        /* We are shafted. */
    }
    else {
        //        printf ("Image has some rows\n");
    }
    rowbytes = png_get_rowbytes (png_ptr, info_ptr);
    if (rowbytes == 0) {
        fprintf (stderr, "Image rows have zero length.\n");
        return 0;
        /* We are shafted. */
    }
    else {
        //        printf ("Image rows are length %d\n", rowbytes);
    }

    /* Create Perl stuff to put the row info into. */

    row_svs = calloc (height, sizeof (SV *));
    if (! row_svs) {
        /* We are shafted. */
        return 0;
    }
    //    printf ("Making %d scalars.\n", height);
    for (r = 0; r < height; r++) {
        row_svs[r] = newSVpvn (rows[r], rowbytes);
    }
    perl_rows = av_make (height, row_svs);
    //    printf ("There are %d elements in the array.\n", av_len (perl_rows));
    free (row_svs);
    return perl_rows;
}

/* Return an array of hashes containing the colour values of the palette. */

int
perl_png_get_PLTE (png_structp png_ptr, png_infop info_ptr,
                   AV * perl_colors)
{
    png_colorp colors;
    int n_colors;
    png_uint_32 status;
    int i;

    status = png_get_PLTE (png_ptr, info_ptr, & colors, & n_colors);
    if (status != PNG_INFO_PLTE) {
        return status;
    }
    av_clear (perl_colors);
    for (i = 0; i < n_colors; i++) {
        HV * palette_entry;

        //        printf ("Palette entry %d\n", i);
        palette_entry = newHV ();
#define PERL_PNG_STORE_COLOR(x) hv_store (palette_entry, #x, strlen (#x), \
                           newSViv (colors[i].x), 0)
        PERL_PNG_STORE_COLOR (red);
        PERL_PNG_STORE_COLOR (green);
        PERL_PNG_STORE_COLOR (blue);
#undef PERL_PNG_STORE_COLOR
        av_push (perl_colors, newRV ((SV *) palette_entry));
    }
}
