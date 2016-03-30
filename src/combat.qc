/*
    Copyright (C) 1996, 1997  Id Software, Inc.

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

/*
============
CanDamage

Returns true if the inflictor can directly damage the target.  Used for
explosions and melee attacks.
============
*/

float (entity targ, entity inflictor)
CanDamage =
{
	// bmodels need special checking because their origin is 0,0,0
	if (targ.movetype == MOVETYPE_PUSH)
	{
		traceline (inflictor.origin, 0.5 * (targ.absmin + targ.absmax), TRUE, self);
		if (trace_fraction == 1)
			return TRUE;
		if (trace_ent == targ)
			return TRUE;
		return FALSE;
	}

	// XXX If traceline() doesn't encounter an obstacle,
	// trace_fraction is suppose to return 1; however;
	// when an entity is forced inside a platform,
	// trace_fraction always returns 1 and causes
	// all entites (within the radius) to be affected.
	//
	// Under the assumption that trace_ent should always
	// return world when no obstacle is encountered, I've
	// worked around the problem by checking trace_ent for
	// world when trace_fraction is 1.

	traceline (inflictor.origin, targ.origin, TRUE, self);
	if (trace_fraction == 1 && trace_ent == world)
		return TRUE;
	traceline (inflictor.origin, targ.origin + '15 15 0', TRUE, self);
	if (trace_fraction == 1 && trace_ent == world)
		return TRUE;
	traceline (inflictor.origin, targ.origin + '-15 -15 0', TRUE, self);
	if (trace_fraction == 1 && trace_ent == world)
		return TRUE;
	traceline (inflictor.origin, targ.origin + '-15 15 0', TRUE, self);
	if (trace_fraction == 1 && trace_ent == world)
		return TRUE;
	traceline (inflictor.origin, targ.origin + '15 -15 0', TRUE, self);
	if (trace_fraction == 1 && trace_ent == world)
		return TRUE;

	return FALSE;
};

/*
============
Killed
============
*/

void (entity targ, entity attacker, string dtype)
Killed =
{
	local entity old_self, old_other;
	local string x;

	old_self	= self;
	self		= targ;

	if (self.health < -99)
		self.health = -99;	// don't let sbar look bad if a player

	if (!self.th_die)
		objerror ("self.th_die is NULL");

	// doors, triggers, etc
	if (self.movetype == MOVETYPE_PUSH || self.movetype == MOVETYPE_NONE)
	{
		old_other	= other;
		other		= attacker;

		self.th_die ();

		other		= old_other;
		self		= old_self;

		return;
	}

	self.effects	= 0;	// quad glow &c
	self.enemy	= attacker;

	// bump the monster counter
	if (self.flags & FL_MONSTER)
	{
		killed_monsters = killed_monsters + 1;
		WriteByte (MSG_ALL, SVC_KILLEDMONSTER);
	}

	if (gamemode & MODE_ARENA)
		arena_death (targ, attacker, dtype);
	else
		ClientObituary (self, attacker, dtype);

	if (gamemode == MODE_PRACTICE)
	{
		if (attacker != targ)
		{
			if (attacker.classname == "player" && targ.classname == "player")
			{
				x = ftos (attacker.health);
				centerprint5 (targ, "\n\n\n", attacker.netname, " has ", x, " health");
				self_sprint (targ, attacker.netname);
				self_sprint (targ, " has ");
				self_sprint (targ, x);
				self_sprint (targ, " health\n");
			}
		}
	}

	if (!deathmatch & DM_DAMAGE_MATCH)
		high_track_recalc ();

	self.takedamage	= DAMAGE_NO;
	self.touch	= SUB_Null;
	self.effects	= 0;

	monster_death_use ();
	self.th_die ();

	self		= old_self;
};

/*
============
T_Damage

The damage is coming from inflictor, but get mad at attacker
This should be the only function that ever reduces health.

This fucntion returns a boolean which indicates whether any armor or
health was taken.
============
*/
float (entity targ, entity inflictor, entity attacker, float damage, string dtype)
T_Damage =
{
	local entity old_self;
	local vector dir;
	local float save, take, real_take;

	// MODE_MIDAIR
	local float player_height, safe_height;

	if (!targ.takedamage)
		return 0;

	// used by buttons and triggers to set activator for target firing
	damage_attacker = attacker;

	// check for quad damage powerup on the attacker or it's owner (for pets)
	if (attacker.super_damage_finished >= time || attacker.owner.super_damage_finished >= time)
		damage = damage * 4;

	if (attacker.runetype)
	{
		// impact and lumberjack rune do more
		if (attacker.runetype == RN_IMPACT || attacker.runetype == RN_LUMBER)
			damage = damage * 1.1;

		// Rune of Strength deals twice damage.
		else if (attacker.runetype == RN_STRENGTH)
			damage = damage * 2;

		// Berserker rune
		else if (attacker.runetype == RN_BERSERK)
			damage = damage * 6;

		// Shambler Helper stuff
		else if (attacker.runetype == RN_SHAMB && targ == attacker.runent)
			damage = 0;

		else if (attacker.runetype == RN_JACK)
			damage = damage * RN_JACK_STRENGTH;
	}

	// Environmental Protections
	if (environmental (targ))
	{
		if (((attacker.solid == SOLID_BSP && attacker != world) ||
				attacker.classname == "trap_shooter" ||
				attacker.classname == "fireball" ||
				inflictor.classname == "deathorb" ||
				inflictor.classname == "gfire" ||
				inflictor.classname == "radioactive" ||
				attacker.classname == "trap_spikeshooter" ||
				attacker.classname == "trigger_hurt" ||
				dtype == "barrel" ||
				dtype == "squish" ||
				dtype == "lavagun" ||
				dtype == "flamethrower" ||
				dtype == "kamikaze" ||
				dtype == "kamikilled" ||
				dtype == "spikeball" ||
				dtype == "dspotexplode" ||
				dtype == "ftrapexplode"))
			damage = 0;
	}

	if (targ.runetype)
	{
		if (targ.runetype == RN_ATHLETE)
			damage = damage * 0.9;

		else if (targ.runetype == RN_RESIST)
		{
			damage = damage * 0.5;
			sound (targ, CHAN_BODY, "items/protect3.wav", 1, ATTN_NORM);
		}

		else if (targ.runetype == RN_BERSERK)
			damage = damage * 3;

		else if (targ.runetype == RN_ZAP)
		{
			if (dtype == "zapped" || dtype == "lightning")
			{
				damage = damage * 0.5;

				old_self = self;
				self = targ;
				if (self.ammo_cells < MAX_CELLS)
				{
					self.ammo_cells = self.ammo_cells + 1;
					set_current_ammo ();
				}
				self = old_self;
			}
		}

		else if (targ.runetype == RN_CLOAK)
			targ.runetime = time + RECLOAK_DELAY;

		else if (targ.runetype == RN_MONK)
		{
			if (targ.runevar)
			{
				if (attacker.runetype != RN_BERSERK
						&& dtype != "kamikaze"
						&& dtype != "bfgtouch"
						&& dtype != "bfgblast"
						&& dtype != "teledeath"
						&& dtype != "teledeath2"
						&& dtype != "lumber"
						&& damage < SURE_KILL_DAMAGE)
				{
					damage = 0;
					monk_protect (targ);
				}
			}
		}

		else if (targ.runetype == RN_TORCH && attacker.classname == "fireball")
			damage = 0;

		else if (targ.runetype == RN_JACK)
		{
			damage = damage * RN_JACK_RESIST;
			if (targ.runevar == 1 && targ.runetime < time)
			{
				targ.runetime = time + 1;
				sound (targ, CHAN_BODY, "items/protect3.wav", 1, ATTN_NORM);
				targ.runevar = targ.runevar + 1;
			}
		}
	}

	// I don't want the zombie campers to be killable at all.  If I
	// just set them to have a large amount of health, though, you
	// can switch with them to get that health.  I cap the amount of
	// damage here so they don't have to be able to absorb more than
	// this at once.  See zombie_pain().
	if (targ.classname == "zombie_camper" && damage > 90)
		damage = 90;

	damage = ceil (damage);
	if (damage == 0)
		return 0;

	// calculations based on adjusted damage
	if (attacker.runetype == RN_TORCH && dtype != "burn")
	{
		if (random () < TORCH_BURN_ATTACK_CHANCE * damage / 100)
		{
			burn_start (targ, attacker, TORCH_BURN_ATTACK_DURATION);
		}
	}

	if (gamemode == MODE_MIDAIR)
	{
		traceline (targ.origin, targ.origin - '0 0 2048', TRUE, targ);
		player_height = targ.absmin_z - trace_endpos_z;

		if (player_height < 42.5 || targ.flags & FL_ONGROUND)
			safe_height = TRUE;
		else
		{
			damage = damage * floor (1 + (player_height - 42.5) / 128);
			safe_height = FALSE;
		}
	}

	// debug
	/* if (0)
	{
		bprint_float (time);
		bprint (" ");
		bprint_float (damage);
		bprint (" ");
		sprint_entity (world, attacker);
		bprint (" ");
		sprint_entity (world, targ);
		bprint (" ");
		bprint (dtype);
		bprint ("\n");
		return;
	}
	*/

	damage_inflictor = inflictor;

	// figure momentum add
	if (inflictor != world && targ.movetype == MOVETYPE_WALK
			&& (targ.runetype != RN_MONK || targ == attacker))
	{
		dir = targ.origin - (inflictor.absmin + inflictor.absmax) * 0.5;
		dir = normalize (dir);

		if (attacker.runetype == RN_IMPACT)
			targ.velocity = targ.velocity + dir * damage * 70;
		else
			targ.velocity = targ.velocity + dir * damage * 8;

		if (gamemode == MODE_MIDAIR)
		{
			if (safe_height)
				targ.velocity_z = targ.velocity_z + dir_z * damage * 12;
		}

		IN_QW([-
			// Rocket Jump modifiers
			if (rj > 1 && targ == attacker)
				targ.velocity = targ.velocity + dir * damage * rj;
		-])
	}

	if (damage < SURE_KILL_DAMAGE)
	{
		// Activate self preservation after the momentum change so
		// rocket jumping works.
		if (targ.runetype == RN_SELFPRES && attacker == targ)
			damage = 0;

		// Allow momentum change without damage when player is waiting for opponent.
		if (gamemode)
		{
			if (gamemode == MODE_MATCH)
			{
				if (match.state <= 0)
					damage = 0;
			}
			else if (gamemode & MODE_ARENA)
			{
				if (arena.state == -2)
					damage = 0;
				else if (gamemode == MODE_MIDAIR)
				{
					if (safe_height && dtype != "axe")
						damage = 0;
				}
			}
			else if (gamemode == MODE_PRACTICE)
			{
				if (damage && attacker != targ)
				{
					if (attacker.classname == "player" && targ.classname == "player")
					{
						local string x;

						x = ftos (damage);
						centerprint4 (attacker, targ.netname, ": ", x, "\n\n\n\n");
					}
				}
			}
		}
	}

	// save damage based on the target's armor level
	save = 0;

	if (teamplay & TEAM_ARMOR_PROT
			&& targ.team > 0
			&& targ.team == attacker.team
			&& targ != attacker)
		SUB_Null ();
	else if (teamplay & TEAM_SELF_ARMOR_PROT && targ == attacker)
		SUB_Null ();
	else if (targ.armorvalue == 0)
		SUB_Null ();
	else if (attacker.runetype == RN_PIERCING)
		sound (targ, CHAN_AUTO, "weapons/ric1.wav", 1, ATTN_NORM);
	else
	{
		save = ceil (targ.armortype * damage);
		if (attacker.runetype == RN_JACK)
		{
			save = ceil (save * RN_JACK_PIERCING);
			if (attacker.runevar == 3)
			{
				sound (targ, CHAN_AUTO, "weapons/ric1.wav",
					1, ATTN_NORM);
				attacker.runevar = attacker.runevar + 1;
			}
		}
		if (save >= targ.armorvalue)
		{
			// lost all armor
			save = targ.armorvalue;
			targ.armortype = 0;
			targ.items = targ.items
				- (targ.items & (IT_ARMOR1 | IT_ARMOR2
							| IT_ARMOR3));
		}

		// When calculating armor damage, make sure there is at least
		// 1 health point taken away.
		if (damage > 0 && damage - save == 0)
		{
			if (damage == 1)
				damage = 2;
			else
				save = save - 1;
		}

		targ.armorvalue = targ.armorvalue - save;
		if (targ.runetype == RN_ARMOR)
			good_armor_set_armor_items_e (targ);
	}
	take = damage - save;

	// god mode
	if (targ.flags & FL_GODMODE)
		take = 0;

	// invincibility
	else if (targ.invincible_finished >= time || (targ.owner.invincible_finished >= time && !targ.trigger_field.runevar))
	{
		if (targ.invincible_sound < time)
		{
			sound (targ, CHAN_AUTO, "items/protect3.wav", 1, ATTN_NORM);
			targ.invincible_sound = time + 2;
		}
		take = 0;
	}

	else if (teamplay & TEAM_HEALTH_PROT
			&& targ.team > 0
			&& targ.team == attacker.team
			&& targ != attacker)
		take = 0;
	else if (teamplay & TEAM_SELF_HEALTH_PROT && targ == attacker)
		take = 0;

	if (take > targ.health)
		real_take = targ.health;
	else
		real_take = take;

	// damage match
	if (deathmatch & DM_DAMAGE_MATCH
			&& targ.takedamage == DAMAGE_AIM
			&& dtype != "kamiself"
			&& dtype != "teamchange"
			&& dtype != "admin-kill")
		see_damage (attacker, targ, save + real_take);

	// Vampiric Rune gives back, but only the actual health taken
	// (not armor, and none for invincible players or teammates in
	// protected mode).  XXX The server crashes when two vampires
	// telefrag each other.  I guess this is because they both
	// try to respawn in the same spot?  I've also got reports that
	// this happens to targs with rune types other than vamp so I
	// just prevent healing on teledeath entirely.
	if (attacker.runetype == RN_VAMP && dtype != "teledeath")
		Vamp_Heal (attacker, targ, real_take);

	// Vengeance Rune does equal damage back to the attacker, but
	// cap damage so it doesn't exceed targ's armor/health unless
	// it is excessive.  (KILL_DAMAGE)
	if (targ.runetype == RN_VENG
			&& attacker != targ
			&& attacker != world
			&& attacker.runetype != RN_VENG
			&& attacker.runetype != RN_SELFPRES)
		if (damage < KILL_DAMAGE)
			T_Damage (attacker, targ, targ, real_take + save, "vengeance");
		else
			T_Damage (attacker, targ, targ, SURE_KILL_DAMAGE, "vengeance");

	// add to the damage total for clients, which will be sent as a
	// single message at the end of the frame
	// FIXME: remove after combining shotgun blasts?
	//
	// This is what controls the red pain flash and view jerk, but
	// not the velocity change.  I don't want to trigger these two
	// unless you're really going to be hurt (either health or
	// armor, important in some team modes), so I've moved this to
	// after the actual calculation of whether you're actually
	// going to take damage.  In that case take and save are both
	// 0, so no red flash.
	if (targ.flags & FL_CLIENT)
	{
		targ.dmg_take = targ.dmg_take + take;
		targ.dmg_save = targ.dmg_save + save;
		targ.dmg_inflictor = inflictor;

		// Put it on riders, too, so they get the flash and
		// jerk.
		if (targ.aqstate & AQS_HAS_RIDERS)
		{
			local entity e;

			e = find (world, classname, "player");
			while (e)
			{
				if (ridee_e (e) == targ)
				{
					e.dmg_take = targ.dmg_take;
					e.dmg_save = targ.dmg_save;
					e.dmg_inflictor = inflictor;
				}
				e = find (e, classname, "player");
			}
		}
	}

	if (take == 0)
		return save > 0;

	// Do not allow targets with a NULL .th_die field to die, or the
	// server will crash!
	if (!targ.th_die)
		targ.health = take + 1;

	// do the damage
	targ.health = targ.health - take;

	// useful for determining player pain and death sounds
	if (targ.classname == "player")
		targ.damage_type = dtype;

	if (targ.health <= 0)
	{
		//RUNE SERV: Shambler teleports to owner if takes enough health.
		if (targ.classname == "shambler_slave")
		{
			shambler_slave_respawn (targ, 1);
			return 2; // hack, indicates killed
		}

		if (targ.classname == "zombie_camper"
				&& targ.owner.runevar == RN_ZOMBIE
				&& targ.owner.runetime <= targ.runetime
				&& targ.owner.runevar > 0)
			targ.owner.runevar = targ.owner.runevar - 1;

		if (targ.classname == "player")
			stuffcmd (targ, CSHIFT_NONE);

		if (targ.runetype != 0)
		{
			//RUNE SERV: Radioactive types irradiate when killed
			if (targ.runetype == RN_RADIO)
			{
				local entity stemp;
				stemp = self; self = targ;
				Rune_Radio ();
				self = stemp;
			}

			//RUNE SERV: Weird bubbles when killed
			else if (targ.runetype == RN_WEIRD)
			{
				old_self = self;
				self = targ;
				self.runevar = 0;
				while (self.runevar < 7)
				{
					self.runevar = self.runevar + 1;
					Spawn_Weird ();
					self.runent.nextthink = self.runent.nextthink + 5;
				}
				self = old_self;
			}

			else if (targ.runetype == RN_SHAMB)
			{
				shambler_slave_retribution (targ.runent,
								attacker);
			}

			if (!options & NO_DROP_ON_DEATH

				// I disabled the bomb just because of
				// the exploding aspect.  There's a good
				// chance it would do bad things to
				// gameplay as well, but I always had it
				// disabled so I don't know empirically.
					&& targ.runetype != RN_BOMB

				// You can't drop this else the phoenix
				// runes multiply (since she spawns with
				// it in addition to dropping it).
					&& targ.runetype != RN_PHOENIX

				// People tend to kill themselves with
				// death spots, if they then drop it you
				// get huge concentrations of death
				// spots.
					&& targ.runetype != RN_DSPOTS)

				Rune_Spawn (targ.origin, 0, 0, 0, targ.runetype, targ, attacker);
		}

		Killed (targ, attacker, dtype);
		return 1;
	}

	//
	// REACT TO THE DAMAGE
	//

	old_self = self;
	self = targ;

	// monsters: get mad unless of the same class (except for soldiers)
	if ((self.flags & FL_MONSTER) && attacker != world)
	{
		if (ai_valid_enemy (attacker) && attacker != self.enemy)
		{
			if ((self.classname != attacker.classname)
			|| (self.classname == "monster_army"))
			{
				if (self.enemy.classname == "player")
					self.oldenemy = self.enemy;
				self.enemy = attacker;
				FoundTarget ();
			}
		}
	}

	// all: show pain and play pain sound
	if (self.th_pain)
		self.th_pain (attacker, take);

	self = old_self;
	return 1;
};

/*
============
T_RadiusDamage
============
*/
void (float attn, entity inflictor, entity attacker, float damage, entity ignore, string dtype)
T_RadiusDamage =
{
	local	float 	dist, save, points;
	local	entity	head;
	local	vector	org;

	if (attn == RADIUS_150)
		dist = 10000;
	else
		dist = damage+40;
	head = findradius (inflictor.origin, dist);

	while (head)
	{
		if (head != ignore)
		{
			if (head.takedamage)
			{
				org = head.origin + (head.mins + head.maxs)*0.5;
				dist = vlen (inflictor.origin - org);
				points = damage;
				save = 0;
				// Full strength up to 150 units, then
				// dropping off linearly.
				if (attn == RADIUS_150)
				{
					if (dist > 150)
						points = damage * 150 / dist;
				}
				// Save a half point for each unit of
				// distance.
				else
					save = 0.5 * dist;
				if (save < 0)
					save = 0;
				points = points - save;
				if (0)
				{
					bprint ("dist ");
					bprint_float (dist);
					bprint (" save ");
					bprint_float (save);
					bprint (" points ");
					bprint_float (points);
					bprint ("\n");
				}
				if (head == attacker && monk_radius_hack)
					points = points * 0.5;
				if (head.runetype == RN_MONK
						&& head != attacker
						&& attacker.runetype != RN_BERSERK
						&& monk_radius_hack)
				{
					points = 0;
					monk_protect (head);
				}
				else if (head.runetype == RN_TORCH
						&& dtype == "ftrapexplode")
					points = 0;
				else if (discharge_hack
					&& ((options & NO_DISCHARGE
							&& head != attacker)
						|| head.waterlevel == 0))
					points = 0;
				if (points > 0)
				{
					if (CanDamage (head, inflictor))
					{	// shambler takes half damage from all explosions
						if (head.classname == "monster_shambler")
							T_Damage (head, inflictor, attacker, points*0.5, dtype);
						else
						{
							T_Damage (head, inflictor, attacker, points, dtype);

							// rocket efficiency
							if (dtype == "missile")
							{
								if (inflictor.owner.classname == "player" && head.classname == "player" && inflictor.owner != head)
									inflictor.owner.rocket_dmg = inflictor.owner.rocket_dmg + points;
							}
						}
					}
				}
			}
		}
		head = head.chain;
	}
};
