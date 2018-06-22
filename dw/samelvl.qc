/*
Pick a random level
*/

float	SL_RANDOM =		4;

string () RandomLevel =
{
	local float rand;
	local float custom, registered;

	registered = cvar("registered");
	custom = 0;	// allow for custom levels?

	rand = random() * (6 + custom);
	if ((rand < 1) && !(deathmatch & DM_CTF))
	{
		rand = random() * 2;
		if (rand < 1 || !registered)
			return("start");
		else
			return("end");
	}
	else if (rand < 2 || !registered)
	{
		rand = random() * 8;
		if (rand < 1)
			return("e1m1");
		else if (rand < 2)
			return("e1m2");
		else if (rand < 3)
			return("e1m3");
		else if (rand < 4)
			return("e1m4");
		else if (rand < 5)
			return("e1m5");
		else if (rand < 6)
			return("e1m6");
		else if ((rand < 7) && !(deathmatch & DM_CTF))
			return("e1m7");
		else
			return("e1m8");
	}
	else if (rand < 3)
	{	
		rand = random() * 7;
		if (rand < 1)
			return("e2m1");
		else if (rand < 2)
			return("e2m2");
		else if (rand < 3)
			return("e2m3");
		else if (rand < 4)
			return("e2m4");
		else if (rand < 5)
			return("e2m5");
		else if (rand < 6)
			return("e2m6");
		else
			return("e2m7");
	}
	else if (rand < 4)
	{
		rand = random() * 7;
		if (rand < 1)
			return("e3m1");
		else if (rand < 2)
			return("e3m2");
		else if (rand < 3)
			return("e3m3");
		else if (rand < 4)
			return("e3m4");
		else if (rand < 5)
			return("e3m5");
		else if (rand < 6)
			return("e3m6");
		else
			return("e3m7");
	}
	else if (rand < 5)
	{
		rand = random() * 8;
		if (rand < 1)
			return("e4m1");
		else if (rand < 2)
			return("e4m2");
		else if (rand < 3)
			return("e4m3");
		else if (rand < 4)
			return("e4m4");
		else if (rand < 5)
			return("e4m5");
		else if (rand < 6)
			return("e4m6");
		else if (rand < 7)
			return("e4m7");
		else
			return("e4m8");
	}
	else if (rand < 6)
	{
		rand = random() * 6;
		if (rand < 1)
			return("dm1");
		else if (rand < 2)
			return("dm2");
		else if (rand < 3)
			return("dm3");
		else if (rand < 4)
			return("dm4");
		else if (rand < 5)
			return("dm5");
		else
			return("dm6");
	}
	else
	{
		bprint("DAR: Custom level reached!\n");
		return("start");
		// custom levels go here!
	}
};
