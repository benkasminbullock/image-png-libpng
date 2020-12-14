#include <stdio.h>
#include <png.h>
#include <errno.h>
#include <string.h>

static void
gpm (char * filename)
{
    FILE * f;
    png_structrp png_ptr;
    png_infop info_ptr;
    int gpm;

    f = fopen (filename, "r");
    if (! f) {
	fprintf (stderr, "Can't open %s: %s\n", filename, strerror (errno));
	return;
    }
    png_ptr = png_create_read_struct ("1.6.37+apng", 0, 0, 0);
    if (! png_ptr) {
	fprintf (stderr, "No png struct.\n");
	return;
    }
    info_ptr = png_create_info_struct (png_ptr);
    if (! info_ptr) {
	fprintf (stderr, "No info struct.\n");
	return;
    }
    png_init_io (png_ptr, f);
    png_read_png (png_ptr, info_ptr, 0, 0);
    gpm = png_get_palette_max (png_ptr, info_ptr);
    fclose (f);
    printf ("%s %d\n", filename, gpm);
}

int
main(int argc, char ** argv)
{
    int i;
    for (i = 1; i < argc; i++) {
	gpm (argv[i]);
    }
    return 0;
}
