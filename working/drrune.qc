/*
 * RUNES
 *
 * 	Rune 1: Earth Magic (resistance)
 *	Rune 2: Black Magic (strength)
 *	Rune 3: Hell Magic  (haste)
 *	Rune 4: Elder Magic (regeneration)
 *
 * BUGS:
 *	None
 *
 * Copyright (C) 1997-1999 David Russell
 *         ALL RIGHTS RESERVED!
 */
/*******************************************************************************
 * rune globals
 ******************************************************************************/
float IT_RUNE1	= 8388608;
float IT_RUNE2	= 16777216;
float IT_RUNE3	= 33554432;
float IT_RUNE4	= 67108864;


/*******************************************************************************
 * rune::touch()
 ******************************************************************************/
void () rune_touch =
{
	if ((other.classname != "player") || (other.deadflag > 0))
		return;

	other.items = other.items | self.items;

	bprint(other.netname);
	bprint(" got the ");
	bprint(self.netname);
	bprint(" rune.\n");

	sound(other, CHAN_ITEM, "weapons/lock4.wav", 1, ATTN_NORM);
	stuffcd(other, "bf;\n");
	remove(self);
};


/*******************************************************************************
 * rune::spawn()
 ******************************************************************************/
void (float num) rune_spawn =
{
	
};


/*******************************************************************************
 * rune::init2()
 ******************************************************************************/
void () rune_init2 =
{
	local entity rune;

	rune_spawn(IT_RUNE1);
	rune_spawn(IT_RUNE2);
	rune_spawn(IT_RUNE3);
	rune_spawn(IT_RUNE4);
	remove(self);
};


/*******************************************************************************
 * rune::init()
 ******************************************************************************/
void () rune_init =
{
	local entity rspawn;

	precache_model("progs/end1.mdl");
	precache_model("progs/end2.mdl");
	precache_model("progs/end3.mdl");
	precache_model("progs/end4.mdl");

	precache_sound("boss1/sight1.wav");		/* rune/rune1.wav */
	precache_sound("items/r_item1.wav");	/* rune/rune2.wav */
	precache_sound("items/damage3.wav");	/* rune/rune22.wav */
	precache_sound("items/protect3.wav");	/* rune/rune3.wav */

	rpsawn = rune_init2();
	rspawn.nextthink = time + 0.02;	// Solids first!
	rspawn.think = rune_spawn;
};