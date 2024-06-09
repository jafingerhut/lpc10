#include <sys/param.h>
#include <xview/xview.h>
#include <xview/panel.h>
#include <xview/svrimage.h>
#include <xview/icon.h>
#include <gfm.h>
#include "abtool_ui.h"
#include "abplay.h"

extern abtool_win_objects	*Abtool_win;
extern abtool_pwin_objects	*Abtool_pwin;

void		files_play_notify();
void		files_close_notify();
void		files_graph_notify();
void		files_seg_notify();
void		file_loadspd_notify();
void		file_loadseg_notify();
void		file_storeseg_notify();
Panel_setting	align_notify();
double		get_value_double();
double		set_panel_dbl();
void		set_label_char(Xv_opaque, char);
Notify_value	audio_notify();
Notify_value	destroy_func();
Notify_value	open_cmd_files();

#define ABLEN 10
#define NAMELEN 64

struct {
	int segnum;	/* Current segment */
	int seginc;	/* Increment segments if non-zero */
	int nsegs;	/* Number of defined segments */
	int abnum;	/* Current position in ablist (-1 = ignore ablist) */
	char ablist[ABLEN];	/* List of files to play in order (ABC etc) */
} playlist;

gfm_popup_objects	*Gfm;
static Xv_opaque	Flist;
static char	idchar[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
static char	filename[MAXFILES][NAMELEN];
static int	align_id = -1;
static char	*play_label[] = {"Play A/B", "Stop"};
static int	s_argc;
static char	**s_argv;

static char	version[] = {
#include "version.h"
};
static unsigned short icon_bits[] = {
#include "abtool.icon"
};
static unsigned short mask_bits[] = {
#include "abtool_mask.icon"
};

/*
 * Application-specific initialization
 */
void
abtool_initialize(int argc, char **argv)
{
	int		i;
	char		pathname[MAXPATHLEN];
	Menu		menu;
	Menu_item	item;
	struct segparms	parm;
	Server_image	icon_image, mask_image;
	Icon		icon;

/* Save filenames from command line to open from event loop */
	s_argc = argc;
	s_argv = argv;
	playlist.nsegs = 0;

/* Create icon */

	icon_image = (Server_image)xv_create(NULL, SERVER_IMAGE,
	    SERVER_IMAGE_BITS, icon_bits,
	    XV_WIDTH, 64, XV_HEIGHT, 64, NULL);

	mask_image = (Server_image)xv_create(NULL, SERVER_IMAGE,
	    SERVER_IMAGE_BITS, mask_bits,
	    XV_WIDTH, 64, XV_HEIGHT, 64, NULL);

	icon = (Icon)xv_create(Abtool_win->win, ICON,
	    XV_LABEL, "A/B Tool",
	    ICON_IMAGE, icon_image,
	    ICON_MASK_IMAGE, mask_image, NULL);

/* Misc window initialization */
	Flist = Abtool_win->list1;
	window_fit(Abtool_win->controls1);
	window_fit(Abtool_win->win);
	getcwd(pathname, MAXPATHLEN);
	xv_set(Abtool_win->win,
	    XV_LABEL, version,
	    FRAME_ICON, icon,
	    FRAME_LEFT_FOOTER, pathname, NULL);

	xv_set(Abtool_win->controls1,
	    WIN_NOTIFY_EVENT_PROC, open_cmd_files, NULL);

	xv_set(Abtool_win->canvas1,
	    CANVAS_AUTO_CLEAR, TRUE,
	    CANVAS_FIXED_IMAGE, FALSE, NULL);

/* Register audio status notification callback */
	notify_set_event_func(SIGPOLL, audio_notify, NOTIFY_SAFE);
	notify_interpose_destroy_func(Abtool_win->win, destroy_func);

/* Set up file chooser */
	xv_set(Abtool_pwin->thresh, PANEL_VALUE, 50, 0);
	xv_set(Abtool_pwin->gap, PANEL_VALUE, 200, 0);
	xv_set(Abtool_pwin->pad, PANEL_VALUE, 200, 0);
	xv_set(Abtool_pwin->maxdelay, PANEL_VALUE, "1000", 0);
	Gfm = gfm_initialize(NULL, Abtool_win->win, "A/B Tool: Load");
	xv_set(Abtool_win->play_button, PANEL_LABEL_STRING, play_label[0], 0);

/* Attach menu item notify functions, since devguide won't do it. */
	menu = (Menu)xv_get(Abtool_win->list1, PANEL_ITEM_MENU);
	item = (Menu_item)xv_get(menu, MENU_NTH_ITEM, 1);
	xv_set(item, MENU_NOTIFY_PROC, files_play_notify, NULL);
	item = (Menu_item)xv_get(menu, MENU_NTH_ITEM, 2);
	xv_set(item, MENU_NOTIFY_PROC, files_close_notify, NULL);
	item = (Menu_item)xv_get(menu, MENU_NTH_ITEM, 3);
	xv_set(item, MENU_NOTIFY_PROC, files_graph_notify, NULL);
	item = (Menu_item)xv_get(menu, MENU_NTH_ITEM, 4);
	xv_set(item, MENU_NOTIFY_PROC, files_seg_notify, NULL);

	menu = (Menu)xv_get(Abtool_win->file_button, PANEL_ITEM_MENU);
	item = (Menu_item)xv_get(menu, MENU_NTH_ITEM, 2);
	xv_set(item, MENU_NOTIFY_PROC, file_loadspd_notify, NULL);
	item = (Menu_item)xv_get(menu, MENU_NTH_ITEM, 3);
	xv_set(item, MENU_NOTIFY_PROC, file_loadseg_notify, NULL);
	item = (Menu_item)xv_get(menu, MENU_NTH_ITEM, 4);
	xv_set(item, MENU_NOTIFY_PROC, file_storeseg_notify, NULL);

	xv_set(Abtool_pwin->gain,  PANEL_NOTIFY_PROC, align_notify, 0);
	xv_set(Abtool_pwin->delay, PANEL_NOTIFY_PROC, align_notify, 0);
}

Notify_value
open_cmd_files(Xv_Window win, Event *event, Notify_arg arg,
                Notify_event_type type )
{
	int i;
	Notify_value	value;

	value = notify_next_event_func(win, event, arg, type);
	if (event_id(event) == WIN_REPAINT) {
	    for (i=1; i<s_argc; i++) abtool_file_load("", s_argv[i]);
	    s_argc = 0;
	    files_seg_notify(0, 0);
	    show_align(0);
	}
	return value;
}

Notify_value
destroy_func(Notify_client client, Destroy_status status)
{
	if (status == DESTROY_CLEANUP || status == DESTROY_PROCESS_DEATH) {
	   kill(0, SIGTERM);
	}
	return NOTIFY_OK;
}

/*
 * Callback for file chooser
 */
gfm_proc(gfm_popup_objects *ip, char *dir, char *file)
{
	return abtool_file_load(dir, file);
}

void
file_loadspd_notify(Menu menu, Menu_item menu_item)
{
	gfm_activate(Gfm, NULL, NULL, NULL, gfm_proc, NULL, GFM_LOAD);
}

void
file_loadseg_notify(Menu menu, Menu_item menu_item)
{
	printf("load segments not implemented\n");
}

void
file_storeseg_notify(Menu menu, Menu_item menu_item)
{
	printf("store segments not implemented\n");
}

abtool_file_load(char *dir, char *file)
{
	int i, n;

	if (strlen(dir) > (size_t)0) {
	    if (chdir(dir) < 0) return GFM_ERROR;
	    xv_set(Abtool_win->win, FRAME_LEFT_FOOTER, dir, NULL);
	}
	xv_set(Abtool_win->win, FRAME_BUSY, TRUE, NULL);
	xv_set(Abtool_pwin->pwin, FRAME_BUSY, TRUE, NULL);
	n = abp_open_file(file);
	xv_set(Abtool_win->win, FRAME_BUSY, FALSE, NULL);
	xv_set(Abtool_pwin->pwin, FRAME_BUSY, FALSE, NULL);
	if (n < 0) return GFM_ERROR;
	strncpy(filename[n], file, NAMELEN);
	i = (int)xv_get(Flist, PANEL_LIST_NROWS);
	if (i <= n) xv_set(Flist, PANEL_LIST_INSERT, n, NULL);
	show_align(n);
	show_file(n);
	return GFM_OK;
}

show_file(int n)
{
	int n1, n2, show;
	char str[NAMELEN+10];

	n1 = n2 = n;
	if (n < 0) {
	    n1 = 0;
	    n2 = xv_get(Flist, PANEL_LIST_NROWS) - 1;
	}

	show = xv_get(Abtool_pwin->fname, PANEL_VALUE);
	for (n = n1; n <= n2; n++) {
	    str[0] = 0;
	    if (strlen(filename[n]) > (size_t)0) {
	        sprintf(str, "  0: ");
	        str[2] = idchar[n];
	        if (show == 0) strncpy(&str[5], filename[n], NAMELEN);
	    }
	    xv_set(Flist, PANEL_LIST_STRING, n, str, NULL);
	}
}

list_seln()
{
	int i, n;

	for (i=0, n=-1; i<xv_get(Flist, PANEL_LIST_NROWS); i++)
	    if (xv_get(Flist, PANEL_LIST_SELECTED, i))
	        if (strlen((char *)xv_get(Flist, PANEL_LIST_STRING, i))
	               > (size_t)0) {
	            n = i;
	            break;
	        }
	return n;
}

void
files_play_notify(Menu menu, Menu_item menu_item)
{
	playlist.abnum = -1;
	abp_start_play(list_seln(), 0);
}

void
files_close_notify(Menu menu, Menu_item menu_item)
{
	int i, n, nrows, last;

	n = list_seln();
	if (n < 0) {
	    fprintf(stderr,"Fatal: no list selection");
	    exit(-1);
	}
	abp_close_file(n);
	filename[n][0] = 0;
	show_file(n);
	nrows = (int)xv_get(Flist, PANEL_LIST_NROWS);
	for (i=0, last=-1; i<nrows; i++)
	    if (strlen(filename[i]) > (size_t)0) last = i;
	for (i=nrows-1; i>last; i--)
	    xv_set(Flist, PANEL_LIST_DELETE, i, NULL);
}

void
files_graph_notify(Menu menu, Menu_item menu_item)
{
	printf("graph not implemented (%d)\n", list_seln());
}

void
files_seg_notify(Menu menu, Menu_item menu_item)
{
	int id;
	struct segparms parm;

	id = MAX(0, list_seln());
	parm.thresh = (int)xv_get(Abtool_pwin->thresh, PANEL_VALUE);
	parm.gap = (int)xv_get(Abtool_pwin->gap, PANEL_VALUE);
	parm.pad = (int)xv_get(Abtool_pwin->pad, PANEL_VALUE);
	parm.taumax = .001 * get_value_int(Abtool_pwin->maxdelay);
	set_panel_int(Abtool_pwin->maxdelay, PANEL_VALUE,
	    nint(1000.*parm.taumax));
	playlist.nsegs = abp_segment(id, parm);
	set_label_char(Abtool_pwin->ref, idchar[id]);
	set_panel_int(Abtool_win->nsegs_text,
	    PANEL_LABEL_STRING, playlist.nsegs);
	show_align(id);
}

Notify_value
audio_notify(Notify_client client, Notify_event event, Notify_arg arg, Notify_event_type when)
{
	int n, id;
	struct audio_status status;

/* Update selection to indicate which file is playing */
	abp_get_audio_status(&status);
	if (status.state == IDLE) {
	    for (n=0; n<(int)xv_get(Flist, PANEL_LIST_NROWS); n++)
	        xv_set(Flist, PANEL_LIST_SELECT, n, FALSE, NULL);
	    start_play(0);		/* Start playing next file/segment */
	    n = 0;				/* Play button = "Play" */
	    if (playlist.abnum >= 0) n = -1;	/* Don't flicker if queued */
	} else {
	    xv_set(Flist, PANEL_LIST_SELECT, status.id, TRUE, NULL);
	    n = 1;				/* Play button = "Stop" */
	}
	if (n >= 0) {
	    xv_set(Abtool_win->play_button,
	        PANEL_LABEL_STRING, play_label[n], NULL);
	    if (n == 0) if (xv_get(Abtool_pwin->audio_hold, PANEL_VALUE))
	        abp_close_device();
	}
	return NOTIFY_DONE;
}

/*
 *  Play: id > 0 - play a single segment from the file "id" (a,b,etc)
 *           = 0 - continue play with the next element in list
 *           < 0 - initialize A/B list, start play with first element
 */
start_play(int id)
{
	int n;
	char *cp;

/* Play A/B button: Initialize A/B list, play first element */

	playlist.segnum = get_segnum();
	if (id < 0) {
	    strncpy(playlist.ablist, (char *)xv_get(Abtool_win->ab_text,
	        PANEL_VALUE), ABLEN-1);
	    if (strlen(playlist.ablist) == (size_t)0) {
	        n = xv_get(Flist, PANEL_LIST_NROWS);
	        strncpy(playlist.ablist, idchar, n);
	        xv_set(Abtool_win->ab_text, PANEL_VALUE, playlist.ablist, 0);
	    }
	    playlist.abnum = 0;
	    playlist.seginc = 1;
	    if (playlist.segnum > 0 && playlist.segnum <= playlist.nsegs) {
	        playlist.seginc = 0;
	    } else {
	        playlist.segnum = 1;
	    }
	    id = (int)playlist.ablist[playlist.abnum];
	}

/* Idle notify: Play next element from list, if any */

	else if (id == 0) {

	    if (playlist.abnum >= 0) {
	        playlist.abnum += 1;
	        if ((size_t)playlist.abnum >= strlen(playlist.ablist)) {
	            playlist.abnum = 0;
	            if (playlist.seginc == 0)
	                playlist.abnum = -1;
	            else {
	                playlist.segnum += 1;
	                if (playlist.segnum > playlist.nsegs) {
	                    playlist.segnum = 0;
	                    playlist.abnum = -1;
	                }
	            }
	        }
	        id = (int)playlist.ablist[playlist.abnum];
	    }
	}
	set_panel_int(Abtool_win->seg_text, PANEL_VALUE, playlist.segnum);

/* Start playing if id is valid */

	if (id > 0) {
	    if (islower(id)) id = toupper(id);
	    cp = strchr(idchar, id);
	    id = cp ? cp - idchar : -1;
	    abp_start_play(id, playlist.segnum);
	}
}

stop_play()
{
	playlist.abnum = -1;	/* Don't start any new segments */
	if (playlist.seginc != 0) /* If stepping through segments, reset to 0 */
	    set_panel_int(Abtool_win->seg_text, PANEL_VALUE, 0);
	abp_abort_play();
	if (xv_get(Abtool_pwin->audio_hold, PANEL_VALUE)) abp_close_device();
}

/*
 * Notify callback function for 'delay', 'gain' text items.
 */
Panel_setting
align_notify(Panel_item item, Event *event)
{
	set_align(align_id);
	show_align(align_id);
	return panel_text_notify(item, event);
}

show_align(int n)
{
	struct abfile *f;

	align_id = -1;
	if (strlen(filename[n]) <= (size_t)0) return;

	align_id = n;
	set_label_char(Abtool_pwin->file, idchar[n]);
	f = abp_get_abfile(n);
	set_panel_dbl(Abtool_pwin->corr,PANEL_LABEL_STRING,"%6.3f", f->p.corr);
	set_panel_int(Abtool_pwin->delay, PANEL_VALUE, nint(1000*f->p.delay));
	set_panel_dbl(Abtool_pwin->gain, PANEL_VALUE, "%5.2f", f->p.scale);
}

set_align(int n)
{
	int nd, nf;
	struct abfile *f;

	if (strlen(filename[n]) <= (size_t)0 || n != align_id) return;

	f = abp_get_abfile(n);
	nf = nint(1000 * f->p.delay);
	nd = get_value_int(Abtool_pwin->delay);
	if (nf != nd) abp_align(n, .001*nd, 0.0);
}

int
get_segnum()
{
	int segnum;

	segnum = MAX(0, get_value_int(Abtool_win->seg_text));
	return set_panel_int(Abtool_win->seg_text, PANEL_VALUE, segnum);
}

int
get_value_int(Xv_opaque item)
{
	int n;

	if (sscanf((char *)xv_get(item, PANEL_VALUE), "%d", &n) < 1) n = 0;
	return n;
}

double
get_value_double(Xv_opaque item)
{
	float f;

	if (sscanf((char *)xv_get(item, PANEL_VALUE), "%f", &f) < 1) f = 0.0;
	return f;
}

set_panel_int(Xv_opaque item, int type, int n)
{
	char str[20];

	sprintf(str, "%d", n);
	xv_set(item, type, str, 0);
	return n;
}

double
set_panel_dbl(Xv_opaque item, int type, char *fmt, double f)
{
	char str[20];

	sprintf(str, fmt, f);
	xv_set(item, type, str, 0);
	return f;
}

void
set_label_char(Xv_opaque item, char chr)
{
	char str[2];

	str[0] = chr;
	str[1] = 0;
	xv_set(item, PANEL_LABEL_STRING, str, NULL);
}

