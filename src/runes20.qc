/*
    Copyright (C) 1996, 1997  Nick 'SiNGE' Bousman.

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

void ()
Bomb_Think =
{
	if (self.owner.runetype != RN_BOMB || intermission_running)
	{
		remove (self);
		return;
	}

	setorigin (self, self.owner.origin + '0 0 35');
	trackvel (self.owner);
	self.nextthink = time + sys_ticrate;
};

void ()
Rune_Bomb =
{
	if (self.runevar == -1 || self.runetime > time)
		return;

	if (self.runevar > 0)
	{
		sprint (self, "\{133}");
		sprint_float (self, self.runevar);
		sprint (self, "\{133} ");

		self.runetime = time + 0.5;
		self.runevar = self.runevar - 1;
		sound (self, CHAN_BODY, "buttons/switch04.wav", 1, ATTN_NORM);
		return;
	}

	self.runevar = -2;
	create_te_explosion (self.origin, 0);
	sprint (self, "\n");

	sure_kill ("kamiself");
	T_RadiusDamage (RADIUS_NORMAL, self, self, 10000, self, "kamikaze");
};

void ()
Bomb_Arm =
{
	if (self.runevar == -1)
		self.runevar = 3;
};

void ()
Bomb_Spawn =
{
	local entity temp;

	temp = spawn ();
	temp.movetype = MOVETYPE_FLY;
	temp.solid = SOLID_NOT;
	temp.owner = self;
	setorigin (temp, self.origin);
	setsize (temp, VEC_ORIGIN, VEC_ORIGIN);
	setmodel (temp, "progs/grenade.mdl");
	temp.avelocity_x = crandom ()*360;
	temp.avelocity_y = crandom ()*360;
	temp.avelocity_z = crandom ()*360;
	temp.think = Bomb_Think;
	temp.nextthink = time;
	self.runevar = -1;
};

void ()
DSpot_Blow =
{
	if (maybe_update_trap_count (self.owner, RN_DSPOTS))
		sprint (self.owner, "A death spot exploded\n");

	create_te_explosion (self.origin, IN_POQ(1, 0));
	monk_radius_hack = 1;
	T_RadiusDamage (RADIUS_NORMAL, self, self.owner, 200, self, "dspotexplode");
	monk_radius_hack = 0;
	IN_QW([-
		remove (self);
	-])
};

void ()
DSpot_Touch =
{
	if (other == world)
		return;

	if (other.classname != "player" && !is_pet_e (other))
		return;

	if (!other.takedamage || other.health <= 0)
		return;

	if (isfriend2 (self.owner, other) && self.owner != other)
		return;

	if (environmental (other))
		return;

	maybe_update_trap_count (self.owner, RN_DSPOTS);

	T_Damage (other, self, self.owner, KILL_DAMAGE, "dspot");

	sound (self, CHAN_AUTO, "boss2/idle.wav", 1, ATTN_NORM);

	self.solid	= SOLID_NOT;
	self.movetype	= MOVETYPE_NONE;

	setmodel (self, string_null);

	self.think	= SUB_Remove;
	self.nextthink	= time + 1;
};

void ()
DSpot_Think =
{
	self.nextthink = time + 0.6;
	IN_POQ([-
		particle (self.origin, VEC_ORIGIN, PARTICLE_DEATH_SPOT, 40);
		if (teamplay & (TEAM_TEAM_MASK | TEAM_MODE_MATCH))
		{
			local float particle_team;

			particle_team = team_to_particle (self.owner.team);
			particle (self.origin, '0 0 -10', particle_team, 10);
		}
	-], [-
		create_te_gunshot (self.origin, 6);
	-])
	if (self.runetime < time)
		DSpot_Blow ();
};

void ()
DSpot_Arm =
{
	self.runetime	= time + 120;
	self.nextthink	= time;
	self.think	= DSpot_Think;
	self.touch	= DSpot_Touch;
	IN_POQ([-
		setmodel (self, string_null);
	-], [-
		// setmodel (self, "progs/s_light.spr");
		self.effects = self.effects - self.effects & EF_DIMLIGHT;
	-])
	sound (self, CHAN_VOICE, "items/inv1.wav", 1, ATTN_NORM);
};

void (float riders, entity of_e)
Rune_DSpots_sprint =
{
	rprint_numdesc (self, riders, of_e.runevar, "death spot");
	rprint (self, riders, " in use\n");
};

void ()
Rune_DSpots =
{
	local entity dspot;
	local string s, s1;

	if (self.runevar >= MAX_DSPOTS)
	{
		s = ftos (MAX_DSPOTS);
		if (MAX_DSPOTS != 1)
			s1 = "s";
		centerprint5 (self, "Only ", s, " death spot", s1, " allowed");
		return;
	}
	self.runevar = self.runevar + 1;

	T_Damage (self, self, self, 20, "dspotdrop");
	dspot = spawn ();
	dspot.movetype = MOVETYPE_FLY;
	dspot.solid = SOLID_TRIGGER;
	dspot.owner = self;
	dspot.classname = "dspot";
	setorigin (dspot, self.origin + '0 0 10');
	setmodel (dspot, "progs/v_spike.mdl");
	setsize (dspot, VEC_ORIGIN, VEC_ORIGIN);
	dspot.effects = dspot.effects | EF_DIMLIGHT;

	dspot.avelocity_x = crandom ()*360;
	dspot.avelocity_y = 100;
	dspot.avelocity_z = crandom ()*360;

	dspot.think = DSpot_Arm;
	dspot.nextthink = time + 3;
	sound (dspot, CHAN_WEAPON, "buttons/switch04.wav", 1, ATTN_NORM);

	centerprint (self, "Death spot created\nRUN!");
};

void ()
Holo_Think =
{
	if (self.runetime < time)
	{
		if (maybe_update_trap_count (self.owner, RN_HOLO))
			sprint (self.owner, "A hologram burned out\n");

		spawn_tfog (self.origin);
		remove (self);
		return;
	}

	self.angles = self.owner.angles;
	self.angles_y = self.angles_y + self.runevar;
	self.frame = self.owner.frame;
	self.nextthink = time + sys_ticrate;
};

void (float riders, entity of_e)
Rune_Holo_sprint =
{
	rprint_numdesc (self, riders, of_e.runevar, "hologram");
	rprint (self, riders, " active\n");
};

void ()
Rune_Holo =
{
	local entity hologram;

	if (self.runevar >= MAX_HOLO)
	{
		centerprint (self, "Too many fakes!");
		return;
	}
	self.runevar = self.runevar + 1;

	hologram = spawn ();
	hologram.movetype = MOVETYPE_NONE;
	hologram.solid = SOLID_NOT;
	hologram.owner = self;
	hologram.classname = "hologram";
	setmodel (hologram, "progs/player.mdl");
	setorigin (hologram, self.origin);
	setsize (hologram, VEC_ORIGIN, VEC_ORIGIN);
	hologram.angles = self.angles;
	hologram.colormap = self.colormap;
	hologram.think = Holo_Think;
	hologram.nextthink = time;
	sound (hologram, CHAN_BODY, "misc/basekey.wav", 1, ATTN_NORM);

	hologram.runetime = time + 30;
	hologram.runevar = crandom ()*360;
};

void ()
Orb_WanderThink =
{
	if (self.runetime < time)
	{
		IN_POQ([-
			particle (self.origin, '0 0 -10', PARTICLE_ORB_REMOVE, 253);
		-], [-
			create_te_gunshot (self.origin, 30);
		-])
		remove (self);
		return;
	}
	self.nextthink = time + 0.5;

	if (pointcontents (self.origin) == CONTENT_SOLID)
		setorigin (self, self.owner.origin);

	if (self.flags & FL_ONGROUND)
	{
		self.flags = self.flags - FL_ONGROUND;
		IN_QW([-
			self.avelocity_x = crandom ()*360;
			self.avelocity_y = crandom ()*360;
			self.avelocity_z = crandom ()*360;
		-])
		self.velocity_x = crandom ()*400;
		self.velocity_y = crandom ()*400;
		self.velocity_z = random ()*500+100;
	}

	T_RadiusDamage (RADIUS_NORMAL, self, self.owner, 60, self.owner, "deathorb-random");
};

void ()
Orb_Think =
{
	if (intermission_running)
	{
		remove (self.runent);
		remove (self);
		return;
	}

	if (self.owner.health < 1 || self.owner.runetype != RN_ORB)
	{
		remove (self.runent);

		// Only do bouncies if you get killed with orb. Not
		// dropping runes.
		if (self.owner.health < 1) self.runetime = time + 20;

		self.movetype	= MOVETYPE_BOUNCE;
		self.nextthink	= time;
		self.think	= Orb_WanderThink;
		self.flags	= self.flags-(self.flags & FL_ONGROUND);
		self.velocity	= '0 0 1';

		return;
	}

	setorigin (self.runent, self.owner.origin + '0 0 10');
	makevectors (self.runent.angles);

	traceline (self.runent.origin, self.runent.origin + v_forward*120, TRUE, world);

	setorigin (self, trace_endpos-v_forward*10);
	trackvel (self.owner);
	self.nextthink = time + sys_ticrate;

	if (self.runetime > time)
		return;
	self.runetime = self.runetime + 0.5;

	T_RadiusDamage (RADIUS_NORMAL, self, self.owner, 60, self.owner, "deathorb");
};

void ()
Orb_Spawn =
{
	local entity axis, orb;

	axis = spawn ();
	axis.movetype = MOVETYPE_FLY;
	axis.solid = SOLID_NOT;
	axis.owner = self;
	setorigin (axis, self.origin);
	setsize (axis, VEC_ORIGIN, VEC_ORIGIN);
	setmodel (axis, string_null);

	if (random () > 0.5)
		axis.avelocity_y = 55;
	else
		axis.avelocity_y = -55;

	orb = spawn ();
	orb.movetype = MOVETYPE_FLY;
	orb.solid = SOLID_NOT;
	orb.owner = self;
	setorigin (orb, self.origin);
	IN_POQ([-
		orb.flags = orb.flags | FL_ONGROUND;
		orb.effects = orb.effects | EF_BRIGHTFIELD;
		setmodel (orb, "progs/s_light.spr");
	-], [-
		orb.avelocity_x = crandom ()*360;
		orb.avelocity_y = crandom ()*360;
		orb.avelocity_z = crandom ()*360;
		setmodel (orb, "progs/teleport.mdl");
	-])
	orb.nextthink = time;
	orb.think = Orb_Think;
	orb.classname = "deathorb";
	orb.runent = axis;
};

// This blink algorithm blinks you on top of one of the following types
// of items.  This can still fail (with the "Unstuck" message if you
// have developer mode on); it reblinks automatically in this case.

float (string c)
is_blinkable_class =
{
	return 0
		|| c == "backpack"
		|| c == "item_armor1"
		|| c == "item_armor2"
		|| c == "item_armorInv"
		|| c == "item_artifact_envirosuit"
		|| c == "item_artifact_invisibility"
		|| c == "item_artifact_invulnerability"
		|| c == "item_artifact_super_damage"
		|| c == "item_cells"
		|| c == "item_health"
		|| c == "item_key1"
		|| c == "item_key2"
		|| c == "item_rockets"
		|| c == "item_shells"
		|| c == "item_sigil"
		|| c == "item_spikes"
		|| c == "weapon_grenadelauncher"
		|| c == "weapon_lightning"
		|| c == "weapon_nailgun"
		|| c == "weapon_rocketlauncher"
		|| c == "weapon_supernailgun"
		|| c == "weapon_supershotgun"
	;
};

void (float reblink)
Rune_Blink =
{
	local entity e, good_e;
	local float i, time_waited;

	if (self.runetime > time)
	{
		i = self.runetime - time;
		if (i > 0.5)
		{
			i = floor (i + 0.5);
			sprint (self, "Blink recharging, ready in ");
			sprint_float (self, i);
			sprint (self, " second");
			if (i != 1)
				sprint (self, "s");
			sprint (self, "\n");
		}
		else
			sprint (self, "Blink recharging\n");
		return;
	}

	good_e = world;
	i = 0;
	e = nextent (world);
	while (e)
	{
		if (vlen (self.origin - e.origin) > 250)
		{
			if (is_blinkable_class (e.classname))
			{
				i = i + 1;
				if (random () * i < 1 || good_e == world)
				{
					// XXX doing more tests after
					// incrementing i screws up the
					// algorithm
					if (safe_spawn_point (e))
					{
						if (pointcontents (e.origin) == CONTENT_EMPTY
								|| pointcontents (e.origin) == CONTENT_WATER)
							good_e = e;
					}
				}
			}
		}
		e = nextent (e);
	}
	if (!good_e)
	{
		bprint_timestamp ("bug: no blink target\n");
		return;
	}

	e = spawn ();
	e.runevector = good_e.origin + SPAWN_ITEM_OFFSET;
	e.owner = self;
	e.think = maybe_reblink;
	// I used to do this after one tick, but it would occasionally
	// fail to detect a failed blink for some reason.
	e.nextthink = time + 2 * sys_ticrate;
	setorigin (self, e.runevector);
	muzzleflash ();
	self.velocity = VEC_ORIGIN;
	HookOff ();
	HookOff_by_targ ();

	// Some people just love to blink blink blink, particularly
	// while they unload a big bag of grenades.  Slow these
	// people down while still allowing free blinking to get
	// out of danger.
	//
	// self.runevar is the current delay.

	time_waited = time - self.runetime;
	if (reblink)
		SUB_Null ();
	else if (self.runevar < 0.5)
		self.runevar = 0.5;
	else if (time_waited <= self.runevar)
		self.runevar = self.runevar * 1.5;
	else if (time_waited <= self.runevar * 1.5)
		self.runevar = self.runevar * 0.75;
	else if (time_waited <= self.runevar * 3)
		self.runevar = self.runevar * 0.50;
	else if (time_waited <= self.runevar * 4.5)
		self.runevar = self.runevar * 0.25;
	else
		self.runevar = 0;

	if (self.runevar < 0.5)
		self.runevar = 0.5;
	else if (self.runevar > 10)
		self.runevar = 10;

	self.runetime = time + self.runevar;
};

void ()
maybe_reblink =
{
	local float d, reblink;

	d = vlen (self.owner.origin - self.runevector);
	reblink = d > 125;

	if (0)
	{
		if (reblink)
			bprint ("\{141}");
		else
			bprint (" ");
		sprint_int_f (world, time * 10, 4);
		bprint (" dist ");
		bprint_float (d);
		bprint (" targ ");
		bprint_vec (self.runevector);
		bprint (" current ");
		bprint_vec (self.owner.origin);
		bprint ("\n");
	}

	if (reblink)
	{
		local entity oself;

		oself = self;
		self = self.owner;
		self.runetime = time;
		Rune_Blink (1);
		self = oself;
	}
	remove (self);
};

float ()
maybe_remove_hat =
{
	if (intermission_running)
		return TRUE;
	else if (self.runetype && self.owner.runetype != self.runetype)
		return TRUE;
	else if (self.runevar)
	{
		if (!self.owner.health)
			return TRUE;
		if (self.runevar == ITEM_PENT && (self.owner.invincible_finished < time || options & NO_POWERUP_HATS))
			return TRUE;
		if (self.runevar == ITEM_QUAD && (self.owner.super_damage_finished < time || options & NO_POWERUP_HATS))
			return TRUE;
		if (self.runevar == 16 && !self.owner.rqstate & RQS_GUIDED_MISSILE)
			return TRUE;
	}
	return FALSE;
};

void ()
Hat_Think =
{
	local vector a;

	if (maybe_remove_hat ())
	{
		remove (self);
		return;
	}

	if (self.runevar & ITEM_POWERUP_ANY)
		setorigin (self, self.owner.origin + self.runevector);
	else
	{
		// makevectors() uses e.v_angle-style angles rather than
		// e.angles-style.  The pitch goes the other way.
		a = self.owner.angles;
		a_x = 0 - a_x;
		makevectors (a);
		setorigin (self, self.owner.origin
					+ self.runevector_x * v_forward
					+ self.runevector_y * v_right
					+ self.runevector_z * v_up);

		trackvel (self.owner);
		self.angles = self.owner.angles + self.mangle;
	}
	self.nextthink = time + sys_ticrate;
};

void (entity e, string tmodel, vector offs, vector ang, float type)
Hat_Spawn =
{
	local entity dot;

	if (options & NO_POWERUP_HATS && type & ITEM_POWERUP_ANY)
		return;

	dot		= spawn ();
	dot.movetype	= MOVETYPE_FLY;
	dot.solid	= SOLID_NOT;
	dot.owner	= e;

	if (type)
		dot.runevar	= type;
	else
		dot.runetype	= e.runetype;

	setorigin (dot, e.origin);
	setsize (dot, VEC_ORIGIN, VEC_ORIGIN);
	setmodel (dot, tmodel);

	dot.runevector	= offs;
	dot.mangle	= ang;
	dot.think	= Hat_Think;
	dot.nextthink	= time;
};

void ()
Rune_Camo =
{
	// The origin check works around the platform problem.  Without it
	// your view doesn't update while you're on a moving platform due to
	// the way the rendering engine treats you when you have a null
	// model.
	if (self.velocity == VEC_ORIGIN && self.attack_finished < time
			&& self.origin == self.runevector)
		self.runevar = 1;
	else
		self.runevar = 0;
	self.runevector = self.origin;
};

void ()
Rune_Jump =
{
	local entity head, selected;
	local float dist;

	if (self.runetime > time)
		return;
	self.runetime = self.runetime + 0.2;

	dist = 1000;

	selected = world;
	head = findradius (self.origin, dist);
	while (head)
	{
		if (head.health > 0 && !isfriend (head) && head.runetype != RN_ENVIRO
				&& !head.items & IT_SUIT)
		{
			traceline (self.origin, head.origin + head.view_ofs, TRUE, self);
			if ((trace_fraction >= 1) && (vlen (head.origin - self.origin) < dist))
			{
				selected = head;

				if (selected != world && selected.flags & FL_ONGROUND)
				{
					selected.flags = selected.flags - FL_ONGROUND;
					if (selected.classname == "player")
						sound (selected, CHAN_JUMP, "player/plyrjmp8.wav", 1, ATTN_NORM);
					selected.velocity_z = selected.velocity_z + 270;
				}
			}
		}
		head = head.chain;
	}
};

void ()
Rune_Ammo =
{
	local float incl_rocket;

	if (self.runetime > time)
		return;
	self.runetime = time + 0.6;

	if (self.runevar < time)
	{
		self.runevar = time + 1.3;
		incl_rocket = 1;
	}
	else
		incl_rocket = 0;

	Rune_Ammo_1 (incl_rocket);
};

void (float incl_rocket)
Rune_Ammo_1 =
{
	local float new_it;

	if (self.ammo_shells < MAX_SHELLS) self.ammo_shells = self.ammo_shells + 1;
	if (self.ammo_cells < MAX_CELLS) self.ammo_cells = self.ammo_cells + 1;
	if (self.ammo_nails < MAX_NAILS) self.ammo_nails = self.ammo_nails + 2;
	if (self.ammo_rockets < MAX_ROCKETS && incl_rocket)
		self.ammo_rockets = self.ammo_rockets + 1;

	new_it = 0;
	if (self.ammo_nails >= MAX_NAILS)
	{
		new_it = new_it | IT_NAILGUN | IT_SUPER_NAILGUN;
		self.ammo_nails = MAX_NAILS;
	}
	if (self.ammo_shells >= MAX_SHELLS)
		new_it = new_it | IT_SUPER_SHOTGUN;
	if (self.ammo_cells >= MAX_CELLS)
		new_it = new_it | IT_LIGHTNING;
	if (self.ammo_rockets >= MAX_ROCKETS)
		new_it = new_it | IT_GRENADE_LAUNCHER | IT_ROCKET_LAUNCHER;
	if ((options2 & HOOK_MASK == LITHIUM_HOOK)
			&& self.ammo_nails >= MAX_NAILS
			&& self.ammo_shells >= MAX_SHELLS
			&& self.ammo_cells >= MAX_CELLS
			&& self.ammo_rockets >= MAX_ROCKETS
			&& !self.aqflags & AQ_HOOK)
		Rune_Activate (RN_LITHIUM_HOOK, 1);
	if (self.items & new_it != new_it)
	{
		local float was_best;

		was_best = (self.weapon == W_BestWeapon ());
		self.items = self.items | new_it;
		if (was_best)
			set_weapon (W_BestWeapon ());
	}

	set_current_ammo ();
};

void ()
Vamp_Think =
{
	if (self.owner.health < 1 || self.owner.runetype != RN_VAMP)
	{
		if (self.owner.health > 0)
			decay_health_spawn (self.owner, 1);
		remove (self);
		return;
	}
	decay_health (self.owner, 1);
	self.nextthink = time + 1;
};

void ()
Vamp_Spawn =
{
	local entity e;

	e = find (world, classname, "decay_health");
	while (e)
	{
		if (e.owner == self)
		{
			if (e.owner.items & IT_SUPERHEALTH)
				e.owner.items = e.owner.items - e.owner.items & IT_SUPERHEALTH;
			maybe_respawn_mega (e.owner);
			remove (e);
		}
		e = find (e, classname, "decay_health");
	}

	e		= spawn ();
	e.owner		= self;
	e.classname	= "vampthink";
	e.think		= Vamp_Think;
	e.nextthink	= time;
};

void (entity vamp, entity victim, float damage)
Vamp_Heal =
{
	local float wasdead;

	if (victim.takedamage != DAMAGE_AIM
			|| vamp.health >= (vamp.max_health + MAX_OVER_HEALTH)
			|| damage == 0
			|| victim == vamp
			|| victim.classname == "zombie_camper")
		return;

	wasdead = vamp.health <= 0;

	// prevent resurrect abuse
	if (vamp.runevector_x < time)
	{
		if (victim.classname == "player")
			vamp.health = vamp.health + (damage);
		else
			vamp.health = vamp.health + (0.2 * damage);
	}
	if (vamp.health > (vamp.max_health + MAX_OVER_HEALTH))
		vamp.health = vamp.max_health + MAX_OVER_HEALTH;

	if (wasdead && vamp.health > 0)
		Vamp_Resurrect (vamp);
	sound (vamp, CHAN_BODY, "wizard/wpain.wav", 1, ATTN_NORM);
};

void (entity vamp)
Vamp_Resurrect =
{
	local entity oself, e, next;
	local float found;

	oself = self;
	self = vamp;

	bprint (self.netname);
	bprint (" comes back to life!\n");
	Resurrect (0);

	// prevent resurrect abuse
	self.runevector_x = time + self.runevector_y;
	self.runevector_y = self.runevector_y + 0.5;

	// Remove her rune and backpack if possible.
	e = findradius (self.origin, 250);
	while (e)
	{
		next = e.chain;
		if (e.classname == "rune" && e.owner == self && e.runetype == RN_VAMP)
		{
			runecurrent = runecurrent - 1;
			remove (e);
		}
		else if (e.classname == "backpack" && e.owner == self)
			remove (e);
		e = next;
	}

	// Spawn her a new vamp thinker if necessary.
	found = 0;
	e = find (world, classname, "vampthink");
	while (e != world && !found)
	{
		if (e.owner == self)
			found = 1;
		e = find (e, classname, "vampthink");
	}
	if (!found)
		Vamp_Spawn ();

	self = oself;
};

// use this function to prevent takedamage overwrite under certain conditions
float ()
takedamage_hack =
{
	if (gamemode & MODE_ARENA)
	{
		if (arena.state)
			return 0;
	}
	else if (gamemode == MODE_MATCH)
	{
		if (!match.state)
			return 0;
	}
	return 1;
};

// Shield runevar:
//    0 shields off and no shield requested
//    1 shields on
//    2 shields recharging, request pending, will turn on when charged

void ()
Shield_On =
{
	if (self.runevar == 1 && self.runetime <= time)
	{
		// shields are on and time ran out, turn them off
		stuffcmd (self, CSHIFT_NONE);
		self.effects = self.effects - self.effects & EF_BRIGHTFIELD;
		self.runevar = 0;
		self.runetime = time + RN_SHIELD_RECHARGE;	// recharge time

		// prevent overwriting takedamage in arena mode
		if (takedamage_hack ())
			self.takedamage = DAMAGE_AIM;
	}
	else if (self.runevar == 2 && self.runetime <= time)
	{
		// shields finished recharging and a request is pending,
		// turn them on
		self.runevar = 0;
		// clear possible recharging message
		centerprint (self, string_null);
		Rune_Shield ();
	}
};

void ()
Rune_Shield =
{
	if (self.runevar == 0)
	{
		if (self.runetime > time)
		{
			centerprint (self, "Shield recharging");
			self.runevar = 2;
			return;
		}
		stuffcmd (self, CSHIFT_SHIELD);
		sound (self, CHAN_BODY, "items/protect2.wav", 1, ATTN_NORM);
		self.effects = self.effects | EF_BRIGHTFIELD;
		self.runevar = 1;
		self.takedamage = DAMAGE_NO;
		self.runetime = time + RN_SHIELD_DURATION;	// shield duration
	}
	else if (self.runevar == 2)
	{
		centerprint (self, "Pending shield canceled");
		self.runevar = 0;
	}
};
