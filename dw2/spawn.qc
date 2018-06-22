/* Random Spawn
   ------------------------------------
	It's pretty self explanitory.  In addition to just randomly picking
   a spot it also has telefrag prevention code and unlike most other such
   devices mine goes through and trys to pick a spawn point furthest from
   the action.  If and ONLY IF it fails to find a spot that is free will it
   telefrag the person whom happens to be standing on the original spot
   picked.  In time that will be fixed as well. =)

   TODO:
	move anyone on a last spot if it is not free

   AUTHOR:
	David Russell <xxxxxxxxxxxxxxxxxxxx> [http://xxxxxxxxxxxxxxxxxxxxxxxxxx]
   MODIFIED:
	6/11/97
*/

//float	DM_SPAWN =		1024;

float	numspawnspots;

float (string str) CountEntities =
{
	local float num;
	local entity e;

	e = find(world, classname, str);
	while(e !=world)
	{
		num = num + 1;
		e = find(e, classname, str);
	}
	
	return(num);	
};

entity (float num, string str) GetEntity =
{
	local entity e;

	e = world;
	while(num)
	{
		num = num - 1;
		e = find(e, classname, str);
	}

	return(e);
};

entity (entity spot) RandomSpawnPoint =
{
	local entity lastspot, spot, thing;
	local float spotnum, spawn_radius;

	if (!numspawnspots)
		numspawnspots = CountEntities("info_player_deathmatch");

	spotnum = random() * numspawnspots;
	spotnum = ceil(spotnum);
	spot = GetEntity(spotnum, "info_player_deathmatch");
	lastspot = spot;
	spotnum = 0;
	spawn_radius = 48 + (256 * 4);
	thing = findradius(spot.origin, spawn_radius);
	while(thing)
	{
		if (thing.classname == "player" && !thing.deadflag)
		{
			spot = find(spot, classname, "info_player_deathmatch");
			if (spot == world)
				spot = find(world, classname, "info_player_deathmatch");
			if (spot == lastspot && spotnum)
			{
				if (spawn_radius <= 48)
					return(spot);
				spawn_radius = spawn_radius - 256;
				spot = find(world, classname, "info_player_deathmatch");
				thing = findradius(spot.origin, spawn_radius);
				spotnum = 0;
			}
			spotnum = spotnum + 1;
			thing = findradius(spot.origin, spawn_radius);
		}
		else
		{
			thing = thing.chain;
		}
	}
	return(spot);
};
