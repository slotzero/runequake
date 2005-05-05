/*  $Id: match.qc,v 1.13 2005/05/05 22:56:45 slotzero Exp $

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
		}

		self_stuffcmd (self.owner, "color 0\n");
		self.owner.frags = -99;
	}

	remove (self);
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
		bprint (self.netname);
		bprint (" is not ready\n");
	}

	if (!maybe_remove_team (self))
	{
		bit = num_to_bit (self.team);
		TEAMS_PRESENT = TEAMS_PRESENT - TEAMS_PRESENT & bit;
		pqc_erase_team (self.team - 1);
	}
};

float (entity e)
maybe_remove_team =
{
	local entity w;
	local float e_pants, w_pants;

	e_pants = client_colors (e, 0);

	w = find (world, classname, "player");
	while (w)
	{
		w_pants = client_colors (w, 0);
		if (e != w && e_pants == w_pants)
			return TRUE;
		w = find (w, classname, "player");
	}

	return FALSE;
};

// return 1 (player can commit), return 0 (player can't join, reset is color)
float ()
match_obs_join_game =
{
	local float bit;
	local string s;

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
		TEAMS_PRESENT = TEAMS_PRESENT | bit;
		pqc_new_team (self.cl[CL_COLORS] / %1);
	}

	bprint (self.netname);
	bprint (" joined the ");
	bprint (s);
	bprint ("\n");

	if (TEAMS_PRESENT == bit)
		bprint ("only one team present\n");
	else
		bprint ("match begins in 1 minute\n");

	self.frags = 0;

	return TRUE;
};
