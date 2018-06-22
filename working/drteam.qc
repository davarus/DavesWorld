/*
 * TEAMPLAY
 */
.float	teamlast;
.float  teamspam;
.float  teamtime;

float TEAM_MAXCHANGES	= 20;
float TEAM_DELAY		= 1;
float TP_FORCE		= 2;
float TP_LOCK		= 4;
float TP_FAIR		= 8;

//string team1_name	= "Silver";
float team1_color		= 12;
float team1_score		= 0;

//string team2_name	= "Gold";
float team2_color		= 13;
float team2_score		= 0;

//string team3_name	= "Red";
float team3_color		= 5;
float team3_score		= 0;

//string team4_name	= "Blue";
float team4_color		= 14;
float team4_score		= 0;

string (float teamcolor) team_name = {
        if (teamcolor == 12)
                return "Silver";
        if (teamcolor == 13)
                return "Gold";
        if (teamcolor == 5)
                return "Red";
        if (teamcolor == 14)
                return "Blue";
        return "";
};

float (float teamcolor) team_isvalid =
{
        if ((teamcolor > 14) || (teamcolor < 1))
		return 0;
	else if (teamcolor == team1_color)
		return 1;
	else if (teamcolor == team2_color)
		return 2;
	else if (teamcolor == team3_color)
		return 3;
	else if (teamcolor == team4_color)
		return 4;
	return 0;
};

void () team_change =
{
	local float	newscore, oldscore;
	local string	scolor;

//	/* work around for stuffcmd to work */
//	if (self.teamtime > time)
//		return;

	/* prevent players from spamming */
	self.teamspam = self.teamspam + 1;
	if (self.teamspam > TEAM_MAXCHANGES) {
		/* give them the boot */
		stuffcmd(self, "echo Rainbows are not permitted here;\n");
		stuffcmd(self, "disconnect;\n");
		return;
	}

	/* is teamplay locked? */
	if (teamplay & TP_LOCK) {
		scolor = ftos(self.teamlast - 1);
		sprint(self, "Teams are locked!\n");
		stuffcmd(self, "color ");
		stuffcmd(self, scolor);
		stuffcmd(self, ";\n");
//		self.teamtime = time + TEAM_DELAY;
		self.team = self.teamlast;
		return;
	}

	/* is teamplay forced? */
	if (teamplay & TP_FORCE) {
		if (!team_isvalid(self.team)) {
			scolor = ftos(self.teamlast - 1);
			sprint(self, "Not a valid team!\n");
			stuffcmd(self, "color ");
			stuffcmd(self, scolor);
			stuffcmd(self, ";\n");
//			self.teamtime = time + TEAM_DELAY;
			self.team = self.teamlast;
			return;
		}
	}

	/* must teams be fair?
	if (teamplay & TP_FAIR); */


	/* change their team! */
	bprint(self.netname);
	if (team_isvalid(self.team)) {
		scolor = team_name(self.team);
		bprint(" joined the ");
		bprint(scolor);
		bprint(" team!\n");
	} else if (team_isvalid(self.teamlast)) {
		scolor = team_name(self.teamlast);
		bprint(" left the ");
		bprint(scolor);
		bprint(" team!\n");
	} else {
		bprint(" changed colors!\n");
	}
//	self.teamtime = time + TEAM_DELAY;
	self.teamlast = self.team;
	PutClientInServer();
};
