// $Id: items.qc,v 1.5 2002/04/26 03:35:26 slotzero Exp $

/* ALL LIGHTS SHOULD BE 0 1 0 IN COLOR ALL OTHER ITEMS SHOULD
BE .8 .3 .4 IN COLOR */

void ()
SUB_regen =
{
	self.model = self.mdl;	// restore original model
	self.solid = SOLID_TRIGGER;	// allow it to be touched again
	sound (self, CHAN_VOICE, "items/itembk2.wav", 1, ATTN_NORM);	// play respawn sound
	setorigin (self, self.origin);
};

void (entity e, float chan, string samp, float vol, float atten)
item_sound =
{
	sound (e, chan, samp, vol, atten);
	stuffcmd (e, "bf\n");
	spawn_protect_off_e (e);
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
	local float old_z;

	self.mdl	= self.model;	// so it can be restored on respawn
	self.flags	= FL_ITEM;	// make extra wide
	self.solid	= SOLID_TRIGGER;
	self.movetype	= MOVETYPE_TOSS;
	self.velocity	= VEC_ORIGIN;
	self.origin_z	= self.origin_z + 6;
	old_z		= self.origin_z;

	if (!droptofloor (0, 0))
	{
		dprint ("Bonus item fell out of level at ");
		dprint (vtos (self.origin));
		dprint ("\n");
		remove (self);
		return;
	}
	// Get weapons up right away in weapons-stay mode.  Without this
	// they don't go up until after somebody gets them for the first
	// time (weapon_touch sets it up).  Since I have this init step
	// I set runevector here only.
	if (self.touch == weapon_touch)
	{
		// Save the origin no matter what in case DM_WEAPONS_STAY
		// is turned on later.
		self.runevector = self.origin;
		if (deathmatch & DM_WEAPONS_STAY || coop)
		{
			self.runetime = time;
			self.think = weapon_up;
			self.nextthink = time;
		}
	}
};

float did_my_items;

/*
============
StartItem

Sets the clipping size and plants the object on the floor
============
*/

void ()
StartItem =
{
	self.nextthink	= time + 0.2;	// items start after other solids
	self.think	= PlaceItem;
	if (!did_my_items)
	{
		did_my_items = 1;
		place_my_items ();
	}
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

float	H_ROTTEN = 1;
float	H_MEGA = 2;
.float	healamount, healtype;

void ()
item_health =
{
	self.touch = health_touch;

	if (self.spawnflags & H_ROTTEN)
	{
		precache_model ("maps/b_bh10.bsp");
		precache_sound ("items/r_item1.wav");
		setmodel (self, "maps/b_bh10.bsp");
		self.noise = "items/r_item1.wav";
		self.healamount = 15;
		self.healtype = 0;
	}
	else if (self.spawnflags & H_MEGA)
	{
		precache_model ("maps/b_bh100.bsp");
		precache_sound ("items/r_item2.wav");
		setmodel (self, "maps/b_bh100.bsp");
		self.noise = "items/r_item2.wav";
		self.healamount = 100;
		self.healtype = 2;
	}
	else
	{
		precache_model ("maps/b_bh25.bsp");
		precache_sound ("items/health1.wav");
		setmodel (self, "maps/b_bh25.bsp");
		self.noise = "items/health1.wav";
		self.healamount = 25;
		self.healtype = 1;
	}
	setsize (self, VEC_ORIGIN, '32 32 56');
	StartItem ();
};

void ()
health_touch =
{
	local float is_mega, amount;
	local string s;

	if (other.classname != "player")
		return;

	is_mega = self.healtype == 2;
	amount = self.healamount;
	s = self.noise;
	// Vampires only get 5 health from non-mega health boxes.
	if (!is_mega && other.runetype == RN_VAMP)
	{
		amount = 5;
		s = "items/r_item1.wav";
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

	self.model = string_null;
	self.solid = SOLID_NOT;

	// Set up a health decaying entity for megahealth if necessary.
	if (is_mega)
		decay_health_spawn (other, 1);
	if (deathmatch & DM_RESPAWN)
	{
		if (is_mega)
			self.nextthink = time + MEGAHEALTH_RESPAWN_TIME;
		else
			self.nextthink = time + HEALTH_RESPAWN_TIME;
		self.think = SUB_regen;
	}

	activator = other;
	SUB_UseTargets ();				// fire all targets / killtargets
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

	if (self.runevar)
	{
		type	= self.armortype;
		value	= self.armorvalue;
		bit	= self.aqstate;
	}
	else if (self.classname == "item_armor1")
	{
		type	= ARMOR_TYPE_1;
		value	= MAX_ARMOR_1;
		bit	= IT_ARMOR1;
	}
	else if (self.classname == "item_armor2")
	{
		type	= ARMOR_TYPE_2;
		value	= MAX_ARMOR_2;
		bit	= IT_ARMOR2;
	}
	else if (self.classname == "item_armorInv")
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
	else if (other_tot >= this_tot)
		return;

	if (other.runetype == RN_ARMOR)
	{
		other.armortype		= ARMOR_TYPE_3;
		other.armorvalue	= other.armorvalue + value;
	}
	else
	{
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

	// Stop burning, for levels with no water.
	other.aqstate = other.aqstate - other.aqstate & AQS_BURNING;

	activator = other;
	SUB_UseTargets ();				// fire all targets / killtargets
};

void (float armor_skin)
item_armor =
{
	self.touch	= armor_touch;
	self.skin	= armor_skin;
	setmodel (self, "progs/armor.mdl");
	setsize (self, '-16 -16 0', '16 16 56');
	StartItem ();
};

/*QUAKED item_armor1 (0 .5 .8) (-16 -16 0) (16 16 32)
*/
void ()
item_armor1 =
{
	item_armor (0);
};

/*QUAKED item_armor2 (0 .5 .8) (-16 -16 0) (16 16 32)
*/
void ()
item_armor2 =
{
	item_armor (1);
};

/*QUAKED item_armorInv (0 .5 .8) (-16 -16 0) (16 16 32)
*/

void ()
item_armorInv =
{
	item_armor (2);
};

void ()
drop_armor =
{
	local entity e;

	e		= spawn ();
	e.runevar	= 1;
	e.classname	= "dropped_armor";
	e.armortype	= self.armortype;
	e.armorvalue	= self.armorvalue;
	e.origin	= self.origin;
	e.velocity_z	= 300;
	e.velocity_x	= -100 + (random () * 200);
	e.velocity_y	= -100 + (random () * 200);
	e.flags		= FL_ITEM;
	e.solid		= SOLID_TRIGGER;
	e.movetype	= MOVETYPE_TOSS;
	e.mdl		= "progs/armor.mdl";
	setmodel (e, e.mdl);

	e.aqstate = armor_type_to_it (e.armortype);
	if (e.aqstate == IT_ARMOR1)		{ e.skin = 0; }
	else if (e.aqstate == IT_ARMOR2)	{ e.skin = 1; }
	else if (e.aqstate == IT_ARMOR3)	{ e.skin = 2; }
	else
	{
		remove (e);
		return;
	}

	setsize (e, '-16 -16 0', '16 16 56');
	e.touch = armor_touch;
	e.nextthink = time + DROP_ARMOR_DURATION;
	e.think = SUB_Remove;
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

/* float (float w) RankForWeapon =
{
	if (w == IT_LIGHTNING)
		return 1;
	if (w == IT_ROCKET_LAUNCHER)
		return 2;
	if (w == IT_SUPER_NAILGUN)
		return 3;
	if (w == IT_GRENADE_LAUNCHER)
		return 4;
	if (w == IT_SUPER_SHOTGUN)
		return 5;
	if (w == IT_NAILGUN)
		return 6;
	return 7;
};
*/

/*
=============
Deathmatch_Weapon

Deathmatch weapon change rules for picking up a weapon

.float		ammo_shells, ammo_nails, ammo_rockets, ammo_cells;
=============
*/
/*void (float old, float new) Deathmatch_Weapon =
{
	local float or, nr;

	// change self.weapon if desired
	or = RankForWeapon (self.weapon);
	nr = RankForWeapon (new);
	if (nr < or)
		set_weapon (new);
};
*/

/*
=============
weapon_touch
=============
*/

void ()
weapon_touch =
{
	local float charged, hadammo, best, new, old, leave;
	local entity stemp;

	if (!other.flags & FL_CLIENT)
		return;

	// if the player was using his best weapon, change up to the new
	// one if better
	stemp = self;
	self = other;
	best = W_BestWeapon ();
	self = stemp;

	charged = time >= self.runetime;
	if (deathmatch & DM_WEAPONS_STAY || coop)
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
			setorigin (self, self.runevector);
			self.runetime = time + WEAPON_RESPAWN_TIME;
			self.think = weapon_up;
			self.nextthink = self.runetime;
		}
		return;
	}

	// remove it in single player, or setup for respawning in deathmatch
	self.model = string_null;
	self.solid = SOLID_NOT;
	if (deathmatch & DM_RESPAWN)
		self.nextthink = time + WEAPON_RESPAWN_TIME;
	self.think = SUB_regen;

	activator = other;
	SUB_UseTargets ();				// fire all targets / killtargets
};

void ()
weapon_up =
{
	if (deathmatch & DM_WEAPONS_STAY || coop)
	{
		setorigin (self, self.runevector + '0 0 25');
		// Keep on moving it due to the rocket in the squish
		// room in Hell's Atrium (the squishing ceiling moves it
		// down to the floor).
		self.nextthink = time + 5;
	}
};

/*QUAKED weapon_supershotgun (0 .5 .8) (-16 -16 0) (16 16 32)
*/

void ()
weapon_supershotgun =
{
	if (!spawn_no_precache)
		precache_model ("progs/g_shot.mdl");
	setmodel (self, "progs/g_shot.mdl");
	self.weapon = IT_SUPER_SHOTGUN;
	self.netname = "Double-barrelled Shotgun";
	self.touch = weapon_touch;
	setsize (self, '-16 -16 0', '16 16 56');
	StartItem ();
};

/*QUAKED weapon_nailgun (0 .5 .8) (-16 -16 0) (16 16 32)
*/

void ()
weapon_nailgun =
{
	if (!spawn_no_precache)
		precache_model ("progs/g_nail.mdl");
	setmodel (self, "progs/g_nail.mdl");
	self.weapon = IT_NAILGUN;
	self.netname = "nailgun";
	self.touch = weapon_touch;
	setsize (self, '-16 -16 0', '16 16 56');
	StartItem ();
};

/*QUAKED weapon_supernailgun (0 .5 .8) (-16 -16 0) (16 16 32)
*/

void ()
weapon_supernailgun =
{
	if (!spawn_no_precache)
		precache_model ("progs/g_nail2.mdl");
	setmodel (self, "progs/g_nail2.mdl");
	self.weapon = IT_SUPER_NAILGUN;
	self.netname = "Super Nailgun";
	self.touch = weapon_touch;
	setsize (self, '-16 -16 0', '16 16 56');
	StartItem ();
};

/*QUAKED weapon_grenadelauncher (0 .5 .8) (-16 -16 0) (16 16 32)
*/

void ()
weapon_grenadelauncher =
{
	if (!spawn_no_precache)
		precache_model ("progs/g_rock.mdl");
	setmodel (self, "progs/g_rock.mdl");
	self.weapon = 3;
	self.netname = "Grenade Launcher";
	self.touch = weapon_touch;
	setsize (self, '-16 -16 0', '16 16 56');
	StartItem ();
};

/*QUAKED weapon_rocketlauncher (0 .5 .8) (-16 -16 0) (16 16 32)
*/

void ()
weapon_rocketlauncher =
{
	if (!spawn_no_precache)
		precache_model ("progs/g_rock2.mdl");
	setmodel (self, "progs/g_rock2.mdl");
	self.weapon = 3;
	self.netname = "Rocket Launcher";
	self.touch = weapon_touch;
	setsize (self, '-16 -16 0', '16 16 56');
	StartItem ();
};

/*QUAKED weapon_lightning (0 .5 .8) (-16 -16 0) (16 16 32)
*/

void ()
weapon_lightning =
{
	if (!spawn_no_precache)
		precache_model ("progs/g_light.mdl");
	setmodel (self, "progs/g_light.mdl");
	self.weapon = 3;
	self.netname = "Thunderbolt";
	self.touch = weapon_touch;
	setsize (self, '-16 -16 0', '16 16 56');
	StartItem ();
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
	local float best;

	if (other.classname != "player")
		return;
	if (other.health <= 0)
		return;

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
		other.ammo_shells = other.ammo_shells + self.aflag;
	}

	// spikes
	if (self.weapon == 2)
	{
		if (other.ammo_nails >= MAX_NAILS)
			return;
		other.ammo_nails = other.ammo_nails + self.aflag;
	}

	// rockets
	if (self.weapon == 3)
	{
		if (other.ammo_rockets >= MAX_ROCKETS)
			return;
		other.ammo_rockets = other.ammo_rockets + self.aflag;
	}

	// cells
	if (self.weapon == 4)
	{
		if (other.ammo_cells >= MAX_CELLS)
			return;
		other.ammo_cells = other.ammo_cells + self.aflag;
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
	self.model = string_null;
	self.solid = SOLID_NOT;
	if (deathmatch & DM_RESPAWN)
		self.nextthink = time + AMMO_RESPAWN_TIME;
	self.think = SUB_regen;

	activator = other;
	SUB_UseTargets ();				// fire all targets / killtargets
};

float WEAPON_BIG2 = 1;

/*QUAKED item_shells (0 .5 .8) (0 0 0) (32 32 32) big
*/

void ()
item_shells =
{
	self.touch = ammo_touch;

	if (self.spawnflags & WEAPON_BIG2)
	{
		precache_model ("maps/b_shell1.bsp");
		setmodel (self, "maps/b_shell1.bsp");
		self.aflag = 40;
	}
	else
	{
		precache_model ("maps/b_shell0.bsp");
		setmodel (self, "maps/b_shell0.bsp");
		self.aflag = 20;
	}
	self.weapon = 1;
	self.netname = "shells";
	setsize (self, VEC_ORIGIN, '32 32 56');
	StartItem ();
};

/*QUAKED item_spikes (0 .5 .8) (0 0 0) (32 32 32) big
*/

void ()
item_spikes =
{
	self.touch = ammo_touch;

	if (self.spawnflags & WEAPON_BIG2)
	{
		precache_model ("maps/b_nail1.bsp");
		setmodel (self, "maps/b_nail1.bsp");
		self.aflag = 50;
	}
	else
	{
		precache_model ("maps/b_nail0.bsp");
		setmodel (self, "maps/b_nail0.bsp");
		self.aflag = 25;
	}
	self.weapon = 2;
	self.netname = "nails";
	setsize (self, VEC_ORIGIN, '32 32 56');
	StartItem ();
};

/*QUAKED item_rockets (0 .5 .8) (0 0 0) (32 32 32) big
*/

void ()
item_rockets =
{
	self.touch = ammo_touch;

	if (self.spawnflags & WEAPON_BIG2)
	{
		precache_model ("maps/b_rock1.bsp");
		setmodel (self, "maps/b_rock1.bsp");
		self.aflag = 10;
	}
	else
	{
		precache_model ("maps/b_rock0.bsp");
		setmodel (self, "maps/b_rock0.bsp");
		self.aflag = 5;
	}
	self.weapon = 3;
	self.netname = "rockets";
	setsize (self, VEC_ORIGIN, '32 32 56');
	StartItem ();
};

/*QUAKED item_cells (0 .5 .8) (0 0 0) (32 32 32) big
*/

void ()
item_cells =
{
	self.touch = ammo_touch;

	if (self.spawnflags & WEAPON_BIG2)
	{
		precache_model ("maps/b_batt1.bsp");
		setmodel (self, "maps/b_batt1.bsp");
		self.aflag = 12;
	}
	else
	{
		precache_model ("maps/b_batt0.bsp");
		setmodel (self, "maps/b_batt0.bsp");
		self.aflag = 6;
	}
	self.weapon = 4;
	self.netname = "cells";
	setsize (self, VEC_ORIGIN, '32 32 56');
	StartItem ();
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
	self.touch = ammo_touch;

	if (self.spawnflags & WEAPON_SHOTGUN)
	{
		if (self.spawnflags & WEAPON_BIG)
		{
			precache_model ("maps/b_shell1.bsp");
			setmodel (self, "maps/b_shell1.bsp");
			self.aflag = 40;
		}
		else
		{
			precache_model ("maps/b_shell0.bsp");
			setmodel (self, "maps/b_shell0.bsp");
			self.aflag = 20;
		}
		self.weapon = 1;
		self.netname = "shells";
	}

	if (self.spawnflags & WEAPON_SPIKES)
	{
		if (self.spawnflags & WEAPON_BIG)
		{
			precache_model ("maps/b_nail1.bsp");
			setmodel (self, "maps/b_nail1.bsp");
			self.aflag = 40;
		}
		else
		{
			precache_model ("maps/b_nail0.bsp");
			setmodel (self, "maps/b_nail0.bsp");
			self.aflag = 20;
		}
		self.weapon = 2;
		self.netname = "spikes";
	}

	if (self.spawnflags & WEAPON_ROCKET)
	{
		if (self.spawnflags & WEAPON_BIG)
		{
			precache_model ("maps/b_rock1.bsp");
			setmodel (self, "maps/b_rock1.bsp");
			self.aflag = 10;
		}
		else
		{
			precache_model ("maps/b_rock0.bsp");
			setmodel (self, "maps/b_rock0.bsp");
			self.aflag = 5;
		}
		self.weapon = 3;
		self.netname = "rockets";
	}

	setsize (self, VEC_ORIGIN, '32 32 56');
	StartItem ();
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
	SUB_UseTargets ();				// fire all targets / killtargets
};

void ()
key_setsounds =
{
	if (world.worldtype == 0)
	{
		precache_sound ("misc/medkey.wav");
		self.noise = "misc/medkey.wav";
	}
	if (world.worldtype == 1)
	{
		precache_sound ("misc/runekey.wav");
		self.noise = "misc/runekey.wav";
	}
	if (world.worldtype == 2)
	{
		precache_sound2 ("misc/basekey.wav");
		self.noise = "misc/basekey.wav";
	}
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
	if (world.worldtype == 0)
	{
		precache_model ("progs/w_s_key.mdl");
		setmodel (self, "progs/w_s_key.mdl");
		self.netname = "silver key";
	}
	else if (world.worldtype == 1)
	{
		precache_model ("progs/m_s_key.mdl");
		setmodel (self, "progs/m_s_key.mdl");
		self.netname = "silver runekey";
	}
	else if (world.worldtype == 2)
	{
		precache_model2 ("progs/b_s_key.mdl");
		setmodel (self, "progs/b_s_key.mdl");
		self.netname = "silver keycard";
	}
	key_setsounds ();
	self.touch = key_touch;
	self.items = IT_KEY1;
	setsize (self, '-16 -16 -24', '16 16 32');
	StartItem ();
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
	if (world.worldtype == 0)
	{
		precache_model ("progs/w_g_key.mdl");
		setmodel (self, "progs/w_g_key.mdl");
		self.netname = "gold key";
	}
	if (world.worldtype == 1)
	{
		precache_model ("progs/m_g_key.mdl");
		setmodel (self, "progs/m_g_key.mdl");
		self.netname = "gold runekey";
	}
	if (world.worldtype == 2)
	{
		precache_model2 ("progs/b_g_key.mdl");
		setmodel (self, "progs/b_g_key.mdl");
		self.netname = "gold keycard";
	}
	key_setsounds ();
	self.touch = key_touch;
	self.items = IT_KEY2;
	setsize (self, '-16 -16 -24', '16 16 32');
	StartItem ();
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
	self.solid = SOLID_NOT;
	self.model = string_null;
	serverflags = serverflags | (self.spawnflags & SERVERFLAGS_RUNE_MASK);
	self.classname = string_null;		// so rune doors won't find it

	activator = other;
	SUB_UseTargets ();				// fire all targets / killtargets
};

/*QUAKED item_sigil (0 .5 .8) (-16 -16 -24) (16 16 32) E1 E2 E3 E4
End of level sigil, pick up to end episode and return to jrstart.
*/

void ()
item_sigil =
{
	if (!self.spawnflags)
		objerror ("no spawnflags");

	precache_sound ("misc/runekey.wav");
	self.noise = "misc/runekey.wav";

	if (self.spawnflags & 1)
	{
		precache_model ("progs/end1.mdl");
		setmodel (self, "progs/end1.mdl");
	}
	if (self.spawnflags & 2)
	{
		precache_model2 ("progs/end2.mdl");
		setmodel (self, "progs/end2.mdl");
	}
	if (self.spawnflags & 4)
	{
		precache_model2 ("progs/end3.mdl");
		setmodel (self, "progs/end3.mdl");
	}
	if (self.spawnflags & 8)
	{
		precache_model2 ("progs/end4.mdl");
		setmodel (self, "progs/end4.mdl");
	}

	self.touch = sigil_touch;
	setsize (self, '-16 -16 -24', '16 16 32');
	StartItem ();
};

/*
===============================================================================

POWERUPS

===============================================================================
*/

void ()
powerup_touch =
{
	local float tell, n;

	if (other.classname != "player")
		return;
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
				&& RANDOM_POWERUP_RESPAWN)
		{
			n = ceil (random () * 5 * 60);
			self.nextthink = self.nextthink + n;
		}

		self.think = SUB_regen;
	}

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
		observer_sprint2 (other.netname, " just picked up the ");
		observer_sprint2 (self.netname, "\n");
	}

	activator = other;
	SUB_UseTargets ();				// fire all targets / killtargets
};

float num_pent;

/*QUAKED item_artifact_invulnerability (0 .5 .8) (-16 -16 -24) (16 16 32)
Player is invulnerable for 30 seconds
*/
void ()
item_artifact_invulnerability =
{
	num_pent = num_pent + 1;
	if (deathmatch & DM_PENT_REPLACEMENT && num_pent > 1) {
		item_powerup_replacement (num_pent);
		return;
	}

	self.touch = powerup_touch;

	precache_model ("progs/invulner.mdl");
	precache_sound ("items/protect.wav");
	precache_sound ("items/protect2.wav");
	precache_sound ("items/protect3.wav");
	self.noise = "items/protect.wav";
	setmodel (self, "progs/invulner.mdl");
	self.netname = "Pentagram of Protection";
	self.items = IT_INVULNERABILITY;
	setsize (self, '-16 -16 -24', '16 16 32');
	StartItem ();
};

/*QUAKED item_artifact_envirosuit (0 .5 .8) (-16 -16 -24) (16 16 32)
Player takes no damage from water or slime for 30 seconds
*/
void ()
item_artifact_envirosuit =
{
	self.touch = powerup_touch;

	precache_model ("progs/suit.mdl");
	precache_sound ("items/suit.wav");
	precache_sound ("items/suit2.wav");
	self.noise = "items/suit.wav";
	setmodel (self, "progs/suit.mdl");
	self.netname = "Biosuit";
	self.items = IT_SUIT;
	setsize (self, '-16 -16 -24', '16 16 32');
	StartItem ();
};

/*QUAKED item_artifact_invisibility (0 .5 .8) (-16 -16 -24) (16 16 32)
Player is invisible for 30 seconds
*/
void ()
item_artifact_invisibility =
{
	self.touch = powerup_touch;

	precache_model ("progs/invisibl.mdl");
	precache_sound ("items/inv1.wav");
	precache_sound ("items/inv2.wav");
	precache_sound ("items/inv3.wav");
	self.noise = "items/inv1.wav";
	setmodel (self, "progs/invisibl.mdl");
	self.netname = "Ring of Shadows";
	self.items = IT_INVISIBILITY;
	setsize (self, '-16 -16 -24', '16 16 32');
	StartItem ();
};

float num_quad;

/*QUAKED item_artifact_super_damage (0 .5 .8) (-16 -16 -24) (16 16 32)
The next attack from the player will do 4x damage
*/
void ()
item_artifact_super_damage =
{
	num_quad = num_quad + 1;
	if (deathmatch & DM_QUAD_REPLACEMENT && num_quad > 1) {
		item_powerup_replacement (num_quad);
		return;
	}

	self.touch = powerup_touch;

	precache_model ("progs/quaddama.mdl");
	precache_sound ("items/damage.wav");
	precache_sound ("items/damage2.wav");
	precache_sound ("items/damage3.wav");
	self.noise = "items/damage.wav";
	setmodel (self, "progs/quaddama.mdl");
	self.netname = "Quad Damage";
	self.items = IT_QUAD;
	setsize (self, '-16 -16 -24', '16 16 32');
	StartItem ();
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

	if (!deathmatch & DM_NO_DROP_ARMOR && self.armorvalue > 0)
		drop_armor ();

	if (!(self.ammo_shells + self.ammo_nails + self.ammo_rockets + self.ammo_cells))
		return;	// nothing in it

	item = spawn ();
	item.classname = "backpack";
	item.origin = self.origin - '0 0 24';
	item.owner = self;

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

	item.ammo_shells = self.ammo_shells;
	item.ammo_nails = self.ammo_nails;
	item.ammo_rockets = self.ammo_rockets;
	item.ammo_cells = self.ammo_cells;

	item.velocity_z = 300;
	item.velocity_x = -100 + (random () * 200);
	item.velocity_y = -100 + (random () * 200);

	item.flags = FL_ITEM;
	item.solid = SOLID_TRIGGER;
	item.movetype = MOVETYPE_TOSS;
	setmodel (item, "progs/backpack.mdl");
	setsize (item, '-16 -16 0', '16 16 56');
	item.touch = BackpackTouch;

	item.nextthink = time + DROP_BACKPACK_DURATION;
	item.think = SUB_Remove;
};

void (string type, float finish_time)
drop_powerup =
{
	local entity item;
	local float time_left;
	local string it_noise, it_model;

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
	item.nextthink	= item.cnt;	// remove it with the time left on it
	item.think	= SUB_Remove;
};

void ()
drop_powerup_touch =
{
	local float it, time_left;

	if (other.classname != "player")
		return;

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
			other.super_damage_finished = self.cnt;
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
			other.invincible_finished = self.cnt;
	}
	else
		return;

 	item_sound (other, CHAN_AUTO, self.noise, 1, ATTN_NORM);
	self.solid = SOLID_NOT;
	other.items = other.items | it;
	self.model = string_null;

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

	activator = other;
	SUB_UseTargets ();	// fire all targets / killtargets
};
