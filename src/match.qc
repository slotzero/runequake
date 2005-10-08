/*  $Id: match.qc,v 1.25 2005/10/08 03:30:10 slotzero Exp $

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
float TEAMS_PRESENT;

float ()
mode_match =
{
	if (!match)
		return FALSE;
	if (!teamplay & TEAM_MODE_MATCH)
		return FALSE;

	return TRUE;
};

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
	local float i, c, pants, cl_colors, seconds, minutes;

	if (!HUNK_CONTEXT)
		return;

	for (i = %1; i <= %16; i = i + %1)
	{
		cl_colors = Read_Hunk_Float (HUNK_CONTEXT, HUNK_TEAMS + i);
  		if (cl_colors && cl_colors != 0x20202020)
		{
			pqc_new_team (e, cl_colors / %1);
			pants = cl_colors_to_pants (cl_colors);
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

		self.owner.rqflags = self.owner.rqflags - self.owner.rqflags & RQ_READY;
		self_stuffcmd (self.owner, "color 0\n");
		self.owner.frags = -99;
	}

	remove (self);
};

void (float type)
match_obs_become =
{
	local entity e;
	local float bit;

	e		= spawn ();
	e.owner		= self;
	e.runevar	= !type;

	e.think		= match_obs_init;

	if (!type)
		e.nextthink = time + 0.1;
	else
		e.nextthink = time;

	if (type)
		maybe_remove_team (self);
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

float (float cl_colors)
cl_colors_to_shirt =
{
	return floor (cl_colors / %1 / 16);
};

float (float cl_colors)
cl_colors_to_pants =
{
	local float shirt;

	shirt = floor (cl_colors / %1 / 16);
	shirt = shirt * 16;
	return cl_colors / %1 - shirt;
};

void (entity e, float cl_colors)
restore_colors =
{
	local float i, shirt, pants;
	local string s;

	shirt = i = floor (cl_colors / 16);
	i = i * 16;
	pants = cl_colors - i;

	self_stuffcmd (e, "color ");
	s = ftos (shirt);
	self_stuffcmd (e, s);
	self_stuffcmd (e, " ");
	s = ftos (pants);
	self_stuffcmd (e, s);
	self_stuffcmd (e, "\n");
};

void ()
match_pre_think =
{
	if (is_observer ())
		return;

	if (!self.rqflags & RQ_READY)
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
		pqc_match_time (world, 255, 0);
		remove_bit_from_players (rqflags, RQ_READY);
		remove (self);
		return;
	}
	else if (seconds < 11)
	{
		bprint ("  ");
		bprint_float (seconds);
		if (seconds == 1)
			bprint (" second\n");
		else
			bprint (" seconds\n");
	}
	else if (seconds == 11)
		bprint ("Match ends in T minus\n");
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
match_countdown =
{
	local float minutes, seconds;

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

		match.state	= 1;
		match.frags	= 2; // XXX make a setting
		match.count	= time + (match.frags * 60);

		pqc_match_time (world, match.frags, 0);

		self.think	= match_timer;
		self.nextthink	= time;
	}
	else if (seconds < 11)
	{
		bprint ("  ");
		bprint_float (seconds);
		if (seconds == 1)
			bprint (" second\n");
		else
			bprint (" seconds\n");
	}
	else if (seconds == 11)
		bprint ("Match begins in T minus\n");
	else if (seconds == 15)
	{
		remove_classname ("backpack");
		remove_classname ("dropped_armor");
		bprint ("All items have respawned\n");
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
			e.frags		= 20;
			e.count		= time + e.frags;

			if (e.frags == 20)
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
		if (!is_observer_e (e) && !e.rqflags & RQ_READY)
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
		if (!teams)
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

float ()
match_obs_join_game =
{
	local entity e;
	local float bit;
	local string s;

	if (!HUNK_CONTEXT_MAX)
	{
		self_sprint (self, "waiting for level to load\n");
		return FALSE;
	}

	if (!mode_match ())
	{
		self_sprint (self, "you are not an observer\n");
		return FALSE;
	}

	if (self.rqflags & RQ_READY)
	{
		self_sprint (self, "You have already committed\n");
		return FALSE;
	}

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

	if (match.state)
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
	self.rqflags		= self.rqflags | RQ_READY;
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

	return TRUE;
};

float (entity e)
maybe_remove_team =
{
	local entity w;
	local float e_pants, w_pants;

	e.rqflags = e.rqflags - e.rqflags & RQ_READY;
	e_pants = cl_colors_to_pants (e.cl[CL_COLORS]);

	w = find (world, classname, "player");
	while (w)
	{
		w_pants = cl_colors_to_pants (w.cl[CL_COLORS]);
		if (e != w && e_pants == w_pants && w.rqflags & RQ_READY)
		{
			audit_match ();
			return FALSE;
		}
		w = find (w, classname, "player");
	}
	remove_team (e.team);

	return TRUE;
};

void (float tm)
remove_team =
{
	local entity e;
	local float bit;

	if (!HUNK_CONTEXT)
		return;

	if (!TEAMS_PRESENT)
		return;

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
	if (!mode_match ())
	{
		self_sprint (self, "command valid in match mode only\n");
		return;
	}

	if (!self.rqflags & RQ_READY)
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

	maybe_remove_team (self);
};
