// $Id: bfg.qc,v 1.2 2002/06/08 05:42:32 slotzero Exp $
//
// Copyright (c) 2001, 2002 Rune Quake Development Team.  All rights reserved.
// See the file `Copying' in the distribution for terms.

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

	if (self.lip < time)
	{
		BecomeExplosion ();
		return;
	}

	// Find everything within range
	head = findradius (self.origin, BFG_ZAP_RANGE);

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
	if (self.owner.health <= 0 || !self.owner.items & IT_LIGHTNING)
	{
		self.owner.effects = self.owner.effects
			- (self.owner.effects & EF_BRIGHTLIGHT);
		remove (self);
		return;
	}

	// Always reposition the lava ball.
	self.nextthink = time + sys_ticrate;
	makevectors (self.owner.v_angle);
	setorigin (self, self.owner.origin
				+ PLAYER_WEAPON_OFFSET
				+ 32 * v_forward
				- 12 * v_up);
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

	// I think this is voodoo.
	//number = 1;
	//while (number < 7)
	//{
	//	  self.owner.weaponframe = self.owner.weapon { xxx .weapon? } + number;
	//	  number = number + 1;
	//}

	bigkick_e (self.owner, -10);
	self.owner.effects = self.owner.effects
		- (self.owner.effects & EF_BRIGHTLIGHT);

	self.effects = self.effects | EF_BRIGHTLIGHT;

	// Don't make launch sound while cloaked.
	if (self.owner.runetype != RN_CLOAK)
		sound (self, CHAN_WEAPON, "weapons/sgun1.wav", 1, ATTN_NORM);

	self.movetype = MOVETYPE_FLYMISSILE;
	self.velocity = aim (self.owner, 500);
	if (self.owner.runetype == RN_HASTE)
		self.velocity = self.velocity * 800;
	else if (self.owner.runetype == RN_JACK)
		self.velocity = self.velocity * 500;
	else
		self.velocity = self.velocity * 400;
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

	missile = spawn ();
	missile.owner = self;
	missile.movetype = MOVETYPE_NONE;
	missile.solid = SOLID_BBOX;
	missile.classname = "bfg";
	missile.count = 0;
	missile.ltime = time;	// start time

	setmodel (missile, "progs/lavaball.mdl");
	setsize (missile, VEC_ORIGIN, VEC_ORIGIN);

	missile.nextthink = time;
	missile.think = BFG_Warmup;
};
