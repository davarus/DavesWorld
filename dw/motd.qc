/* Message Of The Day
   ----------------------------------------
   David Russell <xxxxxxxxxxxxxxxxxxxxx>
   Modified:                    7/14/97


TODO:
	Make it more useful...

BUGS:
	A regular centerprint during the MOTD causes it to flicker or
	isn't printed...
		Easy enough to fix, but why bother?
*/


/*  --- Colored Alphabet ---
   ABCDEFGHIJKLMNOPQRSTUVWXYZ
   ÁÂÃÄÅÆÇÈÉÊËÌÍÎÏĞÑÒÓÔÕÖ×ØÙÚ

   abcdefghijklmnopqrstuvwxyz
   áâãäåæçèéêëìíîïğñòóôõö÷øùû
*/

// Player Flags... one is for level changes and the other is
// so that it doesn't start two...
float		FL_MOTD =		8192;
float		FL_MOTD_RUNNING =	16384;

// Deathmatch settings... here so I don't need to put them in defs.qc
float		DM5 =			5;
float		DM_CTH =		16;
float		DM_CTF =		32;
float		DM_RUNES =		128;
float		DM_HOOK =		256;
float		DM_QUAKES =		512;
float		DM_SPAWN =		1024;
float		DM_CUSTOM =		2048;

void () MOTD_printmessage =
{
	local string line1, line2, line3, line4, line5, line6, line7;

	line1  = "Welcome to my world:\nÄáöå'ó ×ïòìä\nModified: 8/1/97\n\n";
	line2  = "\n\n!!!!See Web-Page please!!!!\nhttp://xxxxxxxxxxxxxxxxxxxxxxxxxx\n\n";
	line7  = "\nFor more help or information see:               \nÄavid Òussell <xxxxxxxxxxxxxxxxxxxx>\nhttp://xxxxxxxxxxxxxxxxxxxxxxxxxx";

	// Have they disconnected?
	if (!(self.owner.flags & FL_CLIENT))
	{
		remove(self);
		return;
	}

	centerprint7(self.owner, line1, line2, line3, line4, line5, line6, line7);

	if (self.health > time)
	{
		self.nextthink = time + 1.5;
	}
	else
	{
		self.owner.flags = self.owner.flags - (FL_MOTD + FL_MOTD_RUNNING);
		remove(self);
		return;	
	}
};

// Stuff MOTD
void () MOTD_PreThink =
{
	self.health = time + 10;
	self.think = MOTD_printmessage;
	self.nextthink = time + frametime;

	// ANTI-BOT Messages...
	sprint(self.owner, "No Bots\nNo Bots Please\nHumans Only Please\n\n\n\n\n\n\n");
};

// Init the MOTD
void () MOTD_Init =
{
	local entity motd;

	self.flags = self.flags + FL_MOTD_RUNNING;
	motd = spawn();
	motd.owner = self;
	motd.think = MOTD_PreThink;
	motd.nextthink = time + frametime;
};
