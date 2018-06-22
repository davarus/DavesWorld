void (entity ent) head_think =
{
	local float pc;

	if (self.carried_head)
	{
		if (self.carried_head.classname != "player" ||
			self.carried_head.deadflag ||
			self.carried_head.carried_head != self)
		{
			bprint(self.carried_head.netname);
			bprint(" dropped ");
			bprint(self.netname);
			bprint("'s lifeless skull\n");

			self.touch = head_touch;
			self.supertime = time + LIVE_TIME;
			self.solid = SOLID_TRIGGER;
			self.movetype = MOVETYPE_TOSS;
			self.velocity = '0 0 300';
			self.carried_head.carried_head = world;
			self.carried_head = world;
			self.flags = self.flags - (self.flags - FL_ONGROUND);
		}
		else
		{
			makevectors(self.carried_head.carried_head);
			self.origin = self.carried_head.origin + '0 0 16' + v_right * 22;
			setorigin(self, self.origin);
		}
	}
	else
	{
		pc = pointcontents(self);
		if (pointcontents <= CONTENT_WATER)
		{
			self.flags = self.flags - (self.flags & FL_ONGROUND);
			self.velocity_z = (self.velocity_z / 2) + ((cvar("sv_gravity") * 2) * frametime);
			if (self.velocity_z > 200)
				self.velocity_z = 200;
		}
		if (self.supertime >= time)
		{
			remove(self);
		}
	}
};

void (entity ent) make_head =
{
	ent.solid =	SOLID_NOT;
	ent.movetype =	MOVETYPE_NONE;

	setmodel(ent, "progs/h_player.mdl");
	setsize(ent, '-16 -8 -16', '4 8 8');	// BUG: Get it right!
	ent.classname =	"head";
	ent.frame =	0;
	ent.think =	head_think;
	ent.nextthink = time + 0.01;

	if (ent.flags & FL_CLIENT)
	{
		// Just for their view...
		ent.view_ofs =	'-10 0 -4';		// BUG: Get it right!
		ent.health =	1;
		stuffcmd(ent, "fov 110;\n");
		stuffcmd(ent, "v_cshift -20 -10 10 20;\n");
	}
};

void () altar_think =
{
	local float color;

	// TODO: This could be MUCH cooler...	
	color = random () * 255;
	particle(self.origin, '0 0 1000', color, 100);
	self.nextthink = time + 0.3;
};

void () CTH_CreateAltar =
{
	local entity altar;

	altar = spawn();
	setorigin(altar, self.origin);
	setsize(altar, '-32 -32 0', '32 32 56';
	altar.team = self.team;

	altar.touch = altar_touch;
	altar.think = altar_think;
	altar.nextthink = time + 0.01;
	altar.flags = altar.flags + FL_ITEM;
	altar.solid = SOLID_TRIGGER;

	if (!droptofloor())
	{
		dprint("Altar fell out of level at ");
		dprint(vtos(altar.origin));
		dprint("\n");
		remove(altar);
		return;
	}

	// InitHeadQue(altar);
};

void (float dm) CTH_ThrowHeads =
{
	local entity newhead;
	
	newhead =		self.carried_head;
	newhead.carried_head =	world;
	self.carried_head =	world;
	newhead.flags =		newhead.flags - (newhead.flags & FL_ONGROUND);
	setorigin(newhead, self.origin);
	newhead.velocity =	VelocityForDamage(dm);
	newhead.avelocity =	crandom() * '0 600 0';
	newhead.solid =		SOLID_TRIGGER;
	newhead.movetype =	MOVETYPE_TOSS;
	newhead.touch =		head_touch;
	self.numheads =		self.numheads - 1;

	while (numheads)
	{
		newhead =		spawn();
		make_head(newhead);
		setorigin(newhead, self.origin);
		newhead.netname =	"someone";
		newhead.flags =		newhead.flags - (newhead.flags & FL_ONGROUND);
		newhead.velocity =	VelocityForDamage(dm);
		newhead.avelocity =	crandom() * '0 600 0';
		newhead.solid =		SOLID_TRIGGER;
		newhead.movetype =	MOVETYPE_TOSS;
		newhead.touch =		head_touch;
		self.numheads =		self.numheads - 1;
	}
};

void () CTH_ThrowHead =
{
	make_head(self);
	self.flags =		self.flags - (self.flags & FL_ONGROUND);
	self.velocity =		VelocityForDamage(dm);
	self.avelocity =	crandom() * '0 600 0';
	self.solid =		SOLID_TRIGGER;
	self.movetype =		MOVETYPE_TOSS;
	self.nextthink =	time + 0.01;
};

void () CTH_LoneHead =
{
	local entity newhead;

	if (ent.classname == "haunt")
	{
		sound(ent, CHAN_VOICE, "player/gib.wav", 1, ATTN_NONE);
		ThrowGib("progs/gib1.mdl", -40);

		ent.solid = SOLID_NOT;
		ent.movetype = MOVETYPE_NONE;
		ent.modelindex = 0;
		ent.nextthink = -1;
		return(1);
	}
	else if (ent.classname == "head")
	{
		newhead = spawn();
		newhead.classname = "head";
		newhead.flags = ent.flags - (ent.flags & FL_CLIENT);
		newhead.colormap = ent.colormap;
		newhead.velocity = ent.velocity;
		newhead.avelocity = ent.avelocity;
		newhead.angles = ent.angles;
		newhead.netname = ent.netname;
		newhead.think = ent.think;
		newhead.touch = ent.touch;		// NEVER CALL IN TOUCH
		newhead.nextthink = ent.nextthink;
		newhead.solid = ent.solid;
		newhead.movetype = ent.movetype;
		// BUG: What other variables do I need to copy?
		if (ent.carried_head)
		{
			ent.carried_head.carried_head = newhead;
			newhead.carried_head = ent.carried_head;
		}

		ent.solid = SOLID_NOT;
		ent.movetype = MOVETYPE_NONE;
		ent.modelindex = 0;
		ent.nextthink = -1;
		return(1);
	}
	else
		return(0);
};
