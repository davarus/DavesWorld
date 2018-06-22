/*
 * SPAWN LOCATION SELECTION
 *
 * TODO:
 *	Move existing entities out of way if we can't find a free spot
 *
 * BUGS:
 *	None
 *
 * Copyright (C) 1997-99 David Russell
 *        ALL RIGHTS RESERVED!
 */
/*******************************************************************************
 * spawn globals
 ******************************************************************************/
float	DM_SPAWN =		8192;
float	spawn_numspots;


/*******************************************************************************
 * spawn::init()
 ******************************************************************************/
void () spawn_init =
{
	local entity e;

	dprint("spawn::init()...\n");
	/* get the number of spawn points for this level */
	spawn_numspots = 0;
	e = find(world, classname, "info_player_deathmatch");
	while (e != world) {
		spawn_numspots = spawn_numspots + 1;
		e = find(e, classname, "info_player_deathmatch");
	}
	if (spawn_numspots == 0)
		error("spawn::init() found no spawn points!\n");
};


/*******************************************************************************
 * spawn::select()
 ******************************************************************************/
entity () spawn_select =
{
	local float spotnum, spawn_radius;
	local entity randspot, spot, ent;

	/* get the first random spawn point */
	spot = world;
	spotnum = random() * spawn_numspots;
	while (spotnum > 0) {
		spot = find(spot, classname, "info_player_deathmatch");
		spotnum = spotnum - 1;
	}

	/* setup stuff */
	randspot = spot;
	spawn_radius = 512;

	ent = findradius(spot.origin, spawn_radius);
	while (ent) {
		if (ent.classname == "player" && ent.deadflag) {
			spot = find(spot, classname, "info_player_deathmatch");
			if (spot == world) {
				spot = find(world, classname,
					"info_player_deathmatch");
			}
			if (spot == randspot) {
				if (spawn_radius <= 72) {
					/* TODO: move shit */
					return spot;
				}
				spawn_radius = spawn_radius / 2;
			}
			ent = findradius(spot.origin, spawn_radius);
		} else {
			ent = ent.chain;
		}
	}

	/* return the spot */
	return spot;
};
