/* Taken from https://github.com/djpohly/dwl/issues/466 */
#define COLOR(hex)    { ((hex >> 24) & 0xFF) / 255.0f, \
                        ((hex >> 16) & 0xFF) / 255.0f, \
                        ((hex >> 8) & 0xFF) / 255.0f, \
                        (hex & 0xFF) / 255.0f }
/* appearance */
static const int sloppyfocus               = 1;  /* focus follows mouse */
static const int bypass_surface_visibility = 0;  /* 1 means idle inhibitors will disable idle tracking even if it's surface isn't visible  */
static const int smartgaps                 = 1;  /* sway: smart_gaps on */  /* 1 means no outer gap when there is only one window */
static const int monoclegaps               = 0;  /* 1 means outer gaps in monocle layout */
static const unsigned int borderpx         = 1;  /* border pixel of windows */
static const int showbar                   = 1; /* 0 means no bar */
static const int topbar                    = 1; /* 0 means bottom bar */
/* coat theming ---------------------------------------------------------------
 * coat renders ~/.config/dwl/coat-colors.h; config.mk adds -I$(HOME)/.config/dwl
 * so it is found. If it is absent (fresh clone, coat not installed) the build
 * still works and falls back to the framer values below. */
#if defined(__has_include)
#  if __has_include("coat-colors.h")
#    include "coat-colors.h"
#  endif
#endif

#ifndef COAT_THEMED
/* fg is bar-only (status text, layout symbol, tags, title); border is
 * window-only. They differ on purpose -- see templates/dwl.tera in coat. */
#  define COAT_NORM_FG     0xd0d0d0ff  /* base05 */
#  define COAT_NORM_BG     0x181818ff  /* base00 */
#  define COAT_NORM_BORDER 0x747474ff  /* base03 */
#  define COAT_SEL_FG      0x20bcfcff  /* base0D, accent */
#  define COAT_SEL_BG      0x181818ff
#  define COAT_SEL_BORDER  0xd0d0d0ff  /* base05 */
#  define COAT_URG_FG      0xfd886bff  /* base08 */
#  define COAT_URG_BG      0x181818ff
#  define COAT_URG_BORDER  0xfd886bff
#  define COAT_ROOTCOLOR   0x181818ff
#endif
#ifndef COAT_FONT
#  define COAT_FONT "MartianMono Nerd Font Mono:size=10"
#endif

static const char *fonts[]                 = {COAT_FONT};
static const float rootcolor[]             = COLOR(COAT_ROOTCOLOR); /* base00 */
static const int centeredmaster_always     = 0;  /* always center even if only 1 window */
/* Gaps. All four equal on purpose: tile() reads gappov as the x/width axis and
 * gappoh as y/height, while monocle() reads them the other way round (dwl.c:2695
 * vs :4142). With one value everywhere that disagreement is invisible; split
 * them and one of the two layouts will gap the wrong axis.
 *
 * smartgaps above drops the OUTER gap when a single client is tiled, which is
 * what sway's `smart_gaps on` amounted to. Tune live with Super+Alt+h/l (both),
 * +Ctrl for inner only, +Shift for outer only; Super+Alt+0 toggles gaps off,
 * Super+Alt+g restores these numbers. */
static const unsigned int gappih          = 8;  /* horiz inner gap between windows */
static const unsigned int gappiv          = 8;  /* vert inner gap between windows */
static const unsigned int gappoh          = 8;  /* horiz outer gap between windows and screen edge */
static const unsigned int gappov          = 8;  /* vert outer gap between windows and screen edge */
/* This conforms to the xdg-protocol. Set the alpha to zero to restore the old behavior */
/* modes: keybindings can be scoped to a mode, the way sway's `mode "resize"`
 * block was. NORMAL is implicit; entermode(&(Arg){.ui = RESIZE}) switches, and
 * entermode with .ui = 0 returns to NORMAL. */
enum {
	RESIZE,
};
const char *modes_labels[] = {
	"resize",
};

static const float fullscreen_bg[]         = {0.0f, 0.0f, 0.0f, 1.0f}; /* You can also use glsl colors */
static uint32_t colors[][3]                = {
	/*               fg              bg              border    */
	[SchemeNorm] = { COAT_NORM_FG,   COAT_NORM_BG,   COAT_NORM_BORDER },
	[SchemeSel]  = { COAT_SEL_FG,    COAT_SEL_BG,    COAT_SEL_BORDER  },
	[SchemeUrg]  = { COAT_URG_FG,    COAT_URG_BG,    COAT_URG_BORDER  },
};

static const float resize_factor           = 0.0002f; /* Resize multiplier for mouse resizing, depends on mouse sensivity. */
static const uint32_t resize_interval_ms   = 16; /* Resize interval depends on framerate and screen refresh rate. */

enum Direction { DIR_LEFT, DIR_RIGHT, DIR_UP, DIR_DOWN };

static int enableautoswallow = 1; /* enables autoswallowing newly spawned clients */
static float swallowborder = 1.0f; /* add this multiplied by borderpx to border when a client is swallowed */

#define SCRATCHPAD_COUNT 3
/* tagging */
static char *tags[] = { "1", "2", "3", "4", "5", "6", "7", "8", "9", "10" };

/* logging */
static int log_level = WLR_ERROR;

/* Autostart */
static const char *const autostart[] = {
	/* Ported from the sway config's exec lines. Dropped: autotiling-rs (dwl
	 * tiles natively), nm-applet (no tray without bar-systray), and the bare
	 * xdg-desktop-portal (it is dbus-activated, launching it by hand is wrong). */
	"dbus-update-activation-environment", "--all", NULL,
	"dbus-update-activation-environment", "WAYLAND_DISPLAY", "XDG_CURRENT_DESKTOP=wlroots", NULL,
	/* NOTE: the sway config pointed at /usr/libexec, which does not exist here --
	 * these binaries live in /usr/lib, so those two exec lines never ran. */
	"/usr/lib/xdg-desktop-portal-wlr", NULL,
	"ww", "-m", "fill", "/home/amarnath/jbwallpapers/wallpapers/Matanuska-River-ENBLA05.jpg", NULL,
	/* swayidle, not widle: widle's .resumed handler is a noop, so it cannot
	 * express the `timeout 600 dpms-off resume dpms-on` pair or before-sleep.
	 * widle is built and installed if a single-timeout job ever needs it. */
	"swayidle", "-w", "-C", "/home/amarnath/.config/swayidle/config", NULL,
	"dunst", NULL,
	"wl-clip-persist", "--clipboard", "regular", NULL,
	"sh", "-c", "wl-paste --type text --watch cliphist store", NULL,
	"sh", "-c", "wl-paste --type image --watch cliphist store", NULL,
	"start-polkit", NULL,
	"canvas-notify", NULL,
	"artix-pipewire-launcher", "restart", NULL,
	"nvibrant", "1023", "1023", "1023", "1023", NULL,
	"refresh-paru-completions", NULL,
	NULL /* terminate */
};

static const Rule rules[] = {
	/* app_id             title       tags mask     isfloating   isterm   noswallow   monitor */
	{ "foot",             NULL,       0,            0,           1,       1,          -1 },
	{ "Gimp_EXAMPLE",     NULL,       0,            1,           0,       0,          -1 }, /* Start on currently visible tags floating, not tiled */
	{ "firefox_EXAMPLE",  NULL,       1 << 8,       0,           0,       0,          -1 }, /* Start on ONLY tag "9" */
    /* default/example rule: can be changed but cannot be eliminated; at least one rule must exist */
};

/* layout(s) */
static const Layout layouts[] = {
	/* symbol     arrange function */
	{ "|w|",      btrtile },
	{ "[]=",      tile },
	{ "><>",      NULL },    /* no layout function means floating behavior */
	{ "[M]",      monocle },
	{ "[\\]",     dwindle },
	{ "TTT",      bstack },
	{ "===",      bstackhoriz },
	{ "|M|",      centeredmaster },
	{ "###",      gaplessgrid },
	{ "[E]",      deck },
	{ "@|@",      snail },
	{ "||=",      mastercol },
};

/* monitors */
/* (x=-1, y=-1) is reserved as an "autoconfigure" monitor position indicator
 * WARNING: negative values other than (-1, -1) cause problems with Xwayland clients due to
 * https://gitlab.freedesktop.org/xorg/xserver/-/issues/899 */
static const MonitorRule monrules[] = {
   /*    name  mfact nmaster  scale       layout              rotate/reflect   x   y  resx resy      rate mode adaptive */
   /*{"eDP-1",  0.5f,      1,     2, &layouts[0], WL_OUTPUT_TRANSFORM_NORMAL,  0,  0,    0,   0, 120.000f,   1,       1}, -- example of a HiDPI laptop monitor at 120Hz */
   /*
	* mode lets the user decide how dwl should implement the modes:
	* -1 sets a custom mode following the user's choice
	* All other numbers set the mode at the index n; 0 is the standard mode; see wlr-randr
	*/
	/* eDP-1: 2560x1600@240Hz OLED panel, at origin (from the sway config) */
	{  "eDP-1", 0.55f,     1,     1, &layouts[1], WL_OUTPUT_TRANSFORM_NORMAL,    0,  0, 2560, 1600,  240.0f,  -1,       1},
	/* HDMI-A-1: 3840x2160@30Hz, placed to the right of the panel */
	{"HDMI-A-1", 0.55f,    1,     1, &layouts[1], WL_OUTPUT_TRANSFORM_NORMAL, 2560,  0, 3840, 2160,   30.0f,  -1,       1},
	/* fallback for anything else */
	{     NULL, 0.55f,     1,     1, &layouts[1], WL_OUTPUT_TRANSFORM_NORMAL,   -1, -1,    0,    0,    0.0f,   0,       1},
	/* default monitor rule: can be changed but cannot be eliminated; at least one monitor rule must exist */
};

/* keyboard */
static const struct xkb_rule_names xkb_rules = {
	/* can specify fields: rules, model, layout, variant, options */
	/* example:
	.options = "ctrl:nocaps",
	*/
	.options = NULL,
};

/* input devices */
static const InputRule inputrules[] = {
	/* name                      kbcreate                 ptrcreate      */
	/* ignore bad device - like a touchpad ;) */
	{ "BAD DEVICE",              NULL,                    NULL                },
	/* ungroup ydotool device - fixes a bug */
	{ "ydotoold virtual device", createungroupedkeyboard, createpointer       },
	/* The device that XF86TouchpadToggle (and Super+Alt+v) turns on and off.
	 * Matching is strstr, not strcmp -- dwl.c:2379 -- so the bare word matches
	 * this machine's "ASUP1207:00 093A:3012 Touchpad" and stays portable. The
	 * upstream placeholder here was "Elan Touchpad", which matches nothing on
	 * this laptop: togglepointerdevice stayed NULL and both binds were no-ops. */
	{ "Touchpad",                createkeyboard,          createtogglepointer },
	{ NULL,                      createkeyboard,          createpointer       },
};

static const int repeat_rate = 50;   /* matches the sway config */
static const int repeat_delay = 200; /* matches the sway config */

/* Trackpad */
static const int tap_to_click = 1;
static const int tap_and_drag = 1;
static const int drag_lock = 1;
static const int natural_scrolling = 0;
static const int disable_while_typing = 1;
static const int left_handed = 0;
static const int middle_button_emulation = 0;
/* You can choose between:
LIBINPUT_CONFIG_SCROLL_NO_SCROLL
LIBINPUT_CONFIG_SCROLL_2FG
LIBINPUT_CONFIG_SCROLL_EDGE
LIBINPUT_CONFIG_SCROLL_ON_BUTTON_DOWN
*/
static const enum libinput_config_scroll_method scroll_method = LIBINPUT_CONFIG_SCROLL_2FG;

/* You can choose between:
LIBINPUT_CONFIG_CLICK_METHOD_NONE
LIBINPUT_CONFIG_CLICK_METHOD_BUTTON_AREAS
LIBINPUT_CONFIG_CLICK_METHOD_CLICKFINGER
*/
static const enum libinput_config_click_method click_method = LIBINPUT_CONFIG_CLICK_METHOD_BUTTON_AREAS;

/* You can choose between:
LIBINPUT_CONFIG_SEND_EVENTS_ENABLED
LIBINPUT_CONFIG_SEND_EVENTS_DISABLED
LIBINPUT_CONFIG_SEND_EVENTS_DISABLED_ON_EXTERNAL_MOUSE
*/
static const uint32_t send_events_mode = LIBINPUT_CONFIG_SEND_EVENTS_ENABLED;

/* You can choose between:
LIBINPUT_CONFIG_ACCEL_PROFILE_FLAT
LIBINPUT_CONFIG_ACCEL_PROFILE_ADAPTIVE
*/
/* Mice and other non-touchpad pointers. FLAT means no acceleration -- pointer
 * travel is proportional to how far you move the mouse, always. This is what
 * the sway config had (`input type:pointer { accel_profile flat }`); dwl
 * defaults to ADAPTIVE, which accelerates and feels twitchier by comparison.
 * accel_speed runs -1.0 (slowest) to 1.0 (fastest), 0.0 is neutral. */
static const enum libinput_config_accel_profile accel_profile = LIBINPUT_CONFIG_ACCEL_PROFILE_FLAT;
static const double accel_speed = 0.0;

/* Touchpad, kept separate. The sway config only set flat for type:pointer and
 * left the touchpad alone, and adaptive genuinely suits a touchpad better --
 * flat makes crossing a 2560px screen a multi-swipe affair. */
static const enum libinput_config_accel_profile touchpad_accel_profile = LIBINPUT_CONFIG_ACCEL_PROFILE_ADAPTIVE;
static const double touchpad_accel_speed = 0.0;

/* You can choose between:
LIBINPUT_CONFIG_TAP_MAP_LRM -- 1/2/3 finger tap maps to left/right/middle
LIBINPUT_CONFIG_TAP_MAP_LMR -- 1/2/3 finger tap maps to left/middle/right
*/
static const enum libinput_config_tap_button_map button_map = LIBINPUT_CONFIG_TAP_MAP_LRM;

static const int cursor_timeout = 3; /* sway: hide_cursor 3000 */

/* If you want to use the windows key for MODKEY, use WLR_MODIFIER_LOGO */
#define MODKEY WLR_MODIFIER_LOGO

/* dwl has no SHCMD (it is a dwm macro); define it so media-key binds can run
 * a shell command directly. */
#define SHCMD(cmd) { .v = (const char*[]){ "/bin/sh", "-c", cmd, NULL } }

#define TAGKEYS(KEY,SKEY,TAG) \
	{ MODKEY,                    KEY,            view,            {.ui = 1 << TAG} }, \
	{ MODKEY|WLR_MODIFIER_CTRL,  KEY,            toggleview,      {.ui = 1 << TAG} }, \
	{ MODKEY|WLR_MODIFIER_SHIFT, SKEY,           tag,             {.ui = 1 << TAG} }, \
	{ MODKEY|WLR_MODIFIER_CTRL|WLR_MODIFIER_SHIFT,SKEY,toggletag, {.ui = 1 << TAG} }

/* helper for spawning shell commands in the pre dwm-5.0 fashion */
#define SHCMD(cmd) { .v = (const char*[]){ "/bin/sh", "-c", cmd, NULL } }

/* commands */
/* The third element is used by the 'spawnorfocus' function to match a title/app_id.
 * If the third element is 'NULL', match on the first element instead */
static const char *termcmd[] = { "foot", NULL, NULL };
static const char *browsercmd[] = { "firefox", NULL, "Mozilla Firefox" };
static const char *menucmd[] = { "tofi-drun", NULL };
static const char *lockcmd[]    = { "gtklock-once", NULL };
static const char *reloadcmd[]  = { "dwl-reload", NULL };
static const char *kbdcmd[]     = { "wlboard", NULL };
static const char *themecmd[]   = { "theme-pick", NULL };
static const char *themerndcmd[]= { "theme-random", NULL };
static const char *shotcmd[]    = { "swayscreenshot", NULL };
static const char *shoteditcmd[]= { "swayscreenshot-edit", NULL };
static const char *pickcmd[]    = { "grimpicker", "-n", "-c", NULL };
static const char *clipcmd[]    = { "sh", "-c", "cliphist list | tofi --prompt-text 'clip \xe2\x9d\xaf ' | cliphist decode | wl-copy", NULL };

static const Key keys[] = {
	/* Note that Shift changes certain key codes: 2 -> at, etc. */
	/* modifier                  key                  function          argument */
	/* the per-axis gap functions; vanitygaps' own Mod+y/o binds were dropped
	 * because they collide with the dwindle and bstackhoriz layout keys */
	{ MODKEY|WLR_MODIFIER_ALT,   XKB_KEY_bracketleft, incihgaps,        {.i = +1} },
	{ MODKEY|WLR_MODIFIER_ALT,   XKB_KEY_bracketright,incihgaps,        {.i = -1} },
	{ MODKEY|WLR_MODIFIER_ALT,   XKB_KEY_u,           incivgaps,        {.i = +1} },
	{ MODKEY|WLR_MODIFIER_ALT,   XKB_KEY_i,           incivgaps,        {.i = -1} },
	{ MODKEY|WLR_MODIFIER_ALT,   XKB_KEY_n,           incovgaps,        {.i = +1} },
	{ MODKEY|WLR_MODIFIER_ALT,   XKB_KEY_m,           incovgaps,        {.i = -1} },
	{ MODKEY|WLR_MODIFIER_ALT,   XKB_KEY_g,           defaultgaps,      {0} },
	/* --- ported from the sway config --- */
	{ MODKEY,                    XKB_KEY_q,           spawn,            {.v = termcmd} },
	/* rebuild and restart dwl in place -- the nearest thing to sway's
	 * $mod+Shift+c reload, though only Qt6 clients survive it */
	{ MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_r,           spawn,            {.v = reloadcmd} },
	{ MODKEY,                    XKB_KEY_d,           spawn,            {.v = menucmd} },
	{ MODKEY,                    XKB_KEY_c,           killclient,       {0} },
	{ MODKEY,                    XKB_KEY_v,           spawn,            {.v = clipcmd} },
	{ MODKEY,                    XKB_KEY_t,           spawn,            {.v = themecmd} },
	{ MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_t,           spawn,            {.v = themerndcmd} },
	{ MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_s,           spawn,            {.v = shotcmd} },
	{ MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_e,           spawn,            {.v = shoteditcmd} },
	{ MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_p,           spawn,            {.v = pickcmd} },
	{ MODKEY,                    XKB_KEY_Escape,      spawn,            {.v = lockcmd} },
	{ MODKEY,                    XKB_KEY_Delete,      spawn,            {.v = kbdcmd} },
	/* media keys -- ~/.local/bin/osd both performs the change and draws the OSD */
	{ 0, XKB_KEY_XF86AudioRaiseVolume,  spawn, SHCMD("osd volume up") },
	{ 0, XKB_KEY_XF86AudioLowerVolume,  spawn, SHCMD("osd volume down") },
	{ 0, XKB_KEY_XF86AudioMute,         spawn, SHCMD("osd volume mute") },
	{ 0, XKB_KEY_XF86AudioMicMute,      spawn, SHCMD("osd mic mute") },
	{ 0, XKB_KEY_XF86AudioPlay,         spawn, SHCMD("osd playpause") },
	{ 0, XKB_KEY_XF86Launch3,           spawn, SHCMD("osd playpause") },
	{ 0, XKB_KEY_XF86MonBrightnessUp,   spawn, SHCMD("osd brightness up") },
	{ 0, XKB_KEY_XF86MonBrightnessDown, spawn, SHCMD("osd brightness down") },
	/* sway: `bindsym XF86TouchpadToggle input type:touchpad events toggle`.
	 * togglepointer flips send_events on the one device inputrules attached
	 * createtogglepointer to -- "Elan Touchpad" above -- so the rule and this
	 * bind have to name the same device to do anything. Same function as the
	 * Super+Alt+v bind further down; this just wires up the hardware key. */
	{ 0, XKB_KEY_XF86TouchpadToggle,    togglepointer, {0} },
	{ MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_Return,      spawn,            {.v = termcmd} },
	{ MODKEY,                    XKB_KEY_p,           togglebar,        {0} }, /* sway: $mod+p */
	{ MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_b,           spawnorfocus,     {.v = browsercmd} },
	/* directional focus, matching sway's $mod+Left/Down/Up/Right */
	{ MODKEY,                    XKB_KEY_Left,        focusdir,         {.ui = 0} },
	{ MODKEY,                    XKB_KEY_Right,       focusdir,         {.ui = 1} },
	{ MODKEY,                    XKB_KEY_Up,          focusdir,         {.ui = 2} },
	{ MODKEY,                    XKB_KEY_Down,        focusdir,         {.ui = 3} },
	{ MODKEY,                    XKB_KEY_j,           focusstack,       {.i = +1} },
	{ MODKEY,                    XKB_KEY_k,           focusstack,       {.i = -1} },
	{ MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_j,           movestack,        {.i = +1} },
	{ MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_k,           movestack,        {.i = -1} },
	{ MODKEY,                    XKB_KEY_i,           incnmaster,       {.i = +1} },
	{ MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_d,           incnmaster,       {.i = -1} },
	{ MODKEY,                    XKB_KEY_h,           setmfact,         {.f = -0.05f} },
	{ MODKEY,                    XKB_KEY_l,           setmfact,         {.f = +0.05f} },
	{ MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_H,           setcfact,         {.f = +0.25f} },
	{ MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_L,           setcfact,         {.f = -0.25f} },
	{ MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_K,           setcfact,         {.f = 0.0f} },
	{ MODKEY|WLR_MODIFIER_ALT,  XKB_KEY_h,          incgaps,       {.i = +1 } },
	{ MODKEY|WLR_MODIFIER_ALT,  XKB_KEY_l,          incgaps,       {.i = -1 } },
	{ MODKEY|WLR_MODIFIER_ALT|WLR_MODIFIER_SHIFT,   XKB_KEY_H,      incogaps,      {.i = +1 } },
	{ MODKEY|WLR_MODIFIER_ALT|WLR_MODIFIER_SHIFT,   XKB_KEY_L,      incogaps,      {.i = -1 } },
	{ MODKEY|WLR_MODIFIER_ALT|WLR_MODIFIER_CTRL,    XKB_KEY_h,      incigaps,      {.i = +1 } },
	{ MODKEY|WLR_MODIFIER_ALT|WLR_MODIFIER_CTRL,    XKB_KEY_l,      incigaps,      {.i = -1 } },
	{ MODKEY|WLR_MODIFIER_ALT,  XKB_KEY_0,          togglegaps,     {0} },
	{ MODKEY|WLR_MODIFIER_ALT|WLR_MODIFIER_SHIFT,   XKB_KEY_parenright,defaultgaps,    {0} },
	{ MODKEY|WLR_MODIFIER_ALT,  XKB_KEY_y,          incohgaps,     {.i = +1 } },
	{ MODKEY|WLR_MODIFIER_ALT,  XKB_KEY_o,          incohgaps,     {.i = -1 } },
	{ MODKEY,                    XKB_KEY_Return,      zoom,             {0} },
	{ MODKEY,                    XKB_KEY_Tab,         view,             {0} },
	{ MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_c,           killclient,       {0} },
	{ MODKEY|WLR_MODIFIER_CTRL,  XKB_KEY_w,           setlayout,        {.v = &layouts[0]} }, /* btrtile        |w|  BSP, you pick the split */
	{ MODKEY|WLR_MODIFIER_CTRL,  XKB_KEY_t,           setlayout,        {.v = &layouts[1]} }, /* tile           []=  classic master/stack */
	{ MODKEY|WLR_MODIFIER_CTRL,  XKB_KEY_f,           setlayout,        {.v = &layouts[2]} }, /* floating       ><> */
	{ MODKEY|WLR_MODIFIER_CTRL,  XKB_KEY_m,           setlayout,        {.v = &layouts[3]} }, /* monocle        [M] */
	{ MODKEY|WLR_MODIFIER_CTRL,  XKB_KEY_y,           setlayout,        {.v = &layouts[4]} }, /* dwindle        [\]  fibonacci spiral */
	{ MODKEY|WLR_MODIFIER_CTRL,  XKB_KEY_s,           setlayout,        {.v = &layouts[5]} }, /* bstack         TTT  master top, stack row below */
	{ MODKEY|WLR_MODIFIER_CTRL,  XKB_KEY_o,           setlayout,        {.v = &layouts[6]} }, /* bstackhoriz    ===   */
	{ MODKEY|WLR_MODIFIER_CTRL,  XKB_KEY_u,           setlayout,        {.v = &layouts[7]} }, /* centeredmaster |M|  master centred, stack both sides */
	{ MODKEY|WLR_MODIFIER_CTRL,  XKB_KEY_g,           setlayout,        {.v = &layouts[8]} }, /* gaplessgrid    ### */
	{ MODKEY|WLR_MODIFIER_CTRL,  XKB_KEY_a,           setlayout,        {.v = &layouts[9]} }, /* deck           [E]  stack becomes a monocle deck */
	{ MODKEY|WLR_MODIFIER_CTRL,  XKB_KEY_n,           setlayout,        {.v = &layouts[10]} }, /* snail          @|@  spiral master + spiral stack */
	{ MODKEY|WLR_MODIFIER_CTRL,  XKB_KEY_r,           setlayout,        {.v = &layouts[11]} }, /* mastercol      ||=  master split into columns */
	{ MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_z,           addscratchpad,    {0} },
	{ MODKEY|WLR_MODIFIER_CTRL,  XKB_KEY_z,           togglescratchpad, {0} },
	{ MODKEY,                    XKB_KEY_z,           removescratchpad, {0} },
	/* step through every layout in order; Ctrl goes backwards */
	{ MODKEY,                    XKB_KEY_space,       cyclelayout,      {.i = +1} },
	{ MODKEY|WLR_MODIFIER_CTRL,  XKB_KEY_space,       cyclelayout,      {.i = -1} },
	{ MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_space,       togglefloating,   {0} },
	{ MODKEY,                    XKB_KEY_e,           togglefullscreen, {0} },
	/* sway bound fullscreen to $mod+f and $mod+m; f is free here since the
	 * layouts moved to Super+Ctrl, so keep the muscle memory working. */
	{ MODKEY,                    XKB_KEY_f,           togglefullscreen, {0} },
	{ MODKEY,                    XKB_KEY_x,           toggleswallow,    {0} },
	{ MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_A,           toggleautoswallow,{0} },
	{ MODKEY|WLR_MODIFIER_ALT,   XKB_KEY_v,           togglepointer,    {0} },
	{ MODKEY,                    XKB_KEY_F5,          togglefullscreenadaptivesync, {0} },
	{ MODKEY,                    XKB_KEY_comma,       focusmon,         {.i = WLR_DIRECTION_LEFT} },
	{ MODKEY,                    XKB_KEY_period,      focusmon,         {.i = WLR_DIRECTION_RIGHT} },
	{ MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_less,        tagmon,           {.i = WLR_DIRECTION_LEFT} },
	{ MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_greater,     tagmon,           {.i = WLR_DIRECTION_RIGHT} },
	{ MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_Up,         swapclients,       {.i = DIR_UP} },
	{ MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_Down,       swapclients,       {.i = DIR_DOWN} },
	{ MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_Right,      swapclients,       {.i = DIR_RIGHT} },
	{ MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_Left,       swapclients,       {.i = DIR_LEFT} },
	{ MODKEY|WLR_MODIFIER_CTRL,  XKB_KEY_Right,      setratio_h,        {.f = +0.025f} },
	{ MODKEY|WLR_MODIFIER_CTRL,  XKB_KEY_Left,       setratio_h,        {.f = -0.025f} },
	{ MODKEY|WLR_MODIFIER_CTRL,  XKB_KEY_Up,         setratio_v,        {.f = -0.025f} },
	{ MODKEY|WLR_MODIFIER_CTRL,  XKB_KEY_Down,       setratio_v,        {.f = +0.025f} },
	{ MODKEY|WLR_MODIFIER_ALT,  XKB_KEY_1,           setscratchpad,    {.i = 0} },
	{ MODKEY|WLR_MODIFIER_ALT,  XKB_KEY_2,           setscratchpad,    {.i = 1} },
	{ MODKEY|WLR_MODIFIER_ALT,  XKB_KEY_3,           setscratchpad,    {.i = 2} },
	TAGKEYS(          XKB_KEY_1, XKB_KEY_exclam,                        0),
	TAGKEYS(          XKB_KEY_2, XKB_KEY_at,                            1),
	TAGKEYS(          XKB_KEY_3, XKB_KEY_numbersign,                    2),
	TAGKEYS(          XKB_KEY_4, XKB_KEY_dollar,                        3),
	TAGKEYS(          XKB_KEY_5, XKB_KEY_percent,                       4),
	TAGKEYS(          XKB_KEY_6, XKB_KEY_asciicircum,                   5),
	TAGKEYS(          XKB_KEY_7, XKB_KEY_ampersand,                     6),
	TAGKEYS(          XKB_KEY_8, XKB_KEY_asterisk,                      7),
	TAGKEYS(          XKB_KEY_9, XKB_KEY_parenleft,                     8),
	/* tenth tag: sway had workspaces 1-10, and $mod+0 was workspace 10 rather
	 * than dwl's view-all, so that pair is replaced here. */
	TAGKEYS(          XKB_KEY_0, XKB_KEY_parenright,                    9),
	{ MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_q,           quit,             {0} },

	{ MODKEY,                    XKB_KEY_r,           entermode,        {.i = RESIZE} },

	/* Ctrl-Alt-Backspace and Ctrl-Alt-Fx used to be handled by X server */
	{ WLR_MODIFIER_CTRL|WLR_MODIFIER_ALT,XKB_KEY_Terminate_Server, quit, {0} },
	/* Ctrl-Alt-Fx is used to switch to another VT, if you don't know what a VT is
	 * do not remove them.
	 */
#define CHVT(n) { WLR_MODIFIER_CTRL|WLR_MODIFIER_ALT,XKB_KEY_XF86Switch_VT_##n, chvt, {.ui = (n)} }
	CHVT(1), CHVT(2), CHVT(3), CHVT(4), CHVT(5), CHVT(6),
	CHVT(7), CHVT(8), CHVT(9), CHVT(10), CHVT(11), CHVT(12),
};

static const Modekey modekeys[] = {
	/* Mirrors the sway config's `mode "resize"`: Super+r enters, arrows or hjkl
	 * resize, Return/Escape leave. setratio_h/_v come from btrtile and resize on
	 * both axes; in the other layouts only the horizontal axis moves.
	 *
	 * mode     modifier  key                function     argument */
	{ RESIZE, { 0, XKB_KEY_Left,   setratio_h, {.f = -0.025f} } },
	{ RESIZE, { 0, XKB_KEY_Right,  setratio_h, {.f = +0.025f} } },
	{ RESIZE, { 0, XKB_KEY_Up,     setratio_v, {.f = -0.025f} } },
	{ RESIZE, { 0, XKB_KEY_Down,   setratio_v, {.f = +0.025f} } },
	{ RESIZE, { 0, XKB_KEY_h,      setratio_h, {.f = -0.025f} } },
	{ RESIZE, { 0, XKB_KEY_l,      setratio_h, {.f = +0.025f} } },
	{ RESIZE, { 0, XKB_KEY_k,      setratio_v, {.f = -0.025f} } },
	{ RESIZE, { 0, XKB_KEY_j,      setratio_v, {.f = +0.025f} } },
	{ RESIZE, { 0, XKB_KEY_Return, entermode,  {.i = NORMAL} } },
	{ RESIZE, { 0, XKB_KEY_Escape, entermode,  {.i = NORMAL} } },
};

static const Button buttons[] = {
	{ ClkLtSymbol, 0,      BTN_LEFT,   setlayout,      {.v = &layouts[0]} },
	{ ClkLtSymbol, 0,      BTN_RIGHT,  setlayout,      {.v = &layouts[2]} },
	{ ClkTitle,    0,      BTN_MIDDLE, zoom,           {0} },
	{ ClkStatus,   0,      BTN_MIDDLE, spawn,          {.v = termcmd} },
	{ ClkClient,   MODKEY, BTN_LEFT,   moveresize,     {.ui = CurMove} },
	{ ClkClient,   MODKEY, BTN_MIDDLE, togglefloating, {0} },
	{ ClkClient,   MODKEY, BTN_RIGHT,  moveresize,     {.ui = CurResize} },
	{ ClkTagBar,   0,      BTN_LEFT,   view,           {0} },
	{ ClkTagBar,   0,      BTN_RIGHT,  toggleview,     {0} },
	{ ClkTagBar,   MODKEY, BTN_LEFT,   tag,            {0} },
	{ ClkTagBar,   MODKEY, BTN_RIGHT,  toggletag,      {0} },
};
