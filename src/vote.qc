/*  $Id: vote.qc,v 1.2 2004/07/07 08:46:10 slotzero Exp $

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

float VOTE_PRACTICE	= 8;
float VOTE_NORMAL	= 16;

void (entity vip)
vote_action =
{
	if (self.classname != "player")
		bprint (vip.owner.classname);
	else
		bprint (self.classname);

	bprint (" performed an action\n");	// XXX fix me

	vip.think1 ();
	remove_bit_from_players (rqstate, RQS_VOTE_YES);

	remove (vip);
};

float ()
xcount_votes =
{
	local entity e, vip;
	local float tot, lack, need, voted;

	vip = find (world, classname, "vote_in_progress");
	if (!vip)
		return 0;

	tot = voted = 0;

	e = find (world, classname, "player");
	while (e)
	{
		if (is_player_e (e))
		{
			tot = tot + 1;
			if (e.rqstate & RQS_VOTE_YES)
				voted = voted + 1;
		}
		e = find (e, classname, "player");
	}

	need = ceil (tot * vip.frag_rate);
	if (need < 1)
		need = 1;
	lack = need - voted;

	if (0)
	{
		bprint ("debug: ");
		bprint_float (tot);   bprint (" tot ");
		bprint_float (voted); bprint (" voted ");
		bprint_float (need);  bprint (" need ");
		bprint_float (lack);  bprint (" lack\n");
	}

	if (LEVEL_RECONNECT_ALLOWANCE > time)
		return voted;
	else
		return lack;
};

// type
//  0 self_sprint (client) / dprint  (world)
//  1 sprint      (client) / bprint  (world)
//  2 bprint	  (client) / bprint  (world)

float (float type)
print_count_votes =
{
	local entity e, vip;
	local float lack;

	vip = find (world, classname, "vote_in_progress");
	if (!vip)
		return 0;

	lack = xcount_votes ();
	if (!lack)
	{
		vip.nextthink = time;
		return 0;
	}

	if (LEVEL_RECONNECT_ALLOWANCE > time)
	{
		if (type)
		{
			if (type == 1)
				e = self;
			else
				e = world;

			sprint_float (e, lack);
			sprint (e, " vote");
			if (lack != 1)
				sprint (e, "s");
			sprint (e, " in queue\n");
		}
		else
		{
			self_sprint_float (e, lack);
			self_sprint (e, " vote");
			if (lack != 1)
				self_sprint (e, "s");
			self_sprint (e, " in queue\n");
		}
	}
	else
	{
		if (type)
		{
			if (type == 1)
				e = self;
			else
				e = world;

			sprint_float (e, lack);
			sprint (e, " more vote");
			if (lack != 1)
				sprint (e, "s");
			sprint (e, " needed to ");
			sprint (e, vip.netname);
			if (vip.map)
				sprint (e, vip.map);
			sprint (e, "\n");
		}
		else
		{
			self_sprint_float (self, lack);
			self_sprint (self, " more vote");
			if (lack != 1)
				self_sprint (self, "s");
			self_sprint (self, " needed to ");
			self_sprint (self, vip.netname);
			if (vip.map)
				self_sprint (self, vip.map);
			self_sprint (self, "\n");
		}
	}

	return lack;
};

void ()
vote_think =
{
	local string s;

	// poq prevent error crashing
	if (!HUNK_CONTEXT_MAX)
	{
		self.nextthink = time + sys_ticrate;
		return;
	}

	if (!xcount_votes ())
	{
		vote_action (self);
		return;
	}

	if (self.runevar)
	{
		// poq
		s = allocate_string_size (64);
		s = "\{1}Request to ";
		s = strcat (s, self.netname);
		if (self.map)
			s = strcat (s, self.map);

		// poq
		bprint (s);

		// qw
		/* bprint ("\{1}");
		bprint ("Request to ");
		bprint (self.netname);
		if (e.map)
		bprint (self.map); */

		// all
		bprint ("\ntype 'yes' or 'no' in console to vote\n");

		self.runevar = self.runevar - 1;
	}
	else
	{
		bprint ("\{1}Vote cancelled\n");
		remove_bit_from_players (rqstate, RQS_VOTE_YES);
		remove (self);
		return;
	}

	if (LEVEL_RECONNECT_ALLOWANCE > time)
		self.nextthink = LEVEL_RECONNECT_ALLOWANCE;
	else
		self.nextthink = time + 8; // broadcast interval
};

void (float vote_type)
vote_spawn =
{
	local entity e, vip;
	local float cancel;

	vip = find (world, classname, "vote_in_progress");
	if (vip)
	{
		if (vote_type == vip.impulse)
			return vote_yes ();

		return self_sprint (self, "\{141} A vote is already in progress\n");
	}

	self.rqstate = self.rqstate | RQS_VOTE_YES;

	e		= spawn ();
	e.classname	= "vote_in_progress";
	e.runevar	= 3; // request attempts
	e.impulse	= vote_type;
	e.owner		= self;

	// XXX I want to make adding vote types very easy, so I need to elaborate on this.

	if (vote_type == VOTE_EXIT)
	{
		e.frag_rate	= VOTE_EXIT_PERCENTAGE;
		e.think1	= NextLevel;

		if (forced_nextmap)
		{
			e.map		= forced_nextmap;
			e.netname	= "change map to ";
		}
		else
			e.netname	= "change to a random map";
	}
	else if (vote_type == VOTE_TEAM)
	{
		cancel	= vote_team_disabled (1);
		e.frag_rate	= VOTE_TEAM_PERCENTAGE;
		e.think1	= toggle_teamplay;	// XXX Fix me, cause I predict this will create
							// compile errors in Frikqcc.
		if (teamplay & TEAM_TEAM_MASK)
			e.netname	= "disable teams";
		else
			e.netname	= "enable teams";
	}
	else if (vote_type == VOTE_HOOK)
	{
		cancel	= vote_hook_disabled (1);
		e.frag_rate	= VOTE_HOOK_PERCENTAGE;
		e.think1	= toggle_hook_mode;

		if (temp1 & T1_HOOK_MASK)
			e.netname	= "disable hook";
		else
			e.netname	= "enable hook";
	}
	else
		cancel = -1;

	if (cancel)
	{
		if (cancel < 0)
			dprint ("Invalid vote type\n");

		remove_bit_from_players (rqstate, RQS_VOTE_YES);
		remove (e);
	}
	else
	{
		e.think		= vote_think;
		e.nextthink	= time + sys_ticrate;
	}
};

void ()
vote_yes =
{
	local entity vip;

 	vip = find (world, classname, "vote_in_progress");
 	if (!vip)
		return self_sprint (self, "\{141} Nothing to vote on\n");

	if (self.rqstate & RQS_VOTE_YES)
	{
		print_count_votes (1);
		return;
	}

	self.rqstate = self.rqstate | RQS_VOTE_YES;

	if (!print_count_votes (1))
		vote_action (vip);
};
