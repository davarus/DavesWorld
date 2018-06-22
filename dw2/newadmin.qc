/* self.owner   = admin
   self.health  = next print time
   self.armor =   numeric value  (variable value)
   self.message = numeric value  (variable value)
   self.netname = string value   (variable name)
   self.touch =   function       (call when variable has been obtained)
*/

/* Get a number from 0 to 65545 */
/* TODO: Allow for negatives...
float value, digit;
void () ADMIN_GetValue =
{
	if (digit > 10000 || self.owner.impulse == IMPULSE_RETURN)
	{
		self.armor = value;
		self.think = self.touch;
		value = 0;
		digit = 0;
		self.nextthink = time + 0.1;
		return;
	}

	if (self.owner.impulse == 10)
		value = value * digit;
	else
		value = (value * digit) + self.owner.impulse;

	self.message = ftos(self.armor);

	if (!digit)
		digit = 10;
	else
		digit = digit * digit;

	if (self.health > time)
	{
		centerprint(self.message, "\n");
		self.health = time + 0.7;
	}
};

centerprint("Remote Administration\n
