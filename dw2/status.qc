.entity		status_bar;

void (entity ent, string str) centerprint =
{
	if (ent.status_bar != world)
	{
		ent.status_bar.message = str;
		ent.status_bar.nextthink = time + 0.01;
	}
	else
		real_centerprint1(ent, str);
};

void () STATUS_think =
{
	local string line1, line2, line3, line4, line5;
	local entity facing;

	facing = identify_player(self.owner);
	if (facing != world)
		line1 = facing.netname;
	else
		line1 = "          ";
	line2 = "  ...    ";
	line3 = vtos(self.owner.v_angle);


	real_centerprint7(self.owner, self.message, self.netname, line1, line2, line3, line4, line5);
	// reset the original centerprint crap...
	self.message = "";

	self.nextthink = time + 0.7;
};

void (entity ent) STATUS_init =
{
	local entity status;

	status = spawn();
	status.classname = "status_bar";
	status.owner = ent;
	ent.status_bar = status;

	status.message = "";
	status.netname = "\n\n\n\n\n\n\n\n\n\n\n\n";

	status.think = STATUS_think;
	status.nextthink = time + 0.01;
};
