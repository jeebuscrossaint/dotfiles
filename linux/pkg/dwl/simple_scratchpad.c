/* ************************************************************************** */
/*                                                 @@@            @@@@@@@@    */
/*                                                  @@@          @@@@@@@@@@   */
/*                                                   @@!         @@!   @@@@   */
/*                                                    !@!        !@!  @!@!@   */
/*   simple_scratchpad.c                               @!!       @!@ @! !@!   */
/*                                                      !!!      !@!!!  !!!   */
/*   By: julmajustus <julmajustus@tutanota.com>          !!:     !!:!   !!!   */
/*                                                        ::!    :!:    !:!   */
/*   Created: 2024/12/19 19:35:02 by jmakkone           ::    ::::::: ::   */
/*   Updated: 2026/05/20 23:58:16 by julmajustus            : :   : : :  :    */
/*                                                                            */
/* ************************************************************************** */

void
addscratchpad(const Arg *arg)
{
	Client *cc, *c = focustop(selmon);

	if (!c)
		return;
	/* Check if the added client is already a scratchpad client */
	for (int i = 0; i < SCRATCHPAD_COUNT; i++) {
		wl_list_for_each(cc, &scratchpad_clients[i], link_temp) {
			if (cc == c)
				return;
		}
	}
	if (!c->isfloating) {
		setfloating(c, 1);
	}
	wl_list_insert(&scratchpad_clients[scratchpad_sel], &c->link_temp);
}

void
togglescratchpad(const Arg *arg)
{
	Client *c;
	Monitor *m = selmon;

	scratchpad_visible[scratchpad_sel] = !scratchpad_visible[scratchpad_sel];
	if (scratchpad_visible[scratchpad_sel]) {
		wl_list_for_each(c, &scratchpad_clients[scratchpad_sel], link_temp) {
			c->mon = m;
			c->tags = m->tagset[m->seltags];
			arrange(m);
			focusclient(c, 1);
		}
	} else {
		wl_list_for_each(c, &scratchpad_clients[scratchpad_sel], link_temp) {
			c->tags = 0;
			focusclient(focustop(m), 1);
			arrange(m);
		}
	}
}

void
removescratchpad(const Arg *arg)
{
	Client *sc, *c = focustop(selmon);
	if (!c)
		return;
	for (int i = 0; i < SCRATCHPAD_COUNT; i++) {
		/* Check if c is in scratchpad_clients */
		wl_list_for_each(sc, &scratchpad_clients[i], link_temp) {
			if (sc == c) {
				wl_list_remove(&c->link_temp);
				return;
			}
		}
	}
}

void
setscratchpad(const Arg *arg)
{
	int idx = arg->i;

	if (idx < 0)
		idx = 0;
	else if (idx >= SCRATCHPAD_COUNT)
		idx = SCRATCHPAD_COUNT - 1;
	scratchpad_sel = idx;
}
