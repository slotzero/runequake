/*  $Id: develop.qc,v 1.65 2004/07/06 09:57:44 slotzero Exp $

    Copyright (C) 2003  David 'Slot Zero' Roberts.

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

//-------------------------------------------------------------------
// DEVELOPMENT FUNCTIONS
//-------------------------------------------------------------------

float DEVELOPER_MODE = 0;

void (.float field, float bit)
remove_bit_from_players =
{
	local entity e;

	e = find (world, classname, "player");
	while (e)
	{
		e.field = e.field - e.field & bit;
		e = find (e, classname, "player");
	}
};

void ()
ghost_check =
{	IN_QW(return;)
	local entity e, os;

	e = find (world, classname, "player");
	while (e)
	{
		if (!e.cl[CL_ACTIVE])
		{
			os = self;
			self = e;
			bprint ("Ghost Player");
			ClientDisconnect ();
			self = os;
		}

		e = find (e, classname, "player");
	}
};

float ()
maxplayers =
{
	local entity e;
	local float i;

	e = nextent (world);
	for (i = 0; i < 16; i = i + 1)
	{
		if (e.classname == "bodyque")
			return i;
		e = nextent (e);
	}
	return 16;
};

float VOTE_IN_PROGRESS;

float (float vote_type)
vote_type_valid =
{
	if (vote_type == 1)
		return TRUE;
	if (vote_type == 2)
		return TRUE;
	if (vote_type == 3)
		return TRUE;
	if (vote_type == 4)
		return TRUE;

	return FALSE;
};

void ()
xvote_think =
{
	if (self.runevar)
	{
		local string s;

		// XXX I'm going to do this another way or I'll kill Quakeworld.
		s = allocate_string_size (64);
		s = strcat ("\{1}Request to ", self.netname);
		s = strcat (s, self.map);

		bprint (s);
		bprint ("\ntype 'yes' or 'no' in console to vote\n");

		self.runevar = self.runevar - 1;
	}
	else
	{
		bprint ("\{1}Vote cancelled\n");
		remove_bit_from_players (rqflags, RQ_VOTE_YES);
		VOTE_IN_PROGRESS = 0;
		remove (self);
		return;
	}

	self.nextthink = time + 8;
};

void (string net, string m, float vote_type)
xvote =
{
	local entity e;

	if (VOTE_IN_PROGRESS)
		return self_sprint (self, "a vote is already in progress!\n");

   	if (!vote_type_valid (vote_type))
		return dprint ("vote: invalid vote type\n");

	VOTE_IN_PROGRESS = 1;

	self.rqflags = self.rqflags | RQ_VOTE_YES;

	e		= spawn ();
	e.classname	= "vote_in_progress";
	e.netname	= net; // levels
	e.map		= m;
	e.runevar	= 3;
	e.runetype	= vote_type;
	e.think		= xvote_think;
	e.nextthink	= time + sys_ticrate;
};

void ()
vote_yes =
{
	local entity e;
	local float vote_type;
	local float bit, pct;
	local string cmd, desc;
	local float tot, voted, need, lack, force;
	local entity e;
	local string s;

	if (!VOTE_IN_PROGRESS)
		return self_sprint (self, "Nothing to vote on\n");

	if (self.rqflags & RQ_VOTE_YES)
		return self_sprint (self, "You already voted yes\n");

	self.rqflags = self.rqflags | RQ_VOTE_YES;

	bit = RQ_VOTE_YES;
	pct = VOTE_EXIT_PERCENTAGE;
	tot = voted = 0;
	e = find (world, classname, "player");
	while (e)
	{
		if (is_player_e (e))
		{
			tot = tot + 1;
			if (e.rqflags & bit)
				voted = voted + 1;
		}
		e = find (e, classname, "player");
	}

	need = ceil (tot * pct);
	if (need < 1) // can't happen
		need = 1;
	lack = need - voted;
	s = ftos (lack);

	if (lack > 0)
		 self_sprint (self, "x more votes needed\n");
  	else
	{
		self_sprint (self, "the action should be performed NOW!\n");
		e = find (world, classname, "vote_in_progress");
		while (e)
		{
			if (e.map)
				forced_nextmap = e.map;
			vote_type = e.runetype;
			e = find (e, classname, "vote_in_progress");
		}
		VOTE_IN_PROGRESS = 1;

		remove_bit_from_players (rqflags, RQ_VOTE_YES);

		if (vote_type == 1 && forced_nextmap != string_null)
			NextLevel ();
		else if (vote_type == 4)
			change_practice_mode (!deathmatch & DM_MODE_PRACTICE);
	}

	if (1) // debug
	{
		//self_sprint (self, cmd);
		self_sprint (self, "vote: ");
		self_sprint_float (self, tot);   self_sprint (self, " tot ");
		self_sprint_float (self, voted); self_sprint (self, " voted ");
		self_sprint_float (self, need);  self_sprint (self, " need ");
		self_sprint_float (self, lack);  self_sprint (self, " lack\n");
		return;
	}

};

void ()
Test_Button =
{
	//xvote ("change level to ", "dm6", 1);	// 1 would be VOTE_EXIT (or something like that);
	xvote ("change mode to practice", string_null, 4);
};
