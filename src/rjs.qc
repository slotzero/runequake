/*  $Id: rjs.qc,v 1.159 2004/12/27 03:36:34 slotzero Exp $

    Copyright (C) 1998-2001  Roderick Schertler.

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
timelimit_countdown =
{
	local float seconds, minutes, n;
	local string s1, s2;

	timelimit = cvar ("timelimit") * 60;
	if (!timelimit)
		return;

	seconds = ceil (timelimit - time);
	minutes = ceil (seconds / 60);

	n = 1;
	s2 = "s";

	if ((minutes == 25 || minutes == 20 || minutes == 15 || minutes == 10
			|| minutes == 5) && countdown != minutes)
		countdown = minutes;
	else if (minutes == 1 && countdown != minutes && seconds >= 60)
	{
		countdown = minutes;
		s2 = "";
	}
	else if ((seconds == 30 || seconds == 15 || seconds == 5)
			&& countdown != seconds)
		countdown = seconds;
	else
		n = 0;

	if (n)
	{
		if (seconds < 60)
			s1 = " second";
		else
			s1 = " minute";

		bprint ("\{141} ");
		bprint_float (countdown);
		bprint (s1);
		bprint (s2);
		bprint (" remaining\n");

		if (TIMELIMIT_COUNTDOWN == 2)
			sound (self, CHAN_BODY, "misc/talk.wav", 1, ATTN_NONE);
	}
};

void (entity e, float chan, string samp, float vol, float atten)
sound =
{
	// debug
	/* if (self.classname == "player")
	{
		bprint_float (time);
		bprint (": ");
		bprint (samp);
		bprint (", ");
		bprint_float (chan);
		bprint ("\n");
	} */

	if (e.runetype != RN_CLOAK)
		xsound (e, chan, samp, vol, atten);
};

void (entity e, float chan, string samp, float vol, float atten)
cloaked_sound =
{
	xsound (e, chan, samp, vol, atten);
};

void (entity e, string samp)
self_sound =
{
	self_stuffcmd (e, "play ");
	self_stuffcmd (e, samp);
	self_stuffcmd (e, "\n");
};

void (string samp)
admin_sound =
{
	local entity e;

	e = find (world, classname, "player");
	while (e)
	{
		if (is_admin_e (e))
			self_sound (e, samp);

		e = find (e, classname, "player");
	}
};

void (string samp)
observer_sound =
{
	local entity e;

	e = find (world, classname, "player");
	while (e)
	{
		if (is_observer_e (e))
			self_sound (e, samp);

		e = find (e, classname, "player");
	}
};

void (entity e, float chan, string samp1, string samp2, float vol, float atten)
random_sound2 =
{
	local string samp;

	samp = random_string2 (samp1, samp2);
	sound (e, chan, samp, vol, atten);
};

float (entity e)
isteammate =
{
	return (teamplay & TEAM_TEAM_MASK && e.team == self.team);
};

float (entity e)
isfriend =
{
	local float i;

	// self could be world if this was via isfriend2().
	if (self == world || e == world)
		return FALSE;

	// Only one argument in an if statement will work, so I had to break this up.
	i = (e == self || e.owner == self || self.owner == e || isteammate (e));
	//  This should prevent monsters from triggering a teammate's traps.
	return (i || isteammate (e.owner));
};

float (entity a, entity b)
isfriend2 =
{
	local entity oself;
	local float result;

	oself = self;
	self = a;
	result = isfriend (b);
	self = oself;
	return result;
};

float (entity e)
is_valid_player_e =
{
	return (e.classname == "player"
			&& e.aqflags & AQ_INIT_DONE
			&& e.last_thought > time - 5);
};

float ()
is_valid_player =
{
	return is_valid_player_e (self);
};

void (float n)
localcmd_kick =
{
	local string s;

	s = ftos (n);
	localcmd ("kick # ");
	localcmd (s);
	localcmd ("\n");
};

void (string s1, string s2)
kick =
{
	local float n;

	if (s1 != string_null || s2 != string_null)
	{
		bprint (self.netname);
		bprint (" was kicked ");
		bprint (s1);
		bprint (s2);
		bprint ("\n");
	}
	n = player_ent_to_num (self);
	if (n > 0)
		localcmd_kick (n);
	else
		self_stuffcmd (self, "disconnect\n");
	self.aqflags = self.aqflags | AQ_KICKED;
};

float ()
kick_suicider =
{
	if (self.last_suicide && time - self.last_suicide < 60)
	{
		kick ("for suiciding too often", string_null);
		return 1;
	}
	if (!self.aqflags & AQ_ADMIN)
	{
		sprint (self, "You will be kicked if you suicide again within a minute\n");
		self.last_suicide = time;
	}
	return 0;
};

void ()
rjs_worldspawn =
{
	local entity e;

	sys_ticrate = cvar ("sys_ticrate");
	if (!sys_ticrate) sys_ticrate = 0.1;

	scratch1	= cvar_infokey ("scratch1");

	frag_init ();
	orig_serverflags = serverflags;
	if (deathmatch & DM_DM_MASK && mapname == "start"
			&& serverflags & SERVERFLAGS_RUNE_MASK == SERVERFLAGS_RUNE_MASK)
		serverflags = serverflags - SERVERFLAGS_RUNE_MASK;
	lp_set_map (mapname);
	fix_map_spawn ();

	// Spawn an entity to update the infrequently-updated cvar-backed
	// variables, and do what initial processing of them is necessary.
	e = spawn ();
	e.think = process_cvars;
	e.nextthink = time;

	e = spawn ();
	e.think = update_frag_rates;
	e.nextthink = update_frag_rates_time = time + 60;

	if (START_LEVEL_EXEC != string_null)
	{
		localcmd ("exec ");
		localcmd (START_LEVEL_EXEC);
		localcmd ("\n");
	}

	if (!map_size (mapname))
		MAP_IS_CUSTOM = 1;

	// I used to do an initial change_teamplay() here to get the mod
	// and version into the teamplay string.  See the comments in
	// StartFrame().
	IN_QW([-
		Hunk_Settings ();
	-])
};

void ()
set_runemax =
{
	if (NO_RUNES)
		runemax = 0;
	else
	{
		runemax = temp1 & T1_NRUNES_MASK;
		if (runemax == 0)
			runemax = DEFAULT_RUNEMAX;
	}
};

// I don't need vote_count_think() anymore, so I just ride the 15 second
// refresh of process_cvars.

void ()
process_misc =
{
	local float wanted;

	if (time < LEVEL_RECONNECT_ALLOWANCE)
		return;

	set_runemax ();
	ghost_check ();
	update_server_time ();

	if (intermission_running)
		return;

	if (scratch1 & S1_NO_DEFAULT)
		return;

	// Only process the remaining functions if the server is empty.
	if (count_players_by_ent (0))
		return;

	// vote-team
	if (VOTE_TEAM_MODE_DEFAULT)
		toggle_teamplay (VOTE_TEAM_MODE_DEFAULT);

	// vote-hook
	if (temp1 & T1_HOOK_DEFAULT_ON)
	{
		wanted = hook_type (HOOK_DEFAULT);
		if (wanted != hook_type (temp1))
		{
			if (wanted == 0)
				toggle_free_hook ();
			else if (wanted == 1)
				free_hook ();
			else if (wanted == 2)
				lithium_hook ();
		}
	}

	// XXX All of code below is hard coded and should be fixed.
	if (NO_QUAD)
		setquad ();
	if (NO_PENT)
		setpent ();
	if (NO_RING)
		setring ();
	if (NO_SUIT)
		setsuit ();
	if (NO_ARMOR)
		setarmor ();
	else if (!ROTATE)
		setrotate ();
	if (NO_RUNES)
		setrunes ();
	if (NO_ALT_WEAPONS)
		setalts ();
	if (NO_SPAWN_SHIELDS)
		setshields ();
	if (NO_HOOK_DAMAGE)
		sethookdamage ();

	// vote-practice (always do this last)
	if (deathmatch & DM_MODE_PRACTICE)
		mode_normal ();
};

void ()
process_cvars =
{
	local float new_deathmatch, i;

	self.nextthink = time + 15;

	noexit = cvar_infokey ("noexit");
	i = noexit & NOEXIT_FORWARD_MASK;
	if (i)
		FORWARD_MAX_PLAYERS_REAL = i / NOEXIT_FORWARD_MULT;
	else
		FORWARD_MAX_PLAYERS_REAL = FORWARD_MAX_PLAYERS;

	temp1 = cvar_infokey ("temp1");

	i = temp1 & T1_RUNE_DROP_DELAY_MASK;
	if (i == T1_RUNE_DROP_DELAY_0)		rune_drop_delay = 0;
	else if (i == T1_RUNE_DROP_DELAY_15)	rune_drop_delay = 15;
	else if (i == T1_RUNE_DROP_DELAY_30)	rune_drop_delay = 30;
	else if (i == T1_RUNE_DROP_DELAY_60)	rune_drop_delay = 60;
	else if (i == T1_RUNE_DROP_DELAY_120)	rune_drop_delay = 120;
	else if (i == T1_RUNE_DROP_DELAY_240)	rune_drop_delay = 240;
	else if (i == T1_RUNE_DROP_DELAY_INF)	rune_drop_delay = -1;
	else					rune_drop_delay = 3;

	// The game sets deathmatch at the start of each level.  I
	// update it here so that it has the same semantics of the other
	// game-controlling bit vectors (visible either immediately or
	// after a few seconds).
	new_deathmatch = cvar ("deathmatch");

	// If there's a boolean mismatch, though, ignore the new value.
	// This is to keep the QC in sync with the engine on this point.
	// NB:  The redundant parens were necessary, grr.
	if ((!deathmatch) == (!new_deathmatch))
		deathmatch = new_deathmatch;

	// XXX This shouldn't be necessary, but there's a bug with the
	// current_hooks handling.
	current_hooks = count_hooks ();

	process_misc ();
};

// If E's health is > E.max_health, decay it by up to AMOUNT and return
// true.  Else, return false.  XXX Assumes you're doing 1 decay a second.

float (entity e, float amt)
decay_health =
{
	if (e.health <= e.max_health)
		return FALSE;

	if (amt > 0)
	{
		e.health = e.health - amt;
		if (e.health < e.max_health)
			e.health = e.max_health;
	}

	return TRUE;
};

// Decay E's health down to E.max_health at RATE points per second.

void (entity e, float rate)
decay_health_spawn =
{
	local entity this;

	if (e.runetype == RN_VAMP)
		return;

	if (e.health <= e.max_health)
		return;

	if (e.items & IT_SUPERHEALTH)
		return;

	e.items		= e.items | IT_SUPERHEALTH;

	this		= spawn ();
	this.owner	= e;
	this.classname	= "decay_health";
	this.runevar	= rate;
	this.think	= decay_health_think;
	this.nextthink	= time + 1;
};

void ()
decay_health_think =
{
	if (decay_health (self.owner, self.runevar))
		self.nextthink = time + 1;
	else
	{
		self.owner.items = self.owner.items
			- self.owner.items & IT_SUPERHEALTH;
		remove (self);
	}
};

string (float n)
weaponnum_to_class =
{
	if (n == 3) return "weapon_supershotgun";
	else if (n == 4) return "weapon_nailgun";
	else if (n == 5) return "weapon_supernailgun";
	else if (n == 6) return "weapon_grenadelauncher";
	else if (n == 7) return "weapon_rocketlauncher";
	else if (n == 8) return "weapon_lightning";
	error ("invalid weapon number");
	return "invalid_weapon_number";
};

void (float n)
item_xweapon =
{
	self.classname = weaponnum_to_class (n);
	     if (n == 3) weapon_supershotgun ();
	else if (n == 4) weapon_nailgun ();
	else if (n == 5) weapon_supernailgun ();
	else if (n == 6) weapon_grenadelauncher ();
	else if (n == 7) weapon_rocketlauncher ();
	else if (n == 8) weapon_lightning ();
	else
		error ("invalid weapon number");
};

// Turn this powerup (quad or pentagram) into something else, either a
// good weapon which isn't in the immediate vicinity or yellow armor.
// The algorithm which chooses which is deterministic so that once you
// know what a particular powerup turned into it's always the same.
//
// The real work is done after a think so that the regular weapons are
// there to be seen.  The spawn_no_precache setting is a hack to allow
// the regular spawn functions to be used but without precaching (since
// that's not allowed after the think).

void (float ix)
item_powerup_replacement =
{
	precache_model ("progs/armor.mdl");
	precache_model ("progs/g_nail2.mdl");
	precache_model ("progs/g_rock.mdl");
	precache_model ("progs/g_rock2.mdl");
	precache_model ("progs/g_light.mdl");

	self.ammo_shells = ix;
	self.think = item_powerup_replacement_real;
	self.nextthink = time + 0.5;
};

void ()
item_powerup_replacement_real =
{
	local float ix, ok, tries;
	local entity e;

	spawn_no_precache = 1;

	ix = self.ammo_shells;
	while (ix >= 4)
		ix = ix - 4;
	ok = 0;
	tries = 0;
	while (!ok && tries < 4)
	{
		local float found;

		found = 0;
		e = findradius (self.origin, 1000);
		while (e != world && found == 0)
		{
			if (e.classname == weaponnum_to_class (5 + ix))
			{
				if (0)
				{
					dprint ("reject weapon ");
					dprint (ftos (5+ix));
					dprint (" at ");
					dprint (vtos (e.origin));
					dprint ("\n");
				}
				found = found + 1;
			}
			e = e.chain;
		}
		if (found)
		{
			ix = ix + 1;
			if (ix == 4)
				ix = 0;
			tries = tries + 1;
		}
		else
			ok = 1;
	}
	if (ok)
		item_xweapon (5 + ix);
	else
	{
		self.classname = "item_armor2";
		item_armor2 ();
	}
};

void (float all)
disp_info =
{
	local float i;
	local entity e, of_e;

	of_e = ridee ();
	if (!of_e)
		of_e = self;

	// global rune info
	if (all || 1)
	{
		i = count_ent_class ("rune");
		self_sprint_float (self, i);
		self_sprint (self, " runes counted ");
		self_sprint_float (self, runecurrent);
		self_sprint (self, " cur ");
		self_sprint_float (self, runemax);
		self_sprint (self, " max\n");
	}

	// global hook info
	if (all || 0)
	{
		self_sprint_float (self, current_hooks);
		self_sprint (self, " current_hooks ");
		i = count_ent_class ("hook");
		self_sprint_float (self, i);
		self_sprint (self, " in lev, on players: ");
		i = 0;
		e = find (world, classname, "player");
		while (e)
		{
			if (e.aqflags & AQ_HOOK)
			{
				self_sprint (self, e.netname);
				self_sprint (self, " ");
				i = i + 1;
			}
			e = find (e, classname, "player");
		}
		self_sprint_float (self, i);
		self_sprint (self, " total on players\n");
	}

	// my rune info
	if (all || 1)
	{
		self_sprint (self, "rune type ");
		self_sprint_float (self, of_e.runetype);
		self_sprint (self, " var ");
		self_sprint_float (self, of_e.runevar);
		self_sprint (self, " time ");
		self_sprint_float (self, of_e.runetime);
		self_sprint (self, "/");
		self_sprint_float (self, of_e.runetime - time);
		self_sprint (self, "\n");
	}

	// self.aqflags
	if (all || 1)
	{
		self_sprint (self, "aqflags ");
		self_sprint_float (self, of_e.aqflags);
		self_sprint (self, " aqstate ");
		self_sprint_float (self, of_e.aqstate);
		self_sprint (self, "\n");
	}

	// deathmatch
	if (all || 0)
	{
		self_sprint (self, "var ");
		self_sprint_float (self, deathmatch);
		self_sprint (self, " cvar ");
		i = cvar ("deathmatch");
		self_sprint_float (self, i);
		self_sprint (self, "\n");
	}

	// team
	if (all || 0)
	{
		self_sprint (self, "team ");
		self_sprint_float (self, self.team);
		self_sprint (self, " is_correct ");
		i = is_correct_team ();
		self_sprint_float (self, i);
		self_sprint (self, " correct ");
		i = correct_team ();
		self_sprint_float (self, i);
		self_sprint (self, "\n");
	}

	// attack/jump buttons
	if (all || 0)
	{
		self_sprint (self, "attack ");
		self_sprint_float (self, of_e.button0);
		self_sprint (self, " jump ");
		self_sprint_float (self, of_e.button2);
		self_sprint (self, "\n");
	}

	// waterlevel and type
	if (all || 0)
	{
		self_sprint (self, "waterlevel ");
		self_sprint_float (self, of_e.waterlevel);
		self_sprint (self, " type ");
		self_sprint_float (self, of_e.watertype);
		self_sprint (self, " burning ");
		self_sprint_float (self, of_e.aqstate & AQS_BURNING);
		self_sprint (self, "\n");
	}

	// lp
	if (all || 0)
	{
		self_sprint_bitfield (self, "serverflags", serverflags);
		i = cvar ("samelevel");
		self_sprint_bitfield (self, "samelevel", i);
	}

	// powerup
	if (all || 0)
	{
		self_sprint (self, "powerups: ");
		if (of_e.invincible_finished)
		{
			self_sprint (self, " pent ");
			self_sprint_float (self, of_e.invincible_finished - time);
		}
		if (of_e.super_damage_finished)
		{
			self_sprint (self, " quad ");
			self_sprint_float (self, of_e.super_damage_finished - time);
		}
		if (of_e.invisible_finished)
		{
			self_sprint (self, " ring ");
			self_sprint_float (self, of_e.invisible_finished - time);
		}
		if (of_e.radsuit_finished)
		{
			self_sprint (self, " suit ");
			self_sprint_float (self, of_e.radsuit_finished - time);
		}
		self_sprint (self, "\n");
	}

	// player entities
	if (all || 0)
	{
		// This returns 0.
		//maxplayers = cvar ("maxplayers");
		//self_sprint (self, "players (max ");
		//self_sprint_float (self, maxplayers);
		//self_sprint (self, "):\n");
		i = 1;
		e = nextent (world);
		while (e != world && e.classname != "bodyque" && i < 100)
		{
			if (i < 10)
				self_sprint (self, " ");
			self_sprint_float (self, i);

			if (is_valid_player_e (e))
				self_sprint (self, " val ");
			else
				self_sprint (self, " inv ");

			if (e.classname == string_null)
				self_sprint (self, " (null)");
			else
				self_sprint (self, e.classname);

			self_sprint (self, " ");
			self_sprint_float (self, e.last_thought);

			self_sprint (self, " ");
			self_sprint (self, e.netname);
			self_sprint (self, "\n");
			e = nextent (e);
			i = i + 1;
		}
	}

	// vote-exit/vote-team
	if (all || 0)
	{
		count_votes (3);
		//count_votes (IMP_VOTE_TEAM, 3);
		//count_votes (IMP_VOTE_EXIT, 3);
		//count_votes (IMP_VOTE_HOOK, 3);
	}

	// damage
	if (all || deathmatch & DM_DAMAGE_MATCH)
	{
		if (!deathmatch & DM_DAMAGE_MATCH)
			self_sprint (self, "unknown");
		else
			self_sprint_float (self, of_e.damage_done);
		self_sprint (self, " damage done\n");
	}

	// frag rate
	if (all || 1)
	{
		i = rint (100 * of_e.frag_rate);
		self_sprint_float (self, i);
		self_sprint (self, " frag rate ");
		self_sprint_float (self, of_e.recent_frags);
		self_sprint (self, " recent ");
		self_sprint_float (self, update_frag_rates_time - time);
		self_sprint (self, " secs left\n");
	}

	// forward name
	if (all || 0)
	{
		if (FORWARD_NAME)
		{
			self_sprint (self, "forward dest: ");
			self_sprint (self, FORWARD_NAME);
			self_sprint (self, "\n");
		}
	}
};

void (float n)
show_float =
{
	if (n != 0)
	{
		sprint_float (self, n);
		sprint (self, "\n");
	}
};

float ()
count_ent =
{
	local entity e;
	local float n;

	n = 0;
	e = nextent (world);
	while (e)
	{
		n = n + 1;
		e = nextent (e);
	}
	return n;
};

float (string s)
count_ent_class =
{
	local float i;
	local entity e;

	i = 0;
	e = find (world, classname, s);
	while (e)
	{
		i = i + 1;
		e = find (e, classname, s);
	}
	return i;
};

float (entity e_owner, string s)
count_class_own =
{
	local float i;
	local entity e;

	i = 0;
	e = find (world, classname, s);
	while (e)
	{
		if (e.owner == e_owner)
			i = i + 1;
		e = find (e, classname, s);
	}
	return i;
};

float (float t)
armor_type_to_it =
{
	if (t == 0)			return 0;
	else if (t == ARMOR_TYPE_1)	return IT_ARMOR1;
	else if (t == ARMOR_TYPE_2)	return IT_ARMOR2;
	else if (t == ARMOR_TYPE_3)	return IT_ARMOR3;
	// Between levels the type is scaled by 100, so it might not be
	// exact.
	else if (t > ARMOR_TYPE_2)	return IT_ARMOR3;
	else if (t > ARMOR_TYPE_1)	return IT_ARMOR2;
	else if (t > 0)			return IT_ARMOR1;
	else				return 0;
};

void (entity e)
set_armor_items_e =
{
	local float bit;

	if (e.runetype == RN_ARMOR)
	{
		good_armor_set_armor_items_e (e);
		return;
	}

	if (e.armorvalue > 255)
		bit = 0;
	else
		bit = armor_type_to_it (e.armortype);
	e.items = e.items
			- (e.items & (IT_ARMOR1 | IT_ARMOR2 | IT_ARMOR3))
			+ bit;
};

float (entity e)
get_max_armor_e =
{
	local float it;

	it = armor_type_to_it (e.armortype);

	if (e.runetype == RN_ARMOR)	return MAX_ARMOR_GOOD_ARMOR;
	else if (it == IT_ARMOR1)	return MAX_ARMOR_1;
	else if (it == IT_ARMOR2)	return MAX_ARMOR_2;
	else if (it == IT_ARMOR3)	return MAX_ARMOR_3;
	else				return 0;
};

float ()
get_max_armor =
{
	return get_max_armor_e (self);
};

float ()
max_players =
{
	return (temp1 & T1_MAX_PLAYERS_MASK) / T1_MAX_PLAYERS_MULT;
};

float (float include_queued)
count_players =
{
	local float players, maxp;
	local entity e;

	players = 0;
	e = find (world, classname, "player");
	while (e)
	{
		// Count queued players, too, if there's room for them in the
		// game.  This matters at the end of a level when people drop
		// out before the game decides what size level to play.
		//
		// This expression had to be broken in two.
		if (is_valid_player_e (e))
		{
			if (is_observer_e (e))
			{
				if (include_queued && e.runevar)
					players = players + 1;
			}
			else
				players = players + 1;
		}
		e = find (e, classname, "player");
	}
	maxp = max_players ();
	if (maxp && players > maxp)
		players = maxp;
	return players;
};

float (float count_qsmack)
count_players_by_ent =
{
	local entity e;
	local float players;

	e = nextent (world);
	players = 0;
	while (e != world && e.classname != "bodyque" && players < 100)
	{
		if (is_valid_player_e (e))
		{
			if (!is_qsmack_e (e) || count_qsmack)
			players = players + 1;
		}
		e = nextent (e);
	}
	return players;
};

// This turns a player entity into an entity number.  I use this for
// doing localcmd "kick #" and for keeping your ridee accross levels.

float (entity e_wanted)
player_ent_to_num =
{
	local entity e;
	local float i;

	e = world;
	for (i = 0;i <= 16; i = i + 1)
	{
		if (e == e_wanted)
			return i;
		e = nextent (e);
	}
	return 0;
};

entity (float n)
player_num_to_ent =
{
	local entity e;

	e = world;
	while (n > 0)
	{
		e = nextent (e);
		// Return false if there aren't that many players.  The
		// bodyqueue entities follow the player entities.
		if (e.classname == "bodyque")
			return world;
		n = n - 1;
	}
	return e;
};

entity (float n)
admin_cycle_num_to_ent =
{
	local entity e;
	local float num;

	e = player_num_to_ent (n);
	num = 0;
	while (num < 16)
	{
		e = nextent (e);
		if (e.classname == "bodyque")
			e = world;
		else if (e != self && e.classname == "player")
			return e;
		num = num + 1;
	}
	return world;
};

float (entity targ_e)
ent_to_num =
{
	local float n;
	local entity e;

	if (!targ_e)
		return 0;
	e = nextent (world);
	n = 1;
	while (e)
	{
		if (e == targ_e)
			return n;
		e = nextent (e);
		n = n + 1;
	}
	return -1;
};

float ()
count_hooks =
{
	local float n_ent, n_player;
	local entity e;

	n_ent = count_ent_class ("hook");
	n_player = 0;
	e = find (world, classname, "player");
	while (e)
	{
		if (is_player_e (e) && e.aqflags & AQ_HOOK)
			n_player = n_player + 1;
		e = find (e, classname, "player");
	}
	//bprint ("counted ");
	//bprint_float (n_ent); bprint (" ents ");
	//bprint_float (n_player); bprint (" players\n");
	return n_ent + n_player;
};

void (string class, vector orig, float all)
xremove_classname_origin =
{
	local entity e, next_e;

	e = find (world, classname, class);
	while (e)
	{
		next_e = find (e, classname, class);

		if (all)
			remove (e);
		else if (e.origin == orig)
		{
			remove (e);
			return;
		}
		e = next_e;
	}
};

void (string class, vector orig)
remove_classname_origin =
{
	xremove_classname_origin (class, orig, FALSE);
};

void (string class)
remove_classname =
{
	xremove_classname_origin (class, VEC_ORIGIN, TRUE);
};

// Batman villain syndrome is when your view is permanantly tilted.  It
// has historically happened due to bugs, some of them I haven't been
// able to figure out (eg, the one which comes from the switch rune).
// One workaround is to teleport.  Another is to invoke this function
// (which is bound to impulse 95).
//
// I also have this function fix the passive weirdnesses, since there
// are certainly bugs which cause you to be left with one turned on
// inappropriately.  To prevent abuse (of twirly head (punchangle)
// particularly), you can only run it once a minute.

void ()
fix_batman_villain_syndrome =
{
	if (self.height && time - self.height < 60)
	{
		self_sprint (self, "You can only run fix-angles once a minute\n");
		return;
	}
	self.height = time;
	self.angles_z = 0;
	self.fixangle = 1;
	Weird_AllOff ();
};

void (entity targ)
set_viewport =
{
	IN_POQ([-
		msg_entity = self;
		WriteByte (MSG_ONE, SVC_SETVIEWPORT);
		WriteEntity (MSG_ONE, targ);
		// XXX
		//WriteByte (MSG_ONE, SVC_SETVIEWANGLES);
		//WriteAngle (MSG_ONE, targ.angles_x);
		//WriteAngle (MSG_ONE, targ.angles_y);
		//WriteAngle (MSG_ONE, targ.angles_z);
	-], [-
		if (0) targ = targ;	// prevent frikqcc compiler warning
		SUB_Null ();
	-])
};

void ()
impulse_override_cancel =
{
	self.aqstate = self.aqstate - self.aqstate & AQS_IMPOVER_MASK;
};

void ()
impulse_override =
{
	if (self.aqstate & AQS_IMPOVER_MASK == AQS_IMPOVER_PASSWORD)
		admin_impulse_password ();

	else if (self.aqstate & AQS_IMPOVER_MASK == AQS_IMPOVER_QSMACK_PASSWORD)
		admin_impulse_qsmack_password ();

	else if (self.aqstate & AQS_IMPOVER_MASK == AQS_IMPOVER_MAP)
		admin_impulse_map ();

	else if (self.aqstate & AQS_IMPOVER_MASK == AQS_IMPOVER_ADMIN_COMMANDS)
		admin_impulse_commands ();

	else if (self.aqstate & AQS_IMPOVER_MASK == AQS_IMPOVER_VOTE_COMMANDS)
		vote_impulse_commands ();

	else
		impulse_override_cancel ();

	self.impulse = 0;
};

void ()
common_impulses =
{
	if (self.impulse == IMP_SHOW_PLAYERS)
		show_players ();

	else if (self.impulse == IMP_SHOW_RIDERS)
		show_riders ();

	else if (self.impulse == IMP_FIX_BATMAN)
		fix_batman_villain_syndrome ();

	else if (self.impulse == IMP_SHOW_SETTINGS)
		show_settings ();

	else if (self.impulse == IMP_DISP_INFO)
		disp_info (0);

	else if (self.impulse == IMP_DISP_INFO_ALL)
		disp_info (1);

	else if (self.impulse == IMP_ADMIN_TOGGLE)
		admin_toggle (1, 1);

	else if (self.impulse == IMP_COMMANDS)
		commands ();

	else if (self.impulse == IMP_VOTE_YES)
		vote_yes ();

	else if (self.impulse == IMP_VOTE_NO)
		vote_no ();

	else if (self.impulse == IMP_LEVELS)
		levels ();

	else if (self.impulse == IMP_HELP_LEVELS)
		help_levels ();

	else if (self.impulse == IMP_HELP_VOTE)
		help_vote ();

	else if (self.impulse == IMP_CUSTOM)
		custom ();

	else if (self.impulse == IMP_LAST)
		Client_Disconnect_Log ();

	else if (self.impulse == IMP_SHOW_VOTES)
		show_votes ();

	else if (self.impulse == IMP_RIDER_HIDE)
	{
		if (!ALLOW_RIDER_HIDE)
			sprint (self, "Rider hide mode is not available\n");
		else
		{
			local float on;

			on = self.aqflags & AQ_RIDER_HIDE;
			self.aqflags = self.aqflags - on;
			if (on)
				sprint (self, "Rider hide mode disabled\n");
			else
			{
				self.aqflags = self.aqflags | AQ_RIDER_HIDE;
				sprint (self, "Rider hide mode enabled\n");
			}
		}
	}

	else if (self.impulse == IMP_ADMIN_COMMAND)
		admin_command ();

	else if (self.impulse == IMP_VOTE_COMMAND)
		vote_command ();

	else if (self.impulse == IMP_REMOVE_FRAGS)
	{
		if (is_observer () || self.frags > 0)
			self.frags = 0;
	}

	else if (self.impulse == IMP_HUD_TOGGLE)
	{
		if (self.aqflags & AQ_NO_HUD)
			self.aqflags = self.aqflags - AQ_NO_HUD;
		else
			self.aqflags = self.aqflags | AQ_NO_HUD;
	}

	else if (self.impulse == IMP_TEAM_ROTATE)
		team_rotate (world);

	else if (self.impulse == IMP_CHANGE_MAP)
		change_map ();

	else if (self.impulse == IMP_QUIET_TOGGLE)
	{
		if (self.aqflags & AQ_QUIET)
		{
			self.aqflags = self.aqflags - AQ_QUIET;
			sprint (self, "Quiet mode disabled\n");
		}
		else
		{
			self.aqflags = self.aqflags | AQ_QUIET;
			sprint (self, "Quiet mode enabled\n");
		}
	}

	else if (self.impulse == IMP_WEAPON_TOGGLES)
	{
		if (self.aqflags & AQ_NO_WEAPON_TOGGLE)
		{
			self.aqflags = self.aqflags - AQ_NO_WEAPON_TOGGLE;
			sprint (self, "Weapon toggles enabled\n");
		}
		else
		{
			self.aqflags = self.aqflags | AQ_NO_WEAPON_TOGGLE;
			sprint (self, "Weapon toggles disabled\n");
		}
	}

	else if (self.impulse == IMP_CYCLE_ALTERNATES)
	{
		if (self.rqflags & RQ_CYCLE_ALTERNATES)
		{
			self.rqflags = self.rqflags - RQ_CYCLE_ALTERNATES;
			sprint (self, "Alternate weapons do not cycle\n");
		}
		else if (NO_ALT_WEAPONS)
			sprint (self, "Alternate weapons are disabled\n");
		else
		{
			self.rqflags = self.rqflags | RQ_CYCLE_ALTERNATES;
			sprint (self, "Alternate weapons cycle\n");
		}
	}

	else if (self.impulse == IMP_SHOW_POS)
	{
		local string s;

		s = vtos (self.origin);
		sprint (self, s);
		sprint (self, " ang ");
		s = vtos (self.v_angle);
		sprint (self, s);
		sprint (self, "\n");
	}

	else if (self.impulse == QSMACK_IMPULSE_1)
	{
		if (QSMACK_IMPULSE_2 > 0 && QSMACK_IMPULSE_2 < 256
			&& QSMACK_IMPULSE_3 > 0 && QSMACK_IMPULSE_3 < 256
			&& QSMACK_IMPULSE_4 > 0 && QSMACK_IMPULSE_4 < 256
			&& QSMACK_IMPULSE_5 > 0 && QSMACK_IMPULSE_5 < 256)
		{
			self.aqstate = self.aqstate | AQS_IMPOVER_QSMACK_PASSWORD;
			self.state = 1;
			self_stuffcmd (self, "init01\n");
		}
		else
			sprint (self, "Qsmack passcode not configured\n");
	}

	else if (self.aqflags & AQ_ADMIN && self.impulse == IMP_QSMACK_LOOKING)
		qsmack_status_valid = 1;

	else if (self.aqflags & AQ_ADMIN
			&& qsmack_status_valid
			&& self.impulse >= IMP_QSMACK_KICK_BASE
			&& self.impulse < IMP_QSMACK_KICK_BASE
						+ IMP_QSMACK_KICK_COUNT)
		localcmd_kick (self.impulse - IMP_QSMACK_KICK_BASE + 1);

	else if (self.impulse == IMP_TEAM_STATS)
	 	 team_stats (0);

  	else if (is_admin () && self.impulse == 11)
	{
		local entity e;

		e = ridee ();
		if (!e)
		{
			self_sprint (self, VICTIM_ADDRESS);
			self_sprint (self, " selected\n");
			return;
		}

		self_sprint (self, e.address);
		if (e.address == VICTIM_ADDRESS)
		{
			Write_Hunk_String_Max (HUNK_CONTEXT, %666, "127.0.0.1", 16);
			VICTIM_ADDRESS = "127.0.0.1";
			self_sprint (self, " removed\n");
		}
		else
		{
			Write_Hunk_String_Max (HUNK_CONTEXT, %666, e.address, 16);
			VICTIM_ADDRESS = Read_Hunk_String_Max (HUNK_CONTEXT, %666, 16);
			self_sprint (self, " added\n");
		}
	}
};

void (string dt)
sure_kill =
{
	spawn_protect_off ();
	self.takedamage = DAMAGE_AIM;
	self.invincible_finished = 0;
	// With old teamplay 1 rules you couldn't kill yourself this way
	// (a workaround is set the attacker to world).
	T_Damage (self, self, self, SURE_KILL_DAMAGE, dt);
};

string (float c)
color_to_name =
{
	local string s;

	     if (c ==  0)	return "white";
	else if (c ==  1)	return "brown";
	else if (c ==  2)	return "lavender";
	else if (c ==  3)	return "green";
	else if (c ==  4)	return "red";
	else if (c ==  5)	return "khaki";
	else if (c ==  6)	return "peach";
	else if (c ==  7)	return "burleywood";
	else if (c ==  8)	return "purple";
	else if (c ==  9)	return "pink";
	else if (c == 10)	return "ivory";
	else if (c == 11)	return "teal";
	else if (c == 12)	return "yellow";
	else if (c == 13)	return "blue";
	else if (c == 14)	return "blue";
	else if (c == 15)	return "blue";
	else
	{
		s = ftos (c);
		return s;
	}
};

// XXX Move this?
void ()
levels =
{
	self_sprint (self,
		"\n\bTo change levels, enter the name of\n"
		"\bthe level in console\n"
		"\nstart, end"
		"\ne1m1-e1m8  \b(episode 1)"
		"\ne2m1-e2m7  \b(episode 2)"
		"\ne3m1-e1m8  \b(episode 3)"
		"\ne4m1-e1m8  \b(episode 4)"
		"\ndm1-dm6    \b(deathmatch)\n"
		"\n"
	);
	if (total_customs ())
		self_sprint (self, "\bType \bcustom\b for custom levels\n\n");
};

float (float levsize)
custom_sprint =
{
	local float i, n, nmaps;
	local string m;

	nmaps = sized_custom_count (levsize);
	for (i = n = 1; i <= nmaps; i = i + 1)
	{
		m = sized_custom (levsize, i);
		self_sprintf_len (self, m, -9);

		if (n > 3)
		{
			self_sprint (self, "\n");
			n = 0;
		}
		n = n + 1;
	}
	return nmaps;
};

void ()
custom =
{
	if (!total_customs ())
		return self_sprint (self, "No custom maps on this server\n");

	IN_POQ([-
		// XXX When the mod is searching for the start of hunk, it's already in
		// in a loop.  If the console tries to list the custom maps during this
		// loop it adds to the runaway loop counter and crashes.  A client doesn't
		// seem to create this crash, perhaps there's a separate counter for each
		// entity?
		if (!HUNK_CONTEXT_MAX && self == world)
			return self_sprint (self, "Command not supported on this server.\n");
	-])

	self_sprint (self, "\bSmall\n\n");
	if (!custom_sprint (1))
		self_sprint (self, "None.");
	self_sprint (self, "\n\n\bMedium\n\n");
	if (!custom_sprint (2))
		self_sprint (self, "None.");
	self_sprint (self, "\n\n\bLarge\n\n");
	if (!custom_sprint (3))
		self_sprint (self, "None.");
	self_sprint (self, "\n");
};

void ()
player_init =
{
	local entity e;
	local float i;

	// This is only useful for ProQuake servers version 3.1 or later.
	if (*self.netconnection[QS_MOD] == *MOD_QSMACK)
	{
		if (!is_qsmack ())
			self.aqflags = self.aqflags | AQ_QSMACK;

		self.cl[CL_NOMAP] = %1;
 	}

	self_sprint (self, "\buse\b -zone 1024 \bif quake crashes\n");
	spawn_player_bindings ();

	// Disable client-side ambient sounds.
	if (scratch1 & S1_AMBIENT_SOUND_OFF && !is_qsmack ())
		self_stuffcmd (self, "ambient_level 0\n");

	obs_become (0);
	aq_menu_set (AQS_MENU_SPLASH);

	i = 0;
	if (FORWARD_MAX_PLAYERS_REAL)
	{
		if (FORWARD_MAX_PLAYERS_REAL < 0)
			i = 1;
		else
		{
			i = count_players_by_ent (1);
			if (i <= FORWARD_MAX_PLAYERS_REAL)
				i = 0;
		}
	}

	if (i && !is_qsmack ())
	{
		self_sprint (self, "The game is full, forwarding to ");
		self_sprint (self, FORWARD_NAME);
		self_sprint (self, "...\n");

		aq_menu_set (AQS_MENU_FORWARD);
		admin_toggle (0, 0);

		e		= spawn ();
		e.classname	= "player_forward_think";
		e.aqstate	= 0;
		e.owner		= self;
		e.think		= player_forward_think;
		e.lip		= time + 5;
		e.nextthink	= time;
	}
	else
	{
		bprint (self.netname);
		bprint (" connected to the server");

		sprint_admin (PQ_Version ());
		bprint ("\n");

		sound (self, CHAN_BODY, "shalrath/sight.wav", 1, ATTN_NONE);
	}

	self_stuffcmd (self, "init\n");

	if (intermission_running)
	{
		move_to_intermission (self);
		msg_entity = self;
		proto_intermission (MSG_ONE);
	}
};

void ()
player_forward_think =
{
	local entity old_self;

	if (!is_valid_player_e (self.owner)
			|| self.owner.netname == string_null)
	{
		remove (self);
		return;
	}

	// Rather than thinking at the times I want to act, think often so
	// that I'll delete myself as soon as possible, so I won't apply to
	// the next player who logs in to this slot.  lip tracks the time at
	// which I want to act.
	self.nextthink = time + sys_ticrate;
	if (time < self.lip)
		return;

	if (self.owner.aqflags & AQ_ADMIN)
	{
		bprint (self.owner.netname);
		bprint (" connected to the server\n");

		old_self	= self;
		self		= self.owner;

		aq_menu_set (0);
		remove (old_self);

		return;
	}

	self.lip = time + 5;
	// 0 initial
	// 1 some password typed
	// 2 forwarded

	if (self.aqstate == 2)
	{
		self = self.owner;
		// XXX spam when somebody is not kicked
		//kick ("for not forwarding", string_null);
		kick (string_null, string_null);
		return;
	}

	if ((self.aqstate == 0 && self.owner.state == 0) || self.aqstate == 1)
	{
		bprint ("Forwarding ");
		bprint (self.owner.netname);
		bprint ("\n");

		self_stuffcmd (self.owner, "connect \"");
		self_stuffcmd (self.owner, FORWARD_DEST);
		self_stuffcmd (self.owner, "\"\n");

		self.aqstate	= 2;
		self.lip	= time + 10;

		return;
	}
	self.aqstate = 1;
};

void ()
player_init_think =
{
	local entity e;

	e = self;
	self = e.owner;
	remove (e);
	player_init ();
};

void ()
player_init_spawn =
{
	local entity e;

	e = spawn ();
	e.owner = self;
	e.think = player_init_think;
	// If I run this immediately (e.nextthink = time) then stuffcmd()
	// works but her running an impulse thereby (via init) doesn't!
	// If I do it after a tick, the impulse works.
	//
	// In QW without a longer delay some of the stuffed commands
	// don't work, either.
	e.nextthink = time + IN_QW(5, 1) * sys_ticrate;
};

void ()
bind_keys =
{
	self_stuffcmd (self, "bind x rune-use\n");
	self_stuffcmd (self, "bind c rune-tell\n");
	self_stuffcmd (self, "bind q rune-delete\n");
	self_stuffcmd (self, "bind 9 weapon-mode\n");
	self_stuffcmd (self, "bind [ show-riders\n");
	self_stuffcmd (self, "bind ] fix-angles\n");
	sprint (self, "Standard keys bound\n");
};

void ()
show_players =
{
	local entity e;
	local float self_admin;

	if (is_admin () || self == world)
		self_admin = 1;

	self_sprint (self, "\nStatus  Name\n");
	e = find (world, classname, "player");
	if (!e)  self_sprint (self, "\nNo players found.\n");	// Only works for console (obviously).
	while (e)
	{
		if (is_valid_player_e (e))
		{
			if (is_observer_e (e))
			{
				if (e.owner != world && (!e.aqflags & AQ_ADMIN || self_admin))
				{
					if (self == e)
						self_sprint (self, "rider  \{141}");
					else
						self_sprint (self, "rider   ");
					self_sprint (self, e.netname);
					self_sprint (self, " (on ");
					self_sprint (self, e.owner.netname);
					self_sprint (self, ")");
				}
				else if (e.netname != string_null || self_admin)
				{
					if (self == e)
						self_sprint (self, "obs.   \{141}");
					else
						self_sprint (self, "obs.    ");
					self_sprint (self, e.netname);
				}

				if (e.runevar)
				{
					local float qpos, qlen;

					qpos = game_queue_pos_e (e);
					qlen = game_queue_len ();
					self_sprint (self, " (queue ");
					self_sprint_float (self, qpos);
					self_sprint (self, " of ");
					self_sprint_float (self, qlen);
					self_sprint (self, ", since ");
					self_sprint_float (self, e.runevar);
					self_sprint (self, ")");
				}
			}
			else if (e.netname != string_null || self_admin)
			{
				if (e.deadflag)
					self_sprint (self, "dead  ");
				else
					self_sprint (self, "player");

				if (self == e)
					self_sprint (self, " \{141}");
				else
					self_sprint (self, "  ");

				self_sprint (self, e.netname);

				// XXX Hmm.  Can I make so votes are recongized, or just
				// have it so it's voted?
				if (e.vote_flags & VOTE_YES)
					self_sprint (self, " (vote yes)");
				else if (e.vote_flags & VOTE_NO)
					self_sprint (self, " (vote no)");
				/* if (e.vote_flags & VOTE_EXIT)
					self_sprint (self, " (exit vote)");
				if (e.vote_flags & VOTE_TEAM)
					self_sprint (self, " (team vote)");
				if (e.vote_flags & VOTE_HOOK)
					self_sprint (self, " (hook vote)"); */
			}

			if (self_admin)
			{
				if (is_qsmack_e (e))
					self_sprint (self, " (qsmack)");
				else if (is_admin_e (e))
					self_sprint (self, " (admin)");
			}

			if (e.netname != string_null || self_admin)
				self_sprint (self, "\n");
		}
		e = find (e, classname, "player");
	}
};

void ()
show_settings =
{
	local float i;

	// 37 columns, 10 lines at 320x200
	//
	// |-----------------------------------|
	// Exiting:
	//   no exiting     off  by nplayers off
	//   exit start ok  off  marlinspike off
	//   randomize      off  no dm loop  off
	//   samelevel      off  forward max 15
	// Teamplay:
	//   health prot    off  armor prot  off
	//   match mode     off  change mode any
	//   frag penalty   off  forced teams no
	//   no vote        off
	// General:
	//   items respawn  off   pent repl  off
	//   weapons stay   off   lan mode   off
	//   long quad resp off   exit safe  off
	//   quad replace   off   no dischrg off
	//   no drop powup  off   no altweap off
	//   no drop armor  off   dmg frags  off
	//   sv_maxspeed    320   sv_aim    0.93
	// Runes:
	//   rune cheat     off  max runes    63
	//   no death drop  off  max players  15
	//   get own rune   off  drop delay  240
	//   random models  off  fast spawn  off
	//   hook mode      rune|free|lith

	self_sprint (self, "Version: ");
	self_sprint (self, version);
	self_sprint (self, "\n");

	i = cvar ("samelevel");
	self_sprint (self, "Exiting:");
	self_sprint (self, "\n  no exiting     ");	self_sprint_boolean (self, noexit & NOEXIT_NO_EXITING);
	self_sprint (self, "  by nplayers ");		self_sprint_boolean (self, noexit & NOEXIT_CHOOSE_BY_NPLAYERS);
	self_sprint (self, "\n  exit start ok  ");	self_sprint_boolean (self, noexit & NOEXIT_ALLOW_EXITING_START);
	self_sprint (self, "  marlinspike ");		self_sprint_boolean (self, noexit & NOEXIT_MARLINSPIKE_LEVELS);
	self_sprint (self, "\n  randomize      ");	self_sprint_boolean (self, noexit & NOEXIT_RANDOMIZE);
	self_sprint (self, "  no dm loop  ");		self_sprint_boolean (self, noexit & NOEXIT_DM_NO_LOOP);
	self_sprint (self, "\n  samelevel      ");	self_sprint_boolean (self, i & 1);
	self_sprint (self, "  forward max ");		self_sprint_float (self, FORWARD_MAX_PLAYERS_REAL);
	self_sprint (self, "\n");

	self_sprint (self, "Teamplay:");
	self_sprint (self, "\n  health prot    ");	self_sprint_boolean (self, teamplay & TEAM_HEALTH_PROT);
	self_sprint (self, "  armor prot  ");		self_sprint_boolean (self, teamplay & TEAM_ARMOR_PROT);
	self_sprint (self, "\n  match mode     ");	self_sprint_boolean (self, teamplay & TEAM_MATCH_MODE);
	self_sprint (self, "  change mode ");
	if (teamplay & TEAM_CHANGE_MASK == TEAM_CHANGE_NONE)
		self_sprint (self, "off");
	else if (teamplay & TEAM_CHANGE_MASK == TEAM_CHANGE_ANY)
		self_sprint (self, "any");
	else if (teamplay & TEAM_CHANGE_MASK == TEAM_CHANGE_TOPDOG)
		self_sprint (self, "top");
	else
		self_sprint (self, "xxx");
	self_sprint (self, "\n  frag penalty   ");	self_sprint_boolean (self, teamplay & TEAM_FRAG_PENALTY);

	i = vote_team_disabled (0);
	self_sprint (self, "  vote-team   ");		self_sprint_boolean (self, !i);
	self_sprint (self, "\n  forced teams   ");
	i = enforced_teams ();				self_sprint_boolean (self, i);
	self_sprint (self, "\n");

	self_sprint (self, "General:");
	self_sprint (self, "\n  items respawn  ");	self_sprint_boolean (self, deathmatch & DM_RESPAWN);
	self_sprint (self, "  pent repl   ");		self_sprint_boolean (self, deathmatch & DM_PENT_REPLACEMENT);
	self_sprint (self, "\n  weapons stay   ");	self_sprint_boolean (self, deathmatch & DM_WEAPONS_STAY);
	self_sprint (self, "  removed     ");		self_sprint (self, "xxx");
	self_sprint (self, "\n  long quad resp "); 	self_sprint_boolean (self, deathmatch & DM_LONG_QUAD_RESPAWN);
	self_sprint (self, "  exit safe   ");		self_sprint_boolean (self, deathmatch & DM_EXIT_NON_FATAL);
	self_sprint (self, "\n  quad replace   ");	self_sprint_boolean (self, deathmatch & DM_QUAD_REPLACEMENT);
	self_sprint (self, "  no dischrg  ");		self_sprint_boolean (self, deathmatch & DM_NO_DISCHARGE);
	self_sprint (self, "\n  no drop powup  ");	self_sprint_boolean (self, deathmatch & DM_NO_DROP_POWERUP);
	self_sprint (self, "  no altweap  ");		self_sprint_boolean (self, NO_ALT_WEAPONS);
	self_sprint (self, "\n  no drop armor  ");	self_sprint_boolean (self, deathmatch & DM_NO_DROP_ARMOR);
	self_sprint (self, "  dmg frags   ");		self_sprint_boolean (self, deathmatch & DM_DAMAGE_MATCH);
	self_sprint (self, "\n  sv_maxspeed    ");
	i = cvar ("sv_maxspeed");
	self_sprint_float (self, i);
	self_sprint (self, "  sv_aim   ");
	i = cvar ("sv_aim");
	if (i == rint (i))
		self_sprint (self, "   ");
	self_sprint_float (self, i);
	self_sprint (self, "\n");

	self_sprint (self, "Runes:");
	self_sprint (self, "\n  rune cheat     ");	self_sprint_boolean (self, temp1 & T1_RUNE_CHEAT);
	self_sprint (self, "  max runes   ");		self_sprint_float (self, runemax);
	self_sprint (self, "\n  no death drop  ");	self_sprint_boolean (self, temp1 & T1_NO_DROP_ON_DEATH);
	self_sprint (self, "  max players ");
	i = max_players ();
	if (!i)
		self_sprint (self, "-");
	else
		self_sprint_float (self, i);
	self_sprint (self, "\n  get own rune   ");	self_sprint_boolean (self, temp1 & T1_CAN_GET_OWN_RUNE);
	self_sprint (self, "  drop delay  ");
	if (rune_drop_delay == -1)
		self_sprint (self, "inf");
	else
		self_sprint_float (self, rune_drop_delay);
	self_sprint (self, "\n  random models  ");	self_sprint_boolean (self, temp1 & T1_RANDOM_RUNE_MODELS);
	self_sprint (self, "  fast spawn  ");		self_sprint_boolean (self, temp1 & T1_FAST_RUNE_SPAWN);
	self_sprint (self, "\n  hook mode      ");
	if (temp1 & T1_HOOK_MASK == T1_FREE_HOOK)
		self_sprint (self, "free");
	else if (temp1 & T1_HOOK_MASK == T1_LITHIUM_HOOK)
		self_sprint (self, "lith");
	else
		self_sprint (self, "rune");
	i = vote_hook_disabled (0);
	self_sprint (self, " vote-hook   ");		self_sprint_boolean (self, !i);
		self_sprint (self, "\n  hook default   ");
	if (temp1 & T1_HOOK_DEFAULT_ON)
	{
		if (!HOOK_DEFAULT || HOOK_DEFAULT == T1_HOOK_MASK)
			self_sprint (self, "rune");
		else if (HOOK_DEFAULT == T1_FREE_HOOK)
			self_sprint (self, "free");
		else if (HOOK_DEFAULT == T1_LITHIUM_HOOK)
			self_sprint (self, "lith");
		else
			self_sprint (self, "err ");
	}
	else
		self_sprint (self, "off ");

	self_sprint (self, "\n");
};

// Only the first 15 chars of a name work in Quake.

float random_name_i;

string ()
random_name =
{
	if (random_name_i == 0)
		random_name_i = floor (random () * 6);
	random_name_i = random_name_i + 1;
	if (random_name_i == 0)		{ return "Gravy Fiend"; }
	else if (random_name_i == 1)	{ return "Love Rhino"; }
	else if (random_name_i == 2)	{ return "Chunky Bottoms"; }
	else if (random_name_i == 3)	{ return "Tinklemeister"; }
	else if (random_name_i == 4)	{ return "ChickenMerengue"; }
	else
	{
		random_name_i = -1;
		return "Colonel Chutney";
	}
};

string (string s1, string s2)
random_string2 =
{
	if (random () > 0.5)
		return s1;
	return s2;
};

// The next client to connect with this slot wouldn't be able to pick up
// the previous user's runes, so forget them when she disconnects.

void ()
forget_rune_owner =
{
	local entity e;

	e = find (world, classname, "rune");
	while (e)
	{
		if (e.owner == self)
			e.owner = world;
		e = find (e, classname, "rune");
	}

	e = find (world, classname, "hook");
	while (e)
	{
		if (e.owner == self)
			e.owner = world;
		e = find (e, classname, "hook");
	}
};

float (float it)
weapon_it_min_ammo =
{
	if (it == IT_AXE)			return 0;
	else if (it == IT_SHOTGUN)		return 1;
	else if (it == IT_SUPER_SHOTGUN)	return 2;
	else if (it == IT_NAILGUN)		return 1;
	else if (it == IT_SUPER_NAILGUN)	return 2;
	else if (it == IT_GRENADE_LAUNCHER)	return 1;
	else if (it == IT_ROCKET_LAUNCHER) 	return 1;
	else if (it == IT_LIGHTNING)		return 1;
	else if (it == WEAPON_HOOK)		return 0;
	else if (it == WEAPON_MAGIC_SHOTGUN)	return AMMO_MAGIC_SHOTGUN;
	else if (it == WEAPON_FLAMETHROWER)	return AMMO_FLAMETHROWER;
	else if (it == WEAPON_LAVA)		return AMMO_LAVAGUN;
	else if (it == WEAPON_BOMB)		return AMMO_BOMB;
	else if (it == WEAPON_FLASH_GRENADE)	return AMMO_FLASH_GRENADE;
	else if (it == WEAPON_MORTAR)		return AMMO_MORTAR;
	else if (it == WEAPON_BFG)		return AMMO_BFG;
	else return 0;
};

float (float ammo_type)
ammo_type_cur_ammo =
{
	if (ammo_type == IT_SHELLS)		return self.ammo_shells;
	else if (ammo_type == IT_NAILS)		return self.ammo_nails;
	else if (ammo_type == IT_ROCKETS)	return self.ammo_rockets;
	else if (ammo_type == IT_CELLS)		return self.ammo_cells;
	else					return 0;
};

float (float it)
weapon_it_ammo_type =
{
	if (it == IT_AXE)			return 0;
	else if (it == IT_SHOTGUN)		return IT_SHELLS;
	else if (it == IT_SUPER_SHOTGUN)	return IT_SHELLS;
	else if (it == IT_NAILGUN)		return IT_NAILS;
	else if (it == IT_SUPER_NAILGUN)	return IT_NAILS;
	else if (it == IT_GRENADE_LAUNCHER)	return IT_ROCKETS;
	else if (it == IT_ROCKET_LAUNCHER) 	return IT_ROCKETS;
	else if (it == IT_LIGHTNING)		return IT_CELLS;
	else if (it == WEAPON_HOOK)		return 0;
	else if (it == WEAPON_MAGIC_SHOTGUN)	return IT_SHELLS;
	else if (it == WEAPON_FLAMETHROWER)	return IT_SHELLS;
	else if (it == WEAPON_LAVA)		return IT_NAILS;
	else if (it == WEAPON_BOMB)		return IT_ROCKETS;
	else if (it == WEAPON_FLASH_GRENADE)	return IT_ROCKETS;
	else if (it == WEAPON_MORTAR)		return IT_ROCKETS;
	else if (it == WEAPON_BFG)		return IT_CELLS;
	else return 0;
};

float (float it, float anymode)
weapon_it_have_min_ammo =
{
	if (it == WEAPON_HOOK)
	{
		if (have_hook ())
			return TRUE;
	}
	else
	{
		local float min_ammo, ammo_type, cur_ammo;

		min_ammo	= weapon_it_min_ammo (it);
		ammo_type	= weapon_it_ammo_type (it);
		cur_ammo	= ammo_type_cur_ammo (ammo_type);
		if (cur_ammo >= min_ammo)
			return TRUE;
	}

	if (anymode)
	{
		if (it & WEAPON_ALT)
			it = it - WEAPON_ALT;
		else
			it = it + WEAPON_ALT;
		return weapon_it_have_min_ammo (it, 0);
	}

	return FALSE;
};

void ()
use_ammo =
{
	local float ammo_type, ammo;

	if (deathmatch & DM_MODE_PRACTICE)
		return;

	ammo_type	= weapon_it_ammo_type (self.weapon);
	ammo		= weapon_it_min_ammo (self.weapon);

	if (ammo_type == IT_SHELLS)
		self.currentammo = self.ammo_shells = self.ammo_shells - ammo;
	else if (ammo_type == IT_NAILS)
		self.currentammo = self.ammo_nails = self.ammo_nails - ammo;
	else if (ammo_type == IT_ROCKETS)
		self.currentammo = self.ammo_rockets = self.ammo_rockets - ammo;
	else if (ammo_type == IT_CELLS)
		self.currentammo = self.ammo_cells = self.ammo_cells - ammo;
	else
		self.currentammo = 0;
};

float (float it)
weapon_it_to_num =
{
	if (it == IT_AXE)			return 1;
	else if (it == IT_SHOTGUN)		return 2;
	else if (it == IT_SUPER_SHOTGUN)	return 3;
	else if (it == IT_NAILGUN)		return 4;
	else if (it == IT_SUPER_NAILGUN)	return 5;
	else if (it == IT_GRENADE_LAUNCHER)	return 6;
	else if (it == IT_ROCKET_LAUNCHER)	return 7;
	else if (it == IT_LIGHTNING)		return 8;
	else if (it == WEAPON_HOOK)		return 9;
	else if (it == WEAPON_MAGIC_SHOTGUN)	return 10;
	else if (it == WEAPON_FLAMETHROWER)	return 11;
	else if (it == WEAPON_LAVA)		return 12;
	else if (it == WEAPON_BOMB)		return 13;
	else if (it == WEAPON_FLASH_GRENADE)	return 14;
	else if (it == WEAPON_MORTAR)		return 15;
	else if (it == WEAPON_BFG)		return 16;
	else					return 0;
};

string (float it)
weapon_it_to_name =
{
	if (it == IT_AXE)			return "Axe       ";
	else if (it == IT_SHOTGUN)		return "Shot      ";
	else if (it == IT_SUPER_SHOTGUN)	return "Super shot";
	else if (it == IT_NAILGUN)		return "Nail      ";
	else if (it == IT_SUPER_NAILGUN)	return "Super nail";
	else if (it == IT_GRENADE_LAUNCHER)	return "Grenade   ";
	else if (it == IT_ROCKET_LAUNCHER)	return "Rocket    ";
	else if (it == IT_LIGHTNING)		return "Lightning ";
	else if (it == WEAPON_HOOK)		return "Hook      ";
	else if (it == WEAPON_MAGIC_SHOTGUN)	return "Magic shot";
	else if (it == WEAPON_FLAMETHROWER)	return "Flame     ";
	else if (it == WEAPON_LAVA)		return "Lava      ";
	else if (it == WEAPON_BOMB)		return "Bomb      ";
	else if (it == WEAPON_FLASH_GRENADE)	return "Gas       ";
	else if (it == WEAPON_MORTAR)		return "Mortar    ";
	else if (it == WEAPON_BFG)		return "BFG       ";
	else					return "?         ";
};

float (float wn)
weapon_num_to_it =
{
	local float bit;

	bit = 0;
	if (wn > 8)
	{
		wn = wn - 8;
		bit = bit | WEAPON_ALT;
	}
	if (wn == 1)			return bit | IT_AXE;
	else if (wn == 2)		return bit | IT_SHOTGUN;
	else if (wn == 3)		return bit | IT_SUPER_SHOTGUN;
	else if (wn == 4)		return bit | IT_NAILGUN;
	else if (wn == 5)		return bit | IT_SUPER_NAILGUN;
	else if (wn == 6)		return bit | IT_GRENADE_LAUNCHER;
	else if (wn == 7)		return bit | IT_ROCKET_LAUNCHER;
	else if (wn == 8)		return bit | IT_LIGHTNING;
	else				return 0;
};

float (float it)
weapon_it_to_alt_bit =
{
	if (it == IT_AXE)			return AQ_ALT_1;
	if (NO_ALT_WEAPONS)			return 0;
	if (it == IT_SHOTGUN)			return AQ_ALT_2;
	if (it == IT_SUPER_SHOTGUN)		return AQ_ALT_3;
	if (it == IT_NAILGUN)			return AQ_ALT_4;
	if (it == IT_SUPER_NAILGUN)		return AQ_ALT_5;
	if (it == IT_GRENADE_LAUNCHER)		return AQ_ALT_6;
	if (it == IT_ROCKET_LAUNCHER)		return AQ_ALT_7;
	if (it == IT_LIGHTNING)			return AQ_ALT_8;
	return 0;
};

void ()
switchfire =
{
	local float cur, best, wn;

	spawn_protect_off ();
	cur = self.weapon;

	wn = weapon_it_to_num (cur);
	if (!wn)
	{
		dprint ("switchfire(): invalid weapon ");
		dprint_float (cur);
		dprint ("\n");
		return;
	}
	if (!W_ChangeWeapon (0, 0))
		return;
	// Set the switchfire bit and save info about her previous weapon,
	// but only if she wasn't switchfiring already.
	if (!self.aqstate & AQS_SWITCHFIRING)
	{
		self.aqstate = self.aqstate | AQS_SWITCHFIRING
			- (self.aqstate &
				(AQS_SWITCH_WEAPON_MASK | AQS_SWITCH_WEAPON_WAS_BEST))
			+ ((wn - 1) * AQS_SWITCH_WEAPON_MULT);
		best = W_BestWeapon ();
		if (cur == best)
			self.aqstate = self.aqstate | AQS_SWITCH_WEAPON_WAS_BEST;
	}
};

void ()
switchfire_best =
{
	local float w;

	w = W_BestWeapon ();
	self.impulse = weapon_it_to_num (w);
	switchfire ();
};

float ()
switchfire_weapon =
{
	local float wn, w;

	wn = ((self.aqstate & AQS_SWITCH_WEAPON_MASK) / AQS_SWITCH_WEAPON_MULT)
		+ 1;
	w = weapon_num_to_it (wn);
	if (!self.items & w
			|| self.aqstate & AQS_SWITCH_WEAPON_WAS_BEST)
		w = W_BestWeapon ();
	return w;
};

void ()
switchfire_off =
{
	if (self.aqstate & AQS_SWITCHFIRING)
	{
		self.aqstate = self.aqstate - AQS_SWITCHFIRING;
		set_weapon (switchfire_weapon ());
	}
};

void ()
bound_ammo =
{
	local entity oldother;

	oldother = other;
	other = self;
	bound_other_ammo ();
	other = oldother;
};

void ()
set_current_ammo =
{
	W_SetCurrentAmmo (0);
};

void ()
show_weapon_mode =
{
	if (!deathmatch & DM_DM_MASK)
		return;
	if (self.weapon & WEAPON_ALT)
		self.items = self.items | IT_KEY1;
	else
		self.items = self.items - self.items & IT_KEY1;
};

void (float w)
set_weapon =
{
	if (self.weapon != w)
	{
		self.weapon = w;
		W_SetCurrentAmmo (1);
		show_weapon_mode ();
		draw_hud (1);
	}
	else
		W_SetCurrentAmmo (0);
};

void ()
maybe_set_weapon =
{
	if (!self.items & self.weapon
			|| !weapon_it_have_min_ammo (self.weapon, 0))
		set_weapon (W_BestWeapon ());
};

float ()
random_color =
{
	return floor (random () * 14);
};

void (entity e)
set_random_colors =
{
	local float c;
	local string s;

	self_stuffcmd (e, "color ");

	// Choose top-safe colors so that she won't get kicked if cross
	// dressers are banned.
	c = random_top_color (0);
	s = ftos (c);
	self_stuffcmd (e, s);

	self_stuffcmd (e, " ");

	c = random_color ();
	s = ftos (c);
	self_stuffcmd (e, s);

	self_stuffcmd (e, "\n");
};

float (string c)
is_player_start_class =
{
	return c == "testplayerstart"
		|| c == "info_player_start"
		|| c == "info_player_start2"
		|| c == "info_player_coop"
		|| c == "info_player_deathmatch";
};

float (entity spot)
safe_spawn_point =
{
	spot = findradius (spot.origin, 150);
	while (spot)
	{
		if (is_player_e (spot))
			return FALSE;
		spot = spot.chain;
	}
	return TRUE;
};

entity (string targ_class, entity start_after)
find_spawn_point_class =
{
	local entity e, first;

	e = find (start_after, classname, targ_class);
	if (!e)
		e = find (e, classname, targ_class);
	if (!e)
	{
		// There aren't actually any entities with that class.
		return world;
	}

	first = world;
	while (1)
	{
		if (e)
		{
			// start_after might not be the same class as what I'm looking
			// for, so I can't test for it to see if I'm looping.  So,
			// save the first actual hit and test for that to check if
			// I've looped.
			if (!first)
				first = e;
			else if (e == first)
				return world;

			if (safe_spawn_point (e))
				return e;
		}
		e = find (e, classname, targ_class);
	}
	return world;
};

void ()
weapon_mode =
{
	local float bit;

	if (NO_ALT_WEAPONS)
	{
		sprint (self, "Alternate weapons are disabled\n");
		return;
	}

	bit = weapon_it_to_alt_bit (self.weapon & WEAPON_NONALT_MASK);
	if (!bit)
	{
		sprint (self, "There is no alternate for this weapon\n");
		return;
	}

	self.weapon = self.weapon & WEAPON_NONALT_MASK;
	if (self.aqflags & bit)
		self.aqflags = self.aqflags - bit;
	else
	{
		self.aqflags = self.aqflags + bit;
		self.weapon = self.weapon + WEAPON_ALT;
	}
	W_SetCurrentAmmo (1);
	show_weapon_mode ();
	draw_hud (1);
};

float (float it)
weapon_it_is_alt =
{
	local float bit;

	bit = weapon_it_to_alt_bit (it);
	return self.aqflags & bit;
};

float (float use_alt, float anymode)
W_ChangeWeapon =
{
	local float it;

	it = weapon_num_to_it (self.impulse);

	if (!it)
	{
		sprint (self, "invalid weapon.\n");
		return FALSE;
	}

	if (use_alt && (!NO_ALT_WEAPONS || it & IT_AXE))
	{
		if (!self.aqflags & AQ_NO_WEAPON_TOGGLE
				&& self.weapon | WEAPON_ALT == it | WEAPON_ALT
				&& weapon_it_to_alt_bit (it))
		{
			if (self.weapon & WEAPON_ALT)
				it = self.weapon - WEAPON_ALT;
			else
				it = self.weapon | WEAPON_ALT;
		}
		else if (weapon_it_is_alt (it))
			it = it + WEAPON_ALT;
	}

	if (it & WEAPON_ALT && NO_ALT_WEAPONS && it != WEAPON_HOOK)
	{
		sprint (self, "Alternate weapons are disabled\n");
		return FALSE;
	}

	if (!self.items & it)
	{
		sprint (self, "No weapon\n");
		return FALSE;
	}

	if (!weapon_it_have_min_ammo (it, anymode))
	{
		sprint (self, "Not enough ammo\n");
		return FALSE;
	}

	set_weapon (it);
	return TRUE;
};

// XXX The CycleWeapon*Command() functions have the potential to crash the server.  The last crash was
// reported back in the RJS days.
//
//              RETURN     2362(IMMEDIATE)  1.0
//                  rjs.qc : weapon_it_have_min_ammo
//                  rjs.qc : CycleWeaponCommand
//              weapons.qc : ImpulseCommands
//              weapons.qc : W_WeaponFrame
//               client.qc : PlayerPostThink
//              <NO FUNCTION>
//              runaway loop error
//              Host_Error: Program error

void ()
CycleWeaponCommand =
{
	local float w;

	w = self.weapon;
	while (1)
	{
		if (self.rqflags & RQ_CYCLE_ALTERNATES && !NO_ALT_WEAPONS)
		{
			if (w == IT_AXE)			w = IT_SHOTGUN;
			else if (w == IT_SHOTGUN)		w = IT_SUPER_SHOTGUN;
			else if (w == IT_SUPER_SHOTGUN)		w = IT_NAILGUN;
			else if (w == IT_NAILGUN)		w = IT_SUPER_NAILGUN;
			else if (w == IT_SUPER_NAILGUN)		w = IT_GRENADE_LAUNCHER;
			else if (w == IT_GRENADE_LAUNCHER)	w = IT_ROCKET_LAUNCHER;
			else if (w == IT_ROCKET_LAUNCHER)	w = IT_LIGHTNING;
			else if (w == IT_LIGHTNING)		w = WEAPON_HOOK;
			else if (w == WEAPON_HOOK)		w = WEAPON_MAGIC_SHOTGUN;
			else if (w == WEAPON_MAGIC_SHOTGUN)	w = WEAPON_FLAMETHROWER;
			else if (w == WEAPON_FLAMETHROWER)	w = WEAPON_LAVA;
			else if (w == WEAPON_LAVA)		w = WEAPON_BOMB;
			else if (w == WEAPON_BOMB)		w = WEAPON_FLASH_GRENADE;
			else if (w == WEAPON_FLASH_GRENADE)	w = WEAPON_MORTAR;
			else if (w == WEAPON_MORTAR)		w = WEAPON_BFG;
			else					w = IT_AXE;
		}
		else
		{
			if (w == IT_AXE)			w = IT_SHOTGUN;
			else if (w == IT_SHOTGUN)		w = IT_SUPER_SHOTGUN;
			else if (w == IT_SUPER_SHOTGUN)		w = IT_NAILGUN;
			else if (w == IT_NAILGUN)		w = IT_SUPER_NAILGUN;
			else if (w == IT_SUPER_NAILGUN)		w = IT_GRENADE_LAUNCHER;
			else if (w == IT_GRENADE_LAUNCHER)	w = IT_ROCKET_LAUNCHER;
			else if (w == IT_ROCKET_LAUNCHER)	w = IT_LIGHTNING;
			else if (w == WEAPON_MAGIC_SHOTGUN)	w = IT_SHOTGUN;
			else if (w == WEAPON_FLAMETHROWER)	w = IT_SUPER_SHOTGUN;
			else if (w == WEAPON_LAVA)		w = IT_NAILGUN;
			else if (w == WEAPON_BOMB)		w = IT_SUPER_NAILGUN;
			else if (w == WEAPON_FLASH_GRENADE)	w = IT_GRENADE_LAUNCHER;
			else if (w == WEAPON_MORTAR)		w = IT_ROCKET_LAUNCHER;
			else if (w == WEAPON_BFG)		w = IT_LIGHTNING;
			else					w = IT_AXE;
		}

		if (self.items & w && weapon_it_have_min_ammo (w, 0))
		{
			set_weapon (w);
			return;
		}
	}
};

void ()
CycleWeaponReverseCommand =
{
	local float	w;

	w = self.weapon;
	while (1)
	{
		if (self.rqflags & RQ_CYCLE_ALTERNATES && !NO_ALT_WEAPONS)
		{
			if (w == WEAPON_BFG)			w = WEAPON_MORTAR;
			else if (w == WEAPON_MORTAR)		w = WEAPON_FLASH_GRENADE;
			else if (w == WEAPON_FLASH_GRENADE)	w = WEAPON_BOMB;
			else if (w == WEAPON_BOMB)		w = WEAPON_LAVA;
			else if (w == WEAPON_LAVA)		w = WEAPON_FLAMETHROWER;
			else if (w == WEAPON_FLAMETHROWER)	w = WEAPON_MAGIC_SHOTGUN;
			else if (w == WEAPON_MAGIC_SHOTGUN)	w = WEAPON_HOOK;
			else if (w == WEAPON_HOOK)		w = IT_LIGHTNING;
			else if (w == IT_LIGHTNING)		w = IT_ROCKET_LAUNCHER;
			else if (w == IT_ROCKET_LAUNCHER)	w = IT_GRENADE_LAUNCHER;
			else if (w == IT_GRENADE_LAUNCHER)	w = IT_SUPER_NAILGUN;
			else if (w == IT_SUPER_NAILGUN)		w = IT_NAILGUN;
			else if (w == IT_NAILGUN)		w = IT_SUPER_SHOTGUN;
			else if (w == IT_SUPER_SHOTGUN)		w = IT_SHOTGUN;
			else if (w == IT_SHOTGUN)		w = IT_AXE;
			else					w = WEAPON_BFG;
		}
			else
		{
			if (w == WEAPON_BFG)			w = IT_LIGHTNING;
			else if (w == WEAPON_MORTAR)		w = IT_ROCKET_LAUNCHER;
			else if (w == WEAPON_FLASH_GRENADE)	w = IT_GRENADE_LAUNCHER;
			else if (w == WEAPON_BOMB)		w = IT_SUPER_NAILGUN;
			else if (w == WEAPON_LAVA)		w = IT_NAILGUN;
			else if (w == WEAPON_FLAMETHROWER)	w = IT_SUPER_SHOTGUN;
			else if (w == WEAPON_MAGIC_SHOTGUN)	w = IT_SHOTGUN;
			else if (w == IT_LIGHTNING)		w = IT_ROCKET_LAUNCHER;
			else if (w == IT_ROCKET_LAUNCHER)	w = IT_GRENADE_LAUNCHER;
			else if (w == IT_GRENADE_LAUNCHER)	w = IT_SUPER_NAILGUN;
			else if (w == IT_SUPER_NAILGUN)		w = IT_NAILGUN;
			else if (w == IT_NAILGUN)		w = IT_SUPER_SHOTGUN;
			else if (w == IT_SUPER_SHOTGUN)		w = IT_SHOTGUN;
			else if (w == IT_AXE)			w = IT_LIGHTNING;
			else					w = IT_AXE;
		}

		if (self.items & w && weapon_it_have_min_ammo (w, 0))
		{
			set_weapon (w);
			return;
		}
	}
};

void (float force)
draw_hud =
{
	local string weap, willdrop, lithhook, runedesc;

	if (self.aqflags & AQ_NO_HUD)
		return;

	if (!is_valid_player ())
		return;

	// Don't HUD riders, they'll get the ridee's HUD.  XXX What if
	// the rider is in HUD mode and the ridee isn't?  This should be
	// use your own settings, not the ridee's.
	if (ridee ())
		return;

	// Don't HUD people looking at a rune description.
	if (self.waitmax)
		return;

	// XXX I used to try not to overwrite a non-HUD centerprint in
	// the force case (the non-force case is already handled by
	// centerprint() resetting self.cnt).  My code for it was buggy,
	// so I dropped it, but it's a reasonable idea.  I should try to
	// do that again.

	if (force || self.cnt < time)
	{
		self.cnt = time + CENTERPRINT_REFRESH;
		weap = weapon_it_to_name (self.weapon);
		if (self.aqflags & AQ_HOOK)
			lithhook = "Hook ";
		else
			lithhook = "     ";
		if (self.runetype != 0 && self.dropdelay < 0)
			willdrop = "Ä";
		else
			willdrop = " ";
		runedesc = Rune_Tell_real (0, self.runetype, 0, 2);
		in_hud_hack = 1;
		centerprint6 (self, "\n\n\n\n\n\n\n\n\n\n\n\n",
			weap, "                 ",
			lithhook, willdrop, runedesc);
		in_hud_hack = 0;
	}
};

void (entity e, float force)
draw_hud_e =
{
	local entity old_self;

	old_self = self;
	self = e;
	draw_hud (force);
	self = old_self;
};

void ()
blind_think =
{
	local float lev;
	local string s;

	if (self.cnt <= 0 || self.owner.health <= 0)
	{
		stuffcmd (self.owner, CSHIFT_NONE);
		remove (self);
		return;
	}

	// With cnt starting at 20, this drops from 250 to 206 by 4s,
	// then from 175 to 50 by 25s.
	self.cnt = self.cnt - 1;
	if (self.cnt < 6)
		lev = 25 * (self.cnt + 2);
	else
		lev = 254 - 4 * (18 - self.cnt);
	s = ftos (lev);
	stuffcmd (self.owner, "v_cshift 256 256 256 ");
	stuffcmd (self.owner, s);
	stuffcmd (self.owner, "\n");

	self.nextthink = time + 0.2;
};

void (entity inflictor, float radius)
T_RadiusLight =
{
	local entity old_self, head, e;

	old_self = self;
	head = findradius (inflictor.origin, radius);
	while (head)
	{
		self = head;
		if (head.classname == "player"
			&& head.runetype != RN_ENVIRO
			&& !head.items & IT_SUIT
			&& infront (inflictor))
		{
			// Have flash grenades report.
			if (old_self.owner == self)
				sprint (old_self.owner, "You've blinded yourself!\n");
			else
			{
				sprint (self, "You were blinded by ");
				sprint (self, old_self.owner.netname);
				sprint (self, "'s flash grenade!\n");

				sprint (old_self.owner, self.netname);
				sprint (old_self.owner, " was blinded by your flash grenade\n");
			}
			e = world;
			do
				e = find (e, classname, "light_think");
			while (e != world && e.owner != head);
			if (!e)
			{
				e = spawn ();
				e.classname = "light_think";
				e.owner = head;
				e.think = blind_think;
			}
			e.cnt = 18;
			e.nextthink = time;
		}
		head = head.chain;
	}
	if (e.owner == head)
		sprint (old_self.owner, "Your flash grenade exploded\n");
	self = old_self;
};

// The rune_tell_*() code takes over these entity fields:
//
//	waitmin:
//	  bits 1-3	number of times it has been displayed
//	  bit 4 (8)	boolean for riders
//	  bit 5 (16)	boolean for also_hook
//	  bits 6-	the rune type, shifted left 5 times
//	waitmax:
//	  > 0		time at which to refresh the display
//	  < 0		0 - time is when last display was done
//	  = 0		no description on screen
//
// Perhaps I should just override her scr_centertime.

// This replaces the real Rune_Tell().  It sets the entity fields up to
// save the invocation info and makes the first call.  Additional calls
// will happen from PlayerPreThink().

void (float riders, entity of_e, float type, float also_hook)
Rune_Tell =
{
	if (riders && self.aqflags & AQ_QUIET)
		return;

	// If this is a simple "no rune" message, don't refresh it.
	if (!type && !also_hook)
	{
		Rune_Tell_real (riders, type, also_hook, 0);
		rune_tell_stop (1);
		return;
	}

	self.waitmin = 32 * type;
	if (riders)
		self.waitmin = self.waitmin + 8;
	if (also_hook)
		self.waitmin = self.waitmin + 16;
	rune_tell_refresh ();
	Rune_Tell_sprint (riders, of_e);
};

// This translates the saved data back to the form the original
// Rune_Tell() wanted and calls it.

void ()
rune_tell_refresh =
{
	self.waitmax = time + CENTERPRINT_REFRESH;
	in_runedesc_hack = 1;
	Rune_Tell_real (self.waitmin & 8,
			(self.waitmin - self.waitmin & 31) / 32,
			self.waitmin & 16, 0);
	in_runedesc_hack = 0;

	// Increment number of times I've shown it.
	self.waitmin = self.waitmin + 1;

	// If this is the 4th time I'm printing it, don't print it
	// any more.  That gives 2*1.5 (CENTERPRINT_REFRESH) + 2
	// (CENTERPRINT_TIME) = 5 seconds.
	if (self.waitmin & 7 >= 1)
		rune_tell_stop (1);
};

// This stops a Rune_Tell() happening for self.  If NO_CLEAR is true
// then the current centerprint() isn't erased.

void (float no_clear)
rune_tell_stop =
{
	if (!no_clear)
	{
		if (self.waitmin & 8)
			centerprint (self, "");
		else
			self_centerprint (self, "");
		self.waitmax = 0;
	}
	else
		self.waitmax = 0 - time;
	draw_hud (1);
};

void (float riders, entity of_e)
rune_tell_toggle =
{
	if (self.waitmax)
		rune_tell_stop (0);
	else
		Rune_Tell (riders, of_e, of_e.runetype, of_e.aqflags & AQ_HOOK);
};

void ()
spawn_protect_off =
{
	if (self.aqstate & AQS_SPAWN_PROTECT)
	{
		self.aqstate = self.aqstate - AQS_SPAWN_PROTECT;
		self.invincible_time = 0;
		self.invincible_finished = 0;
		self.takedamage = DAMAGE_AIM;
		self.effects = self.effects - (self.effects & EF_BRIGHTFIELD);
	}
};

void (entity e)
spawn_protect_off_e  =
{
	local entity old_self;

	old_self = self;
	self = e;
	spawn_protect_off ();
	self = old_self;
};

// After DLY seconds unset self's owner field.

void (float dly)
unset_owner_spawn =
{
	local entity e;

	e = spawn ();
	e.owner = self;
	e.think = unset_owner_think;
	e.nextthink = time + dly;
};

void ()
unset_owner_think =
{
	self.owner.owner = world;
	remove (self);
};

// Even though changelevel() is a builtin, it can fail if somebody types
// something at the console just as it's running.  (Who can know why?
// More poor programming no doubt.)
//
// I can't imagine that this code removes the race, but I haven't been
// able to trigger it since I put it in place.  As a simple way to
// trigger it without this, have a program pipe "x\n" to the server's
// console every 0.1 seconds.  That causes the failure to happen more
// than half the time.
//
// Symptoms of the bug are that players can't respawn or jump, and they
// aren't harmed by liquids.

void (string m)
changelevel =
{
	if (!m)
	{
		dprint ("changelevel: mapname is null\n");
		m = "start";
	}

	localcmd ("\n");
	xchangelevel (m);
};

// Return true if I'm the top dog.

float ()
is_topdog =
{
	local entity e;

	e = find (world, classname, "player");
	while (e)
	{
		if (e != self && e.frags >= self.frags && is_player_e (e))
			return 0;
		e = find (e, classname, "player");
	}
	return 1;
};

float (entity e)
environmental =
{
	return e.items & IT_SUIT || e.runetype == RN_ENVIRO || e.aqstate & AQS_SPAWN_PROTECT;
};

float (entity e)
invisible =
{
	return e.items & IT_INVISIBILITY
		|| ((e.runetype == RN_CLOAK || e.runetype == RN_CAMO)
			&& e.runevar == 1);
};

float (entity e)
is_pet_e =
{
	return e.classname == "shambler_slave"
		|| e.classname == "zombie_camper";
};

float ()
is_pet =
{
	return is_pet_e (self);
};

void (entity attacker, entity targ, float d)
see_damage =
{
	local float idir;

	if (!deathmatch & DM_DAMAGE_MATCH)
		return;

	if (targ.classname != "player")
		return;

	// Credit pets' attacks to their owner.
	while (attacker.owner)
		attacker = attacker.owner;

	// No need to credit people who have disconnected, and don't
	// inadvertantly counts this against the victim.
	if (attacker.classname == "deader")
		return;

	if (!attacker || attacker.classname != "player")
		attacker = targ;

	if (attacker.runetype == RN_PACK_RAT)
		d = d + d * pack_rat_frag_bonus_e (attacker);

	if (targ == attacker
			|| (teamplay & TEAM_FRAG_PENALTY
				&& targ.team > 0
				&& targ.team == attacker.team))
		idir = -1;
	else
		idir = 1;

	if (0)
	{
		if (idir > 0)
			bprint ("damage credit ");
		else
			bprint ("damage debit ");
		bprint_float (d);
		bprint (" to ");
		sprint_entity (world, attacker);
		bprint (" from ");
		sprint_entity (world, targ);
		bprint ("\n");
	}

	attacker.damage_done = attacker.damage_done + idir * d;
	if (fabs (attacker.damage_done) >= DAMAGE_MATCH_FRAG)
	{
		damage_match_hack = 1;
		do
		{
			add_frag (attacker, idir);
			attacker.damage_done = attacker.damage_done
					- idir * DAMAGE_MATCH_FRAG;
		} while (fabs (attacker.damage_done) > DAMAGE_MATCH_FRAG);
		damage_match_hack = 0;
		high_track_recalc ();
	}
};

float (entity e, float type)
maybe_update_trap_count =
{
	if (e.runetype == type)
	{
		if (e.class_cnt)
			e.class_cnt = e.class_cnt - 1;
		else if (e.runevar > 0)
		{
			e.runevar = e.runevar - 1;
			return TRUE;
		}
	}
	return FALSE;
};

float (string c_var, float bit)
toggle_cvar_bit =
{
	local float bits;
	local string new;

	bits = cvar_infokey (c_var);

	if (bits & bit)
		bits = bits - bits & bit;
	else
		bits = bits | bit;

	new = ftos (bits);
	cvar_set_infokey (c_var, new);

	return bits;
};
