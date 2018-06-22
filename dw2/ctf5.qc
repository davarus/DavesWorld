/* Capture The Flag ///////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////*/

/* Globals ////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////*/
/* Player variables */
.entity	carried_flag;

/* Deathmatch settings */
float	DM_CTF =		16;
float	DM_CUSTOM =		1024;

/* Individual awards... */ 
float	CTF_BONUS_RETURN =		3;	// For returning your flag
float	CTF_BONUS_PICKUP =		1;	// For getting enemy flag
float	CTF_BONUS_CAPTURE =		5;	// For capturing enemy flag
float	CTF_BONUS_GUARD =		2;	// For protecting your flag/base
float	CTF_BONUS_ESCORT =		1;	// For protecting enemy flag carrier

/* Team awards... */
float	CTF_BONUS_TEAM_CAPTURE =	15;	// For capturing enemy flag...


/* Team Updates ///////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////*/
void (float capturecolor, float capturedcolor) CaptureFlag =
{
	local entity ent;
	ent = nextent(world);
	while (ent != world)
	{
		if (ent.flags & FL_CLIENT)
		{
			if (ent.lastteam == capturedcolor)
				centerprint (ent, "YOUR flag was CAPTURED by an ENEMY team!\n");
			else if (ent.lastteam == capturecolor)
			{
				centerprint(ent, "ENEMY flag was CAPTURED by YOUR team!\n");
				ent.frags = ent.frags + CTF_BONUS_TEAM_CAPTURE;
			}
			else
				centerprint(ent, "ENEMY flag was CAPTURED by ANOTHER team!\n");
		}
		ent = nextent(ent);
	}
};

void (float flagcolor, float carriercolor) GetFlag =
{
	local entity ent;
	ent = nextent(world);
	while (ent != world)
	{
		if (ent.flags & FL_CLIENT)
		{
			if (ent.lastteam == carriercolor)
				centerprint (ent, "ENEMY flag was TAKEN by YOUR team!\n");
			else if (ent.lastteam == flagcolor)
				centerprint (ent, "YOUR flag was TAKEN by an ENEMY team!\n");
			else
				centerprint (ent, "ENEMY flag was TAKEN by ANOTHER team!\n");
		}
		ent = nextent(ent);
	}
};

void (float teamcolor) ReturnedFlag =
{
	local entity ent;
	ent = nextent(world);
	while (ent != world)
	{
		if (ent.flags & FL_CLIENT)
		{
			if (ent.lastteam = teamcolor)
				centerprint (ent, "YOUR flag has been RETURNED!\n");
			else
				centerprint (ent, "ENEMY flag has been RETURNED!\n");
		}
		ent = nextent(ent);
	}
};

/* Flags //////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////*/
void (entity flg) RegenFlag =
{
	if (flg.owner != world)
	{
		if (flg.owner.carried_flag != world)
			flg.owner.carried_flag = world;
		flg.owner = world;
	}

	flg.solid = SOLID_TRIGGER;
	flg.nextthink = -1;

	setorigin(flg, flg.oldorigin);
	flg.velocity = '0 0 0';
	flg.angles = flg.mangle;
	sound(flg, CHAN_VOICE, "items/itembk2.wav", 1, ATTN_NORM);
};

void () flag_touch =
{
	if (other.classname != "player")
		return;
	if (other.health <= 0)
		return;

	if (self.lastteam == other.lastteam)
	{
		if (self.origin == self.oldorigin)
		{
			if (other.carried_flag != world)
			{
				CaptureFlag(other.lastteam, other.carried_flag.team);
				bprint(other.netname);
				bprint(" CAPTURED the ");
				bprint(other.carried_flag.netname);
				bprint(" flag\n");
				other.frags = other.frags + CTF_BONUS_CAPTURE;
				// sound()
				RegenFlag(other.carried_flag);
			}
		}
		else
		{
			ReturnedFlag(self.lastteam);
			bprint(other.netname);
			bprint(" RETURNED the ");
			bprint(self.netname);
			bprint(" flag\n");
			other.frags = other.frags + CTF_BONUS_RETURN;
			sound(other, CHAN_ITEM, self.noise1, 1, ATTN_NORM);
			RegenFlag(self);
		}
	}
	else if (IsValidTeam(other.lastteam))
	{
		GetFlag(self.lastteam, other.lastteam);
		bprint(other.netname);
		bprint(" GOT the ");
		bprint(self.netname);
		bprint(" flag\n");
		other.carried_flag = self;
		self.owner = other;
		self.nextthink = time + frametime;
		self.solid = SOLID_NOT;
		other.frags = other.frags + CTF_BONUS_PICKUP;
	}
};

void () flag_think =
{
	local float pc;

	self.nextthink = time + frametime;
	if (self.owner == world)
	{
		if (self.origin = self.oldorigin)
			self.nextthink = -1;
		else if (time > self.super_time)
		{
			RegenFlag(self);
			ReturnedFlag(self.team);
		}
		else
		{
			pc = pointcontents(self.origin);
			if (pc == CONTENT_WATER)
				self.velocity_z = cvar("sv_gravity") + 100;
		}
		return;
	}
	else // We are being carried...
	{
		if ((self.owner.classname != "player") ||
			(self.owner.deadflag > 0) ||
			(self.owner.carried_flag != self))
		{
			bprint(self.owner.netname);
			bprint(" LOST the ");
			bprint(self.netname);
			bprint(" flag\n");
			self.super_time = time + 60;
			self.owner.carried_flag = world;
			self.owner = world;
			self.origin = self.origin - '0 0 24';
			self.velocity = '0 0 300';
			setorigin(self, self.origin);
			// TODO: Throw as though it where a gib...
			self.solid = SOLID_TRIGGER;
		}
		else
		{
			makevectors(self.owner.angles);
			self.angles = self.owner.angles + '0 0 -45';
			self.origin = self.owner.origin + '0 0 -16' + v_right * 22;
			setorigin(self, self.origin);
		}	
	}
};

void () place_flag =
{
	self.mdl = self.model;	
	self.flags = FL_ITEM;
	self.solid = SOLID_TRIGGER;
	self.movetype = MOVETYPE_TOSS;
	self.velocity = '0 0 0';
	self.origin_z = self.origin_z + 6;
	self.think = flag_think;
	self.touch = flag_touch;
	self.nextthink = -1;
	self.mangle = self.angles;
	self.effects = self.effects | EF_DIMLIGHT;
	if (!droptofloor())
	{
		dprint("Flag fell out of level at ");
		dprint(vtos(self.origin));
		dprint("\n");
		remove(self);
		return;
	}
	self.oldorigin = self.origin;
};

void () item_flag =
{
	if (!(deathmatch & DM_CTF))
	{
		remove(self);
		return;
	}

	if (deathmatch & DM_CUSTOM)
	{
		precache_model("progs/flag.mdl");
		setmodel(self, "progs/flag.mdl");
		precache_sound("misc/flagtk.wav");
		precache_sound("misc/flagcap.wav");
		precache_sound("doors/runetry.wav");
		self.noise = "misc/flagtk.wav";
		self.noise1 = "doors/runetry.wav";
		setsize(self, '-16 -16 0', '16 16 74');
	}
	else
	{
		if (self.team == TEAM1_COLOR)
		{
			precache_model("progs/w_g_key.mdl");
			setmodel(self, "progs/w_g_key.mdl");
		}
		else if (self.team == TEAM2_COLOR)
		{
			precache_model("progs/w_s_key.mdl");
			setmodel(self, "progs/w_s_key.mdl");
		}
		precache_sound("misc/medkey.wav");
		precache_sound("doors/runetry.wav");
		self.noise = "misc/medkey.wav";
		self.noise = "doors/runetry.wav";
		self.origin_z = self.origin_z + 24;
		setsize(self, '-16 -16 -24', '16 16 32');
	}
	
	self.classname = "info_flag";
	self.netname = GetTeamColor(self.team);
	self.owner = world;
	self.think = place_flag;
	self.nextthink = time + 0.2;	// items start out after other solids
};

void () item_flag_team2 =
{
	self.lastteam = TEAM2_COLOR;
	self.team = TEAM2_COLOR;
	self.skin = 0;
	item_flag();
};

void () item_flag_team1 =
{
	self.lastteam = TEAM1_COLOR;
	self.team = TEAM1_COLOR;
	self.skin = 1;
	item_flag();
};


/* Misc ///////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////*/
void () func_ctf_wall =
{
	if (!(deathmatch & DM_CTF))
	{
		remove(self);
		return;
	}
	self.angles = '0 0 0';
	self.movetype = MOVETYPE_PUSH;
	self.solid = SOLID_BSP;
	setmodel(self, self.model);
};

void () info_player =
{
	if (!(deathmatch & DM_CTF))
	{
		remove(self);
		return;
	}
};

void () info_player_team1 =
{
	info_player();
};

void () info_player_team2 =
{
	info_player();
};

void (entity killer, entity killed) CheckBonusKill =
{
	local float entc;
	local entity ent;

	local vector vdistance;
	local float dist;

	ent = find(world, classname, "info_flag");
	while (ent != world)
	{
		vdistance = killer.origin - ent.origin;
		if (vdistance_x < 0)
			vdistance_x = vdistance_x * -1;
		if (vdistance_y < 0)
			vdistance_y = vdistance_y * -1;
		if (vdistance_z < 0)
			vdistance_z = vdistance_z * -1;
		dist = (vdistance_x + vdistance_y + vdistance_z) / 3;
		
		if (dist <= 512)
		{
			if ((ent.solid == SOLID_TRIGGER) && // at base
				(ent.origin == ent.oldorigin) && // at base
				(ent.lastteam = killer.lastteam)) // our flag
			{
				bprint(killer.netname);
				bprint(" PROTECTS base\n");
				killer.frags = killer.frags + CTF_BONUS_GUARD;
			}
			if ((ent.solid == SOLID_NOT) && // is not at base & is carried
				(ent.lastteam != killer.lastteam) && // is not our flag
				(ent.owner.lastteam == killer.lastteam)) // is carried by our team
			{
				bprint(killer.netname);
				bprint(" ESCORTS ");
				bprint(ent.owner.netname);
				bprint("\n");
				killer.frags = killer.frags + CTF_BONUS_ESCORT;
			}
		}
		ent = find(ent, classname, "info_flag");
	}
};
