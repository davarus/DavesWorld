/*
Head Hunters / Capture the Head

BUGS:
	MAJOR PROBLEM: Something in this code causes entities to be moved
		to differant entities.  Leads to wrong players being hit,
		messed up death messages, and removing the world... what
		the problem is I don't know. =(	

	head can fly out of world when fumbled
	ltime not set in LoneHead (can't set for carried heads though)
		how to determine if head is being carried...

TODO:
	heads/haunts can be destroyed (respawn them at altar?)
	heads/haunts can spit blood (does minor damage)
*/

float LIVE_TIME			= 10;

void (string gibname, float dm) ThrowGib;	// From player.qc
vector (float dm) VelocityForDamage;		// From player.qc

// float	DM_CTH			=  16;
.float		numheads;
.entity		carried_head;

/* ////////////////////////////////////////////////////////////////////////////
/// HEAD Functions ////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////// */


// Make an entity into a head...
void (entity ent) make_head =
{
	// BUG: WHAT EXACTLY IS NEEDED TO SET THE MODEL?!
	ent.solid =		SOLID_NOT;
	ent.movetype =		MOVETYPE_NONE;	// BOUNCE? TOSS?

	setmodel(ent, "progs/h_player.mdl");
	setsize(ent, '-16 -8 -16', '4 8 8');	// BUG: Get it right!
	ent.frame = 		0;
	ent.view_ofs =		'-10 0 0';	// BUG: Get it right!
	ent.health =		1;		// Just for their view...
	if (ent.flags & FL_CLIENT)
		stuffcmd(ent, "fov 130;\n");	// Just for their view...
};

// Make an entity into a haunt (flying head)
void (entity ent) make_haunt =
{
	make_head(ent);

	ent.classname =		"head_haunt";
	ent.movetype =		MOVETYPE_FLY;
	ent.takedamage =	DAMAGE_NO;
	ent.solid =		SOLID_NOT;	// BUG: What should I use? SLIDEBOX
	ent.think =		SUB_Remove;
	ent.nextthink =		-1;
	ent.numheads =		0;
	ent.carried_head =	world;
	if (!ent.flags & FL_CLIENT)
	{
		bprint("DAR: Non-player made into haunt!\n");
		ent.nextthink =	time + 0.01;
	}

	ent.waterlevel =	3;		// Set controlls to swimming
};

// Make into a head that is gettable...
void () head_touch;
void (entity ent) make_deadhead =
{
	make_head(ent);

	ent.classname =		"head_dead";
	ent.movetype =		MOVETYPE_TOSS;	// BOUNCE
	ent.takedamage =	DAMAGE_NO;
	ent.solid =		SOLID_TRIGGER;	// BUG: What should I use?

	ent.touch =		head_touch;	// BUG: Not recommended?
	ent.flags =		ent.flags | FL_ITEM;
	ent.think =		SUB_Remove;
	ent.numheads =		0;
	ent.carried_head =	world;
	if (!ent.flags & FL_CLIENT)
	{
		ent.nextthink =	time + LIVE_TIME;
		ent.ltime = time;
	}
	else
		ent.nextthink = -1;
};

// Something touched a HEAD_DEAD or was that a DEAD_HEAD?
void () head_touch =
{
	local entity oldhead;

	if (other.classname != "player")
		return;

	bprint(other.netname);
	bprint(" scoops up ");
	if (other.netname == self.netname)
		bprint(" his own skull! INSANE!\n");
	else
	{
		bprint(self.netname);
		if (self.flags & FL_CLIENT)
			bprint("s still breathing head!\n");
		else
			bprint("s lifeless skull!\n");
	}
	
	// Make into a "head_carried"...
	self.nextthink =	-1;
	self.ltime = 		-1;		// BUG: Is this right?
	self.movetype = 	MOVETYPE_NONE;	// BUG: Do what? ?NOCLIP
	self.solid =		SOLID_NOT;	// BUG: Do what?
	self.velocity =		'0 0 0';

	if (!other.numheads)	// they have no heads
	{
		other.carried_head = self;
		self.carried_head = other;
	}
	else	// they have heads... ACK!
	{
		if (self.flags & FL_CLIENT)
		{
			oldhead = other.carried_head;
			if (oldhead.flags & FL_CLIENT)
				make_haunt(oldhead);
			else
				remove(oldhead);
			other.carried_head = self;
			self.carried_head = other;
		}
		else // fuck it, we don't need to keep it...
		{	
			self.think = SUB_Remove;	// Redundant
			self.nextthink = time + 0.01;
		}
	}
	other.numheads = other.numheads + 1;
};

// A Player has (respawned || suicided || quit) clean up the mess he left
// !!!EXTERNAL FUNCTION!!!
float (entity ent) CTH_LoneHead =
{
	local entity newhead, headowner;

	if (ent.classname != "head_dead" && ent.classname != "head_haunt")
		return(0);		// What a stupid bug!
	
	if (ent.classname == "head_haunt")
	{
		sound(ent, CHAN_VOICE, "player/gib.wav", 1, ATTN_NONE);
		ThrowGib("progs/gib1.mdl", -40);
		ThrowGib("progs/gib1.mdl", -40);
		ThrowGib("progs/gib1.mdl", -40);
		ThrowGib("progs/gib1.mdl", -40);
	}
	else
	{
		newhead = spawn();
		make_head(newhead);

		newhead.classname = ent.classname;
		newhead.flags = ent.flags - (ent.flags & FL_CLIENT);	// right?
		newhead.colormap = ent.colormap;
		newhead.velocity = ent.velocity;
		newhead.avelocity = ent.avelocity;
		newhead.angles = ent.angles;
		newhead.netname = ent.netname;
		// BUG: Any other flags I need to copy?
		setorigin(newhead, ent.origin);

		newhead.touch = ent.touch;
		newhead.think = ent.think;
		newhead.movetype = ent.movetype;
		newhead.solid = ent.solid;
		newhead.takedamage = ent.takedamage;
		newhead.nextthink = time + LIVE_TIME;
		headowner = ent.carried_head;
		if (headowner != world)		// Just in case...
		{
			headowner.carried_head = newhead;
			newhead.carried_head = headowner;
		}
		else
			newhead.ltime = time;
	}

	// Make invisiable ... AKA: Non existant... NEVER EVER DELETE!
	// as it causes MASSIVE problems... quake REUSES the same entities
	// for players... so if player 1 disconnects and then another connects
	// they will be using the same entity as player 1 just was... =(
	if (ent.flags & FL_CLIENT)
		stuffcmd(ent, "fov 90;\n");
	ent.solid = SOLID_NOT;
	ent.takedamage = DAMAGE_NO;
	ent.movetype = MOVETYPE_NONE;	
	ent.modelindex = 0;			// Make the model nothing
	ent.touch = SUB_Null;
	ent.think = SUB_Null;			// Redundant...
	ent.nextthink = -1;
	return(1);
};

// A Player is carring a head...
// !!!EXTERNAL CALL!!!
void () CTH_CarryHead =
{
	local float head_location;
	local vector head_org;

	if (self.classname != "player")
		return;
	if (!self.numheads)	// The bum doesn't have any heads to carry
		return;

	if (self.carried_head == world)
	{
		bprint("DAR: World is being carried\n");
		return;
	}

	// BUG: Keep the head inside the world at all times!!!

	head_org = self.carried_head.origin = self.origin - v_right*16;
	head_location = pointcontents(head_org);
	if (head_location == CONTENT_SOLID || head_location == CONTENT_SKY)
		return;		// DUMB DUMB DUMB!
	self.carried_head.origin = head_org;
	setorigin(self.carried_head, self.carried_head.origin);
};


/* ///////////////////////////////////////////////////////////////////////////
/// ALTER FUNCTIONS //////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////// */

// Head Que...
void (entity altar) InitHeadQue =
{
	altar.owner = spawn();
	altar.owner.classname = "head_dead";
	altar.owner.owner = spawn();
	altar.owner.owner.classname = "head_dead";
	altar.owner.owner.owner = spawn();
	altar.owner.owner.owner.classname = "head_dead";
	altar.owner.owner.owner.owner = spawn();
	altar.owner.owner.owner.owner.classname = "head_dead";
	altar.owner.owner.owner.owner.owner = spawn();
	altar.owner.owner.owner.owner.owner.classname = "head_dead";
};

// CopyToHeadQue..
void (entity ent) CopyToHeadQue =
{
	ent.owner = self.owner;
	self.owner = ent;
	ent.ltime = -1;
	if (self.owner.owner.owner.owner.owner.owner != world)
	{
		if (self.owner.owner.owner.owner.owner.owner.classname != "head_dead")
		{
			bprint("DAR: Tried to remove non-head from head_que!\n");
			bprint("DAR: Entity was: ");
			bprint(self.owner.owner.owner.owner.owner.owner.classname);
			bprint(" : ");
			bprint(self.owner.owner.owner.owner.owner.owner.netname);
			bprint("\n");
			if (self.owner.owner.owner.owner.owner.owner.classname == "") // is nothing?
				remove(self.owner.owner.owner.owner.owner.owner);
		}
		else
			remove(self.owner.owner.owner.owner.owner.owner);
	}
	else
		bprint("DAR: Tried to remove world from head_que!\n");
};

// Altar think... make it visable to everyone
void () altar_think =
{
	local float color;

	color = random() * 255;
	particle(self.origin, '0 0 1000', color, 100);	// BUG: This could be cooler
	self.nextthink = time + 0.3;
};

// Altar touch... *dread*
void () altar_touch =
{
	local string temp;
	local entity head;
	local float x, y, z;

	if (other.classname != "player")
		return;

	if (!other.numheads)	// What a LOOSER!
		return;

	if ((deathmatch & DM_CTF) && (other.lastteam == self.team))
		return;		// Don't let them depost it at their own place

	other.frags = other.frags + other.numheads;

	head = other.carried_head;
	head.carried_head = world;	// Redundant?
	other.carried_head = world;	// Redundant?

	bprint(other.netname);
	if (other.numheads == 1)
	{
		if (other.netname == head.netname)
			bprint(" brought his own head to the altar!\n");
		else
		{
			bprint(" blesses the altar with ");
			bprint(head.netname);
			if (head.flags & FL_CLIENT)
				bprint("s head!\n");
			else
				bprint("s skull!\n");
		}
	}
	else
	{
		bprint(" deposits ");
		temp = ftos(other.numheads);
		bprint(temp);
		bprint(" heads at the altar!\n");
	}

	x = random() * 64;
	y = random() * 64;
	z = random() * 16;
	head.origin_x = self.origin_x + x - 32;
	head.origin_y = self.origin_y + y - 32;
	head.origin_z = self.origin_z + z - 16;
	setorigin(head, head.origin);		// Don't confuse the engine...
	head.solid = SOLID_NOT;
	head.movetype = MOVETYPE_NONE;
	head.think = SUB_Null;

	if (head.flags & FL_CLIENT)
		make_haunt(head);
	else
		CopyToHeadQue(head);

	other.numheads = other.numheads - 1;
	while (other.numheads)
	{
		head = spawn();
		make_head(head);
		head.classname = "head_dead";
		x = random() * 64;
		y = random() * 64;
		z = random() * 16;
		head.origin_x = self.origin_x + x - 32;
		head.origin_y = self.origin_y + y - 32;
		head.origin_z = self.origin_z + z - 16;
		setorigin(head, head.origin);	// Don't confuse the engine;
		CopyToHeadQue(head);
		other.numheads = other.numheads - 1;
	}

	sound (self, CHAN_VOICE, "player/pain2.wav", 1, ATTN_NONE);
};

// Spawn the Altar... !!!EXTERNAL FUNCTION!!!
void () CTH_CreateAltar =
{
	local entity altar;

	altar = spawn();
	setorigin(altar, self.origin);
	altar.team = self.team;
	setsize(altar, '-32 -32 0', '32 32 56');

	altar.touch = altar_touch;
	altar.think = altar_think;
	altar.nextthink = 0.01;
		
	altar.takedamage = DAMAGE_NO;
	altar.solid = SOLID_TRIGGER;
	altar.movetype = MOVETYPE_NONE;
	if (!droptofloor())
	{
		bprint("DAR: Altar fell through level!\n");
		remove(self);
		return;
	}

	InitHeadQue(altar);
};


/* ////////////////////////////////////////////////////////////////////////////
/// MISC Functions ////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////// */

// A Player died and we need to throw all his heads... except his own =)
// !!!EXTERNAL CALL!!!
void (float dm) CTH_ThrowHeads =
{
	local entity head;
	local string temp;

	if (self.numheads)
	{
		head = self.carried_head;
		make_deadhead(head);
		head.flags = head.flags - (head.flags & FL_ONGROUND);
		head.velocity = VelocityForDamage(dm);
		head.avelocity = crandom() * '0 600 0';

		if (self.numheads == 1)
		{
			bprint(head.netname);
			bprint("s head is fumbled!\n");
		}
		else if (self.numheads)
		{
			temp = ftos(self.numheads);
			bprint(temp);
			bprint(" heads fly free!\n");
		}

		self.numheads = self.numheads - 1;
		while (self.numheads)
		{
			head = spawn();
			make_deadhead(head);
			setorigin(head, self.origin);
			head.netname = "someone";
			head.flags = head.flags - (head.flags & FL_ONGROUND);
			head.velocity = VelocityForDamage(dm);
			head.avelocity = crandom() * '0 600 0';
			self.numheads = self.numheads - 1;
		}
	}
};

// A Player was gibbed so we need to throw his head
// !!!EXTERNAL CALL!!!
void (string gibname, float dm) CTH_ThrowHead =
{
	local entity head;
	local string temp;

	make_deadhead(self);
	self.flags = self.flags - (self.flags & FL_ONGROUND);
	self.velocity = VelocityForDamage(dm);
	self.avelocity = crandom() * '0 600 0';
};
