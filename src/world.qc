/*  $Id: world.qc,v 1.82 2006/07/16 00:29:00 slotzero Exp $

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

void ()
main =
{
};

entity	lastspawn;

//=======================
/*QUAKED worldspawn (0 0 0) ?
Only used for the world entity.
Set message to the level name.
Set sounds to the cd track to play.

World Types:
0: medieval
1: metal
2: base
*/
//=======================
void ()
worldspawn =
{
	InternalInit ();
	InitBodyQue ();
	rjs_worldspawn ();
	precaches ();
	Light_Setup ();
	place_my_items ();
	InitSearchHunk();
};

float teamplay_set_state;
float initial_obs_process_game_queue;

void ()
StartFrame =
{
	check_teamplay ();

	if (time > LEVEL_RECONNECT_ALLOWANCE && !initial_obs_process_game_queue)
	{
		initial_obs_process_game_queue = 1;
		obs_process_game_queue ();
	}

	check_console_command ();

	IN_QW([-
		deathmatch = cvar ("deathmatch");

		if (!cvar_infokey ("console_bindings"))
		{
			if (time > 3)
			{
				console_aliases ();
				cvar_set_infokey ("console_bindings", "1");
			}
		}
	-])

	framecount = framecount + 1;

	if (lasth)
		SearchHunk();

	CheckRules ();
	spawn_runes ();
	update_client_pings ();
};

/*
==============================================================================

BODY QUE

==============================================================================
*/

entity	bodyque_head;

void ()
InitBodyQue =
{
	bodyque_head = spawn ();
	bodyque_head.classname = "bodyque";
	bodyque_head.owner = spawn ();
	bodyque_head.owner.classname = "bodyque";
	bodyque_head.owner.owner = spawn ();
	bodyque_head.owner.owner.classname = "bodyque";
	bodyque_head.owner.owner.owner = spawn ();
	bodyque_head.owner.owner.owner.classname = "bodyque";
	bodyque_head.owner.owner.owner.owner = bodyque_head;
};

// make a body que entry for the given ent so the ent can be
// respawned elsewhere
void (entity ent)
CopyToBodyQue =
{
	bodyque_head.angles	= ent.angles;
	bodyque_head.model	= ent.model;
	bodyque_head.modelindex	= ent.modelindex;
	bodyque_head.frame	= ent.frame;
	bodyque_head.colormap	= ent.colormap;

	if (ent.movetype == MOVETYPE_WALK)
	{
		dprint ("bad movetype for bodyque by ", ent.netname, "\n");
		bodyque_head.movetype	= MOVETYPE_TOSS;
	}
	else
		bodyque_head.movetype	= ent.movetype;

	bodyque_head.velocity	= ent.velocity;
	bodyque_head.flags	= 0;

	setorigin (bodyque_head, ent.origin);
	setsize (bodyque_head, ent.mins, ent.maxs);

	bodyque_head		= bodyque_head.owner;
};
