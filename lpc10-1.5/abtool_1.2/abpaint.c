#include <xview/xview.h>
#include <xview/panel.h>
#include <xview/xv_xrect.h>
#include "abplay.h"

/*
 * Repaint callback function for `canvas1'.
 */
void
ab_canvas_repaint(canvas, paint_window, dpy, win, rects)
	Canvas		canvas;
	Xv_window	paint_window;
	Display		*dpy;
	Window		win;
	Xv_xrectlist	*rects;
{
	GC gc;
	int width, height;
	struct segstate sg;

	gc = DefaultGC(dpy, DefaultScreen(dpy));
	width = (int)xv_get(paint_window, XV_WIDTH);
	height= (int)xv_get(paint_window, XV_HEIGHT);
	XDrawLine(dpy, win, gc, 0, 0, width, height);
	sg = abp_get_segstate();
/*	fprintf(stderr, "repaint: nsegs= %d\n", sg.nsegs); */
}

