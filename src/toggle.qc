/*  $Id: toggle.qc,v 1.2 2004/07/13 08:45:11 slotzero Exp $

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

float HUNK_NO_QUADS	= %1050;
float HUNK_NO_PENTS	= %1051;
float HUNK_NO_RINGS	= %1052;
float HUNK_NO_SUITS	= %1053;

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
			e.solid		= SOLID_NOT;
			e.model		= string_null;
			e.nextthink	= -1;
		}
		e = find (e, classname, type);
	}
};

void ()
setquad =
{
	toggle_powerup ("item_artifact_super_damage", NO_QUADS);
	NO_QUADS = !NO_QUADS;
	fput (HUNK_NO_QUADS, NO_QUADS);
};

void ()
setpent =
{
	toggle_powerup ("item_artifact_invulnerability", NO_PENTS);
	NO_PENTS = !NO_PENTS;
	fput (HUNK_NO_PENTS, NO_PENTS);
};

void ()
setring =
{
	toggle_powerup ("item_artifact_invisibility", NO_RINGS);
	NO_RINGS = !NO_RINGS;
	fput (HUNK_NO_RINGS, NO_RINGS);
};

void ()
setsuit =
{
	toggle_powerup ("item_artifact_envirosuit", NO_SUITS);
	NO_SUITS = !NO_SUITS;
	fput (HUNK_NO_SUITS, NO_SUITS);
};

void (float offset, float value)
fput =
{
	Write_Hunk_Float (HUNK_CONTEXT, offset, value);
};

//
// hunk settings
//

float (float offset, float default)
fget =
{
	local float i;

	i = Read_Hunk_Float (HUNK_CONTEXT, offset);
	if (i == 0x20202020)
	{
		fput (offset, default);
		return default;
	}

	return i;
};

void ()
Populate_Settings =
{
	NO_QUADS		= fget (HUNK_NO_QUADS,		0);
	NO_PENTS		= fget (HUNK_NO_PENTS,		0);
	NO_RINGS		= fget (HUNK_NO_RINGS,		0);
	NO_SUITS		= fget (HUNK_NO_SUITS,		0);
	NO_RUNES		= fget (HUNK_NO_RUNES,		0);

	// After settings have been populated, there are some take action on
	// those globals that require it.
	//
	// powerups are always on at the start of the level, so check to see if
	// they've been shut off.
	//
	// XXX The powerups aren't removed until almost 3 seconds after the level
	// loads.  If someone touches a powerup before then, they'll be able to
	// pick it up.  I could prevent players from touching the item until
	// 3 seconds after the level loads, but I'm wondering if there isn't
	// a better way to do this.
	if (NO_QUADS)
	{
		dprint_force ("Quad Damage disabled\n");
		toggle_powerup ("item_artifact_super_damage", 0);
	}
	if (NO_PENTS)
	{
		dprint_force ("Pentagram of Protection disabled\n");
		toggle_powerup ("item_artifact_invulnerability", 0);
	}
	if (NO_RINGS)
	{
		dprint_force ("Ring of Shadows disabled\n");
		toggle_powerup ("item_artifact_invisibility", 0);
	}
	if (NO_SUITS)
	{
		dprint_force ("Environmental Protection Suit disabled\n");
		toggle_powerup ("item_artifact_envirosuit", 0);
	}
};
