/*----------------------------------------------------------------------
  The Rune Game modes

  Rune 1 - Earth Magic
	  resistance
  Rune 2 - Black Magic
	  strength
  Rune 3 - Hell Magic
	  haste
  Rune 4 - Elder Magic
	  regeneration

 ----------------------------------------------------------------------*/

/*
BUGS:	none?
TODO:
	sound playing code... that is retarded... just store the name in a
		global string!
	tweak everything
*/

float		IT_RUNE1 = 8388608;
float		IT_RUNE2 = 16777216;
float		IT_RUNE3 = 33554432;
float		IT_RUNE4 = 67108864;

.float		regeneration_sound;
.float		haste_sound;
.float		rune_notice_time;

entity() SelectRuneSpawnPoint =
{
	local entity runespawn;

	runespawn = find(runespawn, classname, "info_player_deathmatch");
	if (runespawn == world)
		runespawn = find (runespawn, classname, "info_player_deathmatch");
	if (runespawn == world)
		error("no info_player_deathmatch to spawn rune");
	return runespawn;
};

void() RuneTouch =
{
	local string	s;
	local	float	best;
	local		entity	stemp;
	
	if (other.classname != "player")
		return;

	if (other.items & IT_RUNE1 ||
		other.items & IT_RUNE2 ||
		other.items & IT_RUNE3 ||
		other.items & IT_RUNE4)
	{
		if (other.rune_notice_time < time) {
			centerprint(other, "You already have a rune.");
			other.rune_notice_time = time + 5;
		}
		return; // one per customer
	}
		
	other.items = other.items | self.items;

	// notification of rune, no nofity in team mode
	if (self.items & IT_RUNE1)
	{
		bprint(other.netname);
		bprint(" got the rune of Åבעפט Íבחיד!\n");
		centerprint(other, "Åבעפט Íבחיד!    Òוףיףפבמדו");
	}
	else if (self.items & IT_RUNE2)
	{
		bprint(other.netname);
		bprint(" got the rune of Âלבדכ Íבחיד!\n");
		centerprint(other, "Âלבדכ Íבחיד!    Óפעומחפט");
	}
	else if (self.items & IT_RUNE3)
	{
		bprint(other.netname);
		bprint(" got the rune of Èולל Íבחיד!\n");
		centerprint(other, "Èולל Íבחיד!    Èבףפו");
	}
	else if (self.items & IT_RUNE4)
	{
		bprint(other.netname);
		bprint(" got the rune of Åלהוע Íבחיד!\n");
		centerprint(other, "Åלהוע Íבחיד!    Òוחומועבפיןמ");
	}
	else
	{
		bprint("DAR: ");
		bprint(other.netname);
		bprint(" picked up a bad rune!\n");
	}
	
	// backpack touch sound
	sound (other, CHAN_ITEM, "weapons/lock4.wav", 1, ATTN_NORM);
	stuffcmd (other, "bf\n");

	remove(self);
};

void (float flag) Do_DropRune;

void() RuneRespawn =
{
	local entity oself;

	oself = self;

	// choose random starting points
	self = SelectRuneSpawnPoint();
	Do_DropRune(oself.items);

	remove(oself);
};

void (float flag) Do_DropRune = 
{
	local entity	item;

	item = spawn();
	item.origin = self.origin - '0 0 24';
	
	item.items = flag;

	item.velocity_z = 400;
	item.velocity_x = -500 + (random() * 1000);
	item.velocity_y = -500 + (random() * 1000);
	
	item.flags = FL_ITEM;
	item.solid = SOLID_TRIGGER;
	item.movetype = MOVETYPE_TOSS;
	if (flag & IT_RUNE1)
		setmodel (item, "progs/end1.mdl");
	else if (flag & IT_RUNE2)
		setmodel (item, "progs/end2.mdl");
	else if (flag & IT_RUNE3)
		setmodel (item, "progs/end3.mdl");
	else if (flag & IT_RUNE4)
		setmodel (item, "progs/end4.mdl");
	setsize (item, '-16 -16 0', '16 16 56');
	item.touch = RuneTouch;
	
	item.nextthink = time + 120;
	item.think = RuneRespawn;
};

/*
===============
Droprune
self is player
===============
*/
void() DropRune =
{
	if (self.items & IT_RUNE1)
	{
		Do_DropRune(IT_RUNE1);
		self.items = self.items - (self.items & IT_RUNE1);
	}
	if (self.items & IT_RUNE2)
	{
		Do_DropRune(IT_RUNE2);
		self.items = self.items - (self.items & IT_RUNE2);
	}
	if (self.items & IT_RUNE3)
	{
		Do_DropRune(IT_RUNE3);
		self.items = self.items - (self.items & IT_RUNE3);
	}
	if (self.items & IT_RUNE4)
	{
		Do_DropRune(IT_RUNE4);
		self.items = self.items - (self.items & IT_RUNE4);
	}
};

/*
================
SpawnRunes
spawn all the runes
self is the entity that was created for us, we remove it
================
*/
void() SpawnRunes =
{
	local entity oself;
	local float i;

	oself = self;

	// choose random starting points
	i = random() * 10;
	while (i > 0)
	{
		self = SelectRuneSpawnPoint();
		i = i - 1;
	}

	self = SelectRuneSpawnPoint();
	Do_DropRune(IT_RUNE1);
	self = SelectRuneSpawnPoint();
	Do_DropRune(IT_RUNE2);
	self = SelectRuneSpawnPoint();
	Do_DropRune(IT_RUNE3);
	self = SelectRuneSpawnPoint();
	Do_DropRune(IT_RUNE4);

	remove(oself);
};

void() StartRuneSpawn =
{
	local entity rspawn;

	precache_model ("progs/end1.mdl");
	precache_model ("progs/end2.mdl");
	precache_model ("progs/end3.mdl");
	precache_model ("progs/end4.mdl");

	if (deathmatch & DM_CUSTOM)
	{
		precache_sound("rune/rune1.wav");
		precache_sound("rune/rune2.wav");
		precache_sound("rune/rune22.wav"); // special rune and quad combo
		precache_sound("rune/rune3.wav");
		precache_sound("rune/rune4.wav");
	}
	else
	{
		precache_sound("boss1/sight1.wav");
		precache_sound("items/r_item1.wav");
		precache_sound("items/damage3.wav");
		precache_sound("items/protect3.wav");
	}

	// spawn the runes
	rspawn = spawn();
	rspawn.nextthink = time + 0.01;
	rspawn.think = SpawnRunes;
};

void (entity who) ResistanceSound =
{
	if (who.items & IT_RUNE1)
	{
		if (who.invincible_sound < time)
		{
			who.invincible_sound = time + 1;
			if (deathmatch & DM_CUSTOM)
				sound (who, CHAN_BODY, "rune/rune1.wav", 1, ATTN_NORM);
			else
				sound (who, CHAN_BODY, "items/protect3.wav", 1, ATTN_NORM);
		}
	}
};

void () RegenerationSound =
{
	if (self.items & IT_RUNE4)
	{
		if (self.regeneration_sound < time)
		{
			self.regeneration_sound = time + 1;
			if (deathmatch & DM_CUSTOM)
				sound (self, CHAN_BODY, "rune/rune4.wav", 1, ATTN_NORM);
			else
				sound (self, CHAN_BODY, "items/r_item1.wav", 1, ATTN_NORM);
		}
	}
};

void () HasteSound =
{
	if (self.items & IT_RUNE3)
	{
		if (self.haste_sound < time)
		{
			self.haste_sound = time + 1;
			if (deathmatch & DM_CUSTOM)
				sound(self, CHAN_BODY, "rune/rune3.wav", 1, ATTN_NORM);
			else
				sound(self, CHAN_BODY, "boss1/sight1.wav", 1, ATTN_NORM);
		}
	}
};
