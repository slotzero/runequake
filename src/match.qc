/*  $Id: match.qc,v 1.15 2005/05/06 23:27:53 slotzero Exp $

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
	local float i, cl_colors;

	if (!HUNK_CONTEXT)
		return;

	for (i = %1; i <= %16; i = i + %1)
	{
		cl_colors = Read_Hunk_Float (HUNK_CONTEXT, HUNK_TEAMS + i);
  		if (cl_colors && cl_colors != 0x20202020)
			pqc_new_team (e, cl_colors / %1);
	}
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


// match is over
// match in progress
// waiting for players

void ()
match_pre_think =
{
	if (is_observer ())
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
reset_colors =
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
	}

	remove (self);
};

float (entity e)
maybe_remove_team =
{
	local entity w;
	local float e_pants, w_pants;

	e_pants = cl_colors_to_pants (e.cl[CL_COLORS]);

	w = find (world, classname, "player");
	while (w)
	{
		w_pants = cl_colors_to_pants (w.cl[CL_COLORS]);
		if (e != w && e_pants == w_pants)
			return FALSE;
		w = find (w, classname, "player");
	}

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

	bit = bits_in_bits (TEAMS_PRESENT);
	if (bit < 2)
	{
		if (match.state)
		{
			if (!bit)
			{
				pqc_match_time (world, 255, 0);
				pqc_match_reset ();
				bprint ("match aborted!\n");
			}
		}
		else
		{
			e = find (world, classname, "match_count_up");
			if (e)
			{
				e.nextthink = time;
				e.count = -1;
				pqc_match_time (world, 255, 0);
				bprint ("timer stopped\nonly 1 team present\n");
			}
		}
	}
};

void (float tell_type)
match_obs_become =
{
	local entity e;
	local float bit;

	e		= spawn ();
	e.runevar	= !tell_type;
	e.owner		= self;
	e.think		= reset_colors;

	if (tell_type)
		e.nextthink	= time;
	else
		e.nextthink	= time + 0.1;

	if (tell_type)
	{
		if (maybe_remove_team (self))
			remove_team (self.team);

		if (!match.state)
		{
			bprint (self.netname);
			bprint (" is not ready\n");
		}
	}
};

void ()
match_count_up =
{
	local float minutes, seconds;

	if (self.count < 0)
	{
		remove (self);
		return;
	}

	seconds = floor (self.count - time);
	seconds = seconds - (seconds * 2);

	if (seconds)
	{
		pqc_match_time (world, 0, seconds);
		self.nextthink = time + 1;
	}
	else
	{
		match.state = 1;
		match.count = time + 20;
		pqc_match_time (world, 20, 0);
		WriteByte(MSG_ALL, 8);
		WriteString(MSG_ALL, "20 minutes remaining\n");
		remove (self);
	}
};

// return 1 (player can commit), return 0 (player can't join, reset his color)
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

	if (self.team == 1)
	{
		self_sprint (self, "invalid pants color\n");
		return FALSE;
	}

	// copy colors
	self.team_colors = self.cl[CL_COLORS];

	bit = num_to_bit (self.team);
	s = team_to_name (self.team);
	if (!TEAMS_PRESENT & bit)
	{
		bprint (s);
		bprint (" team created\n");
		Write_Hunk_Float (HUNK_CONTEXT, HUNK_TEAMS + (self.team * %1), self.cl[CL_COLORS]);
		TEAMS_PRESENT = TEAMS_PRESENT | bit;
		pqc_new_team (e, self.cl[CL_COLORS] / %1);
	}

	bprint (self.netname);
	bprint (" joined the ");
	bprint (s);
	bprint ("\n");

	if (TEAMS_PRESENT == bit)
		bprint ("only one team present\n");
	else
	{
		e = find (world, classname, "match_count_up");
		if (!e)
		{
			e		= spawn ();
			e.classname	= "match_count_up";
			e.count		= time + 60;
			e.think		= match_count_up;
			e.nextthink	= time + 1;

			bprint ("match begins in 1 minute\n");
			pqc_match_time (world, 0, -59);
		}
	}

	self.frags = 0;

	return TRUE;
};
