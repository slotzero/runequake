/*  $Id: match.qc,v 1.49 2008/07/04 04:27:56 slotzero Exp $

    Copyright (C) 2005  David 'Slot Zero' Roberts.

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

float HUNK_TEAMS = %500;
float HUNK_MATCH_TIMELIMIT = %517;
float TEAMS_PRESENT;
float MATCH_LOCKED;

void ()
match_hunk_init =
{
	local float i;

	for (i = %1; i <= %16; i = i + %1)
		Write_Hunk_Float (HUNK_CONTEXT, HUNK_TEAMS + i, 0);
};

void (entity e)
match_client_init =
{
	local float i, c, pants, colors;

	if (!*HUNK_CONTEXT)
		return;

	for (i = %1; i <= %16; i = i + %1)
	{
		colors = Read_Hunk_Float (HUNK_CONTEXT, HUNK_TEAMS + i) / %1;
  		if (colors && colors != 0x20202020)
		{
			pqc_new_team (e, colors);
			pants = colors_to_pants (colors);
			c = color_to_teamfrags (pants);
			pqc_team_frags (e, pants, c);
		}
	}
};

void ()
match_obs_init =
{
	if (is_observer_e (self.owner) || self.runevar)
	{
		if (self.runevar)
		{
			pqc_match_time (self.owner, 255, 0);
			self_stuffcmd (self.owner, "color 1\n");
			match_client_init (self.owner);
		}

		self_stuffcmd (self.owner, "color 0\n");
		self.owner.frags = -99;

		// When a player becomes an observer using the 'observer' command
		// and without being dead, CheckPowerups() overwrites the modelindex
		// that was set in obs_become().  I workaround it here.
		if (self.owner.modelindex != modelindex_eyes)
			self.owner.modelindex = modelindex_eyes;
	}

	remove (self);
};

void (float type)
match_obs_become =
{
	local entity e;

	e		= spawn ();
	e.owner		= self;
	e.runevar	= !type;

	e.think		= match_obs_init;

	if (!type)
		e.nextthink = time + 0.1;
	else
		e.nextthink = time;

	if (type)
	{
		maybe_remove_team ();
		update_showscores_name (world, self);
	}
};

float (float bits)
bits_set =
{
	local float n;

	n = 0;
	if (bits & 1)		n = n + 1;
	if (bits & 2)		n = n + 1;
	if (bits & 4)		n = n + 1;
	if (bits & 8)		n = n + 1;
	if (bits & 16)		n = n + 1;
	if (bits & 32)		n = n + 1;
	if (bits & 64)		n = n + 1;
	if (bits & 128)		n = n + 1;
	if (bits & 256)		n = n + 1;
	if (bits & 512)		n = n + 1;
	if (bits & 1024)	n = n + 1;
	if (bits & 2048)	n = n + 1;
	if (bits & 4096)	n = n + 1;
	if (bits & 8192)	n = n + 1;
	if (bits & 16384)	n = n + 1;
	if (bits & 32768)	n = n + 1;
	if (bits & 65536)	n = n + 1;
	if (bits & 131072)	n = n + 1;
	if (bits & 262144)	n = n + 1;
	if (bits & 524288)	n = n + 1;
	if (bits & 1048576)	n = n + 1;
	if (bits & 2097152)	n = n + 1;
	if (bits & 4194304)	n = n + 1;
	if (bits & 8388608)	n = n + 1;
	return n;
};

float (float c)
colors_to_shirt =
{
	return floor (c / 16);
};

float (float c)
colors_to_pants =
{
	return c & 15;
};

void (entity e, float c)
restore_colors =
{
	local float shirt, pants;
	local string s;

	shirt = colors_to_shirt (c);
	pants = colors_to_pants (c);

	self_stuffcmd (e, "color ");
	s = ftos (shirt);
	self_stuffcmd (e, s);
	self_stuffcmd (e, " ");
	s = ftos (pants);
	self_stuffcmd (e, s);
	self_stuffcmd (e, "\n");
};

void ()
match_respawn_all_items =
{
	local entity os;

	os = self;
	self = nextent (world);
	while (self)
	{
		if (self.classname == "bodyque")
			self.model = string_null;

		else if ((self.classname == "shambler_slave" && self.trigger_field.runevar)
				|| self.classname == "backpack"
				|| self.classname == "dropped_armor"
				|| self.netname == "quad"
				|| self.netname == "pent"
				|| self.netname == "ring"
				|| self.netname == "suit")
			remove (self);

		else if (self.classname == "dspot"
				|| self.classname == "hologram"
				|| self.classname == "deathorb"
				|| self.classname == "radioactive"
				|| self.classname == "freeze"
				|| self.classname == "sucker"
				|| self.classname == "spikeball"
				|| self.classname == "torchtrap"
				|| self.classname == "glue"
				|| self.classname == "antipack")
			self.nextthink = self.runetime = time;

		else if (self.flags & FL_ITEM && self.nextthink != -2)
			SUB_regen ();

		self = nextent (self);
	}
	self = os;
};

void ()
match_pre_think =
{
	if (is_observer ())
		return;

	if (!self.rqstate & RQS_READY)
		return;

	if (self.search_time > time)
		return;

	if (*self.cl[CL_COLORS] != *self.team_colors)
	{
		self.search_time = time + 0.1;
		self_sprint (self, "You have already committed\n");
		restore_colors (self, self.team_colors / %1);
	}
};

void ()
match_abort =
{
	match.state = 0;

	bprint ("Match aborted!\n");
	pqc_match_time (world, 255, 0);
	pqc_match_reset ();
	match_remove_ghosts (world);
};

void ()
match_stop_countdown =
{
	local entity e;

	e = find (world, classname, "match_countdown");
	if (e)
	{
		match.cnt	= 0;
		e.count		= -1;
		e.cnt		= 0;

		bprint ("Timer stopped\n");
		pqc_match_time (world, 255, 0);

		e.nextthink	= time;
	}
};

void ()
match_timer =
{
	local float seconds, minutes;

	if (!match.state || intermission_running)
	{
		remove (self);
		return;
	}

	seconds = rint (match.count - time);
	if (seconds <= 0)
	{
		match.state	= 0;
		TEAMS_PRESENT	= 0;

		bprint ("The match is over\n");
		team_stats (1);
		kill_all_players ();
		match_remove_ghosts (world);
		pqc_match_time (world, 255, 0);
		remove_bit_from_players (rqstate, RQS_READY);
		remove (self);
		return;
	}
	else if (seconds < 11)
	{
		if (seconds == 10)
			bprint ("Match ends in T minus\n");
		bprint ("  ");
		bprint_float (seconds);
		if (seconds == 1)
			bprint (" second\n");
		else
			bprint (" seconds\n");
	}
	else if (seconds == 30)
		bprint ("Match ends in 30 seconds\n");
	else if (seconds > 59)
	{
		minutes = seconds / 60;
		if (minutes == ceil (minutes))
		{
			if (minutes == match.frags)
			{
				bprint_float (minutes);
				bprint (" minutes remaining\n");
			}
			else
			{
				bprint ("Match ends in ");
				bprint_float (minutes);
				if (minutes == 1)
					bprint (" minute\n");
				else
					bprint (" minutes\n");
			}
		}
	}

	match_time_set (world);

	self.nextthink = time + 1;
};

void ()
match_unready_names =
{
	local entity e;

	e = find (world, classname, "player");
	while (e)
	{
		update_showscores_name (world, e);
		e = find (e, classname, "player");
	}
};

void ()
match_countdown =
{
	local float seconds;

	if (self.count < 0 || intermission_running)
	{
		remove (self);
		return;
	}

	seconds		= floor (self.count - time);
	match.cnt	= seconds;
	self.nextthink	= time + 1;

	pqc_match_time (world, 0, seconds - (seconds * 2));

	if (seconds <= 0)
	{
		kill_all_players ();
		reset_efficiency_all ();

		MATCHLOCK	= 1;
		match.state	= 1;

		match_unready_names ();

		local entity vip;
		vip = find_vip ();
		if (vip.impulse == IMP_VOTE_TIMESET)
		{
			vip.runevar = 0;
			vip.nextthink = time;
		}

		match.count	= time + (match.frags * 60);

		pqc_match_time (world, match.frags, 0);

		self.think	= match_timer;
		self.nextthink	= time;
	}
	else if (seconds < 11)
	{
		if (seconds == 10)
			bprint ("Match begins in T minus\n");
		bprint ("  ");
		bprint_float (seconds);
		if (seconds == 1)
			bprint (" second\n");
		else
			bprint (" seconds\n");
	}
	else if (self.frags == 20)
	{
		if (seconds == 12)
			bprint ("Match is currently 1v1\n"); // XXX Fix me!!
		else if (seconds == 15)
		{
			match_respawn_all_items ();
			bprint ("All items have respawned\n");
		}

		if (seconds == 18 || seconds == 15 || seconds == 12)
		{
			bprint ("\btimelimit is \<");
			bprint (timeset_gold[(((match.frags / 5) - 1) * 3) * %1]);
			bprint ("\>\n");

			if (seconds == 18)
				bprint ("use '\btimeset\b' to change timelimit\n");
		}
	}
	else
	{
		if (seconds == 20)
		{
			bprint ("Match is currently 1v1\n"); // XXX Fix me!!
			bprint ("Match begins in 20 seconds\n");
		}
		else if (seconds == 30)
		{
			match_respawn_all_items ();
			bprint ("All items have respawned\n");
			bprint ("Match begins in 30 seconds\n");
		}

		if (seconds == 55 || seconds == 30 || seconds == 20)
		{
			bprint ("\btimelimit is \<");
			bprint (timeset_gold[(((match.frags / 5) - 1) * 3) * %1]);
			bprint ("\>\n");

			if (seconds == 55)
				bprint ("use '\btimeset\b' to change timelimit\n");
		}
	}
};

void ()
match_spawn_countdown =
{
	local entity e;

	e = find (world, classname, "match_countdown");
	if (!e)
	{
			e		= spawn ();
			e.classname	= "match_countdown";
			if (options & FASTSTART)
				e.frags = 20;
			else
				e.frags = 60;
			e.count		= time + e.frags;

			// populate match frags with hunk or use default
			match.frags = Read_Hunk_Float (HUNK_CONTEXT, HUNK_MATCH_TIMELIMIT);
			if (match.frags < 5 || match.frags > 60)
			{
				Write_Hunk_Float (HUNK_CONTEXT, HUNK_MATCH_TIMELIMIT, 20);
				match.frags = 20;
			}

			if (options & FASTSTART)
				bprint ("Match begins in 20 seconds\n");
			else
				bprint ("Match begins in 1 minute\n");

			pqc_match_time (world, 0, e.frags - (e.frags * 2));

			e.think		= match_countdown;
			e.nextthink	= time + 1;
	}
};

float ()
match_players_ready =
{
	local entity e;

	e = find (world, classname, "player");
	while (e)
	{
		if (!is_observer_e (e) && !e.rqstate & RQS_READY)
			return FALSE;
		e = find (e, classname, "player");
	}
	return TRUE;
};

void ()
audit_match =
{
	local float teams;

	teams = bits_set (TEAMS_PRESENT);

	if (match.state)
	{
		if (!count_players (0))
			match_abort ();
		else if (!teams)
		{
			bprint ("No teams present\n");
			match_abort ();
		}
		return;
	}

	if (!teams)
		bprint ("No teams present\n");
	else if (teams == 1)
		bprint ("Only one team present\n");

	if (teams > 1 && match_players_ready ())
		match_spawn_countdown ();
	else
		match_stop_countdown ();
};

void (entity e, entity w)
update_showscores_name =
{
	local float msg_type;
	local string match_name;
	local string s;

	if (e.cl[CL_ACTIVE] == %1)
	{
		msg_entity = e;
		msg_type = MSG_ONE;
	}
	else
		msg_type = MSG_ALL;

	if (w.rqstate & RQS_AFK)
		s = "\bAFK";
	else if (!match.state && w.rqstate & RQS_READY)
		s = "\bREADY";
	else
	{
		svc_updatename (MSG_ALL, w.colormap - 1, w.netname);
		return;
	}

	match_name = flen (w.netname, -16);
	match_name = strcat (match_name, s);
	svc_updatename (msg_type, w.colormap - 1, match_name);
};

float ()
match_obs_join_game =
{
	local float bit;
	local string s;

	if (!HUNK_CONTEXT_MAX)
	{
		self_sprint (self, "waiting for level to load\n");
		return FALSE;
	}

	if (gamemode != MODE_MATCH)
	{
		self_sprint (self, "you are not an observer\n");
		return FALSE;
	}

	if (self.rqstate & RQS_READY)
	{
		self_sprint (self, "You have already committed\n");
		return FALSE;
	}

	if (match.state)
	{
		if (match_find_ghost ())
		{
			self.rqstate = self.rqstate | RQS_RESTORE_GHOST;
			return TRUE;
		}
	}

	// XXX CRMOD allows players to join teams with fewer players.
	if (match.cnt && match.cnt < 6)
	{
		self_sprint (self, "Team locked at T-5 seconds\nCannot join unless someone unreadies\n");
		return FALSE;
 	}

	if (self.team == 1)
	{
		self_sprint (self, "invalid pants color\n");
		return FALSE;
	}

	if (match.state && MATCHLOCK)
	{
		self_sprint (self, "Team full.  A player must enter 'unlock' in console to let you join\n");
		restore_colors (self, self.team_colors / %1);
		return FALSE;
	}

	// Clean up last match.
	if (!TEAMS_PRESENT)
	{
		TEAMS_PRESENT = 0;
		match_hunk_init ();
		frag_init ();
		pqc_match_time (world, 255, 0);
		pqc_match_reset ();
	}

	self.team_colors	= self.cl[CL_COLORS];
	self.rqstate		= self.rqstate | RQS_READY;
	self.frags		= 0;

	bit			= num_to_bit (self.team);
	s			= team_to_name (self.team);
	if (!TEAMS_PRESENT & bit)
	{
		bprint (s);
		bprint (" team created\n");
		Write_Hunk_Float (HUNK_CONTEXT, HUNK_TEAMS + (self.team * %1), self.cl[CL_COLORS]);
		TEAMS_PRESENT = TEAMS_PRESENT | bit;
		pqc_new_team (world, self.cl[CL_COLORS] / %1);
	}

	bprint (self.netname);
	bprint (" joined the ");
	bprint (s);
	bprint ("\n");

	audit_match ();
	update_showscores_name (world, self);

	return TRUE;
};

void (entity e)
match_remove_ghosts =
{
	local entity ghost;

	ghost = find (world, classname, "ghost");
	while (ghost)
	{
		if (e)
		{
			if (e.subnet == ghost.subnet)
			{
				remove (ghost);
				return;
			}
		}
		else
			remove (ghost);

		ghost = find (ghost, classname, "ghost");
	}
};

entity ()
match_find_ghost =
{
	local entity ghost;

	if (self.subnet == VEC_ORIGIN)
		return world;

	ghost = find (world, classname, "ghost");
	while (ghost)
	{
		if (self.subnet == ghost.subnet)
			return ghost;
		ghost = find (ghost, classname, "ghost");
	}
	return world;
};

void ()
match_spawn_ghost =
{
	local entity ghost;

	// remove existing ghosts
	match_remove_ghosts (self);

	// spawn ghost
	ghost			= spawn ();
	ghost.classname		= "ghost";

	// save settings
	ghost.subnet		= self.subnet;
	ghost.frags		= self.frags;
	ghost.team_colors	= self.team_colors;

	ghost.items		= self.items;
	ghost.health		= self.health;
	ghost.armorvalue	= self.armorvalue;
	ghost.ammo_shells	= self.ammo_shells;
	ghost.ammo_nails	= self.ammo_nails;
	ghost.ammo_rockets	= self.ammo_rockets;
	ghost.ammo_cells	= self.ammo_cells;
	ghost.weapon		= self.weapon;
	ghost.armortype		= self.armortype;
	ghost.deadflag		= self.deadflag;
};

float ()
match_restore_ghost =
{
	local entity ghost;

	if (!self.rqstate & RQS_RESTORE_GHOST)
		return FALSE;

	self.rqstate		= self.rqstate - self.rqstate & RQS_RESTORE_GHOST;

	ghost = match_find_ghost ();
	if (!ghost)
		return FALSE;

	self.rqstate		= self.rqstate | RQS_READY;
	self.frags		= ghost.frags;
	self.team_colors	= ghost.team_colors;
	restore_colors (self, self.team_colors / %1);
	self.search_time	= time + 0.1;

	// XXX Just force new parms until I add timer functions.
	if (1)
	{
		match_remove_ghosts (ghost);
		return FALSE;
	}

	self.items		= ghost.items;
	self.items = self.items - self.items & (IT_KEY1 | IT_KEY2 | IT_INVISIBILITY
			| IT_INVULNERABILITY | IT_SUIT | IT_QUAD | IT_SUPERHEALTH);

	self.health		= ghost.health;
	self.armorvalue		= ghost.armorvalue;
	self.ammo_shells	= ghost.ammo_shells;
	self.ammo_nails		= ghost.ammo_nails;
	self.ammo_rockets	= ghost.ammo_rockets;
	self.ammo_cells		= ghost.ammo_cells;

	self.weapon		= 0;
	set_weapon (ghost.weapon);

	self.armortype		= ghost.armortype;

	match_remove_ghosts (ghost);
	return TRUE;
};

void ()
match_client_disconnect =
{
	if (!self.rqstate & RQS_READY)
		return;

	if (match.state)
		match_spawn_ghost ();

	maybe_remove_team ();
};

void ()
maybe_remove_team =
{
	local entity w;
	local float e_pants, w_pants;

	self.rqstate = self.rqstate - self.rqstate & RQS_READY;
	self.team_colors = 0;
	e_pants = colors_to_pants (self.cl[CL_COLORS] / %1);
	w = find (world, classname, "player");
	while (w)
	{
		w_pants = colors_to_pants (w.cl[CL_COLORS] / %1);
		if (self != w && e_pants == w_pants && w.rqstate & RQS_READY)
		{
			audit_match ();
			return;
		}
		w = find (w, classname, "player");
	}
	remove_team (self.team);

	return;
};

void (float tm)
remove_team =
{
	local float bit;

	if (!*HUNK_CONTEXT)
		return;

	if (!TEAMS_PRESENT)
		return;

	if (match.state)
	{
		audit_match ();
		return;
	}

	pqc_erase_team (tm - 1);
	Write_Hunk_Float (HUNK_CONTEXT, HUNK_TEAMS + (tm * %1), 0);

	bit = num_to_bit (tm);
	TEAMS_PRESENT = TEAMS_PRESENT - TEAMS_PRESENT & bit;

	audit_match ();
};

void (entity e)
match_time_set =
{
	local float seconds, minutes;

	seconds = rint (match.count - time);
	minutes = floor (seconds / 60);
	seconds = seconds - rint (minutes * 60);

	pqc_match_time (e, minutes, seconds);
};

// XXX Rename this, use a global function.
void ()
kill_all_players =
{
	local entity e, os;
	e = find (world, classname, "player");
	while (e)
	{
		if (!is_observer_e (e))
		{
			os = self;
			self = e;
			Killed (self, self, string_null);
			self.style = time + 1;
			match.style = time + 1;
			self = os;
		}
		e = find (e, classname, "player");
	}
};

void ()
match_ready =
{
	if (is_observer ())
		obs_join_game (0);
	else
		match_obs_join_game ();
};

void ()
match_notready =
{
	if (gamemode != MODE_MATCH)
	{
		self_sprint (self, "command valid in match mode only\n");
		return;
	}

	if (!self.rqstate & RQS_READY)
		return;

	if (match.state)
	{
		self_sprint (self, "Cannot uncommit during match\ntype 'observer' to leave match\n");
		return;
	}
	else
	{
		bprint (self.netname);
		bprint (" is not ready\n");
	}

	maybe_remove_team ();
	update_showscores_name (world, self);
};

void ()
print_timeset_menu =
{
	if (gamemode == MODE_MATCH)
	{
		if (match.state)
			self_sprint (self, "Cannot change timelimit while match is in progress\n");
		else if (is_observer ())
			count_votes (2);
		else
		{
			self.rqstate = self.rqstate | RQS_TIMESET_OVERRIDE;
			self_sprint (self, "Select timelimit:\n");
			self_sprint (self, "\b\<\1\> 5 minutes     \<\4\> 20 minutes\n");
			self_sprint (self, "\b\<\2\> 10 minutes    \<\5\> 25 minutes\n");
			self_sprint (self, "\b\<\3\> 15 minutes    \<\6\> 30 minutes\n");
		}
	}
	else
		self_sprint (self, "Command only valid in match mode\n");
};

void ()
vote_timeset =
{
	if (match.state)
		return;

	match.frags = VOTE_TIMESET * 5;
	Write_Hunk_Float (HUNK_CONTEXT, HUNK_MATCH_TIMELIMIT, match.frags);
	VOTE_TIMESET = 0;
};

float ()
match_impulse_override =
{
	local float force;

	if (gamemode != MODE_MATCH)
		return FALSE;

	force = self.rqstate & RQS_TIMESET_OVERRIDE;
	self.rqstate = self.rqstate - self.rqstate & RQS_TIMESET_OVERRIDE;

	if (match.state)
		return FALSE;

	if (force)
	{
		if (self.impulse > 6)
			self_sprint (self, "invalid impulse\n");
		else
		{
			if (!VOTE_TIMESET)
				VOTE_TIMESET = self.impulse;
			self.impulse = IMP_VOTE_TIMESET;
			vote_impulse_commands ();
		}
		return TRUE;
	}

	return FALSE;
};
