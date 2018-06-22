/*
 * EARTHQUAKES
 *
 * TODO:
 *	Tweak intensities...
 *	Optimize this a little... it's pathetic now.
 *	Shake the angles as well?
 *
 * BUGS:
 *	None
 *
 * Copyright (C) 1997-99 David Russell
 *       ALL RIGHTS RESERVED!
 */
/*******************************************************************************
 * quakes globals
 ******************************************************************************/
float	DM_QUAKES			= 512;
float QUAKES_IDELAY		= 1;     /* initial delay */
float QUAKES_DURATION		= 15;    /* duration */
float QUAKES_INTENSITY		= 30;    /* intensity */
float QUAKES_INTERVAL		= 30;    /* interval between quakes */
void () quakes_stop;
void () quakes_start;
float	earthquake;


/*******************************************************************************
 * quakes::init()
 ******************************************************************************/
void () quakes_init =
{
	local entity quakes;

	precache_sound("ambience/thunder1.wav");
	quakes = spawn();
	quakes.classname = "earthquake";
	quakes.think = quakes_stop;
	quakes.nextthink = time + QUAKES_IDELAY;
	earthquake = 0;
};


/*******************************************************************************
 * quakes::start()
 ******************************************************************************/
void () quakes_start =
{
	local float rand;

	bprint("EARTHQUAKE!\n");
	earthquake = random() * QUAKES_INTENSITY;
	self.think = quakes_stop;
	self.nextthink = time + (random() * QUAKES_DURATION + 10);
};


/*******************************************************************************
 * quakes::stop()
 ******************************************************************************/
void () quakes_stop =
{
	earthquake = 0;
	self.think = quakes_start;
	self.nextthink = time + (random() * QUAKES_INTERVAL);
};


/*******************************************************************************
 * quakes::stop()
 ******************************************************************************/
void () quakes_think =
{
	local float vx, vy, vz;

	/* get an initial random number */
	vx = (random() * earthquake) + 10;
	vy = (random() * earthquake) + 10;
	vz = (random() * earthquake) + 10;

	/* change velocities based on location */
	if (self.flags & FL_INWATER) {
		vx = vx * frametime / 2;
		vy = vy * frametime / 2;
		vz = vy * frametime / 2;
	} else if (self.flags & FL_ONGROUND) {
		vx = vx * frametime * 1.5;
		vy = vy * frametime * 1.5;
		vz = vz * frametime;
	} else if (self.flags & FL_PARTIALGROUND) {
		vx = vx * frametime * 1.5;
		vy = vy * frametime * 1.5;
		vz = vz * frametime;
	} else { /* we must be in the air */
		vx = vx * frametime / 4;
		vy = vy * frametime / 4;
		vz = vz * frametime / 4;
	}
	
	/* switch directions sometimes. =) */
	if (random() < 0.5)  vx = 0 - vx;
	if (random() < 0.5)  vy = 0 - vy;
	if (random() < 0.5)  vz = 0 - vz;

	/* modify the velocities */
	self.velocity_x = self.velocity_x + (vx * 100);
	self.velocity_y = self.velocity_y + (vy * 100);
	self.velocity_z = self.velocity_z + (vz * 100);

	/* make some noise! */
	if (random() < (frametime * 4))
		sound(self, CHAN_AUTO, "ambience/thunder1.wav", 1, ATTN_NORM);
};
