/* Message Of The Day
   David Russell <xxxxxxxxxxxxxxxxxxxxx>>
   6/16/97

BUGS:
   SZ_GetSize: overflow... blah blah
		centerprint to a non-client?
		FIXED?
*/


/*
ABCDEFGHIJKLMNOPQRSTUVWXYZ
ÁÂÃÄÅÆÇÈÉÊËÌÍÎÏĞÑÒÓÔÕÖ×ØÙÚ

abcdefghijklmnopqrstuvwxyz
áâãäåæçèéêëìíîïğñòóôõö÷øùû
*/

float		FL_MOTD =		8192;
float		FL_MOTD_RUNNING =	16384;

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
	local float val;


	line1  = "Welcome to my world:\nÄáöå'ó ×ïòìä\nModified: 7/1/97:bug-soup\n\n";
	line7  = "\nFor more help or information see:               \nÄavid Òussell <xxxxxxxxxxxxxxxxxxxx>\nhttp://xxxxxxxxxxxxxxxxxxxxxxxxxx\n\n\n\n\n";
	if (deathmatch & DM_CTH)
		line2  = "Head Hunters:              Enabled \n";
	else
		line2  = "Head Hunters:              Disabled\n";
	if (deathmatch & DM_CTF)
		line3  = "Capture The Flag:          Enabled \n";
	else
		line3  = "Capture The Flag:          Disabled\n";
	if (deathmatch & DM_HOOK)
		line4  = "Grappling Hook:            Enabled \n";
	else
		line4  = "Grappling Hook:            Disabled\n";
	if (deathmatch & DM_QUAKES)
		line5  = "EarthQuakes:               Enabled \n"; 
	else
		line5  = "EarthQuakes:               Disabled\n";
	if (deathmatch & DM_RUNES)
		line6  = "Runes:                     Enabled \n";
	else
		line6  = "Runes:                     Disabled\n";

	if (self.health < 1)
		line1  = "W                   \n\n\n\n";
	else if (self.health < 2)
		line1  = "We                  \n\n\n\n";
	else if (self.health < 3)
		line1  = "Wel                 \n\n\n\n";
	else if (self.health < 4)
		line1  = "Welc                \n\n\n\n";
	else if (self.health < 5)
		line1  = "Welco               \n\n\n\n";
	else if (self.health < 6)
		line1  = "Welcom              \n\n\n\n";
	else if (self.health < 7)
		line1  = "Welcome             \n\n\n\n";
	else if (self.health < 8)
		line1  = "Welcome             \n\n\n\n";
	else if (self.health < 9)
		line1  = "Welcome t           \n\n\n\n";
	else if (self.health < 10)
		line1  = "Welcome to          \n\n\n\n";
	else if (self.health < 11)
		line1  = "Welcome to          \n\n\n\n";
	else if (self.health < 12)
		line1  = "Welcome to m        \n\n\n\n";
	else if (self.health < 13)
		line1  = "Welcome to my       \n\n\n\n";
	else if (self.health < 14)
		line1  = "Welcome to my       \n\n\n\n";
	else if (self.health < 15)
		line1  = "Welcome to my w     \n\n\n\n";
	else if (self.health < 16)
		line1  = "Welcome to my wo    \n\n\n\n";
	else if (self.health < 17)
		line1  = "Welcome to my wor   \n\n\n\n";
	else if (self.health < 18)
		line1  = "Welcome to my worl  \n\n\n\n";
	else if (self.health < 19)
		line1  = "Welcome to my world \n\n\n\n";
	else if (self.health < 20)
		line1  = "Welcome to my world:\n\n\n\n";
	else if (self.health < 21)
		line1  = "Welcome to my world:\nD\n\n\n";
	else if (self.health < 22)
		line1  = "Welcome to my world:\nDa\n\n\n";
	else if (self.health < 23)
		line1  = "Welcome to my world:\nDav\n\n\n";
	else if (self.health < 24)
		line1  = "Welcome to my world:\nDave\n\n\n";
	else if (self.health < 25)
		line1  = "Welcome to my world:\nDave'\n\n\n";
	else if (self.health < 26)
		line1  = "Welcome to my world:\nDave's\n\n\n";
	else if (self.health < 27)
		line1  = "Welcome to my world:\nDave's \n\n\n";
	else if (self.health < 28)
		line1  = "Welcome to my world:\nDave's W\n\n\n";
	else if (self.health < 29)
		line1  = "Welcome to my world:\nDave's Wo\n\n\n";
	else if (self.health < 30)
		line1  = "Welcome to my world:\nDave's Wor\n\n\n";
	else if (self.health < 31)
		line1  = "Welcome to my world:\nDave's Worl\n\n\n";
	else if (self.health < 32)
		line1  = "Welcome to my world:\nDave's World\n\n\n";
	if (self.health < 34)
	{
		line2  = "\n";
		line3  = "\n";
		line4  = "\n";
		line5  = "\n";
		line6  = "\n";
	}
	else if (self.health < 40)
	{
		line2  = "Head Hunters:                      \n";
		line3  = "Capture The Flag:                  \n";
		line4  = "Grappling Hook:                    \n";
		line5  = "EarthQuakes:                       \n";
		line6  = "Runes:                             \n";
	}
	else if (self.health < 41)
	{
		if (deathmatch & DM_CTH)
			line2  = "Head Hunters:              E       \n";
		else
			line2  = "Head Hunters:              D       \n";
		if (deathmatch & DM_CTF)
			line3  = "Capture The Flag:          E       \n";
		else
			line3  = "Capture The Flag:          D       \n";
		if (deathmatch & DM_HOOK)
			line4  = "Grappling Hook:            E       \n";
		else
			line4  = "Grappling Hook:            D       \n";
		if (deathmatch & DM_QUAKES)
			line5  = "EarthQuakes:               E       \n";
		else
			line5  = "EarthQuakes:               D       \n";
		if (deathmatch & DM_RUNES)
			line6  = "Runes:                     E       \n";
		else
			line6  = "Runes:                     D       \n";
	}
	else if (self.health < 42)
	{
		if (deathmatch & DM_CTH)
			line2  = "Head Hunters:              En      \n";
		else
			line2  = "Head Hunters:              Di      \n";
		if (deathmatch & DM_CTF)
			line3  = "Capture The Flag:          En      \n";
		else
			line3  = "Capture The Flag:          Di      \n";
		if (deathmatch & DM_HOOK)
			line4  = "Grappling Hook:            En      \n";
		else
			line4  = "Grappling Hook:            Di      \n";
		if (deathmatch & DM_QUAKES)
			line5  = "EarthQuakes:               en      \n";
		else
			line5  = "EarthQuakes:               Di      \n";
		if (deathmatch & DM_RUNES)
			line6  = "Runes:                     En      \n";
		else
			line6  = "Runes:                     Di      \n";
	}
	else if (self.health < 43)
	{
		if (deathmatch & DM_CTH)
			line2  = "Head Hunters:              Ena     \n";
		else
			line2  = "Head Hunters:              Dis     \n";
		if (deathmatch & DM_CTF)
			line3  = "Capture The Flag:          Ena     \n";
		else
			line3  = "Capture The Flag:          Dis     \n";
		if (deathmatch & DM_HOOK)
			line4  = "Grappling Hook:            Ena     \n";
		else
			line4  = "Grappling Hook:            Dis     \n";
		if (deathmatch & DM_QUAKES)
			line5  = "EarthQuakes:               ENa     \n";
		else
			line5  = "EarthQuakes:               Dis     \n";
		if (deathmatch & DM_RUNES)
			line6  = "Runes:                     Ena     \n";
		else
			line6  = "Runes:                     Dis     \n";
	}
	else if (self.health < 44)
	{
		if (deathmatch & DM_CTH)
			line2  = "Head Hunters:              Enab    \n";
		else
			line2  = "Head Hunters:              Disa    \n";
		if (deathmatch & DM_CTF)
			line3  = "Capture The Flag:          Enab    \n";
		else
			line3  = "Capture The Flag:          Disa    \n";
		if (deathmatch & DM_HOOK)
			line4  = "Grappling Hook:            Enab    \n";
		else
			line4  = "Grappling Hook:            Disa    \n";
		if (deathmatch & DM_QUAKES)
			line5  = "EarthQuakes:               enAb    \n";
		else
			line5  = "EarthQuakes:               Disa    \n";
		if (deathmatch & DM_RUNES)
			line6  = "Runes:                     Enab    \n";
		else
			line6  = "Runes:                     Disa    \n";
	}
	else if (self.health < 45)
	{
		if (deathmatch & DM_CTH)
			line2  = "Head Hunters:              Enabl   \n";
		else
			line2  = "Head Hunters:              Disab   \n";
		if (deathmatch & DM_CTF)
			line3  = "Capture The Flag:          Enabl   \n";
		else
			line3  = "Capture The Flag:          Disab   \n";
		if (deathmatch & DM_HOOK)
			line4  = "Grappling Hook:            Enabl   \n";
		else
			line4  = "Grappling Hook:            Disab   \n";
		if (deathmatch & DM_QUAKES)
			line5  = "EarthQuakes:               ENaBl   \n";
		else
			line5  = "EarthQuakes:               Disab   \n";
		if (deathmatch & DM_RUNES)
			line6  = "Runes:                     Enabl   \n";
		else
			line6  = "Runes:                     Disab   \n";
	}
	else if (self.health < 46)
	{
		if (deathmatch & DM_CTH)
			line2  = "Head Hunters:              Enable  \n";
		else
			line2  = "Head Hunters:              Disabl  \n";
		if (deathmatch & DM_CTF)
			line3  = "Capture The Flag:          Enable  \n";
		else
			line3  = "Capture The Flag:          Disabl  \n";
		if (deathmatch & DM_HOOK)
			line4  = "Grappling Hook:            Enable  \n";
		else
			line4  = "Grappling Hook:            Disabl  \n";
		if (deathmatch & DM_QUAKES)
			line5  = "EarthQuakes:               enAbLe  \n";
		else
			line5  = "EarthQuakes:               Disabl  \n";
		if (deathmatch & DM_RUNES)
			line6  = "Runes:                     Enable  \n";
		else
			line6  = "Runes:                     Disabl  \n";
	}
	else if (self.health < 47)
	{
		if (deathmatch & DM_CTH)
			line2  = "Head Hunters:              Enabled \n";
		else
			line2  = "Head Hunters:              Disable \n";
		if (deathmatch & DM_CTF)
			line3  = "Capture The Flag:          Enabled \n";
		else
			line3  = "Capture The Flag:          Disable \n";
		if (deathmatch & DM_HOOK)
			line4  = "Grappling Hook:            Enabled \n";
		else
			line4  = "Grappling Hook:            Disable \n";
		if (deathmatch & DM_QUAKES)
			line5  = "EarthQuakes:               EnAbLEd \n";
		else
			line5  = "EarthQuakes:               Disable \n";
		if (deathmatch & DM_RUNES)
			line6  = "Runes:                     Enabled \n";
		else
			line6  = "Runes:                     Disable \n";
	}
	else 
	{
		if (deathmatch & DM_QUAKES)
		{
			val = random() * 3;
			if (val < 1)
				line5 = "EarthQuakes:               ENaBleD \n";
			else if (val < 2)
				line5 = "EarthQuakes:               eNAbLed \n";
			else
				line5 = "EarthQuakes:               enABlEd \n";
		}
	}

	if (self.health > 88)
	{
		if (deathmatch & DM_QUAKES)
			line5 = "EarthQuakes:               Enabled \n";
		else
			line5 = "EarthQuakes:               Disabled\n";
	}

	if (!(self.flag & FL_CLIENT))
	{
		remove(self);
		return;
	};

	centerprint7(self.owner, line1, line2, line3, line4, line5, line6, line7);

	if (self.health < 90)
	{
		self.health = self.health + 1;
		self.nextthink = time + 0.3;
	}
	else
	{
		self.owner.flags = self.owner.flags - (FL_MOTD + FL_MOTD_RUNNING);
		remove(self);
		return;	
	}
};

void () MOTD_firstthink =
{
	// Stuff any commands the player is to recieve...
	// HOOK
	stuffcmd(self.owner, "wait;\n");
	stuffcmd(self.owner, "alias +hook_launch \"impulse 98;\"\n");
	stuffcmd(self.owner, "alias -hook_launch \"impulse 96;\"\n");
	stuffcmd(self.owner, "alias +hook_grow \"impulse 97;\"\n");
	stuffcmd(self.owner, "alias -hook_grow \"impulse 97;\"\n");
	stuffcmd(self.owner, "alias +hook_shrink \"impulse 96;\"\n");
	stuffcmd(self.owner, "alias -hook_shrink \"impulse 96;\"\n");
	// !HOOK
	// ANTI-BOT
	sprint(self.owner, "No Bots\n");
	sprint(self.owner, "No Bots Please\n");
	sprint(self.owner, "Humans Only Please\n");
	// !ANTI-BOT
	sprint(self.owner, "RULES:\n");
	sprint(self.owner, "   NO returns in your name\n");
	sprint(self.owner, "   NO cross-dressing\n");
	sprint(self.owner, "   NO spamming (suiciding or speaking)\n");
	sprint(self.owner, "   NO killing team-mates\n");
	sprint(self.owner, " Disobeying those rules will get you kicked!\n");
	sprint(self.owner, " Repeat offenses will get you BANNED!\n");

	self.think = MOTD_printmessage;
	self.nextthink = time + 0.01;
};

void () MOTD_Init =
{
	local entity motd;

	if (self.flags & FL_MOTD_RUNNING)
		return;

	self.flags = self.flags + FL_MOTD_RUNNING;
	motd = spawn();
	motd.owner = self;
	motd.health = 0;
	motd.think = MOTD_firstthink;
	motd.nextthink = time + 0.01;
};
