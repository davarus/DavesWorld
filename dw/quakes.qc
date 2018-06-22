// EarthQuake code by David Russell (xxxxxxxxxxxxxxxxxxxx)
// Last Modified: 5/16/97
//
//
// TODO:
//	Make it shake the .angles a little as well...
//	Tweak it to perfection...
//
// BUGS:
//	None
//
// Copyright 1997
// ALL RIGHTS RESERVED!

//float		DM_QUAKES =	512;
float		earthquake;

void () shaker_think;
void () quake_think =
{
	self.health = self.health - 1;
	if (self.health < 1)
	{
		self.health = 0;
		earthquake = 0;
		self.think = shaker_think;
		self.nextthink = time + random() * 1500;

	}
	else
		self.nextthink = time + 1;
};

void () shaker_think =
{
	local float rand;

	bprint("EARTHQUAKE!\n");
	self.health = random() * 30;			// duration
	earthquake = random() * 50 + 100;		// intensity
	self.think = quake_think;
	self.nextthink = time + frametime;
};

void () QUAKE_Init =
{
	local entity shaker;

	precache_sound("ambience/thunder1.wav");

	shaker = spawn();
	shaker.classname = "shaker";
	shaker.think = shaker_think;
	shaker.nextthink = time + random() * 1500;
};

void () QUAKE_Shake =
{
	local float randomx, randomy, randomz;

	randomx  = random();
	randomy  = random();
	randomz  = random();


	if (self.flags & FL_ONGROUND)
	{
		randomx = randomx * earthquake;
		randomy = randomy * earthquake;
		randomz = randomz * earthquake;
	}
	else
	{
		randomx = randomx * 20;
		randomy = randomy * 20;
		randomz = randomz * 20;
	}

	if (random() <= frametime * 6)
		sound(self, CHAN_AUTO, "ambience/thunder1.wav", 1, ATTN_NORM);
		// BUG: is CHAN_AUTO correct?

	if (random() >= 0.5)
		self.velocity_x = self.velocity_x + randomx;
	else
		self.velocity_x = self.velocity_x - randomx;
	if (random() >= 0.5)
		self.velocity_y = self.velocity_y + randomy;
	else
		self.velocity_y = self.velocity_y - randomy;
	if (random() >= 0.5)
		self.velocity_z = self.velocity_z - randomz;
	else
		self.velocity_z = self.velocity_z + randomz;

};
