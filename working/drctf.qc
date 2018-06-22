/*
 * CAPTURE THE FLAG
 *
 * NOTES:
 *	This requires the teamplay add-on in order to function correctly.
 *
 * BUGS:
 *	None
 *
 * Copyright 1997-1999 David Russell
 *       ALL RIGHTS RESERVED!
 */
/*******************************************************************************
 * ctf globals
 ******************************************************************************/
float DM_CTF		= 16;
float DM_CUSTOM		= 1024;

float BONUS_CAPTURE	= 0;

.entity        carried_flag;


/*******************************************************************************
 * flag::capture()
 ******************************************************************************/
void (float capturecolor, float capturedcolor) flag_capture =
{
	local entity ent;

	ent = nextent(world);
	while (ent != world) {	/* TODO: maxplayers */
		if (ent.flags & FL_CLIENT) {
			if (ent.teamlast == capturedcolor) {
				centerprint (ent, "YOUR flag was CAPTURED by an ENEMY team!\n");
			} else if (ent.teamlast == capturecolor) {
				centerprint(ent, "ENEMY flag was CAPTURED by YOUR team!\n");
			} else {
				centerprint(ent, "ENEMY flag was CAPTURED by an ENEMY team!\n");
			}
		}
		ent = nextent(ent);
	}
};


/*******************************************************************************
 * flag::steal()
 ******************************************************************************/
void (float flagcolor, float carriercolor) flag_steal =
{
	local entity ent;

	ent = nextent(world);
	while ( ent != world) {	/* TODO: maxplayers */
		if (ent.flags & FL_CLIENT) {
			if (ent.teamlast == carriercolor) {
				centerprint (ent, "ENEMY flag was TAKEN by YOUR team!\n");
			} else if (ent.teamlast == flagcolor) {
				centerprint (ent, "YOUR flag was TAKEN by an ENEMY team!\n");
			} else {
				centerprint (ent, "ENEMY flag was TAKEN by an ENEMY team!\n");
			}
		}
		ent = nextent(ent);
	}
};


/*******************************************************************************
 * flag::return()
 ******************************************************************************/
void (float teamcolor) flag_return =
{
	local entity ent;

	ent = nextent(world);
	while (ent != world) { /* TODO: maxplayers */
		if (ent.flags & FL_CLIENT) {
			if (ent.teamlast == teamcolor) {
				centerprint (ent, "YOUR flag has been RETURNED!\n");
			} else {
				centerprint (ent, "ENEMY flag has been RETURNED!\n");
			}
		}
		ent = nextent(ent);
	}
};


/*******************************************************************************
 * flag::regen()
 ******************************************************************************/
void (entity flag) flag_regen =
{
	if (flag.owner != world) {
		if (flag.owner.carried_flag != world)
			flag.owner.carried_flag = world;
		flag.owner = world;
	}

	flag.solid = SOLID_TRIGGER;
	flag.movetype = MOVETYPE_TOSS;
	flag.nextthink = time + 60;

	flag.origin = flag.oldorigin;
	flag.velocity = '0 0 0';
	flag.angles = flag.mangle;
	setorigin(flag, flag.origin);
	//sound(flag, CHAN_VOICE, "items/itembk2.wav", 1, ATTN_NORMAL);
};


/*******************************************************************************
 * flag::touch()
 ******************************************************************************/
void () flag_touch =
{
	/* only living players are permitted to do anything */
	if ((other.classname != "player")
				|| (other.health <= 0)
                                || (other.deadflag > 0))
		return;

	/* prevent ppl on invalid teams from doing anything */
        if (other.team != other.teamlast)
		return;

	if (self.team == other.team) {
		if (self.origin == self.oldorigin) {
			if (other.carried_flag != world) {
				bprint(other.netname);
				bprint(" captured the ");
				bprint(other.carried_flag.netname);
				bprint(" flag!\n");
				flag_capture(other.teamlast, other.carried_flag.team);
				//other.frags = other.frags + BONUS_CAPTURE;
				//sound();
				flag_regen(other.carried_flag);
			} else {
				bprint(other.netname);
                                bprint(" returned the ");
                                bprint(self.netname);
				bprint(" flag!\n");
				flag_return(self.team);
				//other.frags = other.frags + BONUS_RETURN;
				// sound();
				flag_regen(self);
			}
		}
	} else if (team_isvalid(other.team)) {
		bprint(other.netname);
		bprint(" stole the ");
		bprint(self.netname);
		bprint(" flag\n");
		if (self.origin == self.oldorigin) {
			flag_steal(other.teamlast, self.team);
			//other.frags = other.frags + BONUS_PICKUP;
		}
		other.carried_flag = self;
		self.owner = other;
		self.nextthink = time + frametime;
		self.solid = SOLID_NOT;
		self.movetype = MOVETYPE_NONE;
	}
};


/*******************************************************************************
 * flag::think()
 ******************************************************************************/
 void () flag_think =
{
	local float pc;

	self.nextthink = time + frametime;
	if (self.owner == world) {
		if (self.origin == self.oldorigin) {
			self.nextthink = time + 60;
		} else if (time > self.super_time) {
			flag_return(self.team);
			flag_regen(self);
		} else {
			pc = pointcontents(self.origin);
			if (pc <= CONTENT_WATER) {
				self.flags = self.flags - (self.flags & FL_ONGROUND);
				self.velocity_z = self.velocity_z / 2 + (cvar("sv_gravity") * 2) * frametime;
				if (self.velocity_z > 100)
					self.velocity_z = 100;
			}
		}
        } else { // We are being carried
                if ((self.owner.classname != "player")
				|| (self.owner.deadflag > 0)
				|| (self.owner.carried_flag != self)) {
			bprint(self.owner.netname);
			bprint(" dropped the ");
			bprint(self.netname);
			bprint(" flag!\n");
			self.super_time = time + 60;
			self.owner.carried_flag = world;
			self.owner = world;
			setorigin(self, self.origin);
			self.solid = SOLID_TRIGGER;
			self.movetype = MOVETYPE_TOSS;
			self.flags = self.flags - (self.flags & FL_ONGROUND);
		} else {
			makevectors(self.owner.angles);
			self.angles = self.owner.angles + '0 0 -45';
			self.origin = self.owner.origin + '0 0 -16' + v_right * 22;
			self.velocity = self.owner.velocity;
			setorigin(self, self.origin);
		}
	}
};


/*******************************************************************************
 * ctf::flag()
 ******************************************************************************/
void () flag_place =
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
	if (!droptofloor()) {
		dprint("error: ctf_flag() flag fell out of level at ");
		dprint(vtos(self.origin));
		dprint("\n");
		remove(self);
		return;
	}
	self.oldorigin = self.origin;
};
void () item_flag = {
	if (!deathmatch & DM_CTF) {
		remove(self);
		return;
	}

	if (deathmatch & DM_CUSTOM) {
		precache_model("progs/flag.mdl");
		precache_sound("misc/flagtk.wav");
		precache_sound("misc/flagcap.wav");
		precache_sound("doors/runetry.wav");

		setmodel(self, "progs/flag.mdl");
		setsize(self, '-16 -16 0', '16 16 74');
		self.noise = "misc/flagtk.wav";
		self.noise1 = "doors/runetry.wav";
	} else {       /* ONLY USE STUFF IN QUAKE */
		precache_model("progs/w_s_key.mdl");
		setmodel(self, "progs/w_s_key.mdl"); /* w_g_* */
		precache_sound("misc/medkey.wav");
		precache_sound("doors/runetry.wav");
		self.noise = "misc/medkey.wav";
		self.noise1 = "doors/runetry.wav";
		self.origin_z = self.origin_z + 24;
		setsize(self, '-16 -16 -24', '16 16 32');
	}

	self.classname = "info_flag";
	self.netname = team_name(self.team);
	self.oldorigin = self.origin;
	self.owner = world;
	self.think = flag_place;
	self.nextthink = time + 0.2;    // Place AFTER solids

	if (!team_isvalid(self.team)) {
		dprint("warning: ctf_flag() called for an invalid team.\n");
		remove(self);
		return;
	}
};
void () item_flag_team1 = { self.team = team1_color; item_flag(); };
void () item_flag_team2 = { self.team = team2_color; item_flag(); };
void () item_flag_team3 = { self.team = team3_color; item_flag(); };
void () item_flag_team4 = { self.team = team4_color; item_flag(); };


/*******************************************************************************
 * ctf::func_wall()
 ******************************************************************************/
void () func_ctf_wall =
{
        if (!(deathmatch & DM_CTF)) {
                remove(self);
                return;
        }
        self.angles = '0 0 0';
        self.movetype = MOVETYPE_PUSH;
        self.solid = SOLID_BSP;
        setmodel(self, self.model);
};


/*******************************************************************************
 * ctf::player()
 ******************************************************************************/
void () info_player =
{
	if (!deathmatch & DM_CTF) {
		remove(self);
		return;
	}

        if (!team_isvalid(self.team)) {
		dprint("warning: ctf_player() called for an invalid team.\n");
		remove(self);
		return;
	}
};
void () info_player_team1 = { self.team = team1_color; info_player();};
void () info_player_team2 = { self.team = team2_color; info_player();};
void () info_player_team3 = { self.team = team3_color; info_player();};
void () info_player_team4 = { self.team = team4_color; info_player();};
