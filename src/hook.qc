/*  $Id: hook.qc,v 1.5 2002/10/14 18:57:06 slotzero Exp $

    Copyright (C) 1998, 1988  Jared 'KnyteHawkk' Larsen.

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

float (entity e)
have_hook_e =
{
	return e.runetype == RN_HOOK
			|| e.aqflags & AQ_HOOK
			|| temp1 & T1_HOOK_MASK == T1_FREE_HOOK;
};

float ()
have_hook =
{
	return have_hook_e (self);
};

float (entity e)
hook_damage_e =
{
	if (e.runetype == RN_HOOK)	return HOOK_DAMAGE_RUNE;
	else if (e.aqflags & AQ_HOOK)	return HOOK_DAMAGE_LITHIUM;
	else if (temp1 & T1_HOOK_MASK == T1_FREE_HOOK)
					return HOOK_DAMAGE_FREE;
	else				return 0;
};

// Remove the hook from the wall and detach the player

void ()
DropHook =
{
	local entity linkptr, nextptr;

	// remove all hook flags
	self.owner.aqstate = self.owner.aqstate
		- (self.owner.aqstate & AQS_HOOK);

	// removes chain
	linkptr = self.goalentity;
	while (linkptr)
	{
		nextptr = linkptr.goalentity;
		remove (linkptr);
		linkptr = nextptr;
	}

	// removes hook
	remove (self);
};

// If the player dies or teleports or the like, drop the hook and return
// true.

float ()
MaybeDropHook =
{
	local float dropit;

	dropit = 0;

	// player died
	if (self.owner.health <= 0)
		dropit = 1;

	// target died
	else if (self.enemy != world && self.enemy.solid == SOLID_NOT)
		dropit = 1;

	// player lost hook (via switch or change in server settings)
	else if (!have_hook_e (self.owner))
		dropit = 1;

	// player picked up ep suit/rune
	else if (environmental (self.enemy))
		dropit = 1;

	if (dropit)
		DropHook ();
	return dropit;
};

// Pull the player to the wall

void ()
HookPull =
{
	local vector vel, spray;
	local float v;

	if (self.owner.runetype == RN_CLOAK)
		self.owner.runetime = time + RECLOAK_DELAY;

	if (MaybeDropHook ())
		return;

	// Damage the target if possible
	if (self.enemy.takedamage)
	{
		local float d;

		d = hook_damage_e (self.owner);
		if (d)
			T_Damage (self.enemy, self, self.owner, d, "hook");
	}

	// Spray blood if you hit an enemy
	if (self.enemy.solid == SOLID_SLIDEBOX)
	{
		sound (self, CHAN_WEAPON, "blob/land1.wav", 1, ATTN_NORM);
		spray_x = 100 * crandom ();
		spray_y = 100 * crandom ();
		spray_z = 100 * crandom () + 50;
		SpawnBlood (self.origin, spray, IN_POQ(20, 1));
		setorigin (self, self.enemy.origin + self.enemy.mins
				+ self.enemy.size * 0.5);
	}

	// keep the hook tracking whatever it stuck to
	self.velocity = self.enemy.velocity;

	// Set the owner's velocity.  If the she is less than 100 units from
	// the hook, set the speed at 7 * the distance, else set it to 700.
	// She slows down as she approaches the hook.
	vel = self.origin - (self.owner.origin + PLAYER_WEAPON_OFFSET);
	v = vlen (vel);
	if (v <= 100)
		vel = normalize (vel) * v * 7;
	else
		vel = normalize (vel) * 700;
	self.owner.velocity = vel;
	self.nextthink = time + sys_ticrate;
};

// Updated calculation of link positions

void ()
LinkPos =
{
	setorigin (self, self.owner.origin
			+ (self.enemy.origin + PLAYER_WEAPON_OFFSET - self.owner.origin)
			* self.weapon);
	self.angles = vectoangles (self.owner.origin - self.enemy.origin);
	self.nextthink = time + 0.01;
};

// Creates chain

entity (entity head, entity tail, float num)
CreateChain =
{
	local entity link, prevlink;
	local float linknum;

	linknum = num;
	num = num + 1;
	prevlink = world;
	while (linknum > 0)
	{
		link = spawn ();
		link.goalentity = prevlink;
		prevlink = link;
		link.owner = head;
		link.enemy = tail;
		link.weapon = linknum / num;
		link.movetype = MOVETYPE_NOCLIP;
		link.solid = SOLID_NOT;
		setmodel (link, "progs/s_spike.mdl");
		setsize (link, VEC_ORIGIN, VEC_ORIGIN);
		link.think = LinkPos;
		link.nextthink = time;
		linknum = linknum - 1;
	}
	return link;
};

// Hook's touch function

void ()
HookTouch =
{
	local float d;

	d = hook_damage_e (self.owner);

	IN_QW([-
		if (other.aqflags & AQ_OBSERVER)
			return;
	-])

	if (isfriend2 (self.owner, other)
			|| (!d && other.takedamage == DAMAGE_AIM)
			|| other.items & IT_SUIT
			|| other.runetype == RN_ENVIRO)
	{
		sound (self, CHAN_AUTO, "weapons/bounce.wav", 1, ATTN_NORM);
		DropHook ();
		return;
	}

	if (other.solid == SOLID_SLIDEBOX)
	{
		sound (self, CHAN_AUTO, "shambler/smack.wav", 1, ATTN_NORM);
		SpawnBlood (self.origin, self.velocity, IN_POQ(10, 1));
		setorigin (self, other.origin + other.mins + other.size * 0.5);
	}
	else
	{
		sound (self, CHAN_AUTO, "player/axhit2.wav", 1, ATTN_NORM);
		self.avelocity = VEC_ORIGIN;
	}

	if (other.takedamage)
	{
		// It's a secret, not a creature, so allow hooking it
		// regardless.
		if (!d)
			d = 1;
		T_Damage (other, self, self.owner, d, "hook");
	}

	self.velocity = other.velocity;
	self.enemy = other;
	self.nextthink = time + sys_ticrate;
	self.think = HookPull;
	self.touch = SUB_Null;
};

// Limit hook length during launch

void ()
LaunchHook =
{
	local vector chainvec;		// chain vector
	local float chainlength;	// length of extended chain

	if (self.owner.runetype == RN_CLOAK)
		self.owner.runetime = time + RECLOAK_DELAY;

	if (MaybeDropHook ())
		return;

	chainvec = self.origin - (self.owner.origin + PLAYER_WEAPON_OFFSET);
	chainlength = vlen (chainvec);
	if (chainlength > HOOK_MAX_CHAIN_LEN)
	{
		DropHook ();
		return;
	}
	self.nextthink = time + sys_ticrate;
};

// Initiate the hook

void ()
HookOn =
{
	local entity newhook;

	if (self.aqstate & AQS_HOOK)
		HookOff ();

	spawn_protect_off ();
	if (self.runetype == RN_CLOAK)
		self.runetime = time + RECLOAK_DELAY;

	self.aqstate = self.aqstate | AQS_HOOK;
	newhook = spawn ();
	newhook.classname = "hook-head";
	newhook.owner = self;
	newhook.movetype = MOVETYPE_FLY;
	newhook.solid = SOLID_BBOX;
	setmodel (newhook, "progs/v_spike.mdl");
	setsize (newhook, VEC_ORIGIN, VEC_ORIGIN);
	makevectors (self.v_angle);
	setorigin (newhook, self.origin + (v_forward*16) + PLAYER_WEAPON_OFFSET);
	newhook.velocity = v_forward * HOOK_TRAVEL_SPEED;
	newhook.angles = vectoangles (newhook.velocity);
	newhook.avelocity = '0 0 600';
	sound (self, CHAN_AUTO, "weapons/ax1.wav", 1, ATTN_NORM);
	newhook.goalentity = CreateChain (newhook, self, HOOK_LINK_COUNT);

	newhook.touch = HookTouch;
	newhook.nextthink = time + sys_ticrate ;
	newhook.think = LaunchHook;
};

// This used to just turn off her AQS_HOOK, and the other functions would
// check for that and drop the hook.  If the user shot out multiple hooks,
// though, that would have them all flying through the air.  If you kept
// the hook on, both would strike and pull you!

void (entity e)
HookOff_e =
{
	local entity this_e, old_self;

	this_e = find (world, classname, "hook-head");
	while (this_e)
	{
		if (this_e.owner == e)
		{
			old_self = self;
			self = this_e;
			DropHook ();
			self = old_self;
			return;
		}
		this_e = find (this_e, classname, "hook-head");
	}
};

void ()
HookOff =
{
	return HookOff_e (self);
};

// Drop any non-rune hooks which are attached to self.

void (entity e)
HookOff_by_targ_e =
{
	local entity this_e, old_self;

	this_e = find (world, classname, "hook-head");
	while (this_e)
	{
		if (this_e.enemy == e && this_e.owner.runetype != RN_HOOK)
		{
			old_self = self;
			self = this_e;
			DropHook ();
			self = old_self;
		}
		this_e = find (this_e, classname, "hook-head");
	}
};

void ()
HookOff_by_targ =
{
	return HookOff_by_targ_e (self);
};

void ()
HookToggle =
{
	if (self.aqstate & AQS_HOOK)
		HookOff ();
	else
		HookOn ();
};
