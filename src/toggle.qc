/*  $Id: toggle.qc,v 1.17 2005/04/30 07:52:55 slotzero Exp $

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
			e.nextthink	= -1;
		}
		e = find (e, classname, type);
	}
};

void ()
setquad =
{
	toggle_powerup ("item_artifact_super_damage", NO_QUAD);
	NO_QUAD = fput (HUNK_NO_QUAD, !NO_QUAD);
};

void ()
setpent =
{
	toggle_powerup ("item_artifact_invulnerability", NO_PENT);
	NO_PENT = fput (HUNK_NO_PENT, !NO_PENT);
};

void ()
setring =
{
	toggle_powerup ("item_artifact_invisibility", NO_RING);
	NO_RING = fput (HUNK_NO_RING, !NO_RING);
};

void ()
setsuit =
{
	toggle_powerup ("item_artifact_envirosuit", NO_SUIT);
	NO_SUIT = fput (HUNK_NO_SUIT, !NO_SUIT);
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
			e.nextthink	= -1;
		}
		e = find (e, netname, "item_armor_all");
	}
};

void ()
setarmor =
{
	toggle_armor (NO_ARMOR);
	NO_ARMOR = fput (HUNK_NO_ARMOR, !NO_ARMOR);
};

void ()
setrotate =
{
	if (NO_ARMOR)
		return;

	toggle_armor (1);
	ROTATE = fput (HUNK_ROTATE, !ROTATE);
};

void ()
setrunes =
{
	local entity e, os;

	NO_RUNES = fput (HUNK_NO_RUNES, !NO_RUNES);
	if (NO_RUNES)
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

	NO_ALT_WEAPONS = fput (HUNK_NO_ALT_WEAPONS, !NO_ALT_WEAPONS);
	if (NO_ALT_WEAPONS)
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
	NO_SPAWN_SHIELDS = fput (HUNK_NO_SPAWN_SHIELDS, !NO_SPAWN_SHIELDS);
};

void ()
sethookdamage =
{
	NO_HOOK_DAMAGE = fput (HUNK_NO_HOOK_DAMAGE, !NO_HOOK_DAMAGE);
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
				e.nextthink	= -1;
			}
		}
		e = find (e, classname, type);
	}
};

void ()
setmega =
{
	toggle_health ("item_health", 2, NO_MEGA);
	NO_MEGA = fput (HUNK_NO_MEGA, !NO_MEGA);
};

void ()
toggle_mode_midair =
{
	MODE_MIDAIR = fput (HUNK_MODE_MIDAIR, !MODE_MIDAIR);
};

void ()
toggle_weapons_stay =
{
	local float new_deathmatch;
	local string s;

	new_deathmatch = cvar ("deathmatch");

	if (new_deathmatch & DM_WEAPONS_STAY)
		new_deathmatch = new_deathmatch - new_deathmatch & DM_WEAPONS_STAY;
	else
		new_deathmatch = new_deathmatch | DM_WEAPONS_STAY;

	s = ftos (new_deathmatch);
	deathmatch = new_deathmatch;
	cvar_set ("deathmatch", s);
};
