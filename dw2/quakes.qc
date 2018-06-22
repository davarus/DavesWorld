// EarthQuake code by David Russell (xxxxxxxxxxxxxxxxxxxx)
// Last Modified: 5/16/97
//
//
// TODO:
//	Make it shake the .angles a little as well...
//	Tweak it to perfection...
//	Very little momentum shaking while in the air
//	A little more in the water
//	A ton on the ground..
//	Equal angle shaking all around... (not too much though)
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
		self.nextthink = time + 3;

	}
	else
		self.nextthink = time + 1;
};

void () shaker_think =
{
	local float rand;

	rand = random() * 100;
	if (rand > 90)
	{
		bprint("EARTHQUAKE!\n");
		self.health = random() * 30;		// duration
		earthquake = random() * 300;		// intensity
		self.think = quake_think;
		self.nextthink = time + frametime;
	}
	else
		self.nextthink = time + 3;
};

void () QUAKE_Init =
{
	local entity shaker;

	shaker = spawn();
	shaker.classname = "shaker";
	shaker.think = shaker_think;
	shaker.nextthink = time + 3;
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
