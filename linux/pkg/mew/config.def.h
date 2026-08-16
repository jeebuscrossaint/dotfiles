/* See LICENSE file for copyright and license details. */
/* Default settings; can be overriden by command line. */

/* coat theming ---------------------------------------------------------------
 * coat renders ~/.config/mew/coat-colors.h; the Makefile adds
 * -I$(HOME)/.config/mew so it is found. Guarded so a fresh clone without coat
 * still builds, on the framer values below. */
#if defined(__has_include)
#  if __has_include("coat-colors.h")
#    include "coat-colors.h"
#  endif
#endif

#ifndef COAT_THEMED
#  define COAT_NORM_FG 0xd0d0d0ff  /* base05 */
#  define COAT_NORM_BG 0x181818ff  /* base00 */
#  define COAT_SEL_FG  0x181818ff
#  define COAT_SEL_BG  0x20bcfcff  /* base0D, the accent -- matches tofi */
#  define COAT_OUT_FG  0x181818ff
#  define COAT_OUT_BG  0x32ccdcff  /* base0B */
#endif
#ifndef COAT_FONT
#  define COAT_FONT "MartianMono Nerd Font Mono:size=10"
#endif


static int top              = 1;                       /* -b option; if 0, appear at bottom */
static const char *fonts[]  = { COAT_FONT }; /* -f option overrides fonts[0] */ /* -f option overrides fonts[0] */
static const char *prompt   = "\xe2\x9d\xaf";                    /* -p option; prompt to the left of input field */
static uint32_t colors[][2] = {
	/*               fg             bg          */
	[SchemeNorm] = { COAT_NORM_FG,  COAT_NORM_BG },
	[SchemeSel]  = { COAT_SEL_FG,   COAT_SEL_BG  },
	[SchemeOut]  = { COAT_OUT_FG,   COAT_OUT_BG  },
};

/* -m option; if provided, use that output instead of default output */
static const char *output_name = NULL;

/* -l option; if nonzero, use vertical list with given number of lines */
static unsigned int lines      = 8;

/* -p option; display input as asterisks */
static int passwd = 0;

/*
 * Characters not considered part of a word while deleting words
 * for example: " /?\"&[]"
 */
static const char worddelimiters[] = " ";
