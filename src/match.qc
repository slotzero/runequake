/*
    Copyright (C) 2005-2014  David 'Slot Zero' Roberts.

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

float HUNK_MATCH_TIMELIMIT = %500;

// match entity
//
// match.state		= 1 (match in progress) | 0 (waiting | countdown)
// match.count		= match timer
// match.cnt		= countdown
// match.frags		= match timelimit
// match.class_cnt	= teams present
// match.delay		= tracks teams present after match (+teamscores hack)
// match.aimtent[1-14]	= team colors
// match.frag_rate	= max players per team

void ()
match_init =
{
	local float i;

	// spawn and offset array
	if (!match.aiment)
		match.aiment = *(&match + %400);

	for (i = %1; i <= %14; i = i + %1)
		match.aiment[i] = 0;
};

void (entity e)
match_client_init =
{
	local float i, c, pants, colors;

	for (i = %1; i <= %14; i = i + %1)
	{
		colors = match.aiment[i] / %1;
  		if (colors)
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
		self.owner.team_colors = 0;

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
		svc_updatename_hack (world, self);
	}
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

float (float c)
colors_to_team =
{
	return c & 15 + 1;
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

	// XXX Allow players to change shirt colors?
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
	match.state	= 0;
	match.class_cnt	= 0;

	bprint ("Match aborted!\n");
	match_init ();
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
		match.delay	= match.class_cnt;
		match.state	= 0;
		match.class_cnt	= 0;

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
				bprint_teamsize (0);
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
		svc_updatename_hack (world, e);
		e = find (e, classname, "player");
	}
};

void (entity e)
reset_efficiency_e =
{
	if (e.cl[CL_ACTIVE])
	{
		e.shell_dmg = e.shell_dmg_max = e.nail_dmg = e.nail_dmg_max = e.rocket_dmg = e.rocket_dmg_max = e.cell_dmg = e.cell_dmg_max = 0;
		e.enemy_kills = e.suicide = e.mate_kills = e.killed = 0;
	}
};

void ()
reset_efficiency_all =
{
	local entity e;

	e = find (world, classname, "player");
	while (e)
	{
		reset_efficiency_e (e);
		e = find (e, classname, "player");
	}
};

float (float tm)
players_on_team =
{
	local entity e;
	local float players;

	// check if team exits
	if (!match.aiment[tm * %1])
		return 0;

	e = find (world, classname, "player");
	while (e)
	{
		if (e.rqstate & RQS_READY)
		{
			// I used to use e.team but this is safer.
			if (tm == colors_to_team (e.team_colors / %1))
				players = players + 1;
		}
		e = find (e, classname, "player");
	}

	return players;
};

float ()
max_players_per_team =
{
	local float i, tm, players;

	match.frag_rate = 0;
	for (i = %1;i < %14;i = i + %1)
	{
		tm = colors_to_team (match.aiment[i] / %1);
		if (tm)
		{
			players = players_on_team (tm);
			if (players > match.frag_rate)
				match.frag_rate = players;
		}
	}

	return match.frag_rate;
};

void (float countdown)
bprint_teamsize =
{
	local string s;
	local float i;

	i = max_players_per_team ();
	if (countdown == 1)
		bprint ("Match is currently ");
	else if (countdown == 2)
	{
		bprint ("Match teamsize set to ");
		bprint_float (i);
		bprint ("\n");
		return;
	}
	else
		bprint ("Match is ");
	s = ftos (i);
	bprint (s);
	bprint ("v");
	s = ftos (i);
	bprint (s);
	bprint ("\n");
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

		// update teamsize (match.frag_rate)
		if (seconds == 5)
			max_players_per_team ();
	}
	else if (self.frags == 20)
	{
		if (seconds == 12)
			bprint_teamsize (1);
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
			bprint_teamsize (1);
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

	if (match.state)
	{
		if (!count_players (0))
		{
			bprint ("No players present\n");
			match_abort ();
		}
		return;
	}

	teams = match.class_cnt;
	if (!teams)
		bprint ("No teams present\n");
	else if (teams == 1)
		bprint ("Only one team present\n");

	if (teams > 1 && match_players_ready ())
		match_spawn_countdown ();
	else
		match_stop_countdown ();
};

void (entity client, entity e)
svc_updatename_hack =
{
	local float msg_type;
	local string match_name;
	local string s;

	if (client.cl[CL_ACTIVE] == %1)
	{
		msg_entity = client;
		msg_type = MSG_ONE;
	}
	else
		msg_type = MSG_ALL;

	if (e.rqstate & RQS_AFK)
		s = "\bAFK";
	else if (!match.state && e.rqstate & RQS_READY)
		s = "\bREADY";
	else
	{
		svc_updatename (msg_type, e.colormap - 1, e.netname);
		return;
	}

	match_name = flen (e.netname, -16);
	match_name = strcat (match_name, s);
	svc_updatename (msg_type, e.colormap - 1, match_name);
};

float ()
match_obs_join_game =
{
	local string s;
	local float i, tm, allow;

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
		// XXX Prevent ghost from joining when full.
		if (match_find_ghost ())
		{
			self.rqstate = self.rqstate | RQS_RESTORE_GHOST;
			return TRUE;
		}
	}

	if (self.team == 1)
	{
		self_sprint (self, "invalid pants color\n");
		return FALSE;
	}

	if (match.aiment[self.team * %1])
	{
		if (players_on_team (self.team) < match.frag_rate)
			allow = 1;
	}

	if (match.cnt && match.cnt < 6 && !allow)
	{
		self_sprint (self, "Team locked at T-5 seconds\nCannot join unless someone unreadies\n");
		return FALSE;
 	}

	if (match.state && !match.aiment[self.team * %1])
	{
		self_sprint (self, "There are already enough teams:\n");
		for (i = %1;i <= %14;i = i + %1)
		{
			if (match.aiment[i])
			{
				tm = match.aiment[i];
				tm = colors_to_team (tm / %1);
				s = team_to_name (tm);
				self_sprint (self, s);
				self_sprint (self, " (color ");
				self_sprint_float (self, tm - 1);
				self_sprint (self, ")\n");
			}
		}
		return FALSE;
	}

	if (match.state && MATCHLOCK && !allow)
	{
		self_sprint (self, "Team full.  A player must enter 'unlock' in console to let you join\n");
		restore_colors (self, self.team_colors / %1);
		return FALSE;
	}

	// Clean up last match.
	if (!match.class_cnt)
	{
		match.delay = 0;
		match_init ();
		frag_init ();
		pqc_match_time (world, 255, 0);
		pqc_match_reset ();
	}

	self.team_colors	= self.cl[CL_COLORS];
	self.rqstate		= self.rqstate | RQS_READY;
	self.frags		= 0;
	s			= team_to_name (self.team);

	if (!match.aiment[self.team * %1])
	{
		bprint (s);
		bprint (" created\n");
		match.aiment[self.team * %1] = self.cl[CL_COLORS];
		match.class_cnt = match.class_cnt + 1;
		pqc_new_team (world, self.cl[CL_COLORS] / %1);
	}

	bprint (self.netname);
	bprint (" joined the ");
	bprint (s);
	bprint ("\n");

	audit_match ();
	svc_updatename_hack (world, self);

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
	if (match.delay)
		return;

	if (is_observer_e (self))
		return;

	if (self.rqstate & RQS_READY)
	{
		if (match.state)
			match_spawn_ghost ();
	}

	// I had to set this early in order for audit_match() to work properly
	// when players disconnect.
	self.classname = "deader";

	maybe_remove_team ();
};

void ()
maybe_remove_team =
{
	local float tm;

	// If ready check fails, this is her second time here.  Go straight to audit.
	if (!self.rqstate & RQS_READY)
	{
		audit_match ();
		return;
	}

	self.rqstate = self.rqstate - self.rqstate & RQS_READY;
	tm = colors_to_team (self.team_colors / %1);
	self.team_colors = 0;

	if (players_on_team (tm))
	{
		audit_match ();
		return;
	}

	remove_team (tm);
};

void (float tm)
remove_team =
{
	if (match.state)
	{
		audit_match ();
		return;
	}

	// safety net
	if (!match.class_cnt)
		return;

	// safety net
	if (!match.aiment[tm * %1])
		return;

	pqc_erase_team (tm - 1);
	match.aiment[tm * %1] = 0;
	match.class_cnt = match.class_cnt - 1;

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
	svc_updatename_hack (world, self);
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
