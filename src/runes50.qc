// $Id: runes50.qc,v 1.7 2002/07/20 19:04:34 slotzero Exp $
//
// Copyright (c) 2001, 2002 Rune Quake Development Team.  All rights reserved.
// See the file `Copying' in the distribution for terms.

void ()
Athlete_Jump =
{
	if (self.flags & FL_WATERJUMP
			|| self.waterlevel >= 2
			|| !self.flags & FL_ONGROUND
			|| !self.flags & FL_JUMPRELEASED)
		return;

	self.flags = self.flags - (self.flags & FL_JUMPRELEASED);
	self.flags = self.flags - FL_ONGROUND;	// don't stairwalk
	self.button2 = 0;

	// player jumping sound
	sound (self, CHAN_JUMP, "player/plyrjmp8.wav", 1, ATTN_NORM);

	self.velocity_z = self.velocity_z + 540;
};

float ()
is_zombie =
{
	return self.classname == "monster_zombie"
			|| self.classname == "zombie_camper";
};

void (float riders, entity of_e)
Rune_Zombie_sprint =
{
	rprint_numdesc (self, riders, of_e.runevar, "zombie");
	rprint (self, riders, " placed\n");
};

void ()
Rune_Zombie =
{
	local entity old_self, e, oldest;
	local float i;
	local string action;

	action = "placed";

	// If you place a zombie too close to another one it won't be
	// able to get up (the walkmove() test in zombie_paine12 will
	// fail).  So, prevent her from placing them too close together.
	i = 0;
	e = findradius (self.origin, 45);
	while (e)
	{
		if (e != self && (e.solid == SOLID_BBOX
					|| e.solid == SOLID_SLIDEBOX
					|| e.solid == SOLID_BSP))
			i = i + 1;
		e = e.chain;
	}
	if (i)
	{
		centerprint2 (self,
				"This zombie would be too close to\n",
				"something, move it over a little");
		return;
	}

	// If she's already placed all her zombies, remove the oldest
	// one before placing this one.
	while (self.runevar >= MAX_ZOMBIE_CAMPERS)
	{
		action = "moved";
		i = time;
		oldest = world;
		e = find (world, classname, "zombie_camper");
		while (e)
		{
			if (e.owner == self
					&& self.runetime <= e.runetime
					&& e.runetime < i)
			{
				oldest = e;
				i = oldest.runetime;
			}
			e = find (e, classname, "zombie_camper");
		}
		if (!oldest)
			objerror ("no oldest zombie camper");
		spawn_tfog (oldest.origin);
		remove (oldest);
		self.runevar = self.runevar - 1;
	}

	self.runevar = self.runevar + 1;
	sound (self, CHAN_WEAPON, "zombie/z_hit.wav", 1, ATTN_NORM);
	centerprint2 (self, "Zombie camper ", action);

	old_self = self;
	self = spawn ();
	self.classname = "zombie_camper";
	self.owner = old_self;
	self.origin = self.owner.origin;
	self.angles = self.owner.angles;
	self.runevar = self.angles_y;	// preferred yaw
	self.yaw_speed = 40;
	self.runetime = time;

	monster_zombie_1 (2);

	self = old_self;
};

float ()
maybe_remove_zombie_camper =
{
	if (self.owner.runetype != RN_ZOMBIE
			|| self.owner.runetime > self.runetime)
	{
		if (self.owner.health < 1)
		{
			// This will call zombie_die, which decrements
			// self.owner.runevar.
			self.health = 0;
			Killed (self, self.owner, string_null);
		}
		else
			spawn_tfog (self.origin);
		remove (self);
		return TRUE;
	}

	return FALSE;
};

void (entity e)
monk_protect =
{
	local string s;

	if (e.runevar)
	{
		if (e.runevector_y > time)
			return;
		e.runevector_y = time + 1.1;
		s = "zombie/z_pain1.wav";
	}
	else
		s = "demon/dpain1.wav";
	sound (e, CHAN_BODY, s, 1, ATTN_NORM);
};

// The monk_trance_*() functions are a vestige of when I used
// EF_BRIGHTFIELD for meditating monks.

void ()
monk_trance_on =
{
	self.runevar = 1;
};

void ()
monk_trance_off =
{
	self.runevar = 0;
};

void ()
monk_think =
{
	local float trance;

	local float i;
	i = vlen (self.velocity);
	if (0 && i && self.aqflags & AQ_ADMIN)
	{
		sprint_float_f (self, i, 4, 1);
		sprint (self, " ");
		sprint_float_f (self, time, 4, 1);
		sprint (self, "\n");
	}

	// I used to test this for a non-zero velocity, but a monk
	// sitting in water has a small downward pull (about 30).  It
	// turned out that that's there only in PreThink(), after
	// physics run it's back to 0 if you're on the floor.  So, I
	// run this from PostThink() now.
	//
	// I still test for a non-zero value here to allow a pushed monk
	// to remain in trance (but one who pushes back gets a much
	// larger velocity and leaves trance).
	if (vlen (self.velocity) > 80)
		self.runetime = time;

	trance = 1;

	if (self.attack_finished + MONK_ATTACK_DELAY >= time)
	{
		trance = 0;
		self.runevector_x = 0;
	}
	else if (!self.runevector_x)
	{
		self.runevector_x = 1;
		sound (self, CHAN_BODY, "zombie/z_pain.wav", 1, ATTN_NORM);
	}

	if (self.runetime + MONK_MOVE_DELAY >= time)
		trance = 0;

	if (!self.runevar && trance)
		monk_trance_on ();
	else if (self.runevar && !trance)
		monk_trance_off ();
};

// Allow players to slowly push monks out of the way so they can't stand
// in a doorway or the like.

void ()
monk_touch =
{
	local vector v;

	misc_touch ();

	if (0 && self.aqflags & AQ_ADMIN && other != world)
	{
		local float i;

		i = vlen (self.velocity);
		sprint (self, "touch ");
		sprint (self, " vel ");
		sprint_float_f (self, i, 4, 1);
		sprint (self, " at ");
		sprint_float_f (self, time, 4, 1);
		sprint (self, " by ");
		sprint_entity (self, other);
		sprint (self, "\n");
	}

	// Don't use 0 so this works for monks in water.
	if (vlen (self.velocity) > 50)
		return;

	if (!is_player_e (other))
		return;

	v = normalize (other.velocity);
	self.velocity = self.velocity + 20 * v;
};

// This is called every tick while the trap is moving, to check to see
// if it enters water.  After it comes to a rest this is set up to be
// called only when the trap expires.

void ()
Torch_Trap_Think =
{
	local float i;

	if (time >= self.runetime)
	{
		// XXX swap torch-for-torch bug
		if (self.owner.runetype == RN_TORCH && self.owner.runevar > 0)
		{
			if (self.owner.class_cnt)
				self.owner.class_cnt = self.owner.class_cnt - 1;
			else
			{
				sprint (self.owner, "A fire trap exploded\n");
				self.owner.runevar = self.owner.runevar - 1;
			}
		}

		monk_radius_hack = 1;
		T_RadiusDamage (RADIUS_NORMAL, self, self.owner,
				TORCH_TRAP_EXPLODE_DAMAGE,
				world, "ftrapexplode");
		monk_radius_hack = 0;

		BecomeExplosion ();
		return;
	}

	// Check that I don't pass through water while before I stop
	// moving.
	i = pointcontents (self.origin);
	if (i == CONTENT_SLIME || i == CONTENT_WATER)
	{
		bubbles (3, self.origin);
		// Wait before actually removing it so there's a choke
		// on repeatedly throwing traps into water, lagging
		// people out with clouds of bubbles.
		self.solid	= SOLID_NOT;
		self.movetype	= MOVETYPE_NONE;
		setmodel (self, string_null);
		self.think	= Torch_Trap_Remove;
		self.nextthink	= time + 5;
		return;
	}

	// Don't bother to think any more if I've come to a stop.
	if (self.velocity != VEC_ORIGIN)
		self.nextthink	= time + sys_ticrate;
	else
	{
		self.runevar	= 1;
		self.solid	= SOLID_TRIGGER;
		self.nextthink	= self.runetime;
		// Need to reset the size else you get "Error: Trigger
		// in clipping list" crashes.
		setsize (self, self.mins, self.maxs);
	}
};

void ()
Torch_Trap_Touch =
{
	if (!other.health
			|| other == world
			|| !other.takedamage
			|| other.runetype == RN_ENVIRO
			|| other.items & IT_SUIT
			|| other.runetype == RN_TORCH)

		return;

	if (isfriend2 (self.owner, other) && self.owner != other)
		return;

	sound (self, CHAN_WEAPON, "boss1/throw.wav", 1, ATTN_NORM);

	// XXX swap torch-for-torch bug
	if (self.owner.runetype == RN_TORCH && self.owner.runevar > 0)
		self.owner.runevar = self.owner.runevar - 1;

	T_Damage (other, self, self.owner, TORCH_TRAP_TOUCH_DAMAGE,
			"ftraptouch");

	// Start burning before the centerprint(), so the "You are on
	// fire!" is overwritten.
	burn_start (other, self.owner, TORCH_TRAP_BURN_DURATION);

	if (self.runevar && self.owner == other)
		centerprint (other, "You ignited yourself, you big dummy!\n");
	else if (self.runevar && other.classname == "player")
	{
		centerprint3 (other, "You've been ignited by ",
				self.owner.netname,
				// fastqcc chokes on "!"
				"! ");

		if (other.health > 0)
		{
			sprint (self.owner, other.netname);
			sprint (self.owner, " was ignited by your fire trap.\n");
		}
	}

	BecomeExplosion ();
};

void ()
Torch_Trap_Remove =
{
	if (self.owner.runetype == RN_TORCH && self.owner.runevar > 0)
	{
		if (self.owner.class_cnt)
			self.owner.class_cnt = self.owner.class_cnt - 1;
		else
			self.owner.runevar = self.owner.runevar - 1;
	}
	remove (self);
};

void (float riders, entity of_e)
Rune_Torch_sprint =
{
	rprint_numdesc (self, riders, of_e.runevar, "fire trap");
	rprint (self, riders, " placed\n");
};

void ()
Rune_Torch =
{
	local entity e;
	local string s, s1;

	if (self.runevar >= MAX_TORCH)
	{
		s = ftos (MAX_TORCH);
		if (MAX_TORCH != 1)
			s1 = "s";
		centerprint5 (self, "Only ", s, " fire trap", s1, " allowed");
		return;
	}
	self.runevar = self.runevar + 1;

	sound (self, CHAN_WEAPON, "hknight/hit.wav", 1, ATTN_NORM);

	e		= spawn ();
	e.classname	= "torchtrap";
	e.owner		= self;
	e.solid		= SOLID_BBOX;
	e.movetype	= MOVETYPE_TOSS;
	e.runetime	= time + TORCH_TRAP_DURATION;
	e.runevar	= 0;	// 1 after stopping

 	makevectors (self.v_angle);
	e.velocity	= v_forward * 1000;

	setmodel (e, "progs/flame2.mdl");
	setsize (e, '-12 -12 0', '12 12 42');
	setorigin (e, self.origin + PLAYER_VIEW_OFFSET);

	e.touch		= Torch_Trap_Touch;
	e.think		= Torch_Trap_Think;
	e.nextthink	= time;
};

void ()
Torch_Touch =
{
	misc_touch ();

	if (other.takedamage && random () < TORCH_BURN_TOUCH_CHANCE)
		burn_start (other, self, TORCH_BURN_TOUCH_DURATION);
};

// Return the number of bonus frags the pack rat gets based on how many
// runes she's holding.

float (entity e)
pack_rat_frag_bonus_e =
{
	local float f, max;

	f = 0;
	while (e.runevar >= (f+1) * PACK_RAT_BONUS_PERCENT * runemax)
		f = f + 1;

	// She can have > runemax runes for several reasons, so cap the
	// bonus.
	max = floor (1 / PACK_RAT_BONUS_PERCENT);
	if (f > max)
		f = max;

	return f;
};

void (float riders, entity of_e)
pack_rat_sprint =
{
	local float n;

	rprint (self, riders, "Packed away ");
	rprint_numdesc (self, riders, of_e.runevar, "rune");
	n = pack_rat_frag_bonus_e (of_e);
	if (deathmatch & DM_DAMAGE_MATCH)
	{
		rprint (self, riders, ", damage credit multiplier ");
		rprint_float (self, riders, n + 1);
	}
	else
	{
		rprint (self, riders, ", frag bonus ");
		rprint_float (self, riders, n);
	}
	rprint (self, riders, "\n");
};

void ()
pack_rat_rune_touch =
{
	local entity old_self;
	local string s;

	s = Rune_Description (self.runetype, 0);
	sprint3 (other, "You've picked up", s, "\n");
	old_self = self;
	self = other;
	cloaked_sound (self, CHAN_BODY, SOUND_RUNE_PICKUP, 1, ATTN_NORM);
	self.runevar = self.runevar + 1;
	pack_rat_sprint (1, self);
	self = old_self;

	self.owner		= other;
	self.enemy		= world;	// forget killer
	self.flags		= self.flags - self.flags & FL_ONGROUND;
	self.movetype		= MOVETYPE_NONE;
	self.solid		= SOLID_NOT;
	// calculates are as if player faces along positive Y axis
	self.runevector_y	= -20 - 5 * random ();
	self.runevector_x	= 15 * crandom ();
	self.runevector_z	= 20 * crandom ();

	// Link the rat's runes through runent.
	self.runent = other.runent;
	other.runent = self;

	self.touch = SUB_Null;
	self.think = pack_rat_rune_move;
	self.nextthink = time;
};

void ()
pack_rat_rune_move =
{
	if (intermission_running)
	{
		remove (self);
		return;
	}

	// This only actually gets triggered for players who leave the
	// game.  The other cases call pack_rat_rune_drop().  I do it
	// this way rather than doing a regular drop from there to mimic
	// the normal client disconnection behavior (no backpack, eg).
	if (self.owner.health < 0 || self.owner.runetype != RN_PACK_RAT)
	{
		remove (self);
		if (runecurrent > 0)
			runecurrent = runecurrent - 1;
		if (runecurrent < runemax)
			Rune_SpawnAll (1);
	}

	makevectors (self.owner.v_angle);
	setorigin (self, self.owner.origin
				+ v_forward * self.runevector_y
				+ v_right * self.runevector_x
				+ v_up * self.runevector_z);
	trackvel (self.owner);
	self.nextthink = time + sys_ticrate;
};

void (float tell)
pack_rat_rune_drop =
{
	local entity e, next_e;

	if (tell)
	{
		local string s, s2;

		if (!self.runevar)
		{
			// This can't actually happen ATM.
			centerprint (self, "You haven't salted away any runes.");
			return;
		}
		s = ftos (self.runevar);
		if (self.runevar == 1)
			s2 = string_null;
		else
			s2 = "s";
		centerprint5 (self, "You toss ", s, " rune", s2, ".");
	}

	// Drop all the runes.
	self.runevar	= 0;
	e		= self.runent;
	self.runent	= world;
	while (e)
	{
		next_e		= e.runent;
		e.runent	= self;
		e.lip		= time + 2;
		e.owner		= world;
		e.touch		= Rune_Touch;
		e.think		= Rune_Move;
		e.runetime	= time + 60 + random ()*60;
		e.nextthink	= e.runetime - 3;
		e.flags		= e.flags - e.flags & FL_ONGROUND;
		e.movetype	= MOVETYPE_TOSS;
		e.solid		= SOLID_TRIGGER;
		e.velocity_z	= 300;
		e.velocity_x	= 200 * crandom ();
		e.velocity_y	= 200 * crandom ();
		e		= next_e;
	}
};

// Quake won't display an armor value over 255, it wraps around.  So, I
// use the color to help indicate how much you have.  The armor always
// behaves like red armor (80% absorption), the color doesn't figure
// into that.

void (entity e)
good_armor_set_armor_items_e =
{
	local float bit;

	if (e.armorvalue > 767)		bit = 0;
	IN_POQ([-
		else if (e.armorvalue > 511)	bit = IT_ARMOR3;
		else if (e.armorvalue > 255)	bit = IT_ARMOR2;
		else if (e.armorvalue > 0)	bit = IT_ARMOR1;
		else				bit = 0;
	-], [-
		else if (e.armorvalue > 0)	bit = IT_ARMOR3;
	-])
	e.items = e.items
			- (e.items & (IT_ARMOR1 | IT_ARMOR2 | IT_ARMOR3))
			+ bit;
};

float (entity e, float amt)
decay_armor =
{
	local float max;

	if (amt <= 0)
		return FALSE;

	max = get_max_armor_e (e);
	if (e.armorvalue <= max)
		return FALSE;

	e.armorvalue = e.armorvalue - amt;
	if (e.armorvalue < max)
		e.armorvalue = max;
	set_armor_items_e (e);
	return TRUE;
};

// Decay E's armor down to her max at RATE points per second.

void (entity e, float rate)
decay_armor_spawn =
{
	local float max;
	local entity this;

	max = get_max_armor_e (e);
	if (e.armorvalue <= max)
		return;

	this = find (world, classname, "decay_armor");
	while (this)
	{
		if (this.owner == e)
			return;
		this = find (this, classname, "decay_armor");
	}

	this = spawn ();
	this.classname = "decay_armor";
	this.owner = e;
	this.runevar = rate;
	this.think = decay_armor_think;
	this.nextthink = time + 1;
};

void ()
decay_armor_think =
{
	if (decay_armor (self.owner, self.runevar))
		self.nextthink = time + 1;
	else
		remove (self);
};

void ()
quad_activate =
{
	if (self.super_damage_finished >= time || self.runetime > time)
	{
		if (self.runevar)
		{
			self.runevar = 0;
			centerprint (self, "Pending quad canceled");
		}
		else
		{
			self.runevar = 1;
			if (self.super_damage_finished >= time)
				centerprint (self, "Quad queued");
			else
				centerprint (self, "Quad recharging");
		}
		return;
	}

	spawn_protect_off ();
	if (RN_QUAD_DURATION > 3)
	{
		sound (self, CHAN_AUTO, "items/damage.wav", 1, ATTN_NORM);
		stuffcmd (self, "bf\n");
	}
	self.runevar	= 0;
	self.items	= self.items | IT_QUAD;
	self.effects	= self.effects | EF_DIMLIGHT;
	self.super_time	= -2;
	self.super_damage_finished = time + RN_QUAD_DURATION;
	self.runetime	= self.super_damage_finished + RN_QUAD_RECHARGE;
};

void ()
quad_think =
{
	if (self.runevar
			&& self.super_damage_finished < time
			&& self.runetime <= time)
		quad_activate ();
};

void ()
jack_think =
{
	// runevar tells what kind of sound to make next.
	//
	//   0 strength
	//   1 resistance
	//   2 haste
	//   3 piercing
	//
	// Each of these increments it when they make their sound.

	if (self.runevar > 3)
		self.runevar = 0;

	self.runevector_x = self.runevector_x + 1;

	if (rint (self.runevector_x / 10) == self.runevector_x / 10)
		Rune_Regen ();

	if (rint (self.runevector_x / 30) == self.runevector_x / 30)
		Rune_Ammo_1 (rint (self.runevector_x / 90) == self.runevector_x / 90);
};
