/*  $Id: runes60.qc,v 1.1 2003/09/27 02:22:09 slotzero Exp $

    Copyright (C) 2001, 2002  David 'Slot Zero' Roberts.

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
*/

void()
Glue_Think =
{
	if (time >= self.runetime)
	{
		if (self.owner.runetype == RN_GLUE && self.owner.runevar > 0)
		{
			if (self.owner.class_cnt)
				self.owner.class_cnt = self.owner.class_cnt - 1;
			else
			{
				sprint (self.owner, "A glue trap evaporated\n");
				self.owner.runevar = self.owner.runevar - 1;
			}
		}
		create_te_tarexplosion (self.origin);
		remove (self);
		return;
	}

	if (self.velocity != VEC_ORIGIN)
		self.nextthink	= time + sys_ticrate;
	else
	{
		self.runevar	= 1;
		self.solid	= SOLID_TRIGGER;
		self.nextthink	= time + 45;

		setsize (self, self.mins, self.maxs);
		sound (self, CHAN_WEAPON, "blob/land1.wav", 1, ATTN_NORM);
	}
};

void ()
Glue_Stuck =
{
	if (time > self.runetime)
	{
		centerprint (self.runent, "Released from glue trap");
		sound (self, CHAN_WEAPON, "blob/death1.wav", 1, ATTN_NORM);
		remove (self);
		return;
	}

	if (self.runent.health < 1)
	{
		remove (self);
		return;
	}

	setorigin (self.runent, self.origin);

	self.runent.velocity	= '0 0 0';
	self.nextthink		= time + sys_ticrate;
};

void()
Glue_Touch =
{
	//if (other == self.owner)

	if (other.classname != "player"
			&& other.classname != "shambler_slave"
			&& other.classname != "zombie_camper")
		return;

	if (other.health < 1)
		return;

	if (environmental (other))
		return;

	if (isfriend2 (self.owner, other) && self.owner != other)
		return;

	if (!self.runevar)
		return;

	if (self.owner.runetype == RN_GLUE && self.owner.runevar > 0)
		self.owner.runevar = self.owner.runevar - 1;

	self.solid	= SOLID_NOT;
	self.movetype	= MOVETYPE_NONE;
	self.touch	= SUB_Null;
	self.think	= Glue_Stuck;
	self.nextthink	= time;
	self.runent	= other;
	self.runetime	= time + 10;

	setorigin(self, other.origin);
	self.frame	= 60;

	setmodel (self, "progs/tarbaby.mdl");
	sound (self, CHAN_WEAPON, "blob/hit1.wav", 1, ATTN_NORM);

	centerprint(other, "You are stuck!");

	if (other == self.owner)
		sprint(self.owner, "You glued yourself\n");
	else
	{
		sprint (other, "You stepped in ");
		sprint (other, self.owner.netname);
		sprint (other, "'s glue.\n");

		sprint(self.owner, other.netname);
		sprint(self.owner, " is caught in your glue.\n");
	}
};

void()
Rune_Glue =
{
	local entity glue;
	local string s, s1;

	if (self.runevar >= MAX_GLUE)
	{
		s = ftos (MAX_GLUE);
		if (MAX_GLUE != 1)
			s1 = "s";
		centerprint5 (self, "Only ", s, " glue trap", s1, " allowed");
		return;
	}
	self.runevar		= self.runevar + 1;

	sound (self, CHAN_WEAPON, "blob/sight1.wav", 1, ATTN_NORM);

	IN_POQ([-
		self.punchangle_x = -2;
	-])

	glue			= spawn();
	glue.owner		= self;
	glue.movetype		= MOVETYPE_BOUNCE;
	glue.solid		= SOLID_TRIGGER;
	glue.classname		= "glue";

	makevectors (self.v_angle);

	glue.velocity		= v_forward * 600 + v_up * 200;
	glue.avelocity		= '0 600 0';
	glue.runetime		= time + 10;

	setmodel (glue, "progs/tarbaby.mdl");
	setsize (glue, '-16 -16 -24', '16 16 24');
	setorigin (glue, self.origin + '0 0 24');

	glue.touch		= Glue_Touch;
	glue.think		= Glue_Think;
	glue.nextthink		= time;
};
