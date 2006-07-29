/*  $Id: bomb.qc,v 1.14 2006/07/29 23:25:57 slotzero Exp $

    Copyright (C) 1998-2001  Roderick Schertler.

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

// The idea for this weapon comes from W. Harris' DM Plus mod.  I looked
// at his source code to get the specific sounds and damages and such
// that he used, but since I couldn't find the copyright for the code I
// implemented it from scratch.

void ()
W_Bomb =
{
	local entity e;

	makevectors (self.v_angle);

	e = spawn ();
	e.classname = "bomb";
	e.owner = self;
	e.solid = SOLID_BBOX;
	e.movetype = MOVETYPE_FLYMISSILE;
	e.velocity = v_forward * 1000;
	e.angles = vectoangles (e.velocity);
	e.touch = bomb_arm;
	e.enemy = world;

	setmodel (e, "progs/missile.mdl");
	setsize (e, VEC_ORIGIN, VEC_ORIGIN);
	setorigin (e, self.origin + v_forward*8 + PLAYER_WEAPON_OFFSET);

	sound (self, CHAN_WEAPON, "weapons/rocket1i.wav", 1, ATTN_NORM);

	e.think = SUB_Remove;
	e.nextthink = time + 60;
};

void ()
bomb_arm =
{
	self.touch = SUB_Null;

	if (pointcontents (self.origin) == CONTENT_SKY)
	{
		remove (self);
		return;
	}

	// If it stricks a person or monster, do some damage plus stick
	// to it as it moves around.
	if (other.takedamage == DAMAGE_AIM)
	{
		T_Damage (other, self, self.owner, 30, "bombhit");
		self.runevar = 1;
		self.enemy = other;

		// v_angle is used to keep the bomb pointing in the
		// right direction.  It stores the difference between
		// the bomb's angles and the target's angles, then this
		// is added to the target's current angles to get the
		// bomb's current angles.

		self.v_angle	= self.angles - self.enemy.angles;

		// runevector and runetime doe a similar thing for
		// position.  I find the angles between the bomb's
		// position and the target's origin, and I save the
		// distance between the two.

		self.runevector	= self.origin - self.enemy.origin;
		self.runetime	= vlen (self.runevector);
		self.runevector	= vectoangles (self.runevector);
		self.runevector	= self.runevector - self.enemy.angles;

		if (self.runetime > 15)
			self.runetime = 15;
	}
	else
		self.runevar = 0;

	// dropdelay is tick time
	// ltime is explode time
	if (self.owner.runetype == RN_HASTE)
		self.ltime = time + 2.5;
	else if (self.owner.runetype == RN_JACK)
		self.ltime = time + 4.375;
	else
		self.ltime = time + 5;

	self.velocity	= VEC_ORIGIN;

	// XXX The bomb locks the player down in Quakeworld.  I work around it
	// here.
	IN_QW([-
		self.solid	= SOLID_NOT;
	-])

	self.think	= bomb_tick;
	self.dropdelay	= self.nextthink = time;
};

void ()
bomb_tick =
{
	local vector a;
	local float timeleft;

	if (pointcontents (self.origin) == CONTENT_SOLID)
	{
		remove (self);
		return;
	}

	if (self.runevar && (self.enemy.health <= 0
			|| self.enemy.origin == VEC_ORIGIN))
	{
		self.velocity = self.enemy.velocity;
		self.movetype = MOVETYPE_TOSS;
		self.runevar = 0;
	}

	if (self.runevar)
	{
		// XXX I'm not sure this is quite right for differences
		// in pitch.

		self.angles = self.enemy.angles + self.v_angle;

		// XXX I know this fails for differences in pitch if
		// the bomb strikes the player from behind (but it
		// works otherwise).  I spent a long time trying to
		// make this work right and this was the best I came up
		// with before getting too tired of it.

		// makevectors() uses e.v_angle-style angles rather than
		// e.angles-style.  The pitch goes the other way.
		a = self.enemy.angles + self.runevector;
		a_x = 0 - a_x;
		makevectors (a);
		setorigin (self, self.enemy.origin
					+ v_forward * self.runetime);
	}

	if (self.ltime <= time)
	{
		bomb_explode ();
		return;
	}

	if (self.dropdelay <= time)
	{
		if (self.owner.runetype != RN_CLOAK)
		{
			sound (self, CHAN_WEAPON, "doors/runetry.wav",
				1, ATTN_NORM);
		}

		timeleft = self.ltime - time;
		timeleft = (timeleft + 1) / 5;
		self.dropdelay = time + timeleft;
	}

	if (self.runevar)
		self.nextthink = time + sys_ticrate;
	else
		self.nextthink = self.dropdelay;
};

void ()
bomb_explode =
{
	if (self.runevar)
		T_Damage (self.enemy, self, self.owner, 100, "bombed");
	else
		self.enemy = world;
	T_RadiusDamage (RADIUS_150, self, self.owner, 150, self.enemy, "bomb");
	create_te_explosion (self.origin, 1);
};

//=============================================================================

void (float damage, float radius)
Gas_Cloud_Damage =
{
	local entity head;
	local float head_dmg;

	head = findradius (self.origin, radius);
	while (head)
	{
		if (head.health > 0)
		{
			if (head.classname == "player")
			{
				if (CanDamage (head, self))
					head_dmg = damage;
				else
					head_dmg = damage * 0.25;

				if (environmental (head))
					head_dmg = 0;
				else if (head == self.owner)
					head_dmg = head_dmg * 0.5;
			}
			else if (is_pet_e (head))
				head_dmg = damage * 0.5;
			else
				head_dmg = 0;

			head_dmg = ceil (head_dmg);
			if (head_dmg)
				T_Damage (head, self, self.owner, head_dmg, "gas");
		}
		head = head.chain;
	}
};

void ()
Gas_Cloud_Think =
{
	if (self.cnt > 0)
	{
		Gas_Cloud_Damage (4, 225 - self.cnt);

		self.cnt	= self.cnt - 1;
		self.nextthink	= time + 0.1;
	}
	else
		remove (self);
};

void ()
Gas_Cloud =
{
	local entity cloud;

	create_te_lavasplash (self.origin + '0 0 -50');

	cloud		= spawn ();
	cloud.movetype	= MOVETYPE_NONE;
	cloud.velocity	= VEC_ORIGIN;
	cloud.solid	= SOLID_NOT;
	cloud.cnt	= 25;
	cloud.owner	= self.owner;
	cloud.classname	= "gascloud";

	setmodel (cloud, string_null);
	setorigin (cloud, self.origin);

	cloud.nextthink	= time + 0.1;
	cloud.think	= Gas_Cloud_Think;
};
