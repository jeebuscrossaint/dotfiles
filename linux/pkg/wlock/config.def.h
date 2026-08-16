/* coat theming: see linux/pkg/README.md. Guarded so a clone without coat still
 * builds, on the framer fallbacks below. wlock stores 32-bit components and
 * scales them from 8-bit hex exactly as wlock.c does. */
#if defined(__has_include)
#  if __has_include("coat-colors.h")
#    include "coat-colors.h"
#  endif
#endif
#ifndef COAT_THEMED
#  define COAT_C8(x) ((x) * (0xffffffffu / 0xffu))
#  define COAT_RGB(hex) \
	COAT_C8(((hex) >> 16) & 0xff), \
	COAT_C8(((hex) >>  8) & 0xff), \
	COAT_C8(((hex) >>  0) & 0xff)
#  define COAT_INIT      COAT_RGB(0x181818)  /* base00 */
#  define COAT_INPUT     COAT_RGB(0x747474)  /* base03 */
#  define COAT_INPUT_ALT COAT_RGB(0x20bcfc)  /* base0D */
#  define COAT_FAILED    COAT_RGB(0xfd886b)  /* base08 */
#endif

static Clr colorname[4] = {
	[INIT]      = { COAT_INIT },
	[INPUT]     = { COAT_INPUT },
	[INPUT_ALT] = { COAT_INPUT_ALT },
	[FAILED]    = { COAT_FAILED },
};

/* treat a cleared input like a wrong password (color) */
static const int failonclear = 1;
