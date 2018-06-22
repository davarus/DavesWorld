.float		heat;
.float		power;

//.armor = shields...
//.currentammo = power...
//.spawnflags = heat... &1	&2	&4	&8
//			Green	Yellow	Orange	Red

/*
Heat has been temporarily disabled for the sake of making it like a DM5 mode
which is similiar to DM4 although I had the idea long before DM4...
interestingly, I think my DM5 is a lot better.... in concept and in effect.
*/

void () set_suicide_frame;
void () ClientRegen =
{
	// POWER / AMMO
	if (self.power < 100)
	{
		self.power = self.power + 10 * frametime;
		self.heat = self.heat + 1 * frametime;
		if (self.power > 100)
			self.power = 100;
	}
	else if (self.power > 150)
		self.power = self.power - 2 * frametime;

	// HEAT
	if (self.watertype == CONTENT_LAVA)
		self.heat = self.heat + 10 * frametime;
	else if (self.watertype == CONTENT_SLIME)
		self.heat = self.heat + 5 * frametime;
	else if (self.watertype == CONTENT_WATER)
		self.heat = self.heat - 5 * frametime;
	if (self.heat > 0 && self.power > 0)
	{
		self.power = self.power - 2 * frametime;
		self.heat = self.heat - 6 * frametime;
		if (self.heat < 0)
			self.heat = 0;
	}
	if (self.heat > 90)
	{
		self.health = self.health - self.heat * 0.01 * frametime;
		if (self.health < 0)
		{
			bprint(self.netname);
			bprint(" overheated\n");
			self.frags = self.frags - 1;
			set_suicide_frame();
		}
	}
	if (self.heat < 0)
		self.heat = 0;
	if (self.heat > 255)
		self.ammo_shells = 255;
	else
		self.ammo_shells = self.heat;

	// ARMOR / SHIELDS
	if (self.armorvalue < 100 && self.power > 0)
	{
		self.power = self.power - 6 * frametime;
		self.armorvalue = self.armorvalue + 20 * frametime;
		self.heat = self.heat + 1 * frametime;
		if (self.armorvalue > 100)
			self.armorvalue = 100;
	}
	if (self.armortype < 0.2)
	{
		self.armortype = 0.2;
	}

	self.currentammo = self.power;
	if (self.power < 0)
		self.currentammo = 0;
};
