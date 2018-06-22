/* GLOBALS ////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////*/
/* New entity variables */
.float	lastteam;

/* Team Colors */
float	TEAM1_COLOR =		5;
float	TEAM2_COLOR =		14;

/* Teamplay Settings */
float	TP_FORCE =		2;
float	TP_LOCK =		4;
float	TP_FAIR =		4096;


/* Teamplay ///////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////*/
/* Return a Team Color */
string (float teamcolor) GetTeamColor =
{
	if (teamcolor == TEAM1_COLOR)
		return("Red");
	if (teamcolor == TEAM2_COLOR)
		return("Blue");
	return("");
};

/* Is it a valid Team? */
float (float teamcolor) IsValidTeam =
{
	if (teamcolor == TEAM1_COLOR)
		return(1);
	if (teamcolor == TEAM2_COLOR)
		return(1);
	return(0);
};

/* Put the player on the Team of their choice */
void (float teamcolor) PutOnTeam =
{
	local string scolor;
	local entity p;
	local float team1, team2;
	local float score1, score2;

	self.lastteam = -1;
	if ((!teamplay & TP_FAIR) && IsValidTeam(self.team))
	{
		self.lastteam = self.team;
	}
	else
	{
		// Put them on team in need of help...
		score2 = 0;
		score1 = 0;
		team2 = 0;
		team1 = 0;
		p = nextent(world);
		while (p != world)
		{
			if (p.flags & FL_CLIENT)
			{
				if (p.lastteam = TEAM1_COLOR)
				{
					score1 = score1 + p.frags;
					team1 = team1 + 1;
				}
				else if (p.lastteam = TEAM2_COLOR)
				{
					score2 = score2 + p.frags;
					team2 = team2 + 1;
				}
			}
			p = nextent(p);
		}

		self.lastteam = TEAM1_COLOR;
//		if (team1 == team2)
//		{
//			if ((score2 < score1) || (random() > 0.5))
//				self.lastteam = TEAM2_COLOR;
//		}
		if (team2 < team1)
			self.lastteam = TEAM2_COLOR;

		stuffcmd(self, "color ");
		scolor = ftos(self.lastteam - 1);
		stuffcmd(self, scolor);
		stuffcmd(self, ";\n");
		self.team = self.lastteam;
	}

	bprint(self.netname);
	bprint(" joined the ");
	scolor = GetTeamColor(self.lastteam);
	bprint(scolor);
	bprint(" team\n");

	self.frags = 0;
};

/* Deal with Team Locking */
void () CheckTeam =
{
	local string scolor;

	if (!(teamplay & TP_FORCE))
		return;		// No need to continue...

	// Did the player change teams?
	if (self.team != self.lastteam)
	{
		// suicide them...
		if (teamplay & TP_LOCK)
		{
			stuffcmd(self, "color ");
			scolor = ftos(self.lastteam - 1);
			stuffcmd(self, scolor); 
			stuffcmd(self, ";\n");
			bprint(self.netname);
			bprint(" tried to switch teams\n");
		}
		else
		{
			PutOnTeam(self.team);
		}
	}
	else if (!IsValidTeam(self.team))
		PutOnTeam(self.team);
};
