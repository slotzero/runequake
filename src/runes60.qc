/*  $Id: runes60.qc,v 1.8 2003/10/05 02:55:22 slotzero Exp $

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

void (float riders, entity of_e)
Rune_Glue_sprint =
{
	rprint_numdesc (self, riders, of_e.runevar, "glue trap");
	rprint (self, riders, " placed\n");
};

void()
Glue_Think =
{
	if (self.runevar)
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
	if (self.runetime < time)
	{
		centerprint (self.runent, "Released from glue trap");
		sound (self, CHAN_WEAPON, "blob/death1.wav", 1, ATTN_NORM);
		remove (self);
		return;
	}

	if (self.runent.health <= 0)
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
	if (other.classname != "player" && !is_pet_e (other))
		return;

	if (other.health <= 0)
		return;

	if (environmental (other))
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
	self.runetime	= time + 5;

	setorigin(self, other.origin);
	self.frame	= 60;

	setmodel (self, "progs/tarbaby.mdl");
	sound (self, CHAN_WEAPON, "blob/hit1.wav", 1, ATTN_NORM);

	centerprint(other, "You are stuck!");

	if (other == self.owner)
		sprint (self.owner, "You glued yourself\n");
	else
	{
		if (is_pet_e (other))
		{
			sprint (self.owner, other.owner.netname);
			sprint (self.owner, "'s pet is caught in your glue.\n");
		}
		else
		{
			sprint (other, "You stepped in ");
			sprint (other, self.owner.netname);
			sprint (other, "'s glue.\n");

			sprint (self.owner, other.netname);
			sprint (self.owner, " is caught in your glue.\n");
  		}
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

	setmodel (glue, "progs/tarbaby.mdl");
	setsize (glue, '-16 -16 -24', '16 16 24');
	setorigin (glue, self.origin + '0 0 24');

	glue.touch		= Glue_Touch;
	glue.think		= Glue_Think;
	glue.nextthink		= time;
};

void (float riders, entity of_e)
Rune_Blizzard_sprint =
{
	if (self.runevar)
		rprint (self, riders, "\{13} Recharging...\n");
};

void ()
Rune_Blizzard =
{
	local entity e;
	local float i;

	i = 0;
	if (self.runetime > time)
	{
		centerprint (self, "Blizzard recharging");
		return;
	}

	e = findradius (self.origin, 1000);
	while (e)
	{
		if (e.health && CanDamage (e, self) && e != self && e.owner != self)
		{
			if (e.classname == "player"
					|| e.classname == "shambler_slave"
					|| e.classname == "zombie_camper")
			{
				Blizzard_Freeze (e, 1.2);
				i = i + 1;
			}
		}
		e = e.chain;
	}

	if (i)
	{
		sprint (self, "You froze ");
		sprint_float (self, i);
		sprint (self, " player");
		if (i > 1)
			sprint (self, "s");
		sprint (self, "\n");

		self.runetime = time + RN_BLIZZARD_RECHARGE + (i * 5);
	}
	else
		self.runetime = time + 2;

	self.runevar = 1;
	sound (self, CHAN_AUTO, "enforcer/sight2.wav", 1, ATTN_NORM);
};

void (entity tofreeze, float freeze_time)
Blizzard_Freeze =
{
	local entity freeze;

	if (tofreeze.classname == "player")
		sprint (tofreeze, "You're caught in a blizzard!\n");

	freeze			= spawn ();
	freeze.movetype		= MOVETYPE_FLY;
	freeze.solid		= SOLID_TRIGGER;
	freeze.owner		= self;
	freeze.classname	= "freeze";
	freeze.angles		= tofreeze.angles;
	freeze.v_angle		= tofreeze.v_angle;

	setorigin (freeze, tofreeze.origin + '0 0 10');
	setmodel (freeze, string_null);
	setsize (freeze, VEC_ORIGIN, VEC_ORIGIN);

	sound (freeze, CHAN_BODY, "shambler/smack.wav", 1, ATTN_NORM);

	freeze.runent		= tofreeze;
	freeze.runevar		= tofreeze.frame;
	freeze.angles		= tofreeze.v_angle;
	freeze.fixangle		= 1;

	setorigin (freeze, tofreeze.origin);

	freeze.touch		= SUB_Null;

	// how long frozen
	freeze.runetime		= time + freeze_time;
	freeze.nextthink	= time;
	freeze.think		= Freeze_Frozen;

};

void ()
Blizzard_Think =
{
	if (self.runevar && self.runetime < time)
	{
		self.runevar = 0;
		centerprint (self, string_null);
		sprint (self, "\{13} Blizzard recharged\n");
	}

	if (self.watertype == CONTENT_WATER && self.runevector_x < time)
	{
		self.runevector_x = time + 3;
		Blizzard_Freeze (self, 1);
	}

	IN_POQ([-
		particle (self.origin + '0 0 23', '0 0 -0.05', PARTICLE_FREEZE_TRAP, 1);
		particle (self.origin + '0 0 10', '0 0 -0.05', PARTICLE_FREEZE_TRAP, 1);
	-])
};

void ()
Blizzard_Touch =
{
	if (self.runetime > time)
		return;
 	if (other.health <= 1)
		return;
	if (other.classname != "player"
			&& other.classname != "shambler_slave"
			&& other.classname != "zombie_camper")
		return;

	self.runetime = time + 3;
	Blizzard_Freeze (other, 1);
};
