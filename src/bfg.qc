/*
    Copyright (C) 1998  Jared 'KnyteHawkk' Larsen.

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

void (entity targ)
BFG_Lightning =
{
	local vector org;

	org = self.origin + PLAYER_WEAPON_OFFSET;
	traceline (org, targ.origin, 1, self);
	create_te_lightning (TE_LIGHTNING2, self, org, trace_endpos);
	T_Damage (targ, self, self.owner, BFG_ZAP_DAMAGE, "bfgzap");
};

void ()
BFG_Zap =
{
	local entity head;
	local float i;

	if (self.lip < time)
	{
		BecomeExplosion ();
		return;
	}

	i = 1;
	if (self.owner.runetype == RN_ZAP)
		i = 5;
 	else if (self.owner.runetype == RN_THOR)
		i = 2.5;

	// Find everything within range
	head = findradius (self.origin, BFG_ZAP_RANGE * i);

	// Search the list for stuff that takes damage
	while (head)
	{
		if (head.takedamage == DAMAGE_AIM
				&& head != self.owner
				&& head.last_bfg_zap + 0.5 < time)
		{
			if (!isfriend2 (head, self.owner))
			{
				if (CanDamage (head, self))
				{
					head.last_bfg_zap = time;
					BFG_Lightning (head);
				}
			}
		}
		head = head.chain;
	}
	self.nextthink = time + BFG_ZAP_TIME;
};

void ()
BFG_Touch =
{
	if (other == self.owner)
		return;		// don't explode on owner

	if (pointcontents (self.origin) == CONTENT_SKY)
	{
		remove (self);
		return;
	}

	T_Damage (other, self, self.owner, BFG_TOUCH_DAMAGE, "bfgtouch");

	// don't do radius damage to the other, because all the damage
	// was done in the impact
	T_RadiusDamage (RADIUS_NORMAL, self, self.owner, BFG_RADIUS_DAMAGE, other, "bfgblast");

	self.origin = self.origin - 8*normalize (self.velocity);

	create_te_explosion (self.origin, 1);
};

void ()
BFG_Warmup =
{
	local float number;

	// Abort if she died or lost her lightning gun.
	if (self.owner.health <= 0 || !self.owner.items & IT_LIGHTNING || intermission_running)
	{
		self.owner.effects = self.owner.effects
			- (self.owner.effects & EF_BRIGHTLIGHT);
		remove (self);
		return;
	}

	// Always reposition the lava ball.
	self.nextthink = time + sys_ticrate;
	makevectors (self.owner.v_angle);
	setorigin (self, self.owner.origin + PLAYER_WEAPON_OFFSET + 32 * v_forward - 12 * v_up);
	trackvel (self.owner);

	// Return unless another tick passed.
	if (time < self.ltime + 0.75 * self.count)
		return;

	// Make the sound and return unless this is the last tick.
	self.count = self.count + 1;
	if (self.owner.runetype == RN_HASTE)
		number = 2;
	else if (self.owner.runetype == RN_JACK)
		number = 3;
	else
		number = 4;
	if (self.count < number)
	{
		sound (self.owner, CHAN_AUTO, "weapons/lstart.wav", 1, ATTN_NORM);
		return;
	}

	bigkick_e (self.owner);
	self.owner.effects = self.owner.effects - (self.owner.effects & EF_BRIGHTLIGHT);

	self.effects = self.effects | EF_BRIGHTLIGHT;

	// Don't make launch sound while cloaked.
	if (self.owner.runetype != RN_CLOAK)
		sound (self, CHAN_WEAPON, "weapons/sgun1.wav", 1, ATTN_NORM);

	self.movetype = MOVETYPE_FLYMISSILE;
	if (self.owner.runetype == RN_HASTE)
		self.velocity = v_forward * 800;
	else if (self.owner.runetype == RN_JACK)
		self.velocity = v_forward * 500;
	else
		self.velocity = v_forward * 400;
	self.touch = BFG_Touch;
	self.lip = time + 15;
	self.nextthink = time + sys_ticrate;
	self.think = BFG_Zap;
};

void ()
W_BFG =
{
	local entity missile;

	self.effects = self.effects | EF_BRIGHTLIGHT;

	missile			= spawn ();
	missile.owner		= self;
	missile.movetype	= MOVETYPE_NONE;
	missile.solid		= SOLID_BBOX;
	missile.classname	= "bfg";
	missile.count		= 0;
	missile.ltime		= time;	// start time

	setmodel (missile, "progs/lavaball.mdl");
	setsize (missile, VEC_ORIGIN, VEC_ORIGIN);

	missile.nextthink	= time;
	missile.think		= BFG_Warmup;

	if (self.runetype == RN_THOR)
		self.runetime = time + 15;
};
