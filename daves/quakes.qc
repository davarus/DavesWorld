/*
 * EARTHQUAKES
 *
 * TODO:
 *	Shake the angles as well?
 *	Tweak intensities...
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
float	DM_QUAKES =		512;
float	QUAKES_IDELAY =		15;	/* initial delay */
float	QUAKES_DURATION =	30;	/* duration */
float	QUAKES_INTENSITY =	300;	/* intensity */
float	QUAKES_INTERVAL =	600;	/* interval between quakes */
void () quakes_stop;
void () quakes_start;
float	earthquake;


/*******************************************************************************
 * quakes::init()
 ******************************************************************************/
void () quakes_init =
{
	local entity quakes;

	dprint("quakes::init()...\n");
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
	self.nextthink = time + (random() * QUAKES_DURATION);
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
        vx = random();
        vy = random();
        vz = random();

	/* change velocities based on location */
	if (self.flags & FL_INWATER) {
		vx = frametime * (vx * (earthquake / 4));
		vy = frametime * (vy * (earthquake / 4));
		vz = frametime * (vz * (earthquake / 4));
        } else if (self.flags & FL_ONGROUND) {
		vx = frametime * (vx * earthquake);
		vy = frametime * (vy * earthquake);
		vz = frametime * (vz * (earthquake / 4));
	} else if (self.flags * FL_PARTIALGROUND) {
		vx = frametime * (vx * earthquake);
		vy = frametime * (vy * earthquake);
		vz = frametime * (vz * (earthquake / 4));
        } else { /* we must be in the air */
		vx = frametime * (vx * (earthquake / 8));
		vy = frametime * (vy * (earthquake / 8));
		vz = frametime * (vz * (earthquake / 8));
        }
	
	/* switch directions sometimes. =) */
	if (random() < 0.5)  vx = 0 - vx;
	if (random() < 0.5)  vy = 0 - vy;
	if (random() < 0.5)  vz = 0 - vz;

	/* modify the velocities */
	self.velocity_x = self.velocity_x + vx;
	self.velocity_y = self.velocity_y + vy;
	self.velocity_z = self.velocity_z + vz;
};
