/*  $Id: vote.qc,v 1.6 2004/07/08 02:38:53 slotzero Exp $

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

// VOTE TODO (DEV)
/*
	// hook
	* fix hook voting so that vote-hook is always always-on.
	* add vote-lithium to always turn on lithium hook (but not off)
	* vote-hook will turn off lithium hook or full hook

	// practice
	* add disabled for practice mode
	* perhaps a new function to give refresh message, use disabled function maybe?

	// no
	* there's still no active 'no' command, should there be?

	// observer
	* this kinda works

	// warnings
	* make sure that you don't try to assign value to a world entity (!vip for example)!!!
*/

void (entity vip)
vote_action =
{
	if (!vip)
		return dprint ("vote_action: vip is null\n");

	if (self.classname != "player")
		bprint (vip.owner.classname);
	else
		bprint (self.classname);

	bprint (" voted to ");
	bprint (vip.netname);
	if (vip.map)
		bprint (vip.map);
	bprint ("\n");

	vip.think1 ();
	remove_bit_from_players (vote_flags, VOTE_YES);
	remove (vip);
};

void (entity vip, float msg_type, float is_queue, float value)
maybe_print_votes =
{
	if (!msg_type)
		return;

	if (is_queue)
	{
		if (msg_type < 3)
		{
			sprint_float (self, value);
			sprint (self, " vote");
			if (value != 1)
				sprint (self, "s");
			sprint (self, " in queue\n");
		}
	}
	else
	{
		if (msg_type < 3)
		{
			if (msg_type == 1 && value <= 0)
				return;

			sprint_float (self, value);
			sprint (self, " more vote");
			if (value != 1)
				sprint (self, "s");
			sprint (self, " needed to ");
			sprint (self, vip.netname);
			if (vip.map)
				sprint (self, vip.map);
			sprint (self, "\n");
		}
	}
};

// print type
// 0 no message
// 1 only when value positive (when in doubt, use 1)
// 2 all
// 3 disp-info

float (float type)
count_votes =
{
	local entity e, vip;
	local float tot, lack, need, voted, is_queue;

	vip = find (world, classname, "vote_in_progress");

	if (!vip)
	{
		sprint (self, "\{141} Nothing to vote on\n");
		return 0;
	}

	is_queue = LEVEL_RECONNECT_ALLOWANCE > time;

	tot = voted = 0;
	e = find (world, classname, "player");
	while (e)
	{
		if (is_player_e (e))
		{
			tot = tot + 1;
			if (e.vote_flags & VOTE_YES)
				voted = voted + 1;
		}
		e = find (e, classname, "player");
	}

	need = ceil (tot * vip.frag_rate);
	if (need < 1)
		need = 1;
	lack = need - voted;

	if (is_queue)
		maybe_print_votes (vip, type, is_queue, voted);
	else
		maybe_print_votes (vip, type, is_queue, lack);

	// disp-info()
	if (type == 3)
	{
		bprint ("vote: ");
		bprint_float (tot);   bprint (" tot ");
		bprint_float (voted); bprint (" voted ");
		bprint_float (need);  bprint (" need ");
		bprint_float (lack);  bprint (" lack\n");
	}

	if (is_queue)
		return voted;
	else
		return lack;
};

void ()
vote_think =
{
	local string s;

	IN_POQ([-
		// poq prevent crashing error
		if (!HUNK_CONTEXT_MAX)
		{
			self.nextthink = time + sys_ticrate;
			return;
		}
	-])

	if (!count_votes (0))
	{
		vote_action (self);
		return;
	}

	if (self.runevar)
	{
		IN_POQ([-
			// poq broadcast
			s = allocate_string_size (64);
			s = "\{1}Request to ";
			s = strcat (s, self.netname);
			if (self.map)
				s = strcat (s, self.map);

			bprint (s);
		-], [-
			// qw
			bprint ("\{1}");
			bprint ("Request to ");
			bprint (self.netname);
			if (self.map)
			bprint (self.map);
		-])

		// all
		bprint ("\ntype 'yes' or 'no' in console to vote\n");

		self.runevar = self.runevar - 1;
	}
	else
	{
		bprint ("\{1}Vote cancelled\n");
		if (self.impulse == IMP_VOTE_EXIT)
			forced_nextmap = string_null;
		remove_bit_from_players (vote_flags, VOTE_YES);
		remove (self);
		return;
	}

	if (LEVEL_RECONNECT_ALLOWANCE > time)
		self.nextthink = LEVEL_RECONNECT_ALLOWANCE;
	else
		self.nextthink = time + 8; // broadcast interval
};

void ()
vote =
{
	local entity e, vip;
	local float cancel;

	vip = find (world, classname, "vote_in_progress");
	if (vip)
	{
		if (self.impulse == vip.impulse)
			return vote_yes ();

		return self_sprint (self, "\{141} A vote is already in progress\n");
	}

	self.vote_flags = self.vote_flags | VOTE_YES;

	e		= spawn ();
	e.classname	= "vote_in_progress";
	e.runevar	= 3; // request attempts
	e.impulse	= self.impulse;
	e.owner		= self;

	// add vote type help
	//
	// frag_rate	= vote percentage
	// think1	= function that does the action
	// netname	= vote description for bprint
	// map		= appended to vote description (if not null)

	if (self.impulse == IMP_VOTE_EXIT)
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
	else if (self.impulse == IMP_VOTE_TEAM)
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
	else if (self.impulse == IMP_VOTE_HOOK)
	{
		cancel	= vote_hook_disabled (1);
		e.frag_rate	= VOTE_HOOK_PERCENTAGE;
		e.think1	= toggle_hook_mode;

		if (temp1 & T1_HOOK_MASK)
			e.netname	= "disable hook";
		else
			e.netname	= "enable hook";
	}
	else if (self.impulse == IMP_VOTE_PRACTICE)
	{
		// cancel = XXX add me
		e.frag_rate	= 0.51;	// XXX settings.
		e.think1	= mode_practice;
		e.netname	= "change mode to practice";

		if (deathmatch & DM_MODE_PRACTICE)
		{
			cancel = 1;
			self_sprint (self, "Already in Practice mode\n");
		}
	}
	else
		cancel = -1;

	if (cancel)
	{
		if (cancel < 0)
		{
			sprint (self, "Bug, unknown vote impulse ");
			sprint_float (self, self.impulse);
			sprint (self, "\n");
		}

		remove_bit_from_players (vote_flags, VOTE_YES);
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

	if (self.vote_flags & VOTE_YES || is_observer ())
	{
		count_votes (1);
		return;
	}

	self.vote_flags = self.vote_flags | VOTE_YES;

	if (!count_votes (1))
		vote_action (vip);
};
