// Originally found in CTF4.1 ... didn't work worth a shit so I fixed
// it up..

// Um... I think I fucked up.

entity(entity ent) identify_player =
{
	local entity e, guy;
	local vector targetangle, entangle, diff;

	e=find(world, classname, "player");
	while (e!=world)
	{
		targetangle = e.origin - ent.origin;
		targetangle = normalize(diff);
		targetangle = vectoangles(diff);
		// targetangle = '-180 -180 0' to '180 180 0'

		entangle = ent.v_angle;
		// entangle = '-180 -180 0' to '180 180 0'

		diff = targetangle - entangle;
		// diff = '-360 -360 0' to '360 360 0'

		// a diff of (> -10 && < 10) || ( < -350 || > 350) is looking
		// at target (within 10 degrees)

		// Make sure they are visable...
		if (((diff_x > -10) && (diff_x < 10)) || ((diff_x < -350) || (diff_x > 350)) &&
		   ((diff_y > -10) && (diff_y < 10)) || ((diff_y < -350) || (diff_y > 350)))
		{
			traceline(ent.origin + ent.view_ofs, e.origin, FALSE, ent);
			if (trace_ent == e)
				guy = e;
		}
		e=find(e, classname, "player");
	}
	return guy;
};	 

