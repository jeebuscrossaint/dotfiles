/* See LICENSE file for copyright and license details. */


/* coat theming: see linux/pkg/README.md. Guarded so a clone without coat still
 * builds, on the framer fallbacks below. */
#if defined(__has_include)
#  if __has_include("coat-colors.h")
#    include "coat-colors.h"
#  endif
#endif
#ifndef COAT_THEMED
#  define COAT_FG     0xd0d0d0ff  /* base05 */
#  define COAT_BG     0x181818e6  /* base00 + popup opacity */
#  define COAT_BORDER 0x747474ff  /* base03 */
#endif
#ifndef COAT_FONT
#  define COAT_FONT "MartianMono Nerd Font Mono:size=14"
#endif

/* appearance */
static const char *fonts[] = { COAT_FONT };

static unsigned int padding = 12;
static unsigned int borderpx = 2; /* set to 0 to disable */ 
static uint32_t color[] = {
	COAT_FG,     /* foreground */
	COAT_BG,     /* background */
	COAT_BORDER, /* border */
};

/* geometry */
/*
 * note: position of notification is not absolute, it will
 *       appear below a bar for example
 */
static const bool dynamic_width = true;
static unsigned int max_width = 360;
static unsigned int max_height = 512;
static int32_t margin = 14;
/* ZWLR_LAYER_SURFACE_V1_ANCHOR_{TOP,BOTTOM,LEFT,RIGHT} */
static uint32_t anchor =
	/* add LEFT to center the notification */
	ZWLR_LAYER_SURFACE_V1_ANCHOR_TOP |
	ZWLR_LAYER_SURFACE_V1_ANCHOR_RIGHT;

static unsigned int duration = 5; /* in seconds */

static const char *output_name = NULL;
