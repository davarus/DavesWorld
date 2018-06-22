/*
 * MESSAGE OF THE DAY
 *
 * BUGS:
 *	When a centerprint occures while the MOTD is displayed it will cause
 *	either the MOTD to flicker or will not be displayed.  I know how to fix
 *	this I'm just to lazy to do it for such a small problem.
 *
 * Copyright (C) 1997-99 David Russell
 *        ALL RIGHTS RESERVED!
 */
/*******************************************************************************
 * motd globals
 ******************************************************************************/
float	FL_MOTD =		8192;
float	MOTD_IDELAY =	1;		/* delay before showing */
float	MOTD_MDELAY =	1.5;  	/* delay before refreshes */
float	MOTD_DURATION =	15;		/* how long to display it */


/*******************************************************************************
 * motd::think()
 ******************************************************************************/
void () motd_think =
{
        local string line1, line2, line3, line4;

	/* have they disconnected? */
	if (!(self.owner.flags & FL_CLIENT)) {
		remove(self);
		return;
	}

	/* print the motd */
	line1 = "Welcome to my world: Dave's World\n";
	line2 = "Last Modified: 6/12/99\n\n";
	line3 = "For more information contact:\n";
	line4 = "'David Russell' <xxxxxxxxxxxxxxx>\n";
	centerprint4(self.owner, line1, line2, line3, line4);

	/* remove us if we've lived our life */
	if (self.health > time) {
		self.nextthink = time + MOTD_MDELAY;
	} else {
		remove(self);
		return;
	}
};


/*******************************************************************************
 * motd::first()
 ******************************************************************************/
void () motd_first =
{
	sprint(self.owner, "No Bots\nNo Bots Please\nHumans Only Please\n\n");
	sprint(self.owner, "Welcome to Dave's World!\n");
	self.think = motd_think;
	self.nextthink = time + MOTD_MDELAY;
};


/*******************************************************************************
 * motd::init()
 ******************************************************************************/
void () motd_init =
{
	local entity motd;

	/* do not print on level changes */
	if (self.flags & FL_MOTD)
		return;

	/* initialize the motd entity */
	self.flags = self.flags | FL_MOTD;
	motd = spawn();
	motd.owner = self;
	motd.think = motd_first;
	motd.health = time + MOTD_DURATION;
	motd.nextthink = time + MOTD_IDELAY;
};

