/*  $Id: develop.qc,v 1.73 2004/07/12 04:57:24 slotzero Exp $

    Copyright (C) 2003  David 'Slot Zero' Roberts.

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

//-------------------------------------------------------------------
// DEVELOPMENT FUNCTIONS
//-------------------------------------------------------------------

float DEVELOPER_MODE = 0;

void (.float field, float bit)
remove_bit_from_players =
{
	local entity e;

	e = find (world, classname, "player");
	while (e)
	{
		e.field = e.field - e.field & bit;
		e = find (e, classname, "player");
	}
};

void ()
ghost_check =
{	IN_QW(return;)
	local entity e, os;

	e = find (world, classname, "player");
	while (e)
	{
		if (!e.cl[CL_ACTIVE])
		{
			os = self;
			self = e;
			bprint ("Ghost Player");
			ClientDisconnect ();
			self = os;
		}

		e = find (e, classname, "player");
	}
};

float ()
maxplayers =
{
	local entity e;
	local float i;

	e = nextent (world);
	for (i = 0; i < 16; i = i + 1)
	{
		if (e.classname == "bodyque")
			return i;
		e = nextent (e);
	}
	return 16;
};

void ()
ring_on =
{
	local entity e;

	e = find (world, classname, "item_artifact_invisibility");
	while (e)
	{
				e = find (e, #, #);
	}
};

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

float HUNK_NO_QUADS	= %1050;
float HUNK_NO_PENTS	= %1051;
float HUNK_NO_RINGS	= %1052;
float HUNK_NO_SUITS	= %1053;

float HUNK_NO_RUNES	= %1060;

void ()
setquad =
{
	NO_QUADS = !NO_QUADS;
	toggle_powerup ("item_artifact_super_damage", !NO_QUADS);
	fput (HUNK_NO_QUADS, NO_QUADS);
};

void ()
setpent =
{
	NO_PENTS = !NO_PENTS;
	toggle_powerup ("item_artifact_invulnerability", !NO_PENTS);
	fput (HUNK_NO_PENTS, NO_PENTS);
};

void ()
setring =
{
	NO_RINGS = !NO_RINGS;
	toggle_powerup ("item_artifact_invisibility", !NO_RINGS);
	fput (HUNK_NO_RINGS, NO_RINGS);
};

void ()
setsuit =
{
	NO_SUITS = !NO_SUITS;
	toggle_powerup ("item_artifact_envirosuit", !NO_SUITS);
	fput (HUNK_NO_SUITS, NO_SUITS);
};

void ()
setrunes =
{

};

void (float offset, float value)
fput =
{
	Write_Hunk_Float (HUNK_CONTEXT, offset, value);
};

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
	// NO_RUNES		= fget (HUNK_NO_RUNES,		0);

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

void ()
Test_Button =
{
	SUB_Null ();
};
