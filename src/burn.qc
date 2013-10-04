/*
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

// There's at most one burn thinker per player.  If a player has one
// her AQS_BURNING bit is set.  Turning this bit off (or a few other
// conditions) will stop her burning.
//
// The burn thinker uses runevar to store the time at which to stop
// burning, lip to store the time at which to damage the player again,
// and enemy to store the target.  New burnings add to the runevar of
// the existing thinker.  The more time left to burn, the more damage
// done per unit time.

void ()
weapon_bubble =
{
	local entity e;

	if (random () < 0.5)
	{
		sound (self, CHAN_WEAPON, "misc/water1.wav", 1, ATTN_NORM);
		return;
	}
	sound (self, CHAN_WEAPON, "misc/water2.wav", 1, ATTN_NORM);

	// Prevent bubble spam.
	if (self.bubble_count > time)
		return;

	self.bubble_count = time + 0.5;

	e = spawn ();
	setmodel (e, "progs/s_bubble.spr");
	makevectors (self.v_angle);
	setorigin (e, self.origin + PLAYER_WEAPON_OFFSET + v_forward*64);
	// XXX These should not go through things, but I can't get that to
	// work with MOVETYPE_FLY and SOLID_TRIGGER, eg.
	e.movetype = MOVETYPE_NOCLIP;
	e.solid = SOLID_NOT;
	e.velocity = '0 0 15';
	e.nextthink = time + 0.5;
	e.think = bubble_bob;
	e.classname = "bubble";
	e.frame = 0;
	e.cnt = 15; // don't split, and die quicker
	e.effects = EF_MAYBE_DRAW;
	setsize (e, '-8 -8 -8', '8 8 8');
};

void (float num_bubbles, vector o)
bubbles =
{
	local entity e;

	// Prevent massive bubble spam.
	if (self.owner.classname == "player")
	{
		if (self.owner.bubble_count > time)
			return;

  		self.owner.bubble_count = time + 1;
	}

	e = spawn ();
	// Normally the owner is the player, but these shouldn't move and
	// they should come even if the player leaves water.
	e.owner = e;
	setorigin (e, o);
	e.waterlevel = 3;
	e.bubble_count = num_bubbles;
	e.think = DeathBubblesSpawn;
	e.nextthink = time;
};

void ()
burn_think =
{
	// Stop burning if appropriate.
	if (self.runevar < time
			|| (self.enemy.waterlevel > 1 &&
				self.enemy.watertype != CONTENT_LAVA)
			|| self.enemy.health <= 0
			|| !self.enemy.aqstate & AQS_BURNING
			|| self.enemy.runetype == RN_ENVIRO
			|| self.enemy.items & IT_SUIT
			|| self.enemy.runetype == RN_FIREWALK
			|| self.enemy.runetype == RN_TORCH
			|| intermission_running)
	{
		if (self.enemy.waterlevel > 0)
			bubbles (6, self.enemy.origin);
		self.enemy.aqstate = self.enemy.aqstate
					- self.enemy.aqstate & AQS_BURNING;
		if (self.enemy.touch == burn_player_touch)
			self.enemy.touch = SUB_Null;
		remove (self);
		return;
	}

	// Damage her if it's time.
	if (time >= self.lip)
	{
		local float timeleft, d;

		timeleft = self.runevar - time;
		if (timeleft > BURN_3_TIME)		d = BURN_3_DAMAGE;
		else if (timeleft > BURN_2_TIME)	d = BURN_2_DAMAGE;
		else					d = BURN_1_DAMAGE;

		T_Damage (self.enemy, self, self.owner, d, "burn");
		// XXX Give more indication for worse burning.
		sound (self.enemy, CHAN_WEAPON, "zombie/z_shot1.wav",
			1, ATTN_NORM);
		self.lip = time + BURN_DELAY;
	}

	// Move the flame to stay on top of her.
	makevectors (self.enemy.velocity);
	setorigin (self, self.enemy.origin + PLAYER_WEAPON_OFFSET
				+ 5 * v_forward);
	trackvel (self.enemy);

	if (self.enemy.touch == SUB_Null)
		self.enemy.touch = burn_player_touch;
	self.nextthink = time + sys_ticrate;
};

// Burning players get this as their touch function.  It can run many
// times per tick if one player is actively pushing another.  XXX Should
// I prevent that manually so the BURN_TOUCH_CHANCE can be made more
// useful?

void ()
burn_player_touch =
{
	if (other.takedamage && random () < BURN_TOUCH_CHANCE)
		burn_start (other, self, BURN_TOUCH_DURATION);
};

void (entity targ, entity attacker, float duration)
burn_start =
{
	local entity e;

	if (targ.runetype == RN_ENVIRO
			|| targ.items & IT_SUIT
			|| targ.runetype == RN_FIREWALK
			|| targ.runetype == RN_TORCH
			|| (targ.waterlevel > 1
			&& targ.watertype != CONTENT_LAVA)
			|| (targ.runetype == RN_SELFPRES && targ == attacker))
		return;

	if (teamplay & TEAM_HEALTH_PROT
			&& teamplay & TEAM_ARMOR_PROT
			&& isfriend2 (targ, attacker)
			&& targ != attacker)
		return;

	if (teamplay & TEAM_SELF_HEALTH_PROT && targ == attacker)
		return;

	e = world;

	// If there's an existing burner for this player, use it.
	if (targ.aqstate & AQS_BURNING)
	{
		e = find (world, classname, "burn");
		while (e != world && e.enemy != targ)
			e = find (e, classname, "burn");
	}

	// Else make a new one.
	if (!e)
	{
		targ.aqstate	= targ.aqstate | AQS_BURNING;
		e		= spawn ();
		e.classname	= "burn";
		e.think		= burn_think;
		e.runevar	= time;
		e.enemy		= targ;

		// Originally I updated the owner to track the last
		// player who burned you.  Of the simple solutions I
		// think this (continuing to credit the player who
		// originally set you on fire) is better.
		e.owner		= attacker;

		e.movetype	= MOVETYPE_NONE;
		e.velocity	= VEC_ORIGIN;
		e.solid		= SOLID_NOT;
		e.frame	 	= 1;

		setmodel (e, "progs/flame2.mdl");
		setorigin (e, targ.origin + PLAYER_WEAPON_OFFSET);
		setsize (e, VEC_ORIGIN, VEC_ORIGIN);

		if (targ.classname == "player")
		{
			centerprint (targ, "You are on fire!  Find water!\n");
			stuffcmd (targ, "bf\n");
		}
	}

	e.runevar	= e.runevar + duration;
	e.lip		= time;
	e.nextthink	= time;
};

void (entity inflictor, entity attacker, float damage, entity ignore,
	string dtype, float burn_chance, float burn_duration)
burn_radius =
{
	local entity e;

	// Torch does more damage with flame weapons.
	if (attacker.runetype == RN_TORCH)
		damage = damage * 2;

	e = findradius (inflictor.origin, 50);
	while (e)
	{
		if (e.takedamage && e.runetype != RN_TORCH && e != ignore)
		{
			T_Damage (e, inflictor, attacker, damage, dtype);
			if (random () < burn_chance)
				burn_start (e, attacker, burn_duration);
		}
		e = e.chain;
	}
};

// This is called on impact or after a set amount of time.

void ()
flamemissile_explode =
{
	sound (self, CHAN_WEAPON, "hknight/hit.wav", 1, ATTN_NORM);

	if (self.model != "progs/s_explod.spr")
	{
		setmodel (self, "progs/s_explod.spr");
		setsize (self, VEC_ORIGIN, VEC_ORIGIN);
	}

	self.touch	= SUB_Null;
	self.movetype	= MOVETYPE_FLY;
	self.velocity	= '0 0 75';
	self.think	= s_explode1;
	self.nextthink	= time;
};

void ()
flamemissile_touch =
{
	burn_radius (self, self.owner, self.pos1_x, world,
			self.classname,
			self.pos1_y,
			self.pos1_z);
	flamemissile_explode ();
};

void ()
flamemissile_think =
{
	local float i;

	i = pointcontents (self.origin);
	if (i == CONTENT_WATER || i == CONTENT_SLIME)
	{
		bubbles (1, self.origin);
		remove (self);
		return;
	}

	if (time > self.runevar)
		self.think = flamemissile_touch;
	self.nextthink = time + sys_ticrate;
};

void (string class, float ox)
W_FireFlameMissile =
{
	local vector org;
	local string snd;

	if (!weapon_it_have_min_ammo (self.weapon, 0))
	{
		set_weapon (W_BestWeapon ());
		return;
	}

	if (self.waterlevel > SAFE_DISCHARGE_WATERLEVEL)
	{
		weapon_bubble ();
		return;
	}

	newmis			= spawn ();
	newmis.owner		= self;
	newmis.solid		= SOLID_BBOX;
	newmis.classname	= class;
	newmis.touch		= flamemissile_touch;
	newmis.think		= flamemissile_think;
	newmis.nextthink	= time;

	makevectors (self.v_angle);

	if (class == "flamethrower")
	{
		snd		= "knight/sword2.wav";
		newmis.movetype	= MOVETYPE_FLYMISSILE;
		newmis.velocity	= v_forward * 650;
		newmis.pos1_x	= FLAMETHROWER_DAMAGE;
		newmis.pos1_y	= FLAMETHROWER_BURN_CHANCE;
		newmis.pos1_z	= FLAMETHROWER_BURN_DURATION;
		newmis.mdl	= "progs/s_explod.spr";

		if (self.runetype == RN_HASTE)
			newmis.runevar = time + 1.2;
		else if (self.runetype == RN_JACK)
			newmis.runevar = time + 0.75;
		else
			newmis.runevar = time + 0.6;

		org = self.origin + PLAYER_WEAPON_OFFSET + v_forward * 16;
	}

	else if (class == "lavagun")
	{
		snd		= "shambler/sboom.wav";
		if (self.runetype == RN_HASTE)
			newmis.movetype = MOVETYPE_FLYMISSILE;
		else
			newmis.movetype	= MOVETYPE_TOSS;
		newmis.velocity	= v_forward * 1400;
		newmis.angles	= '90 0 0' + vectoangles (v_forward);
		newmis.pos1_x	= LAVAGUN_DAMAGE;
		newmis.pos1_y	= LAVAGUN_BURN_CHANCE;
		newmis.pos1_z	= LAVAGUN_BURN_DURATION;
		newmis.mdl	= "progs/flame2.mdl";
		newmis.runevar	= time + 6;
		org = self.origin + PLAYER_WEAPON_OFFSET + v_right * ox;
	}

	else
		error ("invalid flamemissile class");

	setmodel (newmis, newmis.mdl);
	setorigin (newmis, org);
	setsize (newmis, VEC_ORIGIN, VEC_ORIGIN);
	sound (self, CHAN_WEAPON, snd, 1, ATTN_NORM);
};
