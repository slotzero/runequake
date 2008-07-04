/*  $Id: toggle.qc,v 1.30 2008/07/04 04:27:56 slotzero Exp $

    Copyright (C) 2004  David 'Slot Zero' Roberts.

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

// types
//
// "item_artifact_super_damage"
// "item_artifact_invulnerability"
// "item_artifact_invisibility"
// "item_artifact_envirosuit"

void (string type, float mode)
toggle_powerup =
{
	local entity e;

	e = find (world, classname, type);
	while (e)
	{
		if (mode)
		{
			e.nextthink	= time;
			e.think		= SUB_regen;
		}
		else
		{
			e.model		= string_null;
			e.solid		= SOLID_NOT;
			e.nextthink	= -2;
		}
		e = find (e, classname, type);
	}
};

void ()
setquad =
{
	local float new_options;
	local string s;

	new_options = cvar_infokey (CVAR_C4);
	toggle_powerup ("item_artifact_super_damage", new_options & NO_QUAD);

	if (new_options & NO_QUAD)
		new_options = new_options - new_options & NO_QUAD;
	else
		new_options = new_options | NO_QUAD;

	s = ftos (new_options);
	options = new_options;
	cvar_set (CVAR_C4, s);
};

void ()
setpent =
{
	local float new_options;
	local string s;

	new_options = cvar_infokey (CVAR_C4);
	toggle_powerup ("item_artifact_invulnerability", new_options & NO_PENT);

	if (new_options & NO_PENT)
		new_options = new_options - new_options & NO_PENT;
	else
		new_options = new_options | NO_PENT;

	s = ftos (new_options);
	options = new_options;
	cvar_set (CVAR_C4, s);
};

void ()
setring =
{
	local float new_options;
	local string s;

	new_options = cvar_infokey (CVAR_C4);
	toggle_powerup ("item_artifact_invisibility", new_options & NO_RING);

	if (new_options & NO_RING)
		new_options = new_options - new_options & NO_RING;
	else
		new_options = new_options | NO_RING;

	s = ftos (new_options);
	options = new_options;
	cvar_set (CVAR_C4, s);
};

void ()
setsuit =
{
	local float new_options;
	local string s;

	new_options = cvar_infokey (CVAR_C4);
	toggle_powerup ("item_artifact_envirosuit", new_options & NO_SUIT);

	if (new_options & NO_SUIT)
		new_options = new_options - new_options & NO_SUIT;
	else
		new_options = new_options | NO_SUIT;

	s = ftos (new_options);
	options = new_options;
	cvar_set (CVAR_C4, s);
};

void (float mode)
toggle_armor =
{
	local entity e;

	e = find (world, netname, "item_armor_all");
	while (e)
	{
		if (mode)
		{
			e.skin		= e.impulse;
			e.runetype	= time;
			e.think		= SUB_regen;
			e.nextthink	= time;
		}
		else
		{
			e.solid		= SOLID_NOT;
			e.model		= string_null;
			e.nextthink	= -2;
		}
		e = find (e, netname, "item_armor_all");
	}
};

void ()
setarmor =
{
	local float new_options;
	local string s;

	new_options = cvar_infokey (CVAR_C4);
	toggle_armor (new_options & NO_ARMOR);

	if (new_options & NO_ARMOR)
		new_options = new_options - new_options & NO_ARMOR;
	else
		new_options = new_options | NO_ARMOR;

	s = ftos (new_options);
	options = new_options;
	cvar_set (CVAR_C4, s);
};

void ()
setrotate =
{
	local float new_options;
	local string s;

	if (options & NO_ARMOR)
		return;

	new_options = cvar_infokey (CVAR_C4);
	toggle_armor (1);

	if (new_options & ARMOR_ROTATE)
		new_options = new_options - new_options & ARMOR_ROTATE;
	else
		new_options = new_options | ARMOR_ROTATE;

	s = ftos (new_options);
	options = new_options;
	cvar_set (CVAR_C4, s);
};

void ()
setrunes =
{
	local entity e, os;
	local float new_options;
	local string s;

	new_options = cvar_infokey (CVAR_C4);

	if (new_options & NO_RUNES)
		new_options = new_options - new_options & NO_RUNES;
	else
		new_options = new_options | NO_RUNES;

	s = ftos (new_options);
	options = new_options;
	cvar_set (CVAR_C4, s);

	if (options & NO_RUNES)
	{
		runemax		= 0;
		runecurrent	= 0;
		remove_classname ("rune");

		e = find (world, classname, "player");
		while (e)
		{
			if (e.runetype)
			{
				os	= self;
				self	= e;

				Rune_Delete (0);

				self	= os;
			}
			e = find (e, classname, "player");
		}
	}
	else
	{
		set_runemax ();
		runespawntime	= time;
	}
};

void ()
setalts =
{
	local entity e, os;
	local float new_options;
	local string s;

	new_options = cvar_infokey (CVAR_C4);

	if (new_options & NO_ALT_WEAPONS)
		new_options = new_options - new_options & NO_ALT_WEAPONS;
	else
		new_options = new_options | NO_ALT_WEAPONS;

	s = ftos (new_options);
	options = new_options;
	cvar_set (CVAR_C4, s);

	if (options & NO_ALT_WEAPONS)
	{
		e = find (world, classname, "player");
		while (e)
		{
			os = self;
			self = e;
			if (self.weapon & WEAPON_ALT)
				set_weapon (W_BestWeapon ());
			self = os;
			e = find (e, classname, "player");
		}
	}
};

void ()
setshields =
{
	local float new_options;
	local string s;

	new_options = cvar_infokey (CVAR_C4);

	if (new_options & NO_SPAWN_SHIELDS)
		new_options = new_options - new_options & NO_SPAWN_SHIELDS;
	else
		new_options = new_options | NO_SPAWN_SHIELDS;

	s = ftos (new_options);
	options = new_options;
	cvar_set (CVAR_C4, s);
};

void ()
sethookdamage =
{
	local float new_options;
	local string s;

	new_options = cvar_infokey (CVAR_C4);

	if (new_options & NO_HOOK_DAMAGE)
		new_options = new_options - new_options & NO_HOOK_DAMAGE;
	else
		new_options = new_options | NO_HOOK_DAMAGE;

	s = ftos (new_options);
	options = new_options;
	cvar_set (CVAR_C4, s);
};

// -1 all
// 0 large health box
// 1 small health box
// 2 mega health box

void (string type, float bit, float mode)
toggle_health =
{
	local entity e;
	local float force;

	if (bit < 0)
		force = 1;

	e = find (world, classname, type);
	while (e)
	{
		if (e.spawnflags & bit || (!bit && !e.spawnflags) || force)
		{
			if (mode)
			{
				e.nextthink	= time;
				e.think		= SUB_regen;
			}
			else
			{
				e.model		= string_null;
				e.solid		= SOLID_NOT;
				e.nextthink	= -2;
			}
		}
		e = find (e, classname, type);
	}
};

void ()
setmega =
{
	local float new_options;
	local string s;

	new_options = cvar_infokey (CVAR_C4);
	toggle_health ("item_health", 2, new_options & NO_MEGA);

	if (new_options & NO_MEGA)
		new_options = new_options - new_options & NO_MEGA;
	else
		new_options = new_options | NO_MEGA;

	s = ftos (new_options);
	options = new_options;
	cvar_set (CVAR_C4, s);
};

void ()
toggle_weapons_stay =
{
	local entity e;
	local float new_deathmatch;
	local string s;

	new_deathmatch = cvar ("deathmatch");

	// XXX slow?  maybe assign second classname and use find?
	e = nextent (world);
	while (e)
	{
		if (e.touch == weapon_touch)
		{
			e.runetime	= time;
			e.think		= SUB_regen;
			e.nextthink	= time;

			if (new_deathmatch & DM_WEAPONS_STAY)
				setorigin (e, e.runevector);
			else
			{

				setorigin (e, e.runevector + '0 0 25');
			}
		}
		e = nextent (e);
	}

	if (new_deathmatch & DM_WEAPONS_STAY)
		new_deathmatch = new_deathmatch - new_deathmatch & DM_WEAPONS_STAY;
	else
		new_deathmatch = new_deathmatch | DM_WEAPONS_STAY;

	s = ftos (new_deathmatch);
	deathmatch = new_deathmatch;
	cvar_set ("deathmatch", s);
};

void ()
toggle_armor_drop =
{
	local float new_deathmatch;
	local string s;

	new_deathmatch = cvar ("deathmatch");

	if (new_deathmatch & DM_NO_DROP_ARMOR)
		new_deathmatch = new_deathmatch - new_deathmatch & DM_NO_DROP_ARMOR;
	else
	{
		new_deathmatch = new_deathmatch | DM_NO_DROP_ARMOR;
		remove_classname ("dropped_armor");
	}

	s = ftos (new_deathmatch);
	deathmatch = new_deathmatch;
	cvar_set ("deathmatch", s);
};

void ()
setfaststart =
{
	local float new_options;
	local string s;

	new_options = cvar_infokey (CVAR_C4);

	if (new_options & FASTSTART)
		new_options = new_options - new_options & FASTSTART;
	else
		new_options = new_options | FASTSTART;

	s = ftos (new_options);
	options = new_options;
	cvar_set (CVAR_C4, s);
};

void ()
setmatchlock =
{
	MATCHLOCK = !MATCHLOCK;
};

void ()
setbackpacks =
{
	local float new_options;
	local string s;

	new_options = cvar_infokey (CVAR_C4);

	if (new_options & NO_BACKPACKS)
		new_options = new_options - new_options & NO_BACKPACKS;
	else
		new_options = new_options | NO_BACKPACKS;

	if (new_options & NO_BACKPACKS)
		remove_classname ("backpack");

	s = ftos (new_options);
	options = new_options;
	cvar_set (CVAR_C4, s);
};

void ()
toggle_powerup_drop =
{
	local float new_deathmatch;
	local string s;

	new_deathmatch = cvar ("deathmatch");

	if (new_deathmatch & DM_NO_DROP_POWERUP)
		new_deathmatch = new_deathmatch - new_deathmatch & DM_NO_DROP_POWERUP;
	else
	{
		new_deathmatch = new_deathmatch | DM_NO_DROP_POWERUP;
		remove_classname ("dropped_powerup");
	}

	s = ftos (new_deathmatch);
	deathmatch = new_deathmatch;
	cvar_set ("deathmatch", s);
};

void ()
toggle_rune_drop =
{
	local entity e;
	local float new_temp1;
	local string s;

	new_temp1 = cvar ("temp1");

	if (new_temp1 & T1_NO_DROP_ON_DEATH)
		new_temp1 = new_temp1 - new_temp1 & T1_NO_DROP_ON_DEATH;
	else
	{
		new_temp1 = new_temp1 | T1_NO_DROP_ON_DEATH;

		e = find (world, classname, "rune");
		while (e)
		{
			e.owner = world;
			e.enemy = world;
			e = find (e, classname, "rune");
		}
	}

	s = ftos (new_temp1);
	temp1 = new_temp1;
	cvar_set ("temp1", s);
};

void ()
toggle_lightning_discharge =
{
	local float new_deathmatch;
	local string s;

	new_deathmatch = cvar ("deathmatch");

	if (new_deathmatch & DM_NO_DISCHARGE)
		new_deathmatch = new_deathmatch - new_deathmatch & DM_NO_DISCHARGE;
	else
		new_deathmatch = new_deathmatch | DM_NO_DISCHARGE;

	s = ftos (new_deathmatch);
	deathmatch = new_deathmatch;
	cvar_set ("deathmatch", s);
};

void ()
setclassicmega =
{
	local entity e;
	local float new_options;
	local string s;

	e = find (world, classname, "item_health");
	while (e)
	{
		if (e.spawnflags & H_MEGA)
		{
			if (e.owner)
				e.owner = world;

			if (e.nextthink > -2 && e.solid == SOLID_NOT)
			{
				e.nextthink = time;
				e.think = SUB_regen;
			}
		}
		e = find (e, classname, "item_health");
	}

	e = find (world, classname, "decay_health");
	while (e)
	{
		if (e.runevar > 1)
			e.runevar = 1;
		e = find (e, classname, "decay_health");
	}

	new_options = cvar_infokey (CVAR_C4);

	if (new_options & CLASSIC_MEGA)
		new_options = new_options - new_options & CLASSIC_MEGA;
	else
		new_options = new_options | CLASSIC_MEGA;

	s = ftos (new_options);
	options = new_options;
	cvar_set (CVAR_C4, s);
};

void ()
toggle_mode_lock =
{
	local float new_options;
	local string s;

	new_options = cvar_infokey (CVAR_C4);

	if (new_options & MODE_LOCKED)
		new_options = new_options - new_options & MODE_LOCKED;
	else
		new_options = new_options | MODE_LOCKED;

	s = ftos (new_options);
	options = new_options;
	cvar_set (CVAR_C4, s);
};
