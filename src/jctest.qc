// $Id: jctest.qc,v 1.1 2002/02/21 21:47:53 slotzero Exp $

void ()
jctrig =
{
	dprint ("here\n\n");
	lightstyle (0, "az");
};

/*QUAKED trigger_jctest (.5 .5 .5) ?
*/
void ()
trigger_jctest =
{
	setsize (self, self.mins, self.maxs);
	self.solid = SOLID_EDGE;
	self.touch = jctrig;
};
