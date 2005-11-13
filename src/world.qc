/*  $Id: world.qc,v 1.76 2005/11/13 20:55:16 slotzero Exp $

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
	InitSearchHunk();
};

float teamplay_set_state;
float initial_obs_process_game_queue;

void ()
StartFrame =
{
	local vector v;
	local float i;
	local string s;

	// I used to do an initial change_teamplay() in rjs_worldspawn().
	// When I added START_LEVEL_EXEC, though, that broke.  A teamplay
	// set in startlevel.cfg isn't seen for a second or two after
	// that for some reason.  So, when the change_teamplay() there
	// ran, it would still see the teamplay in place from before
	// startlevel.cfg ran.  The change_teamplay() would do its own
	// localcmd() to set teamplay and that would overwrite the value
	// set in startlevel.cfg.
	//
	// I want to see both the value from before startlevel.cfg and
	// the value from after, so that I assign people to teams or
	// randomize their colors if enforced teams are turned on or
	// off.  I do an initial set of teamplay here as early as
	// possible, but I don't use localcmd() to set it at that point
	// so the value from startlevel.cfg doesn't get overwritten.  I
	// then do nothing for a couple of seconds, after which I check
	// it again and do the localcmd() even if it hasn't changed
	// (because a startlevel.cfg which sets it to the same value it
	// had last level would have lost the mod string in the teamplay
	// cvar).  After that I treat it naturally, doing the
	// change_teamplay() whenever it changes.

	i = cvar ("teamplay");
	if (time > 3 && (teamplay_set_state < 2 || teamplay != i))
	{
		teamplay_set_state = 2;
		change_teamplay (i, 1);
	}
	else if (teamplay_set_state < 1)
	{
		teamplay_set_state = 1;
		change_teamplay (i, 0);
	}

	if (time > LEVEL_RECONNECT_ALLOWANCE
			&& !initial_obs_process_game_queue)
	{
		initial_obs_process_game_queue = 1;
		obs_process_game_queue ();
	}

	i = cvar_infokey (CVAR_C1);
	if (i)
	{
		cvar_set_infokey (CVAR_C1, "0");
		IN_POQ(if (!HUNK_CONTEXT_MAX) i = 0;)

		&%IN_POQ(368,376) = i;
		s = impulse_to_map ();
		if (s)
			admin_changelevel (s);
		else
			dprint ("Invalid level impulse\n");
	}

	i = cvar_infokey (CVAR_C2);
	if (i)
	{
		if (i == C2_UPDATE_BINDINGS)
			console_aliases ();

		else if (i == C2_SHOW_PLAYERS)
			show_players ();

		else if (i == C2_SHOW_SETTINGS)
			show_settings ();

		else if (i == C2_TOGGLE_RUNE_CHEAT)
		{
			// XXX Move this to its own function, for in-game use.
			temp1 = cvar_infokey ("temp1");
			if (temp1 & T1_RUNE_CHEAT)
			{
				temp1 = temp1 - temp1 & T1_RUNE_CHEAT;
				dprint_force ("Rune cheat off\n");
			}
			else
			{
				temp1 = temp1 | T1_RUNE_CHEAT;
				dprint_force ("Rune cheat on\n");
			}
			s = ftos (temp1);
			cvar_set_infokey ("temp1", s);
		}

		else if (i == C2_LAST)
			Client_Disconnect_Log ();

		else if (i == C2_LEVELS)
			levels ();

		else if (i == C2_CUSTOM)
			custom ();

		else if (i == C2_COMMANDS)
			commands ();

		else if (i == C2_LEVEL_TIME)
		{
			dprint_force (parse_time (time));
			dprint_force ("\n");
		}

		else if (i == C2_MODE_PRACTICE)
			change_mode_to_practice ();

		else if (i == C2_MODE_NORMAL)
			change_mode_to_normal ();

		// removed

		else if (i == C2_QUADON)
		{
			if (NO_QUAD)
			{
				dprint_force ("Quad enabled\n");
				setquad ();
			}
		}

		else if (i == C2_QUADOFF)
		{
			if (!NO_QUAD)
			{
				dprint_force ("Quad disabled\n");
				setquad ();
			}
		}

		else if (i == C2_PENTON)
		{
			if (NO_PENT)
			{
				dprint_force ("Pentagram enabled\n");
				setpent ();
			}
		}

		else if (i == C2_PENTOFF)
		{
			if (!NO_PENT)
			{
				dprint_force ("Pentagram disabled\n");
				setpent ();
			}
		}

		else if (i == C2_RINGON)
		{
			if (NO_RING)
			{
				dprint_force ("Ring of shadows enabled\n");
				setring ();
			}
		}

		else if (i == C2_RINGOFF)
		{
			if (!NO_RING)
			{
				dprint_force ("Ring of shadows disabled\n");
				setring ();
			}
		}

		else if (i == C2_SUITON)
		{
			if (NO_SUIT)
			{
				dprint_force ("Environmental protection suit enabled\n");
				setsuit ();
			}
		}

		else if (i == C2_SUITOFF)
		{
			if (!NO_SUIT)
			{
				dprint_force ("Environmental protection suit disabled\n");
				setsuit ();
			}
		}

		else if (i == C2_ARMORON)
		{
			if (NO_ARMOR)
			{
				dprint_force ("Armor enabled\n");
				setarmor ();
			}
		}

		else if (i == C2_ARMOROFF)
		{
			if (!NO_ARMOR)
			{
				dprint_force ("Armor disabled\n");
				setarmor ();
			}
		}

		else if (i == C2_ROTATEON)
		{
			if (!ROTATE)
			{
				dprint_force ("Rotating armors enabled\n");
				setrotate ();
			}
		}

		else if (i == C2_ROTATEOFF)
		{
			if (ROTATE)
			{
				dprint_force ("Rotating armors disabled\n");
				setrotate ();
			}
		}

		else if (i == C2_RUNESON)
		{
			if (NO_RUNES)
			{
				dprint_force ("Runes enabled\n");
				setrunes ();
			}
		}

		else if (i == C2_RUNESOFF)
		{
			if (!NO_RUNES)
			{
				dprint_force ("Runes disabled\n");
				setrunes ();
			}
		}

		else if (i == C2_ALTSON)
		{
			if (deathmatch & DM_MODE_PRACTICE)
				dprint_force ("Alternate weapons disabled in practice mode\n");
			else if (NO_ALT_WEAPONS)
			{
				dprint_force ("Alternate weapons enabled\n");
				setalts ();
			}
		}

		else if (i == C2_ALTSOFF)
		{
			if (!NO_ALT_WEAPONS)
			{
				dprint_force ("Alternate weapons disabled\n");
				setalts ();
			}
		}

		else if (i == C2_SHIELDSON)
		{
			if (NO_SPAWN_SHIELDS)
			{
				dprint_force ("Shields on\n");
				setshields ();
			}
		}

		else if (i == C2_SHIELDSOFF)
		{
			if (!NO_SPAWN_SHIELDS)
			{
				dprint_force ("Shields off\n");
				setshields ();
			}
		}

		else if (i == C2_HOOKDAMAGEON)
		{
			if (NO_HOOK_DAMAGE)
			{
				dprint_force ("Hook damage on\n");
				sethookdamage ();
			}
		}

		else if (i == C2_HOOKDAMAGEOFF)
		{
			if (!NO_HOOK_DAMAGE)
			{
				dprint_force ("Hook damage off\n");
				sethookdamage ();
			}
		}

		else if (i == C2_MODE_ARENA)
			change_mode_to_arena ();

		else if (i == C2_CLIENT_PING_TIMES)
			client_ping_times ();

		else if (i == C2_MEGAON)
		{
			if (NO_MEGA)
			{
				dprint_force ("Mega-health boxes on\n");
				setmega ();
			}
		}

		else if (i == C2_MEGAOFF)
		{
			if (!NO_MEGA)
			{
				dprint_force ("Mega-health boxes off\n");
				setmega ();
			}
		}

		else if (i == C2_BAN_ADD)
		{	IN_QW(return;)
			s = cvar_string ("skill", 1);
			v = ip_to_vec (s);
			if (v == VEC_ORIGIN)
				self_sprint (self, "invalid ip address\n");
			else
				ban_add (v);
		}

		else if (i == C2_BAN_REMOVE)
		{	IN_QW(return;)
			s = cvar_string ("skill", 1);
			v = ip_to_vec (s);
			if (v == VEC_ORIGIN)
				self_sprint (self, "invalid ip address\n");
			else
				ban_remove (v);
		}

		else if (i == C2_BAN_LIST)
		{	IN_QW(return;)
			ban_list ();
		}

		else if (i == C2_CONPRINT)
		{
			scratch1 = cvar_infokey ("scratch1");
			if (scratch1 & S1_BPRINT_TO_CONSOLE)
			{
				dprint ("conprint off\n");
				scratch1 = scratch1 - scratch1 & S1_BPRINT_TO_CONSOLE;
			}
			else
			{
				dprint ("conprint on\n");
				scratch1 = scratch1 | S1_BPRINT_TO_CONSOLE;
			}

			s = ftos (scratch1);
			cvar_set_infokey ("scratch1", s);
		}

		else if (i == C2_EFFICIENCY)
			sprint_efficiency ();

		else if (i == C2_MODE_MATCH)
			change_mode_to_match ();

		else
			dprint ("Unknown command\n");

		cvar_set_infokey (CVAR_C2, "0");
	}

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
	if (intermission_running)
	{
		if (INTERMISSION_AUTO_EXIT >= 0
				&& time >= intermission_exittime
						+ INTERMISSION_AUTO_EXIT)
			ExitIntermission ();
	}

	//RUNE SERV: Adding some more runes till too much.
	if (runespawntime < time)
	{
		runespawntime = time + 1 + random ()*15;

		if (runecurrent < runemax)
		{
			if (temp1 & T1_FAST_RUNE_SPAWN)
				Rune_SpawnAll (runemax - runecurrent);
			else
				Rune_SpawnAll (1);
		}

		if (temp1 & T1_HOOK_MASK == T1_LITHIUM_HOOK)
		{
			i = count_players (0);
			i = ceil (i / 3);
			if (current_hooks < i)
			{
				if (!temp1 & T1_FAST_RUNE_SPAWN)
					i = current_hooks + 1;
				while (current_hooks < i)
					spawn_lithium_hook ();
			}
		}

		// See the comment in Rune_Move() for why this is done.
		i = count_classname ("rune");
		if (i != runecurrent)
		{
			dprint ("runecurrent bug, ");
			dprint_float (runecurrent);
			dprint (" -> ");
			dprint_float (i);
			dprint ("\n");
			runecurrent = i;
		}
	}

	if (UPDATE_CLIENT_PINGS < time)
	{
		UPDATE_CLIENT_PINGS = time + 1;
		pqc_ping_times ();
	}
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
