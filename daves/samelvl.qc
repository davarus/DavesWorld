/*
 * LEVEL SELECTION
 *
 * TODO:
 *	Add in maps for the various add-on packs and mods.
 *	Pick map based on number of players/game-type?
 *
 * BUGS:
 *	None
 *
 * Copyright (C) 1997-99 David Russell
 *       ALL RIGHTS RESERVED!
 */
/*******************************************************************************
 * samelvl globals
 ******************************************************************************/
float	SL_NOLAME =	4;	/* NOTE: start overloading at 4 due to QW */
float	SL_DMONLY =	5;


/*******************************************************************************
 * samelvl::random()
 ******************************************************************************/
string () samelvl_random =
{
	local string nextlvl;
	local float samelvl;
	local float registered;
	local float level;

	samelvl = cvar("samelevel");

	if (!cvar("registered")) {
		level = random() * 9;
	} else if (samelvl & SL_DMONLY) {
		level = (random() * 6) + 32;
	} else { /* anything goes */
		level = random() * 38;
	}

	if (level <= 1) {
		if (samelvl & SL_NOLAME) {
			nextlvl = samelvl_random();
			return nextlvl;
		}
		return "start";
	}
	else if (level <= 2)   return "e1m1";
	else if (level <= 3)   return "e1m2";
	else if (level <= 4)   return "e1m3";
	else if (level <= 5)   return "e1m4";
	else if (level <= 6)   return "e1m5";
	else if (level <= 7)   return "e1m6";
	else if (level <= 8)   return "e1m7";
	else if (level <= 9)   return "e1m8";
	else if (level <= 10)  return "e2m1";
	else if (level <= 11)  return "e2m2";
	else if (level <= 12)  return "e2m3";
	else if (level <= 13)  return "e2m4";
	else if (level <= 14)  return "e2m5";
	else if (level <= 15)  return "e2m6";
	else if (level <= 16)  return "e2m7";
	else if (level <= 17)  return "e3m1";
	else if (level <= 18)  return "e3m2";
	else if (level <= 19)  return "e3m3";
	else if (level <= 20)  return "e3m4";
	else if (level <= 21)  return "e3m5";
	else if (level <= 22)  return "e3m6";
	else if (level <= 23)  return "e3m7";
	else if (level <= 24)  return "e4m1";
	else if (level <= 25)  return "e4m2";
	else if (level <= 26)  return "e4m3";
	else if (level <= 27)  return "e4m4";
	else if (level <= 28)  return "e4m5";
	else if (level <= 29)  return "e4m6";
	else if (level <= 30)  return "e4m7";
	else if (level <= 31)  return "e4m8";
	else if (level <= 32) {
		if (samelvl & SL_NOLAME) {
			nextlvl = samelvl_random();
			return nextlvl;
		}
		return "end";
	}
	else if (level <= 33)   return "dm1";
	else if (level <= 34)   return "dm2";
	else if (level <= 35)   return "dm3";
	else if (level <= 36)   return "dm4";
	else if (level <= 37)   return "dm5";
	else if (level <= 38)   return "dm6";
	dprint("warning: samelvl::random() overflow\n");
	return "start";
};
