/*  $Id: tornado.qc,v 1.1 2003/10/02 04:14:42 slotzero Exp $

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

void() tornado_touch =
{
	// try to gib whatever touched the tornado center
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
W_Tornado =
{
	local entity tornado;

	// create a tornado object
	tornado			= spawn();
	tornado.classname	= "tornado";

	tornado.owner		= self;
	tornado.solid		= SOLID_TRIGGER;
	tornado.movetype	= MOVETYPE_TOSS;

	// set it's placement and velocity

	setorigin (tornado, self.origin + self.view_ofs);

	tornado.velocity	= self.velocity * 0.5;

	setmodel(tornado, "progs/w_spike.mdl");

	// XXX get accurate sizing
	setsize(tornado, '0 0 0', '32 32 32');

	tornado.angles		= '90 0 0';
	tornado.runevar		= 1;
	tornado.think		= tornado_explode;
	tornado.nextthink	= time + 2;

	sound (self, CHAN_BODY, "doors/meduse.wav", 1, ATTN_NORM);

	// Throw away from you
	makevectors (self.angles);
	tornado.velocity = (v_forward * (200 + random() * 100)) + (v_up * (200 + random() * 100));
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
