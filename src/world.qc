/*  $Id: world.qc,v 1.48 2004/07/05 08:06:45 slotzero Exp $

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
	local string s;

	lastspawn = world;
	InternalInit ();
	InitBodyQue ();
	rjs_worldspawn ();

	// I can't read the gravity from sv_gravity in rjs_worldspawn()
	// (for the same reason I have to wait before reading teamplay,
	// I'd wager).
	if (self.model == "maps/e1m8.bsp")
		sv_gravity = 100;
	else
		sv_gravity = DEFAULT_GRAVITY;
	s = ftos (sv_gravity);
	cvar_set ("sv_gravity", s);

	// the area based ambient sounds MUST be the first precache_sounds

	// player precaches
	W_Precache ();			// get weapon precaches

	// sounds used from C physics code
	precache_sound ("demon/dland2.wav");		// landing thud
	precache_sound ("misc/h2ohit1.wav");		// landing splash

	// setup precaches allways needed
	precache_sound ("items/itembk2.wav");		// item respawn sound
	precache_sound ("player/plyrjmp8.wav");		// player jump
	precache_sound ("player/land.wav");		// player landing
	precache_sound ("player/land2.wav");		// player hurt landing
	precache_sound ("player/drown1.wav");		// drowning pain
	precache_sound ("player/drown2.wav");		// drowning pain
	precache_sound ("player/gasp1.wav");		// gasping for air
	precache_sound ("player/gasp2.wav");		// taking breath
	precache_sound ("player/h2odeath.wav");		// drowning death

	precache_sound ("misc/talk.wav");		// talk
	precache_sound ("player/teledth1.wav");		// telefrag
	precache_sound ("misc/r_tele1.wav");		// teleport sounds
	precache_sound ("misc/r_tele2.wav");
	precache_sound ("misc/r_tele3.wav");
	precache_sound ("misc/r_tele4.wav");
	precache_sound ("misc/r_tele5.wav");
	precache_sound ("weapons/lock4.wav");		// ammo pick up
	precache_sound ("weapons/pkup.wav");		// weapon up
	precache_sound ("items/armor1.wav");		// armor up
	precache_sound ("weapons/lhit.wav");		// lightning
	precache_sound ("weapons/lstart.wav");		// lightning start
	precache_sound ("items/damage2.wav");		// phoenix
	precache_sound ("items/damage3.wav");		// berserk, strength, phoenix
	precache_sound ("misc/power.wav");		// lightning for boss
	precache_sound ("demon/dpain1.wav");		// monk

	// player gib sounds
	precache_sound ("player/gib.wav");		// player gib sound
	precache_sound ("player/udeath.wav");		// player gib sound
	precache_sound ("player/tornoff2.wav");		// gib sound

	// player pain sounds

	precache_sound ("player/pain1.wav");
	precache_sound ("player/pain2.wav");
	precache_sound ("player/pain3.wav");
	precache_sound ("player/pain4.wav");
	precache_sound ("player/pain5.wav");
	precache_sound ("player/pain6.wav");

	// player death sounds
	precache_sound ("player/death1.wav");
	precache_sound ("player/death2.wav");
	precache_sound ("player/death3.wav");
	precache_sound ("player/death4.wav");
	precache_sound ("player/death5.wav");

	// ax sounds
	precache_sound ("weapons/ax1.wav");		// ax swoosh
	precache_sound ("player/axhit1.wav");		// ax hit meat
	precache_sound ("player/axhit2.wav");		// ax hit world

	precache_sound ("player/h2ojump.wav");		// player jumping into water
	precache_sound ("player/slimbrn2.wav");		// player enter slime
	precache_sound ("player/inh2o.wav");		// player enter water
	precache_sound ("player/inlava.wav");		// player enter lava
	precache_sound ("misc/outwater.wav");		// leaving water sound

	precache_sound ("player/lburn1.wav");		// lava burn
	precache_sound ("player/lburn2.wav");		// lava burn

	precache_sound ("misc/water1.wav");		// swimming
	precache_sound ("misc/water2.wav");		// swimming

	precache_model ("progs/player.mdl");
	precache_model ("progs/eyes.mdl");
	precache_model ("progs/h_player.mdl");
	precache_model ("progs/gib1.mdl");
	precache_model ("progs/gib2.mdl");
	precache_model ("progs/gib3.mdl");

	precache_model ("progs/s_bubble.spr");		// drowning bubbles
	precache_model ("progs/s_explod.spr");		// sprite explosion

	precache_model ("progs/v_axe.mdl");
	precache_model ("progs/v_shot.mdl");
	precache_model ("progs/v_nail.mdl");
	precache_model ("progs/v_rock.mdl");
	precache_model ("progs/v_shot2.mdl");
	precache_model ("progs/v_nail2.mdl");
	precache_model ("progs/v_rock2.mdl");

	precache_model ("progs/bolt.mdl");		// for lightning gun
	precache_model ("progs/bolt2.mdl");		// for lightning gun
	precache_model ("progs/bolt3.mdl");		// for boss shock
	precache_model ("progs/lavaball.mdl");		// for testing

	precache_model ("progs/missile.mdl");
	precache_model ("progs/grenade.mdl");
	precache_model ("progs/spike.mdl");
	precache_model ("progs/s_spike.mdl");

	precache_model ("progs/backpack.mdl");

	precache_model ("progs/zom_gib.mdl");

	precache_model ("progs/v_light.mdl");

	/***************************\
	* Rune serv extra precaches *
	\***************************/

	precache_model ("progs/end1.mdl");		// for runes
	precache_model ("progs/end2.mdl");		// for runes
	precache_model ("progs/end3.mdl");		// for runes
	precache_model ("progs/end4.mdl");		// for runes
	precache_model ("progs/flame2.mdl");		// firewalk, burning
	precache_model ("progs/bolt2.mdl");		// electric rune
	precache_model ("progs/v_spike.mdl");		// Death spot
	precache_model ("progs/oldone.mdl");		// For the Shub Hat!
	precache_model ("progs/teleport.mdl");		// Big spiky ball
	precache_model ("progs/armor.mdl");		// armor dropping on e1m7 &c
	precache_model ("progs/quaddama.mdl");		// quad hat

	precache_model ("progs/s_light.spr");		// Death orb and gravity well

	precache_sound (SOUND_RUNE_PICKUP);		// You got a rune
	precache_sound ("items/protect2.wav");		// shielding or resistance?
	precache_sound ("items/protect3.wav");		// shielding or resistance?
	precache_sound ("items/damage3.wav");		// strength
	precache_sound ("items/damage.wav");		// radiation
	precache_sound ("items/inv1.wav");		// deathspots become invis
	precache_sound ("boss1/sight1.wav");		// haste rune
	precache_sound ("items/r_item1.wav");
	precache_sound ("items/r_item2.wav");		// regeneration rune
	precache_sound ("wizard/wpain.wav");		// vampiric rune
	precache_sound ("fish/bite.wav");		// freeze activate
	precache_sound ("blob/death1.wav");		// unfreeze!
	precache_sound ("shambler/smack.wav");		// freeze!
	precache_sound ("hknight/hit.wav");		// firewalk, flame missiles, fire trap
	precache_sound ("boss1/throw.wav");		// trigger fire trap
	precache_sound ("misc/basekey.wav");		// holorune activate
	precache_sound ("enforcer/sight2.wav");		// drop ice trap
	precache_sound ("buttons/switch04.wav");	// drop death spots
	precache_sound ("doors/airdoor2.wav");		// Enviro-jump
	precache_sound ("zombie/z_miss.wav");		// Chaff hits someone.
	precache_sound ("boss2/idle.wav");		// Blowing up in a Death Spot
	precache_sound ("knight/sword1.wav");		// lumberjack axe
	precache_sound ("knight/sword2.wav");		// lumberjack axe
	precache_sound ("shalrath/sight.wav");		// player connect

	// developer runes

	// RN_GLUE
	precache_model ("progs/tarbaby.mdl");
	precache_sound ("blob/hit1.wav");
	precache_sound ("blob/sight1.wav");

	// RN_TORNADO
	precache_model ("progs/w_spike.mdl");
	precache_sound ("boss1/out1.wav");
	precache_sound ("doors/meduse.wav");

	// RN_SONAR
	precache_sound ("enforcer/sight3.wav");
	precache_sound ("wizard/widle1.wav");
	precache_sound ("fish/idle.wav");

	// RN_ANTIPACK
	precache_sound ("demon/ddeath.wav");

	// For the Shambler Helper
	precache_model ("progs/shambler.mdl");
	precache_model ("progs/s_light.mdl");
	precache_model ("progs/h_shams.mdl");
	precache_model ("progs/bolt.mdl");
	precache_sound ("shambler/sattck1.wav");
	precache_sound ("shambler/sboom.wav");
	precache_sound ("shambler/sdeath.wav");
	precache_sound ("shambler/shurt2.wav");
	precache_sound ("shambler/sidle.wav");
	precache_sound ("shambler/ssight.wav");
	precache_sound ("shambler/melee1.wav");
	precache_sound ("shambler/melee2.wav");
	precache_sound ("shambler/smack.wav");

	// Zombie campers
	precache_model ("progs/zombie.mdl");
	precache_model ("progs/h_zombie.mdl");
	precache_model ("progs/zom_gib.mdl");
	precache_sound ("zombie/z_idle.wav");
	precache_sound ("zombie/z_idle1.wav");
	precache_sound ("zombie/z_shot1.wav");
	precache_sound ("zombie/z_gib.wav");
	precache_sound ("zombie/z_pain.wav");
	precache_sound ("zombie/z_pain1.wav");
	precache_sound ("zombie/z_fall.wav");
	precache_sound ("zombie/z_miss.wav");
	precache_sound ("zombie/z_hit.wav");
	precache_sound ("zombie/idle_w2.wav");

	/*******************************\
	* Rune serv extra precaches end *
	\*******************************/

	//RUNE SERV: Set current rune number at 0.
	runecurrent = 0;

	Light_Setup ();
	InitSearchHunk();
};

float teamplay_set_state;
float initial_obs_process_game_queue;

void ()
StartFrame =
{
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
			change_practice_mode (1);

		else if (i == C2_MODE_NORMAL)
			change_practice_mode (0);

		else if (i == C2_TOGGLE_NOALTS)
			toggle_cvar_bit ("deathmatch", DM_NO_ALT_WEAPONS, "no alts ");

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

		if (temp1 & T1_LITHIUM_HOOK)
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
		i = count_ent_class ("rune");
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
};

/*
==============================================================================

BODY QUE

==============================================================================
*/

entity	bodyque_head;

void ()
bodyque =
{	// just here so spawn functions don't complain after the world
	// creates bodyques
};

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
	bodyque_head.movetype	= ent.movetype;
	bodyque_head.velocity	= ent.velocity;
	bodyque_head.flags	= 0;

	setorigin (bodyque_head, ent.origin);
	setsize (bodyque_head, ent.mins, ent.maxs);

	bodyque_head		= bodyque_head.owner;
};
