// $Id: flag.qc,v 1.1 2002/02/21 21:47:51 slotzero Exp $

/*QUAKED item_deathball (.3 .3 1) (0 0 0) (32 32 32)
*/

void ()
item_deathball =
{
	self.touch = deathball_touch;
};
