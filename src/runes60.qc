/*  $Id: runes60.qc,v 1.5 2003/09/28 04:05:37 slotzero Exp $

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

	if (environmental (other) || other.runetype == RN_FREEZE)
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
	self.runetime	= time + 5;

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

void (float riders, entity of_e)
Rune_Blizzard_sprint =
{
	if (self.runevar)
		rprint (self, riders, "\> Recharging...\n");
};

void ()
Rune_Blizzard =
{
	local entity e;
	local float i;

	i = 0;
	if (self.runevar == 0)
	{
		if (self.runetime > time)
		{
			centerprint (self, "Blizzard recharging");
			self.runevar = 2;
			return;
		}

		e = findradius (self.origin, 1000);
		while (e)
		{
			if (e.health && CanDamage (e, self) && e != self && e.owner != self)
			{
				Blizzard_Freeze (e, 2.5);
				if (e.classname == "player")
					sprint (e, "You're caught in a blizzard!\n");
				i = i + 1;
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

		sound (self, CHAN_AUTO, "enforcer/sight2.wav", 1, ATTN_NORM);
	}
	else if (self.runevar == 2)
	{
		centerprint (self, "Pending recharge canceled");
		self.runevar = 0;
	}
};

void (entity tofreeze, float freeze_time)
Blizzard_Freeze =
{
	local entity freeze;

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
	if (self.runevar == 2 && self.runetime <= time)
	{
		self.runevar = 0;
		centerprint (self, string_null);
		sprint (self, "\> Blizzard recharged\n");
	}

	// This needs to be fixed?
	if (self.waterlevel && self.runetime < time && self.watertype != CONTENT_LAVA)
	{
		self.runetime = time + 3;
		Blizzard_Freeze (self, 1);
	}

	self.touch = Blizzard_Touch;
	IN_POQ([-
		particle (self.origin + '0 0 23', '0 0 -0.05', PARTICLE_FREEZE_TRAP, 1);
		particle (self.origin + '0 0 10', '0 0 -0.05', PARTICLE_FREEZE_TRAP, 1);
	-])
};

void ()
Blizzard_Touch =
{
	if (other == world)
		return;
	if (other.owner == self)
		return;
	if (!other.health)
		return;
	if (self.runetime > time)
		return;

	self.runetime = time + 3;

	Blizzard_Freeze (other, 1.5);
};

void (float riders, entity of_e)
Rune_Tornado_sprint =
{
	rprint_numdesc (self, riders, of_e.runevar, "tornado");
	rprint (self, riders, " placed\n");
};

void() tornado_touch =
{
	// try to gib whatever touched the tornado centre
	if (other.takedamage && other.health > 0 && !environmental (other))
		T_Damage(other, self, self.owner, self.runevar / 2, "tornado");
};

void() tornado_pull =
{
	local entity e;
	local float d;
	local vector org;
	local float gPercent;
	local float gDist;
	local float gPower;

	gDist = 960;

	//This makes the wind build up speed from 1 to 512 very rapidly
	gPower = self.runevar;

	if (gPower >= 512 && time < self.attack_finished + 0.5)
		gPower = 512;
	else
		self.runevar = self.runevar * 2;


	setorigin (self, self.origin + '0 0 2');

	self.movetype = MOVETYPE_FLYMISSILE;
	self.flags = self.flags - FL_ONGROUND;


	tornado_random_move ();

	if (time > self.attack_finished)
		{
		if (self.effects & EF_BRIGHTLIGHT) // turn off bright light
			self.effects = self.effects - EF_BRIGHTLIGHT;

		// Explode
		T_RadiusDamage (RADIUS_NORMAL, self, self.owner, 40, world, "tornado");
		create_te_explosion (self.origin, 1);
		BecomeExplosion();//This automatically removes self
		return;
		}

	org = (self.absmin + self.absmax) * 0.5;
	e = findradius(self.origin, gDist);

	while (e)
	{
		if (visible(e) && e.classname != "tornado"
				&& e.movetype != MOVETYPE_NONE
				&& e.movetype != MOVETYPE_PUSH
				&& e.movetype != MOVETYPE_NOCLIP
				&& e.runetype != RN_ENVIRO
				&& e.health)
		{
			d = vlen(e.origin - org);
			if (e.flags & FL_ONGROUND)
			{
				// raise the object a bit
				setorigin(e, e.origin + '0 0 1');
				e.flags = e.flags - FL_ONGROUND;
			}
			//dprint(e.classname);
			gPercent = 1 - (d / gDist);

			// modify the velocity
			// I added '0 0 10' to give it more lift (x y z, z being up and down)
			e.velocity = e.velocity + '0 0 10' + normalize(self.origin - e.origin) * gPower * gPercent;


			IN_POQ([-
				particle (e.origin + v_up*random ()*30, e.velocity, 96, 3);//Fire those particles toward the tornado
			-])
		}
			e = e.chain;
	}
	self.nextthink = time + 0.1;
};

void ()
tornado_explode =
{
	setmodel (self, "progs/w_spike.mdl");
	self.attack_finished = time + 3.2;      // duration of tornado well
	self.touch	= tornado_touch;
	self.effects	= self.effects | EF_BRIGHTLIGHT;
	self.think	= tornado_pull;
	self.nextthink	= time + 0.1;
	sound (self, CHAN_BODY, "boss1/out1.wav", 1, ATTN_NORM);
};

void()
Rune_Tornado =
{
	local entity tornado;
	local float i;

	if (self.runetime > time)
	{
		i = self.runetime - time + 0.1;
		if (i > 0.5)
			{
			i = floor (i + 0.5);
			sprint (self, "Wind recharging, ready in ");
			sprint_float (self, i);
			sprint (self, " second");
			if (i != 1)
			sprint (self, "s");
			sprint (self, "\n");
		}
		else
			sprint (self, "Wind recharging\n");
		return;
	}

	// create a tornado object
	tornado = spawn();
	tornado.classname = "tornado";

	tornado.owner = self;
	tornado.solid = SOLID_TRIGGER;
	tornado.movetype = MOVETYPE_TOSS;

	// set it's placement and velocity
	setorigin (tornado, self.origin + self.view_ofs);
	tornado.velocity = self.velocity * 0.5;
	setmodel(tornado, "progs/w_spike.mdl");

	// TODO get accurate sizing
	setsize(tornado, '0 0 0', '32 32 32');

	tornado.angles = '90 0 0';

	tornado.runevar = 1;

	tornado.think = tornado_explode;

	tornado.nextthink = time + 2;

	sound (self, CHAN_BODY, "doors/meduse.wav", 1, ATTN_NORM);

	// Throw away from you
	makevectors (self.angles);
	tornado.velocity = (v_forward * (200 + random() * 100)) + (v_up * (200 + random() * 100));

	sprint (self, "Tornado unleashed!  Get out of here, quick!\n");

	self.runevar = self.runevar + 1;

	if (self.runevar == MAX_TORNADO)
	{
		sprint (self, "No tornados left, rune deleted.\n");
		self.runevar = 0;
		Rune_Delete (0);
	}
	else if (self.runevar == 1)
		centerprint (self, "2 tornados left.\n");
	else if (self.runevar == 2)
		centerprint (self, "1 tornado left.\n");

	self.runetime = tornado.nextthink + 3.2;//Delay time: Charge time + attack time
};

void ()
tornado_random_move =
{
	self.velocity = self.velocity * 0.2;

	local float torn_speed, ranman;
	local vector vecman;

	torn_speed = ceil (100 + (random () * 300));

	ranman = ceil (random () * 8);

	if (ranman <= 1)
		vecman = '1 0 0';
	else if (ranman <= 2)
		vecman = '0 1 0';
	else if (ranman <= 3)
		vecman = '1 1 0';
	else if (ranman <= 4)
		vecman = '-1 0 0';
	else if (ranman <= 5)
		vecman = '0 -1 0';
	else if (ranman <= 6)
		vecman = '-1 -1 0';
	else if (ranman <= 7)
		vecman = '1 -1 0';
	else if (ranman > 7)
		vecman = '-1 1 0';

	self.velocity = self.velocity + (vecman * torn_speed);
};
