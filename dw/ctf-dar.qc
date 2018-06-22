/* Capture The Flag ///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

	This is a Capture The Flag add-on written by David Russell based on
  the original Threewave CTF by Zoid.  None of his code is used so don't bug
  him!  There are many enhancements to his including more teams allowed,
  better scoring system (in my opinion), floating flags, and more.

  TODO:
	colorized messages

  BUGS:
	Key gets into the ground... ugly.
*/

float	BONUS_CAPTURE =		5;
float	BONUS_RETURN =		1;
float	BONUS_PICKUP =		2;
float	BONUS_ESCORT =		1;
float	BONUS_PROTECT =		1;
float	BONUS_TEAM_CAPTURE =	10;

.entity	carried_flag;

/* Team broadcasts... */
void (float capturecolor, float capturedcolor) CaptureFlag =
{
	local entity ent;
	ent = nextent(world);
	while (ent != world)	// could speed up by stopping at maxplayers setting
	{
		if (ent.flags & FL_CLIENT)
		{
			if (ent.lastteam == capturedcolor)
				centerprint (ent, "YOUR flag was CAPTURED by an ENEMY team!");
			else if (ent.lastteam == capturecolor)
			{
				centerprint(ent, "ENEMY flag was CAPTURED by YOUR team!");
				ent.frags = ent.frags + BONUS_TEAM_CAPTURE;
			}
			else if (IsValidTeam(ent.lastteam))
				centerprint(ent, "ENEMY flag was CAPTURED by an ENEMY team!");
		}
		ent = nextent(ent);
	}
};

void (float carriercolor, float flagcolor) GetFlag =
{
	local entity ent;
	ent = nextent(world);
	while (ent != world)	// could speed up by stopping at maxplayers setting
	{
		if (ent.flags & FL_CLIENT)
		{
			if (ent.lastteam == flagcolor)
				centerprint(ent, "YOUR flag was TAKEN by an ENEMY team!");
			else if (ent.lastteam == carriercolor)
				centerprint(ent, "ENEMY flag was TAKEN by YOUR team!");
			else if (!IsValidTeam(ent.lastteam))
				centerprint(ent, "ENEMY flag was TAKEN by an ENEMY team!");
		}
		ent = nextent(ent);
	}
};

void (float teamcolor) ReturnedFlag =
{
	local entity ent;
	ent = nextent(world);
	while (ent != world)	// could speed up by stopping at maxplayer setting
	{
		if (ent.flags & FL_CLIENT)
		{
			if (ent.lastteam == teamcolor)
				centerprint(ent, "YOUR flag was RETURNED             ");
			else if (!IsValidTeam(ent.lastteam))
				centerprint(ent, "ENEMY flag was RETURNED            ");
		}
		ent = nextent(ent);
	}
};

void (entity flg) RegenFlag = 
{

	// Just in case...
	if (flg.owner != world)
	{
		if (flg.owner.carried_flag == flg)
			flg.owner.carried_flag = world;
		flg.owner = world;
	}

	flg.solid = SOLID_TRIGGER;
	flg.movetype = MOVETYPE_TOSS;
	flg.nextthink = time + 60;

	flg.origin = flg.oldorigin;
	flg.velocity = '0 0 0';
	flg.angles = flg.mangle;
	setorigin(flg, flg.origin);
	sound(flg, CHAN_VOICE, "items/itembk2.wav", 1, ATTN_NORM);
};

void () flag_touch =
{
	if ((other.classname != "player") ||
	    (other.health <= 0) ||
	    (other.deadflag > 0))
		return;

	if (other.team != other.lastteam)
		return;

	if (self.team == other.team)
	{
		if (self.origin == self.oldorigin)
		{
			if (other.carried_flag != world)
			{
				// BUG: insure flag is valid!
				bprint(other.netname);
				bprint(" CAPTURED the ");
				bprint(other.carried_flag.netname);
				bprint(" flag\n");
				CaptureFlag(other.lastteam, other.carried_flag.team);
				other.frags = other.frags + BONUS_CAPTURE;
				// sound()
				RegenFlag(other.carried_flag);
			}
		}
		else
		{
			bprint(other.netname);
			bprint(" RETURNED the ");
			bprint(self.netname);
			bprint(" flag\n");
			ReturnedFlag(self.team);
			other.frags = other.frags + BONUS_RETURN;
			// sound()
			RegenFlag(self);
		}
	}
	else if (IsValidTeam(other.team))
	{
		bprint(other.netname);
		bprint(" GOT the ");
		bprint(self.netname);
		bprint(" flag\n");
		if (self.origin == self.oldorigin)	// only first get
		{
			GetFlag(other.lastteam, self.team);
			other.frags = other.frags + BONUS_PICKUP;
		}
		other.carried_flag = self;
		self.owner = other;
		self.nextthink = time + frametime;
		self.solid = SOLID_NOT;
		self.movetype = MOVETYPE_NONE;
	}
};

void () flag_think =
{
	local float pc;

	self.nextthink = time + frametime;	// BUG: ?
	if (self.owner == world)
	{
		if (self.origin == self.oldorigin)
		{
			self.nextthink = time + 60;
		}
		else if (time > self.super_time)
		{
			ReturnedFlag(self.team);
			RegenFlag(self);
		}
		else
		{
			pc = pointcontents(self.origin);
			if (pc <= CONTENT_WATER)
			{
				self.flags = self.flags - (self.flags & FL_ONGROUND);
				self.velocity_z = self.velocity_z / 2 + (cvar("sv_gravity") * 2) * frametime;
				if (self.velocity_z > 200)
					self.velocity_z = 200;
			}
		}
	}
	else	// We ARE being carried...
	{
		if ((self.owner.classname != "player") ||
		    (self.owner.deadflag > 0)  ||
		    (self.owner.carried_flag != self))
		{
			bprint(self.owner.netname);
			bprint(" LOST the ");
			bprint(self.netname);
			bprint(" flag\n");
			self.super_time = time + 60;
			self.origin = self.owner.origin - '0 0 24';
			self.velocity = '0 0 300';	// BUG: Throw as though gib...
			self.owner.carried_flag = world;
			self.owner = world;
			setorigin(self, self.origin);
			self.solid = SOLID_TRIGGER; 
			self.movetype = MOVETYPE_TOSS;
			self.flags = self.flags - (self.flags & FL_ONGROUND);
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


/* Flags */
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
	self.nextthink = time + 60;
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
		precache_sound("misc/flagtk.wav");
		precache_sound("misc/flagcap.wav");
		precache_sound("doors/runetry.wav");

		setmodel(self, "progs/flag.mdl");
		setsize(self, '-16 -16 0', '16 16 74');
		self.noise = "misc/flagtk.wav";
		self.noise1 = "doors/runetry.wav";
	}
	else	// ONLY USE STUFF FOUND IN QUAKE
	{
		if (self.team == TEAM1_COLOR)
		{
			precache_model("progs/w_s_key.mdl");
			setmodel(self, "progs/w_s_key.mdl");
		}
		else if (self.team == TEAM2_COLOR)
		{
			precache_model("progs/w_g_key.mdl");
			setmodel(self, "progs/w_g_key.mdl");
		}
		precache_sound("misc/medkey.wav");
		precache_sound("doors/runetry.wav");
		self.noise = "misc/medkey.wav";
		self.noise1 = "doors/runetry.wav";
		self.origin_z = self.origin_z + 24;
		setsize(self, '-16 -16 -24', '16 16 32');
	}

	self.classname = "info_flag";
	self.netname = GetTeamColor(self.team);
	self.oldorigin = self.origin;
	self.owner = world;
	self.think = place_flag;
	self.nextthink = time + 0.2;	// Place AFTER solids

	if (!IsValidTeam(self.team))
	{
		bprint("DAR: Invalid Team Flag\n");
		remove(self);
		return;
	}

	// CTH
//	if (deathmatch & DM_CTH)
//		CTH_CreateAltar();
	// !CTH
};
void () item_flag_team1 = {self.team = TEAM1_COLOR; self.skin = 0; item_flag();};
void () item_flag_team2 = {self.team = TEAM2_COLOR; self.skin = 1; item_flag();};
void () item_flag_team3 = {self.team = TEAM3_COLOR; self.skin = 2; item_flag();};
void () item_flag_team4 = {self.team = TEAM4_COLOR; self.skin = 3; item_flag();};


/* Player Start Spots */
void () info_player =
{
	if (!deathmatch & DM_CTF)
	{
		remove(self);
		return;
	}
	
	if (!IsValidTeam(self.team))
	{
		bprint("DAR: Invalid Team Start\n");
		remove(self);
		return;
	}
};
void () info_player_team1 = {self.team = TEAM1_COLOR; info_player();};
void () info_player_team2 = {self.team = TEAM2_COLOR; info_player();};
void () info_player_team3 = {self.team = TEAM3_COLOR; info_player();};
void () info_player_team4 = {self.team = TEAM4_COLOR; info_player();};

/* CTF Wall Section */
void () func_ctf_wall =
{
	if (!deathmatch & DM_CTF)
	{
		remove(self);
		return;
	}
	self.angles = '0 0 0';
	self.movetype = MOVETYPE_PUSH;
	self.solid = SOLID_BSP;
	setmodel(self, self.model);
};


/* Check for BONUS kill points */
void (entity killer, entity killed) CheckBonusKill =
{
	local float entc;
	local entity ent;

	local vector vdist;
	local float fdist;

	if (killer.lastteam == killed.lastteam)
	{
		if (killed.carried_flag != world)
		{
			bprint(killer.netname);
			bprint(" killed his flag-carrier!\n");
			killer.frags = killer.frags - BONUS_CAPTURE;
		}
		// Don't give llamas bonus points!
		return;
	}

	ent = find(world, classname, "info_flag");
	while (ent != world)
	{
		vdist = killer.origin - ent.origin;
		if (vdist_x < 0)
			vdist_x = vdist_x * -1;
		if (vdist_y < 0)
			vdist_y = vdist_y * -1;
		if (vdist_z < 0)
			vdist_z = vdist_z * -1;
		fdist = (vdist_x + vdist_y + vdist_z) / 3;

		if (fdist <= 512 && CanDamage(ent, killer) || fdist <= 128)
		{
			if ((ent.solid == SOLID_TRIGGER) &&
				(ent.origin == ent.oldorigin) && // at base
				(ent.team == killer.lastteam))	// our flag
			{
				bprint(killer.netname);
				bprint(" PROTECTS base\n");
				killer.frags = killer.frags + BONUS_PROTECT;
			}
			else if ((ent.solid == SOLID_NOT) &&	// carried
				(ent.team != killer.lastteam) && // not ours
				(ent.owner.lastteam == killer.lastteam) && // carried by our team
				(ent.owner != killer))	// not the carrier
			{
				bprint(killer.netname);
				bprint(" ESCORTS ");
				bprint(ent.owner.netname);
				bprint("\n");
				killer.frags = killer.frags + BONUS_ESCORT;
			}
		}
		ent = find(ent, classname, "info_flag");
	}
};
