/*  $Id: toggle.qc,v 1.7 2004/07/16 12:11:47 slotzero Exp $

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

/* void (float offset, float value)
fput =
{
	Write_Hunk_Float (HUNK_CONTEXT, offset, value);
}; */

/* float (float offset, float default)
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
}; */

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
	toggle_powerup ("item_artifact_super_damage", voteflags & C3_NO_QUAD);
	voteflags = toggle_cvar_bit (CVAR_C3, C3_NO_QUAD);
};

void ()
setpent =
{
	toggle_powerup ("item_artifact_invulnerability", voteflags & C3_NO_PENT);
	voteflags = toggle_cvar_bit (CVAR_C3, C3_NO_PENT);
};

void ()
setring =
{
	toggle_powerup ("item_artifact_invisibility", voteflags & C3_NO_RING);
	voteflags = toggle_cvar_bit (CVAR_C3, C3_NO_RING);
};

void ()
setsuit =
{
	toggle_powerup ("item_artifact_envirosuit", voteflags & C3_NO_SUIT);
	voteflags = toggle_cvar_bit (CVAR_C3, C3_NO_SUIT);
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
	toggle_armor (voteflags & C3_NO_ARMOR);
	voteflags = toggle_cvar_bit (CVAR_C3, C3_NO_ARMOR);
};

void ()
setrotate =
{
	if (voteflags & C3_NO_ARMOR)
		return;

	toggle_armor (1);
	voteflags = toggle_cvar_bit (CVAR_C3, C3_ROTATE);
};

void ()
setrunes =
{
	local entity e, os;

	voteflags = toggle_cvar_bit (CVAR_C3, C3_NO_RUNES);
	if (voteflags & C3_NO_RUNES)
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
		runemax = temp1 & T1_NRUNES_MASK;
		if (runemax == 0)
			runemax = DEFAULT_RUNEMAX;
		runespawntime	= time;
	}
};
