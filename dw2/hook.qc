//====================================================================
//
// GRAPPLING HOOK			by: Perecli Manole AKA Bort
//
//====================================================================
// Aside from this new file, the following are the modifications
// done to id's original source files:
//--------------------------------------------------------------------
// File: Progs.src
// Location: before the "weapons.qc" line
// Added: hook.qc
//--------------------------------------------------------------------
// File: Client.qc
// Procedure: PlayerPreThink
// Location: after line "WaterMove ();"
// Added: CheckGrapHook ();
//--------------------------------------------------------------------
// File: World.qc
// Procedure: worldspawn
// Location: after line "precache_model ("progs/s_spike.mdl");"
// Added: precache_model ("progs/hook.mdl");	DAR [progs/v_spike.mdl]
//        precache_model ("progs/bit.mdl");	DAR [progs/s_spike.mdl]
//--------------------------------------------------------------------
// File: Weapons.qc
// Procedure: W_Precache
// Location: end of procedure
// Added: precache_sound ("shambler/smack.wav");
//        precache_sound ("blob/land1.wav");
//        precache_sound ("hook/chain1.wav");	DAR [n/a]
//        precache_sound ("hook/chain2.wav");	DAR [n/a]
//        precache_sound ("hook/retract.wav");	DAR [n/a]
//--------------------------------------------------------------------
// File: Defs.qc
// Declaration group: player only fields
// Location: after line ".float pain_finished;"
// Added: .float hook;	
//--------------------------------------------------------------------

// DAR Changed all T_Damages ... reversed second and third field... they where wrong.

.float			hook;


void(vector org, vector vel, float damage) SpawnBlood;	// prototype
float () crandom;   							// prototype


float	HOOK_OUT = 1;		// bit flag on if hook has been launched
float	HOOK_ON = 2;		// bit flag on if I_HOOK is active
float GROW_ON = 4;		// bit flag on if I_GROW is active
float SHRINK_ON = 8;		// bit flag on if I_SHRINK is active 
// DAR
float HOOK_ATTACH = 16;		// bit flag for hook being attached...

float I_HOOK = 98;		// impulse constant
float	I_GROW = 97;		// impulse constant
float	I_SHRINK = 96;		// impulse constant

float MIN_CHAIN_LEN = 50;	// minimum chain length
float MAX_CHAIN_LEN = 800;	// maximum chain length
float GROW_SHRINK_RATE = 35;	// speed of chain growth or chain shrinking


//--------------------------------------------------------------------
// Vector dot product function
//--------------------------------------------------------------------
float (vector from, vector onto) Dot = 
{
	return from_x * onto_x + from_y * onto_y + from_z * onto_z;
};


//--------------------------------------------------------------------
// Removes hook and detaches player
//--------------------------------------------------------------------
void () DropHook =
{
      local entity linkptr;
      local entity nextptr;

	// remove all hook flags
	self.owner.hook = 0;

	// removes chain
	linkptr = self.goalentity;
	while (linkptr != world)
	{
		nextptr = linkptr.goalentity;
		remove (linkptr);
		linkptr = nextptr;
	}

//DAR	sound (self.owner, CHAN_AUTO, "hook/retract.wav", 1, ATTN_NORM);	

	// removes hook
	remove (self);
};


//--------------------------------------------------------------------
// Updated calculation of link positions
//--------------------------------------------------------------------
void () NewLinkPos =
{
	setorigin (self, self.owner.origin + ((self.enemy.origin + '0 0 16') - self.owner.origin) * self.weapon);
	self.nextthink = time + 0.01;
};


//--------------------------------------------------------------------
// Creates chain
//--------------------------------------------------------------------
entity (entity head, entity tail, float num) CreateChain =
{
	local entity link, prevlink;
	local float linknum;

	linknum = num;
	num = num + 1;
	prevlink = world;
	while (linknum > 0)
	{
		link = spawn();
		link.goalentity = prevlink;
		prevlink = link;
		link.owner = head;
		link.enemy = tail;
		link.weapon = linknum / num;
		link.movetype = MOVETYPE_NOCLIP;
		link.solid = SOLID_NOT;
		link.angles_z = 51 * linknum;
		link.angles_y = 41 * linknum;
		link.angles_x = 31 * linknum;
		link.avelocity = '310 410 510';
		setmodel (link, "progs/s_spike.mdl");
		setsize (link, '0 0 0', '0 0 0');
		setorigin (link, head.origin + ((tail.origin + '0 0 16') - head.origin) * link.weapon);
		link.nextthink = time + 0.01;
		link.think = NewLinkPos;
		linknum = linknum - 1;
	}
	return link;
};


//--------------------------------------------------------------------
// Hook behavior function
//--------------------------------------------------------------------
void () HookBehavior =
{
      local vector spray;				// for blood	
      local vector chainvec;				// chain vector
	local vector velpart;				// player velocity moving away from hook
	local float chainlength;			// length of extended chain
	local float f1;					// antigravity force
	local float i1, i2;				// intermediate values
		      
	// decide when to disconnect hook
//DAR	if (  ((self.owner.hook & HOOK_ON) != HOOK_ON) ||
//DAR		(self.owner.teleport_time > time) || 	// if player goes through teleport
//DAR		(self.owner.deadflag) ||			// if player dies
//DAR		(self.enemy.solid == SOLID_NOT)	)	// if target dies
// DAR
	if ( ((self.owner.hook & HOOK_ON) != HOOK_ON) ||
		(self.owner.teleport_time > time) ||
		(self.owner.deadflag) ||
		(self.owner.solid == SOLID_NOT) ||
		(self.enemy.teleport_time > time) ||
		(self.enemy.deadflag) ||
		(self.enemy.solid == SOLID_NOT) )	// !DAR
	{
		DropHook();
		return;
	}
	
	// give some damage to entities that take damage
	if (self.enemy.takedamage)
		T_Damage (self.enemy, self.owner, self, 1);

	// when hook hits player add blood and sounds
	if (self.enemy.solid == SOLID_SLIDEBOX)
	{
		sound (self, CHAN_AUTO, "blob/land1.wav", 0.8, ATTN_NORM);
		spray_x = 100 * crandom();
 		spray_y = 100 * crandom();
		spray_z = 100 * crandom() + 50;
		SpawnBlood (self.origin, spray, 20);
		setorigin (self, self.enemy.origin + self.enemy.mins + self.enemy.size * 0.5);
	}

	self.velocity = self.enemy.velocity;

// rope restrainment physics

	// grow the length of the chain
	if ((self.owner.hook & GROW_ON) && (self.armorvalue < MAX_CHAIN_LEN))
	{
		self.armorvalue = self.armorvalue + GROW_SHRINK_RATE;
// DAR		sound (self.owner, CHAN_AUTO, "hook/chain1.wav", 0.8, ATTN_NORM);
	}

	// shrink the length of the chain
 	if ((self.owner.hook & SHRINK_ON) && (self.armorvalue > MIN_CHAIN_LEN))
	{
		self.armorvalue = self.armorvalue - GROW_SHRINK_RATE;
// DAR		sound (self.owner, CHAN_AUTO, "hook/chain2.wav", 0.8, ATTN_NORM);
	}

      chainvec = self.origin - (self.owner.origin + '0 0 16');
	chainlength = vlen (chainvec);

	// derives force towards hook
	if (chainlength > self.armorvalue)	
	{	 
	   	f1 = (chainlength - self.armorvalue) * 3;

		// dampens player's velocity moving away from hook
		i1 = Dot(self.owner.velocity,chainvec);
		i2 = Dot(chainvec,chainvec);
		velpart = chainvec * (i1 / i2);
		self.owner.velocity = self.owner.velocity - velpart;  
		i1 = vlen (velpart);
		if (i1 > 600)
			sound (self.owner, CHAN_AUTO, "player/land2.wav", 1, ATTN_NORM);
	}
	else
      	f1 = 0;

      // applys forces to players velocity 
	self.owner.velocity = self.owner.velocity + normalize(chainvec) * f1;

	self.nextthink = time + frametime;
};


//--------------------------------------------------------------------
// Hook's touch function
//--------------------------------------------------------------------
void() ChainTouch =
{
	if (!(self.owner.hook & HOOK_ON)) 
	{		
		DropHook();
		return;
	}

	if (other.classname == "missile" ||
		other.classname == "grenade" ||
		other.classname == "spike" ||
		other.classname == "wizspike" ||
		other.classname == "knightspike")
	{
		DropHook();
		return;
	}

	if (other.takedamage)
		T_Damage (other, self.owner, self, 10 );

 	if (other.solid == SOLID_SLIDEBOX)
	{
		sound (self, CHAN_AUTO, "shambler/smack.wav", 1, ATTN_NORM);	
		SpawnBlood (self.origin, self.velocity, 10);
		setorigin (self, other.origin + other.mins + other.size * 0.5);
	}
	else
	{
		sound (self, CHAN_AUTO, "player/axhit2.wav", 1, ATTN_NORM);
		self.avelocity = '0 0 0';
	}

	self.velocity = other.velocity;

	//DAR
	self.owner.hook = self.owner.hook | SHRINK_ON;
	self.owner.hook = self.owner.hook | HOOK_ATTACH;

	self.enemy = other;
	self.nextthink = time + frametime;
	self.think = HookBehavior;
	self.touch = SUB_Null;
};


//--------------------------------------------------------------------
// Limit hook length during launch 
//--------------------------------------------------------------------
void() LaunchHook =
{
      local vector chainvec;				// chain vector
	local float chainlength;			// length of extended chain
	
	chainvec = self.origin - (self.owner.origin + '0 0 16');
	chainlength = vlen (chainvec);

	// armorvalue is used to hold current length of chain
	self.armorvalue = chainlength;

	if (chainlength > MAX_CHAIN_LEN)
	{
		DropHook();
		return;
	}

	// DAR
	if (!self.owner.hook)
	{
		DropHook();
		return;
	}
	// !DAR

	self.nextthink = time + frametime;
};


//--------------------------------------------------------------------
// Initiates the hook
//--------------------------------------------------------------------
void(entity myself) InitiateHook =
{
	local entity newhook;

	newhook = spawn ();
	newhook.classname = "hook";
	newhook.owner = myself;
	newhook.movetype = MOVETYPE_FLY;
	newhook.solid = SOLID_BBOX;
	setmodel (newhook, "progs/v_spike.mdl");
	setsize (newhook, '0 0 0', '0 0 0');     
	makevectors (myself.v_angle);
	setorigin (newhook, myself.origin + (v_forward*16) + '0 0 16' );
	newhook.velocity = v_forward*1000;
	newhook.angles = vectoangles(newhook.velocity);
	newhook.avelocity = '0 0 600';
	sound (myself, CHAN_AUTO, "weapons/ax1.wav", 1, ATTN_NORM);
	// DAR changed from 8 to 3 for lag reasons... =(
	newhook.goalentity = CreateChain (newhook, myself, 3);
	
	newhook.touch = ChainTouch;
	newhook.nextthink = time + 0.01;
	newhook.think = LaunchHook;
};


//--------------------------------------------------------------------
// Checks impulse
//--------------------------------------------------------------------
void() CheckGrapHook = 
{
	if ((!(self.hook & HOOK_OUT)) && (self.impulse == I_HOOK))
	{
		// flags that one instance of hook is spawned
		self.hook = self.hook | HOOK_OUT;
	
		// flags last activated hook impulse as being ON 
		self.hook = self.hook | HOOK_ON;   

		InitiateHook (self);
		return;
	}

	if ((self.hook & HOOK_OUT) && (self.impulse == I_SHRINK) && (!(self.hook & HOOK_ATTACH)))
	{
		self.hook = 0;
		return;
	}

	if (self.hook & HOOK_ON) 
	{ 
		// release hook	
		if (self.impulse == I_HOOK)
		{
			self.hook = self.hook - (self.hook & HOOK_ON);
			return;
		}

		// hop of chain and release hook
		if (	(self.button2) && 
			(!(self.flags & FL_ONGROUND)) &&
			(self.flags & FL_JUMPRELEASED) &&
			(!(self.flags & FL_INWATER))	)
		{
			self.hook = self.hook - (self.hook & HOOK_ON);
			self.velocity_z = self.velocity_z + 200;
			sound (self, CHAN_BODY, "player/plyrjmp8.wav", 1, ATTN_NORM);
			return;
		}

		// handle growing chain impulse
		if ((self.impulse == I_GROW) && (!(self.hook & SHRINK_ON)))
		{
			if (self.hook & GROW_ON)
			{  
				self.hook = self.hook - (self.hook & GROW_ON);
				return;
			}
			else	
			{
				self.hook = self.hook | GROW_ON;
				return;
			}
		}

		// handle shrink chain impulse
		if ((self.impulse == I_SHRINK) && (!(self.hook & GROW_ON)))
		{
			if (self.hook & SHRINK_ON) 
			{	
				self.hook = self.hook - (self.hook & SHRINK_ON);
				return;	
			}
			else
			{
				self.hook = self.hook | SHRINK_ON;
				return;
			}
		}
	}
}; 
