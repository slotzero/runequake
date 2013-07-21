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

/* ALL LIGHTS SHOULD BE 0 1 0 IN COLOR ALL OTHER ITEMS SHOULD
BE .8 .3 .4 IN COLOR */

void ()
SUB_regen =
{
	self.model = self.mdl; // restore original model
	self.solid = SOLID_TRIGGER; // allow it to be touched again

	sound (self, CHAN_VOICE, "items/itembk2.wav", 1, ATTN_NORM); // play respawn sound

	if (self.touch == armor_touch)
		armor_cycle ();

	setorigin (self, self.origin);
};

/* QUAKED noclass (0 0 0) (-8 -8 -8) (8 8 8)
prints a warning message when spawned
*/
void ()
noclass =
{
	dprint ("noclass spawned at");
	dprint_vec (self.origin);
	dprint ("\n");

	remove (self);
};

void (entity e, float chan, string samp, float vol, float atten)
item_sound =
{
	sound (e, chan, samp, vol, atten);
	stuffcmd (e, "bf\n");
	// spawn_protect_off_e (e);
};

void (entity e, string s)
precache_noise_e =
{
	precache_sound (s);
	e.noise = s;
};

void (string s)
precache_noise =
{
	precache_noise_e (self, s);
};

void ()
blink_item =
{
	if (time < self.cnt)
	{
		local float i;

		i = self.cnt - time;
		if ((i - floor (i)) >= 0.5)
			setmodel (self, self.mdl);
		else
			setmodel (self, string_null);
		self.nextthink = time + 0.5;
		return;
	}
	remove (self);
};

void ()
maybe_disable_item =
{
	// keep track of items that have been disabled
	self.nextthink = -2;

	if (self.touch == powerup_touch)
	{
		if (self.classname == "item_artifact_super_damage" && options & NO_QUAD)
			return;
		if (self.classname == "item_artifact_invulnerability" && options & NO_PENT)
			return;
		if (self.classname == "item_artifact_invisibility" && options & NO_RING)
			return;
		if (self.classname == "item_artifact_envirosuit" && options & NO_SUIT)
			return;
	}
	else if (self.touch == armor_touch)
	{
		if (options & NO_ARMOR)
		 	return;
	}
	else if (self.touch == health_touch)
	{
		if (self.classname == "item_health" && self.spawnflags & 2 && options & NO_MEGA)
			return;
	}

	self.think	= SUB_regen;
	self.nextthink	= time;
};

/*
============
PlaceItem

plants the object on the floor
============
*/
void ()
PlaceItem =
{
	if (gamemode & MODE_ARENA)
	{
		remove (self);
		return;
	}

	self.mdl	= self.model;	// so it can be restored on respawn
	self.flags	= FL_ITEM;	// make extra wide
	self.solid	= SOLID_TRIGGER;
	self.movetype	= MOVETYPE_TOSS;
	self.velocity	= VEC_ORIGIN;
	self.origin_z	= self.origin_z + 6;

	if (!droptofloor ())
	{
		dprint ("Bonus item \"");
		dprint (self.classname);
		dprint ("\" fell out of level at ");
		dprint_vec (self.origin);
		dprint ("\n");

		remove (self);
		return;
	}

	// Get weapons up right away in weapons-stay mode.  Without this
	// they don't go up until after somebody gets them for the first
	// time (weapon_touch sets it up).  Since I have this init step
	// I set oldorigin here only.
	if (self.touch == weapon_touch)
	{
		// Save the origin no matter what in case WEAPONS_STAY
		// is turned on later.
		self.oldorigin = self.origin;
		if (options & WEAPONS_STAY || coop)
		{
			self.runetime	= time;
			self.think	= weapon_up;
			self.nextthink	= time;
		}
	}
	else if (self.touch == powerup_touch
			|| self.touch == armor_touch
			|| (self.touch == health_touch && self.spawnflags & 2))
	{
		self.model	= string_null;
		self.solid	= SOLID_NOT;
		self.think	= maybe_disable_item;
		self.nextthink	= time;
	}
};

/*
============
StartItem

Sets the clipping size and plants the object on the floor
============
*/
void ()
StartItem =
{
	self.nextthink	= time + 0.2; // items start after other solids
	self.think	= PlaceItem;
};

/*
=========================================================================

HEALTH BOX

=========================================================================
*/

//
// T_Heal: add health to an entity, limiting health to max_health
// "ignore" will ignore max_health limit
//
float (entity e, float heal_amount, float ignore)
T_Heal =
{
	local float max;

	if (e.health <= 0)
		return 0;

	max = e.max_health;
	if (ignore)
		max = max + MAX_OVER_HEALTH;
	if (e.health >= max)
		return 0;

	heal_amount = ceil (heal_amount);
	e.health = e.health + heal_amount;
	if (e.health > max)
		e.health = max;

	return 1;
};

/* QUAKED item_health (.3 .3 1) (0 0 0) (32 32 32) rotten megahealth
Health box. Normally gives 25 points.
Rotten box heals 5-10 points,
megahealth will add 100 health, then
rot you down to your maximum health limit,
one point per second.
*/

float	H_ROTTEN	= 1;
float	H_MEGA		= 2;


void (string it_model, string it_noise)
health_set =
{
	precache_model (it_model);
	precache_noise (it_noise);

	self.touch		= health_touch;

	setmodel (self, it_model);
	setsize (self, VEC_ORIGIN, '32 32 56');

	StartItem ();
};

void ()
item_health =
{
	if (self.spawnflags & H_ROTTEN)
		health_set ("maps/b_bh10.bsp", "items/r_item1.wav");
	else if (self.spawnflags & H_MEGA)
		health_set ("maps/b_bh100.bsp", "items/r_item2.wav");
	else
		health_set ("maps/b_bh25.bsp", "items/health1.wav");
};

void (entity e)
maybe_respawn_mega =
{
	local entity mega;

	if (!options & CLASSIC_MEGA)
		return;

	if (options & NO_MEGA)
		return;

	mega = find (world, classname, "item_health");
	while (mega)
	{
		if (mega.nextthink > -2 && mega.spawnflags & H_MEGA && mega.owner == e)
		{
			mega.owner = world;
			mega.nextthink = time + 20;
			mega.think = SUB_regen;
		}
		mega = find (mega, classname, "item_health");
	}
};

void ()
health_touch =
{
	local float is_mega, amount;
	local string s;

	if (other.classname != "player")
		return;

	if (gamemode == MODE_MATCH)
	{
		if (match.state <= 0)
			return;
	}

	if (other.runetype == RN_REQUIEM)
	{
		if (other.runevector_y > time)
			return;
	}

	is_mega = self.spawnflags & H_MEGA;

	if (self.spawnflags & H_ROTTEN)
		amount = 15;
	else if (self.spawnflags & H_MEGA)
		amount = 100;
	else
		amount = 25;

	s = self.noise;
	// Vampires only get 5 health from non-mega health boxes.

	if (is_mega)
	{
		if (other.runetype == RN_REQUIEM)
			amount = 25;
	}
	else
	{
		if (other.runetype == RN_VAMP)
		{
			amount = 5;
			s = "items/r_item1.wav";
		}
		else if (other.runetype == RN_REQUIEM)
		{
			amount = 15;
			s = "items/r_item1.wav";
		}
	}

	if (!T_Heal (other, amount, is_mega))
		return;

	if (!deathmatch & DM_DM_MASK)
	{
		sprint (other, "You receive ");
		sprint_float (other, amount);
		sprint (other, " health\n");
	}

	// health touch sound
	item_sound (other, CHAN_ITEM, s, 1, ATTN_NORM);

	if (other.runetype == RN_REQUIEM)
	{
		other.runevector_y = time + RN_REQUIEM_RECHARGE;
		if (is_mega)
			decay_health_spawn (other, 1);
	}
	else
	{
		self.model = string_null;
		self.solid = SOLID_NOT;

		if (deathmatch & DM_RESPAWN)
		{
			if (is_mega)
				self.nextthink = time + MEGAHEALTH_RESPAWN_TIME;
			else
				self.nextthink = time + HEALTH_RESPAWN_TIME;
			self.think = SUB_regen;
		}

		// Set up a health decaying entity for megahealth if necessary.
		if (is_mega)
			decay_health_spawn (other, 1);

		activator = other;
		SUB_UseTargets (); // fire all targets / killtargets
	}
};

/*
===============================================================================

ARMOR

===============================================================================
*/

void ()
armor_touch =
{
	local float type, value, max, this_tot, other_tot, bit;

	if (other.health <= 0)
		return;

	if (other.classname != "player")
		return;

	if (gamemode == MODE_MATCH)
	{
		if (match.state <= 0)
			return;
	}

	// Someone touched me, so don't cycle if configured.
	self.runetype	= time + 5;

	if (other.runetype == RN_REQUIEM)
	{
		if (other.runevector_z > time)
			return;
	}

	if (self.runevar)
	{
		type	= self.armortype;
		value	= self.armorvalue;
		bit	= self.aqstate;
	}
	else if (self.skin == 0)
	{
		type	= ARMOR_TYPE_1;
		value	= MAX_ARMOR_1;
		bit	= IT_ARMOR1;
	}
	else if (self.skin == 1)
	{
		type	= ARMOR_TYPE_2;
		value	= MAX_ARMOR_2;
		bit	= IT_ARMOR2;
	}
	else if (self.skin == 2)
	{
		type	= ARMOR_TYPE_3;
		value	= MAX_ARMOR_3;
		bit	= IT_ARMOR3;
	}

	this_tot	= type * value;
	other_tot	= other.armortype * other.armorvalue;


	if (other.runetype == RN_REGEN)
	{
		// Don't go to a worse type if you have regen, even if
		// there's more of it.
		if (other.armortype > type
				|| (other.armortype == type
					&& other_tot >= this_tot))
			return;
	}
	else if (other.runetype == RN_ARMOR)
	{
		if (other.armorvalue >= get_max_armor_e (other))
			return;
	}
	else if (other.runetype == RN_REQUIEM)
	{
		if (other.armorvalue && other.armortype >= type && other.armorvalue >= get_max_armor_e (other))
			return;
	}
	else if (other_tot >= this_tot)
		return;

	if (other.runetype == RN_ARMOR)
	{
		other.armortype		= ARMOR_TYPE_3;
		other.armorvalue	= other.armorvalue + value;
	}
	else if (other.runetype == RN_REQUIEM)
	{
		if (other.armortype > type)
			type = other.armortype;
		else
			other.items	= other.items - (other.items & (IT_ARMOR1 | IT_ARMOR2 | IT_ARMOR3)) + bit;

		other.armortype		= type;
		if (other.armorvalue <= 0)
			other.armorvalue = value / 2;
		else
			other.armorvalue	= other.armorvalue + 15;
	}
	else
	{
		// XXX I wanted to add the option to drop armor of whose type
		// is worse than the one you picked up, but I'm not satisfied
		// with the results.  I left the code here just incase anyone
		// wants to use it.
		/* if (1)
		{
			if (type > other.armortype)
			{
				local entity old_self;

				old_self	= self;
				self		= other;

				drop_armor();

				self		= old_self;
			}
		}*/

		other.armortype		= type;
		other.armorvalue	= value;
		other.items		= other.items - (other.items & (IT_ARMOR1 | IT_ARMOR2 | IT_ARMOR3)) + bit;
	}

	// Bound the armor in case she got good armor dropped by a rune
	// holder, or she's got good armor.
	max = get_max_armor_e (other);
	if (other.armorvalue > max)
		other.armorvalue = max;

	// Have to do this after capping armorvalue.
	if (other.runetype == RN_ARMOR)
		good_armor_set_armor_items_e (other);

	if (!deathmatch & DM_DM_MASK)
		sprint (other, "You got armor\n");

	// armor touch sound
	item_sound (other, CHAN_ITEM, "items/armor1.wav", 1, ATTN_NORM);

	// Stop burning, for levels with no water.
	other.aqstate = other.aqstate - other.aqstate & AQS_BURNING;

	if (other.runetype == RN_REQUIEM)
		other.runevector_z = time + RN_REQUIEM_RECHARGE;
	else
	{
		if (self.runevar)
		{
			remove (self);
			return;
		}

		self.solid = SOLID_NOT;
		self.model = string_null;
		if (deathmatch & DM_RESPAWN)
			self.nextthink = time + ARMOR_RESPAWN_TIME;
		self.think = SUB_regen;

		activator = other;
		SUB_UseTargets (); // fire all targets / killtargets
	}
};

void ()
armor_cycle =
{
	if (!options & ARMOR_ROTATE)
		return;

	if (self.runetype < time)
	{
		if (ARMOR_ROTATE_RANDOM)
			self.skin = rint (random () * 2);
		else
			self.skin = self.skin + 1;

		if (self.skin > 2)
			self.skin = 0;
	}

	self.nextthink	= time + ARMOR_ROTATE_INTERVAL;
	self.think	= armor_cycle;
};

void (float it_skin)
armor_set =
{
	if (!spawn_no_precache)
		precache_model ("progs/armor.mdl");

	self.touch	= armor_touch;
	self.skin	= it_skin;
	self.impulse	= it_skin; // vote-rotate
	self.netname	= "item_armor_all"; // vote-armor, vote-rotate

	setmodel (self, "progs/armor.mdl");
	setsize (self, '-16 -16 0', '16 16 56');

	StartItem ();
};

/*QUAKED item_armor1 (0 .5 .8) (-16 -16 0) (16 16 32)
*/
void ()
item_armor1 =
{
	armor_set (0);
};

/*QUAKED item_armor2 (0 .5 .8) (-16 -16 0) (16 16 32)
*/
void ()
item_armor2 =
{
	armor_set (1);
};

/*QUAKED item_armorInv (0 .5 .8) (-16 -16 0) (16 16 32)
*/

void ()
item_armorInv =
{
	armor_set (2);
};

void ()
drop_armor =
{
	local entity item;

	if (options & NO_DROP_ARMOR)
		return;

	if (self.armorvalue <= 0)
		return;

	item		= spawn ();
	item.runevar	= 1;
	item.classname	= "dropped_armor";
	item.armortype	= self.armortype;
	item.armorvalue	= self.armorvalue;
	item.origin	= self.origin;
	item.velocity_z	= 300;
	item.velocity_x	= -100 + (random () * 200);
	item.velocity_y	= -100 + (random () * 200);
	item.flags	= FL_ITEM;
	item.solid	= SOLID_TRIGGER;
	item.movetype	= MOVETYPE_TOSS;
	item.mdl	= "progs/armor.mdl";

	item.aqstate = armor_type_to_it (item.armortype);
	if (item.aqstate == IT_ARMOR1)
		item.skin = 0;
	else if (item.aqstate == IT_ARMOR2)
		item.skin = 1;
	else if (item.aqstate == IT_ARMOR3)
		item.skin = 2;
	else
	{
		remove (item);
		return;
	}

	setmodel (item, item.mdl);
	setsize (item, '-16 -16 0', '16 16 56');

	item.touch	= armor_touch;
	item.cnt	= time + DROP_ARMOR_DURATION;
	item.nextthink	= item.cnt - 3; // blink before removing
	item.think	= blink_item;
};

/*
===============================================================================

WEAPONS

===============================================================================
*/

void ()
bound_other_ammo =
{
	if (other.ammo_shells > MAX_SHELLS)
		other.ammo_shells = MAX_SHELLS;
	if (other.ammo_nails > MAX_NAILS)
		other.ammo_nails = MAX_NAILS;
	if (other.ammo_rockets > MAX_ROCKETS)
		other.ammo_rockets = MAX_ROCKETS;
	if (other.ammo_cells > MAX_CELLS)
		other.ammo_cells = MAX_CELLS;
};

/*
=============
weapon_touch
=============
*/
void ()
weapon_touch =
{
	local float charged, hadammo, best, new, old, leave, requiem;
	local entity stemp;

	if (!other.flags & FL_CLIENT)
		return;

	if (gamemode == MODE_MATCH)
	{
		if (match.state <= 0)
			return;
	}

	requiem = other.runetype == RN_REQUIEM;
	if (requiem)
	{
		if (other.runevector_x > time)
			return;
	}

	// if the player was using his best weapon, change up to the new
	// one if better
	stemp = self;
	self = other;
	best = W_BestWeapon ();
	self = stemp;

	charged = time >= self.runetime;

	if (options & WEAPONS_STAY || coop)
		leave = 1;
	else
		leave = 0;

	if (self.classname == "weapon_nailgun")
	{
		if (leave && !charged && other.items & IT_NAILGUN)
			return;
		hadammo = other.ammo_nails;
		new = IT_NAILGUN;
		if (hadammo >= MAX_NAILS && other.items & new)
			return;

		if (requiem)
			other.ammo_nails = other.ammo_nails + 5;
		else
			other.ammo_nails = other.ammo_nails + 30;
	}
	else if (self.classname == "weapon_supernailgun")
	{
		if (leave && !charged && other.items & IT_SUPER_NAILGUN)
			return;
		hadammo = other.ammo_nails;
		new = IT_SUPER_NAILGUN;
		if (hadammo >= MAX_NAILS && other.items & new)
			return;

		if (requiem)
			other.ammo_nails = other.ammo_nails + 5;
		else
			other.ammo_nails = other.ammo_nails + 30;
	}
	else if (self.classname == "weapon_supershotgun")
	{
		if (leave && !charged && other.items & IT_SUPER_SHOTGUN)
			return;
		hadammo = other.ammo_shells;
		new = IT_SUPER_SHOTGUN;
		if (hadammo >= MAX_SHELLS && other.items & new)
			return;
		other.ammo_shells = other.ammo_shells + 5;
	}
	else if (self.classname == "weapon_rocketlauncher")
	{
		if (leave && !charged && other.items & IT_ROCKET_LAUNCHER)
			return;
		hadammo = other.ammo_rockets;
		new = IT_ROCKET_LAUNCHER;
		if (hadammo >= MAX_ROCKETS && other.items & new)
			return;
		other.ammo_rockets = other.ammo_rockets + 5;
	}
	else if (self.classname == "weapon_grenadelauncher")
	{
		// if (other.grenade_spam_time < 0)  // spam fix
		//	return; // spam fix
		if (leave && !charged && other.items & IT_GRENADE_LAUNCHER)
			return;
		hadammo = other.ammo_rockets;
		new = IT_GRENADE_LAUNCHER;
		if (hadammo >= MAX_ROCKETS && other.items & new)
			return;
		other.ammo_rockets = other.ammo_rockets + 5;
	}
	else if (self.classname == "weapon_lightning")
	{
		if (leave && !charged && other.items & IT_LIGHTNING)
			return;
		hadammo = other.ammo_cells;
		new = IT_LIGHTNING;
		if (hadammo >= MAX_CELLS && other.items & new)
			return;

		if (requiem)
			other.ammo_cells = other.ammo_cells + 5;
		else
			other.ammo_cells = other.ammo_cells + 15;
	}
	else
		objerror ("weapon_touch: unknown classname");

	if (!deathmatch & DM_DM_MASK)
	{
		sprint (other, "You got the ");
		sprint (other, self.netname);
		sprint (other, "\n");
	}
	// weapon touch sound
	item_sound (other, CHAN_ITEM, "weapons/pkup.wav", 1, ATTN_NORM);

	if (requiem && other.items & new)
		charged = 0;

	bound_other_ammo ();

	// change to the weapon
	old = other.items;
	other.items = other.items | new;

	stemp = self;
	self = other;

	if (!deathmatch & DM_DM_MASK)
		set_weapon (new);
	else if (self.weapon == best)
		set_weapon (W_BestWeapon ());
	else
		set_current_ammo ();

	self = stemp;

	if (leave)
	{
		// If it was charged, set the charge time and prime the
		// think function to raise it.
		if (charged)
		{
			setorigin (self, self.oldorigin);
			self.runetime = time + WEAPON_RESPAWN_TIME;
			self.think = weapon_up;
			self.nextthink = self.runetime;
		}
		if (!requiem)
			return;
	}

	// remove it in single player, or setup for respawning in deathmatch
	if (other.runetype == RN_REQUIEM)
		other.runevector_x = time + RN_REQUIEM_RECHARGE;
	else
	{
		self.model = string_null;
		self.solid = SOLID_NOT;
		if (deathmatch & DM_RESPAWN)
			self.nextthink = time + WEAPON_RESPAWN_TIME;
		self.think = SUB_regen;

		activator = other;
		SUB_UseTargets (); // fire all targets / killtargets
	}
};

void ()
weapon_up =
{
	if (options & WEAPONS_STAY || coop)
	{
		setorigin (self, self.oldorigin + WEAPON_CHARGED_OFFSET);
		// Keep on moving it due to the rocket in the squish
		// room in Hell's Atrium (the squishing ceiling moves it
		// down to the floor).
		self.nextthink = time + 5;
	}
};

void (string it_model, float it_weapon, string it_netname)
weapon_set =
{
	if (!spawn_no_precache)
		precache_model (it_model);

	if (gamemode == MODE_PRACTICE)
	{
		remove (self);
		return;
	}

	self.touch	= weapon_touch;
	self.weapon	= it_weapon;
	self.netname	= it_netname;

	setmodel (self, it_model);
	setsize (self, '-16 -16 0', '16 16 56');

	StartItem();
};

/*QUAKED weapon_supershotgun (0 .5 .8) (-16 -16 0) (16 16 32)
*/
void ()
weapon_supershotgun =
{
	weapon_set ("progs/g_shot.mdl", IT_SUPER_SHOTGUN, "Double-barrelled Shotgun");
};

/*QUAKED weapon_nailgun (0 .5 .8) (-16 -16 0) (16 16 32)
*/
void ()
weapon_nailgun =
{
	weapon_set ("progs/g_nail.mdl", IT_NAILGUN, "Nailgun");
};

/*QUAKED weapon_supernailgun (0 .5 .8) (-16 -16 0) (16 16 32)
*/
void ()
weapon_supernailgun =
{
	weapon_set ("progs/g_nail2.mdl", IT_SUPER_NAILGUN, "Super Nailgun");
};

/*QUAKED weapon_grenadelauncher (0 .5 .8) (-16 -16 0) (16 16 32)
*/
void ()
weapon_grenadelauncher =
{
	weapon_set ("progs/g_rock.mdl", 3, "Grenade Launcher");
};

/*QUAKED weapon_rocketlauncher (0 .5 .8) (-16 -16 0) (16 16 32)
*/
void ()
weapon_rocketlauncher =
{
	weapon_set ("progs/g_rock2.mdl", 3, "Rocket Launcher");
};

/*QUAKED weapon_lightning (0 .5 .8) (-16 -16 0) (16 16 32)
*/
void ()
weapon_lightning =
{
	weapon_set ("progs/g_light.mdl", 3, "Thunderbolt");
};

/*
===============================================================================

AMMO

===============================================================================
*/

void ()
ammo_touch =
{
	local entity stemp;
	local float best, ammo_flag;

	if (other.classname != "player")
		return;

	if (gamemode == MODE_MATCH)
	{
		if (match.state <= 0)
			return;
	}

	if (other.health <= 0)
		return;
	if (other.runetype == RN_REQUIEM)
	{
		if (other.runevector_x > time)
			return;

		ammo_flag = 5;
	}
	else
		ammo_flag = self.aflag;

	// if the player was using his best weapon, change up to the new one if better
	stemp = self;
	self = other;
	best = W_BestWeapon ();
	self = stemp;

	// shotgun
	if (self.weapon == 1)
	{
		if (other.ammo_shells >= MAX_SHELLS)
			return;
		other.ammo_shells = other.ammo_shells + ammo_flag;
	}

	// spikes
	if (self.weapon == 2)
	{
		if (other.ammo_nails >= MAX_NAILS)
			return;
		other.ammo_nails = other.ammo_nails + ammo_flag;
	}

	// rockets
	if (self.weapon == 3)
	{
		if (other.ammo_rockets >= MAX_ROCKETS)
			return;
		other.ammo_rockets = other.ammo_rockets + ammo_flag;
	}

	// cells
	if (self.weapon == 4)
	{
		if (other.ammo_cells >= MAX_CELLS)
			return;
		other.ammo_cells = other.ammo_cells + ammo_flag;
	}

	bound_other_ammo ();

	if (!deathmatch & DM_DM_MASK)
	{
		sprint (other, "You got the ");
		sprint (other, self.netname);
		sprint (other, "\n");
	}
	// ammo touch sound
	item_sound (other, CHAN_ITEM, "weapons/lock4.wav", 1 , ATTN_NORM);

	// change to a better weapon if appropriate
	if (other.weapon == best)
	{
		stemp = self;
		self = other;
		set_weapon (W_BestWeapon ());
		self = stemp;
	}

	// if changed current ammo, update it
	stemp = self;
	self = other;
	set_current_ammo ();
	self = stemp;

	// remove it in single player, or setup for respawning in deathmatch
	if (other.runetype == RN_REQUIEM)
		other.runevector_x = time + RN_REQUIEM_RECHARGE;
	else
	{
		self.model = string_null;
		self.solid = SOLID_NOT;
		if (deathmatch & DM_RESPAWN)
			self.nextthink = time + AMMO_RESPAWN_TIME;
		self.think = SUB_regen;

		activator = other;
		SUB_UseTargets (); // fire all targets / killtargets
	}
};

float WEAPON_BIG2 = 1;

void (string it_model, float it_aflag, float it_weapon, string it_netname)
ammo_set =
{
	precache_model (it_model);

	if (gamemode == MODE_PRACTICE)
	{
		remove (self);
		return;
	}

	self.touch	= ammo_touch;
	self.aflag	= it_aflag;
	self.weapon	= it_weapon;
	self.netname	= it_netname;

	setmodel (self, it_model);
	setsize (self, VEC_ORIGIN, '32 32 56');

	StartItem ();
};

/*QUAKED item_shells (0 .5 .8) (0 0 0) (32 32 32) big
*/
void ()
item_shells =
{
	if (self.spawnflags & WEAPON_BIG2)
		ammo_set ("maps/b_shell1.bsp", 40, 1, "shells");
	else
		ammo_set ("maps/b_shell0.bsp", 20, 1, "shells");
};

/*QUAKED item_spikes (0 .5 .8) (0 0 0) (32 32 32) big
*/
void ()
item_spikes =
{
	if (self.spawnflags & WEAPON_BIG2)
		ammo_set ("maps/b_nail1.bsp", 50, 2, "nails");
	else
		ammo_set ("maps/b_nail0.bsp", 25, 2, "nails");
};

/*QUAKED item_rockets (0 .5 .8) (0 0 0) (32 32 32) big
*/
void ()
item_rockets =
{
	if (self.spawnflags & WEAPON_BIG2)
		ammo_set ("maps/b_rock1.bsp", 10, 3, "rockets");
	else
		ammo_set ("maps/b_rock0.bsp", 5, 3, "rockets");
};

/*QUAKED item_cells (0 .5 .8) (0 0 0) (32 32 32) big
*/
void ()
item_cells =
{
	if (self.spawnflags & WEAPON_BIG2)
		ammo_set ("maps/b_batt1.bsp", 12, 4, "cells");
	else
		ammo_set ("maps/b_batt0.bsp", 6, 4, "cells");
};

/*QUAKED item_weapon (0 .5 .8) (0 0 0) (32 32 32) shotgun rocket spikes big
DO NOT USE THIS!!!! IT WILL BE REMOVED!
*/

float WEAPON_SHOTGUN	= 1;
float WEAPON_ROCKET	= 2;
float WEAPON_SPIKES	= 4;
float WEAPON_BIG	= 8;


void ()
item_weapon =
{
	if (self.spawnflags & WEAPON_SHOTGUN)
	{
		self.spawnflags = self.spawnflags - WEAPON_SHOTGUN;	// remove old flag
		if (self.spawnflags & WEAPON_BIG)
		{
			self.spawnflags = self.spawnflags - WEAPON_BIG;	//remove old flag
			self.spawnflags = self.spawnflags | WEAPON_BIG2;
                }
		self.classname = "item_shells";
		item_shells();
	}
	else if (self.spawnflags & WEAPON_ROCKET)
	{
		self.spawnflags = self.spawnflags - WEAPON_ROCKET;	// remove old flag
		if (self.spawnflags & WEAPON_BIG)
		{
			self.spawnflags = self.spawnflags - WEAPON_BIG;	//remove old flag
			self.spawnflags = self.spawnflags | WEAPON_BIG2;
                }
		self.classname = "item_rockets";
		item_rockets();
	}
	else if (self.spawnflags & WEAPON_SPIKES)
	{
		self.spawnflags = self.spawnflags - WEAPON_SPIKES;	// remove old flag
		if (self.spawnflags & WEAPON_BIG)
		{
			self.spawnflags = self.spawnflags - WEAPON_BIG;	//remove old flag
			self.spawnflags = self.spawnflags | WEAPON_BIG2;
                }
		self.classname = "item_spikes";
		item_spikes();
	}
};

/*
===============================================================================

KEYS

===============================================================================
*/

void ()
key_touch =
{
	if (other.classname != "player")
		return;
	if (other.health <= 0)
		return;
	if (other.items & self.items)
		return;

	if (!deathmatch & DM_DM_MASK)
	{
		sprint (other, "You got the ");
		sprint (other, self.netname);
		sprint (other, "\n");
	}

	item_sound (other, CHAN_ITEM, self.noise, 1, ATTN_NORM);
	other.items = other.items | self.items;

	if (!coop)
	{
		self.solid = SOLID_NOT;
		self.model = string_null;
	}

	activator = other;
	SUB_UseTargets (); // fire all targets / killtargets
};

void ()
key_sound =
{
	if (world.worldtype == 0)
		precache_noise ("misc/medkey.wav");
	else if (world.worldtype == 1)
		precache_noise ("misc/runekey.wav");
	else if (world.worldtype == 2)
		precache_noise ("misc/basekey.wav");
};

void (string it_model, string it_netname, float it_key)
key_set =
{
	precache_model (it_model);
	key_sound ();

	self.touch	= key_touch;
	self.netname	= it_netname;
	self.items	= it_key;

	setmodel (self, it_model);
	setsize (self, '-16 -16 -24', '16 16 32');

	StartItem ();
};

/*QUAKED item_key1 (0 .5 .8) (-16 -16 -24) (16 16 32)
SILVER key
In order for keys to work
you MUST set your maps
worldtype to one of the
following:
0: medieval
1: metal
2: base
*/
void ()
item_key1 =
{
	if (deathmatch & DM_DM_MASK)
		remove (self);
	else if (world.worldtype == 0)
		key_set ("progs/w_s_key.mdl", "silver key", IT_KEY1);
	else if (world.worldtype == 1)
		key_set ("progs/m_s_key.mdl", "silver runekey", IT_KEY1);
	else if (world.worldtype == 2)
		key_set ("progs/b_s_key.mdl", "silver keycard", IT_KEY1);
};

/*QUAKED item_key2 (0 .5 .8) (-16 -16 -24) (16 16 32)
GOLD key
In order for keys to work
you MUST set your maps
worldtype to one of the
following:
0: medieval
1: metal
2: base
*/
void ()
item_key2 =
{
	if (deathmatch & DM_DM_MASK)
		remove (self);
	else if (world.worldtype == 0)
		key_set ("progs/w_g_key.mdl", "gold key", IT_KEY2);
	else if (world.worldtype == 1)
		key_set ("progs/m_g_key.mdl", "gold runekey", IT_KEY2);
	else if (world.worldtype == 2)
		key_set ("progs/b_g_key.mdl", "gold keycard", IT_KEY2);
};

/*
===============================================================================

END OF LEVEL RUNES

===============================================================================
*/

void ()
sigil_touch =
{
	if (other.classname != "player")
		return;

	if (other.health <= 0)
		return;

	centerprint (other, "You got the rune!");

	item_sound (other, CHAN_ITEM, self.noise, 1, ATTN_NORM);
	self.solid	= SOLID_NOT;
	self.model	= string_null;
	serverflags	= serverflags | (self.spawnflags & SERVERFLAGS_RUNE_MASK);
	self.classname	= string_null; // so rune doors won't find it

	activator	= other;
	SUB_UseTargets (); // fire all targets / killtargets
};

void (string it_model)
sigil_set =
{
	precache_model (it_model);
	precache_noise ("misc/runekey.wav");

	self.touch	= sigil_touch;

	setmodel (self, it_model);
	setsize (self, '-16 -16 -24', '16 16 32');

	StartItem ();
};

/*QUAKED item_sigil (0 .5 .8) (-16 -16 -24) (16 16 32) E1 E2 E3 E4
End of level sigil, pick up to end episode and return to jrstart.
*/
void ()
item_sigil =
{
	if (deathmatch & DM_DM_MASK)
		remove (self);
	else if (self.spawnflags & 1)
		sigil_set ("progs/end1.mdl");
	else if (self.spawnflags & 2)
		sigil_set ("progs/end2.mdl");
	else if (self.spawnflags & 4)
		sigil_set ("progs/end3.mdl");
	else if (self.spawnflags & 8)
		sigil_set ("progs/end4.mdl");
	else
		objerror ("no spawnflags");
};

/*
===============================================================================

POWERUPS

===============================================================================
*/

void ()
powerup_denied =
{
	local entity e;
	local float dist;

	// q3 style denied
	e = find (world, classname, "player");
	while (e)
	{
		// XXX I think dead people can still see this message, or there's a race.
		if (e != other && is_player_e (e) && e.health > 0)
		{
			dist = vlen (self.origin - e.origin);
			if (dist < 125)
				self_sprint (e, "\{141} \bdenied!\n");
		}
		e = find (e, classname, "player");
	}
};

void ()
powerup_touch =
{
	local float tell, n;

	if (other.classname != "player")
		return;

	if (gamemode == MODE_MATCH)
	{
		if (match.state <= 0)
			return;
	}

	if (other.health <= 0)
		return;

	if (deathmatch & DM_RESPAWN)
	{
		self.mdl = self.model;

		if (self.classname == "item_artifact_invulnerability"
				|| self.classname == "item_artifact_invisibility"
				|| (deathmatch & DM_LONG_QUAD_RESPAWN
				&& self.classname == "item_artifact_super_damage"))
			self.nextthink = time + SLOW_POWERUP_RESPAWN_TIME;
		else
			self.nextthink = time + FAST_POWERUP_RESPAWN_TIME;

		if ((self.classname == "item_artifact_super_damage"
				|| self.classname == "item_artifact_invulnerability")
				&& deathmatch & DM_RANDOM_POWERUP_RESPAWN)
		{
			n = ceil (random () * SLOW_POWERUP_RESPAWN_TIME);
			self.nextthink = self.nextthink + n;
		}

		self.think = SUB_regen;
	}

	spawn_protect_off_e (other);

	item_sound (other, CHAN_AUTO, self.noise, 1, ATTN_NORM);
	observer_sound (self.noise);
	self.solid = SOLID_NOT;
	other.items = other.items | self.items;
	self.model = string_null;

	tell = 0;
	if (self.classname == "item_artifact_envirosuit")
	{
		if (POWERUP_PICKUP_WARN & ITEM_SUIT)
			tell = 1;
		other.rad_time = -1;
		other.radsuit_finished = time + 30;
		other.aqstate = other.aqstate - other.aqstate & AQS_BURNING;
	}
	else if (self.classname == "item_artifact_invulnerability")
	{
		if (other.invincible_finished < time)
			Hat_Spawn (other, self.mdl, '0 0 35', VEC_ORIGIN, ITEM_PENT);
		if (POWERUP_PICKUP_WARN & ITEM_PENT)
			tell = 1;
		other.invincible_time = -1;
		other.invincible_finished = time + 30;
	}
	else if (self.classname == "item_artifact_invisibility")
	{
		if (POWERUP_PICKUP_WARN & ITEM_EYES)
			tell = 1;
		other.invisible_time = -1;
		other.invisible_finished = time + 30;
	}
	else if (self.classname == "item_artifact_super_damage")
	{
		if (other.super_damage_finished < time)
			Hat_Spawn (other, self.mdl, '0 0 30', VEC_ORIGIN, ITEM_QUAD);

		if (POWERUP_PICKUP_WARN & ITEM_QUAD)
			tell = 1;
		other.super_time = -1;
		other.super_damage_finished = time + 30;
		other.super_sound = time + 1;
	}

	if (!deathmatch & DM_DM_MASK)
	{
		sprint (other, "You got the ");
		sprint (other, self.netname);
		sprint (other, "\n");
	}
	else if (tell)
	{
		bprint (other.netname);
		bprint (" just picked up the ");
		bprint (self.netname);
		bprint ("\n");
	}
	else
	{
		sprint_obs2 (other.netname, " just picked up the ");
		sprint_obs2 (self.netname, "\n");
	}

	powerup_denied ();

	activator = other;
	SUB_UseTargets (); // fire all targets / killtargets
};

void (string it_model, string it_noise, string it_netname, float it_powerup)
powerup_set =
{
	precache_model (it_model);
	precache_noise (it_noise);

	self.touch	= powerup_touch;
	self.netname	= it_netname;
	self.items	= it_powerup;

	setmodel (self, it_model);
	setsize (self, '-16 -16 -24', '16 16 32');

	StartItem ();
};

float num_pent;

/*QUAKED item_artifact_invulnerability (0 .5 .8) (-16 -16 -24) (16 16 32)
Player is invulnerable for 30 seconds
*/
void ()
item_artifact_invulnerability =
{
	num_pent = num_pent + 1;
	if (deathmatch & DM_PENT_REPLACEMENT && num_pent > 1)
	{
		item_powerup_replacement (num_pent);
		return;
	}

	precache_sound ("items/protect2.wav");
	precache_sound ("items/protect3.wav");
	powerup_set ("progs/invulner.mdl", "items/protect.wav",
			"Pentagram of Protection", IT_INVULNERABILITY);
};

/*QUAKED item_artifact_envirosuit (0 .5 .8) (-16 -16 -24) (16 16 32)
Player takes no damage from water or slime for 30 seconds
*/
void ()
item_artifact_envirosuit =
{
	precache_sound ("items/suit2.wav");
	powerup_set ("progs/suit.mdl", "items/suit.wav", "Biosuit", IT_SUIT);
};

/*QUAKED item_artifact_invisibility (0 .5 .8) (-16 -16 -24) (16 16 32)
Player is invisible for 30 seconds
*/
void ()
item_artifact_invisibility =
{
	precache_sound ("items/inv2.wav");
	precache_sound ("items/inv3.wav");
	powerup_set ("progs/invisibl.mdl", "items/inv1.wav", "Ring of Shadows",
			IT_INVISIBILITY);
};

float num_quad;

/*QUAKED item_artifact_super_damage (0 .5 .8) (-16 -16 -24) (16 16 32)
The next attack from the player will do 4x damage
*/
void ()
item_artifact_super_damage =
{
	num_quad = num_quad + 1;
	if (deathmatch & DM_QUAD_REPLACEMENT && num_quad > 1)
	{
		item_powerup_replacement (num_quad);
		return;
	}

	precache_sound ("items/damage2.wav");
	precache_sound ("items/damage3.wav");
	powerup_set ("progs/quaddama.mdl", "items/damage.wav", "Quad Damage", IT_QUAD);
};

/*
===============================================================================

PLAYER BACKPACKS

===============================================================================
*/

void ()
BackpackTouch =
{
	local float best, old, new, acount;
	local entity stemp;

	if (other.classname != "player")
		return;

	if (gamemode == MODE_MATCH)
	{
		if (match.state <= 0)
			return;
	}

	if (gamemode & MODE_ARENA)
	{
		if (arena.state == -1)
			return;
	}

	if (other.health <= 0)
		return;

	acount = 0;
	sprint (other, "You get ");

	if (self.items)
		if ((other.items & self.items) == 0)
		{
			acount = 1;
			sprint (other, "the ");
			sprint (other, self.netname);
		}

	// if the player was using his best weapon, change up to the new one if better
	stemp = self;
	self = other;
	best = W_BestWeapon ();
	self = stemp;

	// change weapons
	other.ammo_shells = other.ammo_shells + self.ammo_shells;
	other.ammo_nails = other.ammo_nails + self.ammo_nails;
	other.ammo_rockets = other.ammo_rockets + self.ammo_rockets;
	other.ammo_cells = other.ammo_cells + self.ammo_cells;

	new = self.items;
	if (!new)
		new = other.weapon;
	old = other.items;
	other.items = other.items | new;

	bound_other_ammo ();

	if (self.ammo_shells)
	{
		if (acount)
			sprint (other, ", ");
		acount = 1;
		sprint_float (other, self.ammo_shells);
		sprint (other, " shells");
	}
	if (self.ammo_nails)
	{
		if (acount)
			sprint (other, ", ");
		acount = 1;
		sprint_float (other, self.ammo_nails);
		sprint (other, " nails");
	}
	if (self.ammo_rockets)
	{
		if (acount)
			sprint (other, ", ");
		acount = 1;
		sprint_float (other, self.ammo_rockets);
		sprint (other, " rockets");
	}
	if (self.ammo_cells)
	{
		if (acount)
			sprint (other, ", ");
		acount = 1;
		sprint_float (other, self.ammo_cells);
		sprint (other, " cells");
	}

	sprint (other, "\n");

	// backpack touch sound
	item_sound (other, CHAN_ITEM, "weapons/lock4.wav", 1, ATTN_NORM);

	// remove the backpack, change self to the player
	remove (self);
	self = other;

	// change to the weapon
	if (!deathmatch & DM_DM_MASK)
		set_weapon (new);
	else if (self.weapon == best)
		set_weapon (W_BestWeapon ());
	else
		set_current_ammo ();
};

/*
===============
DropBackpack
===============
*/
void ()
DropBackpack =
{
	local entity item;

	if (options & NO_BACKPACKS)
		return;

	if (gamemode == MODE_MATCH)
	{
		if (!match.state)
			return;
	}

	if (gamemode == MODE_PRACTICE)
		return;

	if (!(self.ammo_shells + self.ammo_nails + self.ammo_rockets + self.ammo_cells))
		return;	// nothing in it

	item		= spawn ();
	item.classname	= "backpack";
	item.origin	= self.origin - '0 0 24';
	item.owner	= self;

	item.items = self.weapon & WEAPON_NONALT_MASK;
	if (item.items == IT_AXE)
		item.netname = "Axe";
	else if (item.items == IT_SHOTGUN)
		item.netname = "Shotgun";
	else if (item.items == IT_SUPER_SHOTGUN)
		item.netname = "Double-barrelled Shotgun";
	else if (item.items == IT_NAILGUN)
		item.netname = "Nailgun";
	else if (item.items == IT_SUPER_NAILGUN)
		item.netname = "Super Nailgun";
	else if (item.items == IT_GRENADE_LAUNCHER)
		item.netname = "Grenade Launcher";
	else if (item.items == IT_ROCKET_LAUNCHER)
		item.netname = "Rocket Launcher";
	else if (item.items == IT_LIGHTNING)
		item.netname = "Thunderbolt";
	else
		item.netname = string_null;

	item.ammo_shells	= self.ammo_shells;
	item.ammo_nails		= self.ammo_nails;
	item.ammo_rockets	= self.ammo_rockets;
	item.ammo_cells		= self.ammo_cells;

	item.velocity_z = 300;
	item.velocity_x = -100 + (random () * 200);
	item.velocity_y = -100 + (random () * 200);

	item.touch	= BackpackTouch;
	item.flags	= FL_ITEM;
	item.solid	= SOLID_TRIGGER;
	item.movetype	= MOVETYPE_TOSS;
	item.mdl	= "progs/backpack.mdl";

	setmodel (item, item.mdl);
	setsize (item, '-16 -16 0', '16 16 56');

	item.cnt	= time + DROP_BACKPACK_DURATION;
	item.nextthink  = item.cnt - 3; // blink before removing
	item.think	= blink_item;
};

void (string type, float finish_time)
drop_powerup =
{
	local entity item;
	local float time_left;
	local string it_noise, it_model;

	if (gamemode == MODE_MATCH)
	{
		if (!match.state)
			return;
	}

	if (type == "quad")
	{
		it_noise = "items/damage.wav";
		it_model = "progs/quaddama.mdl";
	}
	else if (type == "ring")
	{
		it_noise = "items/inv1.wav";
		it_model = "progs/invisibl.mdl";
	}
	else if (type == "biosuit")
	{
		it_noise = "items/suit.wav";
		it_model = "progs/suit.mdl";
	}
	else if (type == "pentagram")
	{
		it_noise = "items/protect.wav";
		it_model = "progs/invulner.mdl";
	}
	else
		return;

	if (type != "biosuit")
	{
		time_left = ceil (finish_time - time);
		bprint (self.netname);
		bprint (" lost a ");
		bprint (type);
		bprint (" with ");
		bprint_float (time_left);
		bprint (" second");
		if (time_left != 1)
			bprint ("s");
		bprint (" remaining\n");
	}

	item		= spawn ();
	item.origin	= self.origin;
	item.velocity_z	= 300;
	item.velocity_x	= -100 + (random () * 200);
	item.velocity_y	= -100 + (random () * 200);

	item.netname	= type;
	item.flags	= FL_ITEM;
	item.solid	= SOLID_TRIGGER;
	item.movetype	= MOVETYPE_TOSS;
	item.noise	= it_noise;
	item.mdl	= it_model;

	setmodel (item, item.mdl);
	setsize (item, '-16 -16 -24', '16 16 32');

	item.cnt	= finish_time;
	item.touch	= drop_powerup_touch;
	item.nextthink	= item.cnt - 3;	// blink before removing
	item.think	= blink_item;
	item.classname	= "dropped_powerup"; // used by vote-powerup-drop
};

void ()
drop_powerup_touch =
{
	local float it, time_left;

	if (other.classname != "player")
		return;

	if (gamemode == MODE_MATCH)
	{
		if (!match.state)
			return;
	}

	if (other.health <= 0)
		return;

	if (self.netname == "quad")
	{
		it				= IT_QUAD;
		other.super_time		= -1;
		other.super_sound		= time + 1;
		if (other.super_damage_finished > 0)
		{
			other.super_damage_finished
				= other.super_damage_finished
					+ (self.cnt - time);
		}
		else
		{
			other.super_damage_finished = self.cnt;
			Hat_Spawn (other, self.mdl, '0 0 30', VEC_ORIGIN, ITEM_QUAD);
		}
	}
	else if (self.netname == "ring")
	{
		it				= IT_INVISIBILITY;
		other.invisible_time		= -1;
		if (other.invisible_finished > 0)
		{
			other.invisible_finished
				= other.invisible_finished
					+ (self.cnt - time);
		}
		else
			other.invisible_finished = self.cnt;
	}
	else if (self.netname == "biosuit")
	{
		it				= IT_SUIT;
		other.rad_time			= -1;
		if (other.radsuit_finished > 0)
		{
			other.radsuit_finished
				= other.radsuit_finished
					+ (self.cnt - time);
		}
		else
			other.radsuit_finished = self.cnt;
	}
	else if (self.netname == "pentagram")
	{
		it				= IT_INVULNERABILITY;
		other.invincible_time		= -1;
		if (other.invincible_finished > 0)
		{
			other.invincible_finished
				= other.invincible_finished
					+ (self.cnt - time);
		}
		else
		{
			other.invincible_finished = self.cnt;
			Hat_Spawn (other, self.mdl, '0 0 35', VEC_ORIGIN, ITEM_PENT);
		}
	}
	else
		return;

	spawn_protect_off_e (other);

 	item_sound (other, CHAN_AUTO, self.noise, 1, ATTN_NORM);
	self.solid	= SOLID_NOT;
	other.items	= other.items | it;
	self.model	= string_null;

	if (self.netname != "biosuit")
	{
		time_left = ceil (self.cnt - time);
		bprint (other.netname);
		bprint (" recovered a ");
		bprint (self.netname);
		bprint (" with ");
		bprint_float (time_left);
		bprint (" second");
		if (time_left != 1)
			bprint ("s");
		bprint (" remaining!\n");
	}

	powerup_denied ();

	activator = other;
	SUB_UseTargets (); // fire all targets / killtargets

	// XXX When a powerup is dropped again, blink_item() makes
	// both models flash.  I'm not sure why that happens but
	// I remove the entity now to prevent it.
	remove (self);
};

//
void ()
item_arena_rune =
{
	remove (self);
};
