/*  $Id: vote.qc,v 1.14 2004/07/09 02:22:50 slotzero Exp $

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
	* fix hook voting so that vote-hook is always always-on. [DONE]
	* add vote-lithium to always turn on lithium hook (but not off) [DONE]
	* add vote-free to always turn on free hook (but not off) [DONE]
	* vote-hook will turn off lithium hook or full hook [DONE]
	* qw vote-hook is fucked.. go figure.. rint = 1 perhaps? [DONE]
	* hook as rune can still exist in lithium

	// practice
	* add disabled for practice mode
	* perhaps a new function to give refresh message, use disabled function maybe?
	* decide specifics on practice.. should alts be allowed, should runes be allowed, hook, etc.

	// exit
	* you can override a random map by selecting a non-random map.. but how to update message?

	// no
	* there's still no active 'no' command, should there be?

	// observer
	* I still don't like how this works.  Aside from that, disp-info-all prints observer message.

	// warnings
	* make sure that you don't try to assign value to a world entity (!vip for example)!!!
*/

//
// functions that check to see if a voted item is disabled
//

float (float tell)
vote_team_disabled =
{
	if (teamplay & TEAM_NO_VOTE
			|| (teamplay != 0 && teamplay != VOTE_TEAM_MODE)
			|| VOTE_TEAM_PERCENTAGE	<= 0
			|| VOTE_TEAM_PERCENTAGE > 1)
	{
		if (tell)
			sprint (self, "Team voting is disabled\n");
		return TRUE;
	}
	return FALSE;
};

float (float tell)
vote_hook_disabled =
{
	if (temp1 & T1_HOOK_NO_VOTE
			|| VOTE_HOOK_PERCENTAGE	<= 0
			|| VOTE_HOOK_PERCENTAGE > 1)
	{
		if (tell)
			sprint (self, "Hook voting is disabled\n");
		return TRUE;
	}
	return FALSE;
};

entity ()
find_vip =
{
	return find (world, classname, "vote_in_progress");
};

void (entity vip)
vote_action =
{
	if (!vip)
		return dprint ("vote_action: vip is null\n");

	if (self.classname == "player")
		vip.netname = self.netname;
	else if (vip.owner.classname == "player")
		vip.netname = vip.owner.netname;
	else
		vip.netname = "Someone";

	bprint (vip.netname);
	bprint (" voted to ");
	if (vip.noise1)
		bprint (vip.noise1);
	if (vip.noise2)
		bprint (vip.noise2);
	if (vip.noise3)
		bprint (vip.noise3);
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
			sprint (self, " in queue, please wait...\n");
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
			if (vip.noise1)
				sprint (self, vip.noise1);
			if (vip.noise2)
				sprint (self, vip.noise2);
			if (vip.noise3)
				sprint (self, vip.noise3);
			sprint (self, "\n");
		}
	}
};

// print type
// 0 no message
// 1 only when value positive (when in doubt, use 1)
// 2 all (observers)
// 3 disp-info

float (float type)
count_votes =
{
	local entity e, vip;
	local float tot, lack, need, voted, is_queue;

	vip = find_vip ();
	if (!vip)
	{
		if (type == 3)
			sprint (self, "vote: nothing to vote on\n");
		else if (type)
			sprint (self, "Join the game to vote\n");
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

	// always lack in queue
	if (is_queue)
		return 1;
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
			if (self.noise1)
				s = strcat (s, self.noise1);
			if (self.noise2)
				s = strcat (s, self.noise2);
			if (self.noise3)
				s = strcat (s, self.noise3);

			bprint (s);
		-], [-
			// qw broadcast
			bprint ("\{1}");
			bprint ("Request to ");
			if (self.noise1)
				bprint (self.noise1);
			if (self.noise2)
				bprint (self.noise2);
			if (self.noise3)
				bprint (self.noise3);
		-])

		// all
		bprint ("\ntype 'yes' or 'no' in console to vote\n");

		self.runevar = self.runevar - 1;
	}
	else
	{
		bprint ("\{1}Vote cancelled\n");
		// XXX Don't like this... do it elsehwere?
		if (self.impulse == IMP_VOTE_EXIT)
			forced_nextmap = string_null;
		remove_bit_from_players (vote_flags, VOTE_YES);
		remove (self);
		return;
	}

	// XXX I don't like the way this works with queued votes.
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

	vip = find_vip ();
	if (vip)
	{
		if (self.impulse == vip.impulse)
			return vote_yes ();

		return self_sprint (self, "\{141} a vote is already in progress\n");
	}

	self.vote_flags = self.vote_flags | VOTE_YES;

	// entity init
	//
	e		= spawn ();
	e.classname	= "vote_in_progress";

	e.runevar	= 3;		// request attempts
	e.impulse	= self.impulse;	// impulse command
	e.owner		= self;		// owner

	e.frag_rate	= 0;		// vote percentage
	e.think		= SUB_Null;	// vote action
	e.noise1	= string_null;	// bprint 1
	e.noise2	= string_null;	// bprint 2
	e.noise3	= string_null;	// bprint 3

	if (self.impulse == IMP_VOTE_EXIT)
	{
		e.frag_rate	= VOTE_EXIT_PERCENTAGE;
		e.think1	= NextLevel;

		if (forced_nextmap)
		{
			e.noise1	= "change map to ";
			e.noise2	= forced_nextmap;
		}
		else
			e.noise1	= "change to a random map";
	}
	else if (self.impulse == IMP_VOTE_TEAM)
	{
		cancel		= vote_team_disabled (1);
		e.frag_rate	= VOTE_TEAM_PERCENTAGE;
		e.think1	= toggle_teamplay;	// XXX Fix me, cause I predict this will create
							// compile errors in Frikqcc.
		if (teamplay & TEAM_TEAM_MASK)
			e.noise1	= "disable teams";
		else
			e.noise1	= "enable teams";
	}
	else if (self.impulse == IMP_VOTE_HOOK)
	{
		cancel		= vote_hook_disabled (1);
		e.frag_rate	= VOTE_HOOK_PERCENTAGE;
		e.think1	= toggle_free_hook;

		if (hook_type (temp1))
			e.noise1	= "disable hook";
		else
			e.noise1	= "enable free hook";
	}
	else if (self.impulse == IMP_VOTE_FREE)
	{
		cancel		= vote_hook_disabled (1);
		e.frag_rate	= VOTE_HOOK_PERCENTAGE;
		e.think1	= free_hook;
		e.noise1	= "enable free hook";

		if (hook_type (temp1) == 1)
		{
			if (!cancel)
				self_sprint (self, "Free hook already enabled\n");
			cancel	= 1;
		}
	}
	else if (self.impulse == IMP_VOTE_LITHIUM)
	{
		cancel		= vote_hook_disabled (1);
		e.frag_rate	= VOTE_HOOK_PERCENTAGE;
		e.think1	= lithium_hook;
		e.noise1	= "enable lithium hook";

		if (hook_type (temp1) == 2)
		{
			if (!cancel)
				self_sprint (self, "Lithium hook already enabled\n");
			cancel	= 1;
		}
	}
	else if (self.impulse == IMP_VOTE_PRACTICE)
	{
		cancel = -1; // XXX This isn't ready yet.
		e.frag_rate	= 0.51;	// XXX settings.
		e.think1	= mode_practice;
		e.noise1	= "change mode to practice";

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

 	vip = find_vip ();
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

// this doesn't work yet
void ()
vote_no =
{
	local entity vip;

	vip = find_vip ();
	if (!vip)
		return self_sprint (self, "\{141} Nothing to vote on\n");

	// it's your vote, so cancel that bitch
	if (vip.owner == self)
	{
		remove_bit_from_players (vote_flags, VOTE_YES); // XXX Hmm. how can i avoid using this
		vip.runevar = 0;
		vip.nextthink = time;
	}
	else if (self.vote_flags & VOTE_YES)
		self.vote_flags = self.vote_flags - self.vote_flags & VOTE_YES;
};
