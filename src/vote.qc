/*  $Id: vote.qc,v 1.29 2004/07/15 04:23:23 slotzero Exp $

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
	* perhaps a new function to give refresh message, use disabled function maybe? [DONE]
	* decide specifics on practice.. should alts be allowed, should runes be allowed, hook, etc.

	// exit
	* you can override a random map by selecting a non-random map.. but how to update message?

	// observer
	* Better...

	// warnings
	* make sure that you don't try to assign value to a world entity (!vip for example)!!!
*/

float (float tell)
vote_team_disabled =
{
	if (teamplay & TEAM_NO_VOTE
			|| (teamplay != 0 && teamplay != VOTE_TEAM_MODE)
			|| VOTE_TEAM_PERCENTAGE	<= 0
			|| VOTE_TEAM_PERCENTAGE > 1
			IN_QW(|| 1) // XXX QW team support still broken
			)
	{
		if (tell)
			self_sprint (self, "Team voting is disabled\n");
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
			self_sprint (self, "Hook voting is disabled\n");
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
		dprint ("vote_action: vip is null\n");

	/* if (self.classname == "player")
		bprint (self.netname);
	else if (vip.owner.classname == "player")
		bprint (vip.owner.netname);
	else
		bprint ("Someone");

	bprint (" voted to ");
	if (vip.noise1)
		bprint (vip.noise1);
	if (vip.noise2)
		bprint (vip.noise2);
	if (vip.noise3)
		bprint (vip.noise3); */

	if (vip.noise1 == "enable" || vip.noise1 == "disable")
	{
		bprint (vip.noise2[%1]);
		bprint (vip.noise1);
		bprint ("d\n");
	}
	else if (vip.noise1 == "change")
	{
		bprint ("changing");
		bprint (vip.noise2);
		bprint (vip.noise3);
		bprint ("...\n");
	}

	if (vip.think1)
		vip.think1 ();
	else
		dprint ("vote_action: think1 is null\n");

	remove_bit_from_players (vote_flags, VOTE_YES | VOTE_NO);
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
			self_sprint_float (self, value);
			self_sprint (self, " vote");
			if (value != 1)
				self_sprint (self, "s");
			self_sprint (self, " in queue, please wait...\n");
		}
	}
	else
	{
		if (msg_type < 3)
		{
			if (msg_type == 1 && value <= 0)
				return;

			self_sprint_float (self, value);
			self_sprint (self, " more vote");
			if (value != 1)
				self_sprint (self, "s");
			self_sprint (self, " needed to ");
			if (vip.noise1)
				self_sprint (self, vip.noise1);
			if (vip.noise2)
				self_sprint (self, vip.noise2);
			if (vip.noise3)
				self_sprint (self, vip.noise3);
			self_sprint (self, "\n");
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
	local float tot, lack, need, voted, no, is_queue;

	vip = find_vip ();
	if (!vip)
	{
		if (type == 3)
			self_sprint (self, "vote: nothing to vote on\n");
		else if (type)
			self_sprint (self, "Join the game to vote\n");
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
			else if (e.vote_flags & VOTE_NO)
				no = no + 1;
		}
		e = find (e, classname, "player");
	}

	need = ceil (tot * vip.frag_rate);
	if (need < 1)
		need = 1;
	lack = need - voted;

	// XXX I have to see how this works out, for the most part, for every 2 people
	// who vote note, 1 vote is taken away.  This can be kind of pointless though
	// because it's essentially a race between votes.. a race which can be repeated
	// vote after vote...  Again, I have to see how this works out.
	lack = lack + floor (no * 0.50);

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
	IN_POQ([-
		local string s;
		// poq prevent crashing error
		if (!HUNK_CONTEXT_MAX)
		{
			self.nextthink = time + sys_ticrate;
			return;
		}
	-])

	if (count_votes (0) <= 0)
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
		remove_bit_from_players (vote_flags, VOTE_YES | VOTE_NO);
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
	local float i, cancel;

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
		e.noise1	= "change";

		if (forced_nextmap)
		{
			e.noise2	= " map to ";
			e.noise3	= forced_nextmap;
		}
		else
			e.noise2	= " to a random map";
	}
	else if (self.impulse == IMP_VOTE_TEAM)
	{
		cancel		= vote_team_disabled (1);
		e.frag_rate	= VOTE_TEAM_PERCENTAGE;
		e.think1	= toggle_teamplay;
		e.noise2	= " team mode ";

		if (teamplay & TEAM_TEAM_MASK)
			e.noise1	= "disable";
		else
			e.noise1	= "enable";
	}
	else if (self.impulse == IMP_VOTE_HOOK)
	{
		cancel		= vote_hook_disabled (1);
		e.frag_rate	= VOTE_HOOK_PERCENTAGE;
		e.think1	= toggle_free_hook;
		e.noise2	= " free hook ";

		i = hook_type (temp1);
		if (i)
		{
			if (i == 2)
			e.noise2	= " lithium hook ";
			e.noise1	= "disable";
		}
		else
			e.noise1	= "enable";
	}
	else if (self.impulse == IMP_VOTE_FREE)
	{
		cancel		= vote_hook_disabled (1);
		e.frag_rate	= VOTE_HOOK_PERCENTAGE;
		e.think1	= free_hook;
		e.noise1	= "enable";
		e.noise2	= " free hook ";

		if (hook_type (temp1) == 1)
		{
			if (!cancel)
				self_sprint (self, "free hook already enabled\n");
			cancel	= 1;
		}
	}
	else if (self.impulse == IMP_VOTE_LITHIUM)
	{
		cancel		= vote_hook_disabled (1);
		e.frag_rate	= VOTE_HOOK_PERCENTAGE;
		e.think1	= lithium_hook;
		e.noise1	= "enable";
		e.noise2	= " lithium hook ";

		if (hook_type (temp1) == 2)
		{
			if (!cancel)
				self_sprint (self, "lithium hook already enabled\n");
			cancel	= 1;
		}
	}
	else if (self.impulse == IMP_VOTE_PRACTICE)
	{
		// cancel	= 1;	//
		e.frag_rate	= 0.51;	// XXX move to settings.
		e.think1	= mode_practice;
		e.noise1	= "change";
		e.noise2	= " mode to practice";

		if (deathmatch & DM_MODE_PRACTICE)
		{
			if (!cancel)
				self_sprint (self, "already in practice mode\n");
			cancel = 1;
		}
	}
	else if (self.impulse == IMP_VOTE_NORMAL)
	{
		// cancel	= 1;
		e.frag_rate	= 0.51; // XXX move to settings (share with practice?)
		e.think1	= mode_normal;
		e.noise1	= "change";
		e.noise2	= " mode to normal";

		if (!deathmatch & DM_MODE_PRACTICE)
		{
			if (!cancel)
				self_sprint (self, "already in normal mode\n");
			cancel = 1;
		}
	}
	else if (self.impulse == IMP_VOTE_QUAD)
	{
		// cancel	= 1;
		e.frag_rate	= 0.51; // XXX
		e.think1	= setquad;
		e.noise2	= " quad ";

		if (NO_QUADS)
			e.noise1	= "enable";
		else
			e.noise1	= "disable";
	}
	else if (self.impulse == IMP_VOTE_PENT)
	{
		// cancel	= 1;
		e.frag_rate	= 0.51; // XXX
		e.think1	= setpent;
		e.noise2	= " pentagram ";

		if (NO_PENTS)
			e.noise1	= "enable";
		else
			e.noise1	= "disable";
	}
	else if (self.impulse == IMP_VOTE_RING)
	{
		// cancel	= 1;
		e.frag_rate	= 0.51; // XXX
		e.think1	= setring;
		e.noise2	= " ring of shadows ";

		if (NO_RINGS)
			e.noise1	= "enable";
		else
			e.noise1	= "disable";
	}
	else if (self.impulse == IMP_VOTE_SUIT)
	{
		// cancel	= 1;
		e.frag_rate	= 0.51; // XXX
		e.think1	= setsuit;
		e.noise2	= " environmental suit ";

		if (NO_SUITS)
			e.noise1	= "enable";
		else
			e.noise1	= "disable";
	}
	// no runes
	else if (self.impulse == IMP_VOTE_ARMOR)
	{
		// cancel	= 1;
		e.frag_rate	= 0.51; // XXX
		e.think1	= setarmor;
		e.noise2	= " armor ";

		if (NO_ARMORS)
			e.noise1	= "enable";
		else
			e.noise1	= "disable";
	}
	else if (self.impulse == IMP_VOTE_ROTATE)
	{
		// cancel	= 1;
		e.frag_rate	= 0.51; // XXX
		e.think1	= setrotate;
		e.noise2	= " rotating armor ";

		if (ROTATE)
			e.noise1	= "disable";
		else
			e.noise1	= "enable";

		if (NO_ARMORS)
		{
			if (!cancel)
				self_sprint (self, "enable armor first\n");
			cancel = 1;
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

		remove_bit_from_players (vote_flags, VOTE_YES | VOTE_NO);
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

	if (is_admin ())
	{
		vote_action (vip);
		return;
	}

	if (self.vote_flags & VOTE_NO)
	{
		self.vote_flags = self.vote_flags - self.vote_flags & VOTE_NO;
		self_sprint (self, "You recalled your \bno\b vote\n");
		return;
	}

	if (self.vote_flags & VOTE_YES || is_observer ())
	{
		count_votes (1);
		return;
	}

	self.vote_flags = self.vote_flags | VOTE_YES;

	if (count_votes (1) <= 0)
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

	if (is_admin ())
	{
		vip.runevar	= 0;
		vip.nextthink	= time;
		return;
	}

	if (self.vote_flags & VOTE_YES)
	{
		self.vote_flags = self.vote_flags - self.vote_flags & VOTE_YES;
		self_sprint (self, "You recalled your \byes\b vote\n");
		return;
	}

	if (self.vote_flags & VOTE_NO || is_observer ())
	{
		count_votes (1);
		return;
	}

	self.vote_flags = self.vote_flags | VOTE_NO;

	count_votes (1);
};

void ()
show_votes =
{
	local entity e;
	local float yes, no, tot;

	e = find_vip ();
	if (e)
	{
		self_sprint (self, "Vote: ");
		self_sprint (self, e.noise1);
		self_sprint (self, e.noise2);
		self_sprint (self, e.noise3);
		self_sprint (self, "\n\n");
	}
	else
	{
		self_sprint (self, "No votes in progress\n");
		return;
	}

	yes = no = 0;
	e = find (world, classname, "player");
	while (e)
	{
		if (e.vote_flags & VOTE_YES)
		{
			if (e == self)
				self_sprint (self, "\byes\b - ");
			else
				self_sprint (self, "yes - ");

			self_sprint (self, e.netname);
			self_sprint (self, "\n");
			yes = yes + 1;
		}
		e = find (e, classname, "player");
	}

	e = find (world, classname, "player");
	while (e)
	{
		if (e.vote_flags & VOTE_NO)
		{
			if (e == self)
				self_sprint (self, " \bno\b - ");
			else
				self_sprint (self, " no - ");
			self_sprint (self, e.netname);
			self_sprint (self, "\n");
			no = no + 1;
		}
		e = find (e, classname, "player");
	}
	if (no || yes)
	{
		self_sprint (self, "\n");
		self_sprint_float (self, yes); self_sprint (self, " yes / ");
		self_sprint_float (self, no);  self_sprint (self, " no / ");
		tot = count_votes (0);
		self_sprint_float (self, tot); self_sprint (self, " lack\n");
	}
	else
		self_sprint (self, "No vote\n");
};
