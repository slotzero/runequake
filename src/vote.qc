/*  $Id: vote.qc,v 1.52 2005/01/31 02:14:48 slotzero Exp $

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
	// practice
	* add disabled for practice mode
	* decide specifics on practice.. should alts be allowed, should runes be allowed, hook, etc.

	// exit
	* you can override a random map by selecting a non-random map.. but how to update message?

	// warnings
	* make sure that you don't try to assign value to a world entity (!vip for example)!!!

	// ideas
	* maybe a new command, auto-vote to disable your LAST_VOTE_*
	* auto-yes/auto-no to always vote yes or no whatever the vote.
	* a command to toggle the amount of bprints (from 3 to 1).
	* limit the number of votes per given time
*/

void ()
vote_impulse_commands =
{
	if (is_observer ())
	{
		// allow in-game queued players to vote in arena mode
		if (mode_arena () && self.runevar)
			vote ();
		else
			count_votes (2);
	}
	else if (self.impulse >= 1 && self.impulse <= 18)
		vote ();

	impulse_override_cancel ();
};

void ()
vote_command =
{
	self.state	= 0;
	self.aqstate	= self.aqstate | AQS_IMPOVER_VOTE_COMMANDS;
};

float (float tell)
vote_team_disabled =
{
	if (teamplay & TEAM_NO_VOTE
			|| (teamplay != 0 && teamplay != VOTE_TEAM_MODE)
			|| VOTE_TEAM_PERCENTAGE	<= 0
			|| VOTE_TEAM_PERCENTAGE > 1
			// IN_QW(|| 1) // XXX QW team support still broken
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

	remove_bit_from_players (vote_flags, VOTE_YES | VOTE_NO | VOTE_LAST_YES | VOTE_LAST_NO);
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
	local float i, tot, lack, need, voted, no, is_queue;

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
		i = 0;
		// count in-game queued players in arena mode
		if (mode_arena ())
		{
			if (is_observer_e (e) && e.runevar)
				i = 1;
		}

		if (is_player_e (e) || i)
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
toyo_bot =
{
	self_sprint (self.owner, "\{1}Toyo-BOT:");
	self_sprint (self.owner, " Hey ");
	self_sprint (self.owner, self.owner.netname);
	self_sprint (self.owner, ", type help-vote for additional vote options.\n");
	remove (self);
};

void ()
vote_think =
{
	local entity e;

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
			// poq
			s = allocate_string_size (64);
			s = "\{1}Request to ";
			if (self.noise1)
				s = strcat (s, self.noise1);
			if (self.noise2)
				s = strcat (s, self.noise2);
			if (self.noise3)
				s = strcat (s, self.noise3);
		-])
			e = find (world, classname, "player");
			while (e)
			{
				if (!e.vote_flags & (VOTE_LAST_YES | VOTE_LAST_NO) || self.runevar == 3)
				{
				IN_POQ([-
					// poq
					self_sprint (e, s);
				-], [-
					// qw
					self_sprint (e, "\{1}");
					self_sprint (e, "Request to ");
					if (self.noise1)
						self_sprint (e, self.noise1);
					if (self.noise2)
						self_sprint (e, self.noise2);
					if (self.noise3)
						self_sprint (e, self.noise3);
				-])
					// all
					if (e == self.owner)
						self_sprint (e, "\ntype 'no' to recall your vote\n");
					else if (e.vote_flags & VOTE_LAST_YES)
						self_sprint (e, "\nauto vote 'yes', type 'no' to recall\n");
					else if (e.vote_flags & VOTE_LAST_NO)
						self_sprint (e, "\nauto vote 'no', type 'yes' to recall\n");
					else
						self_sprint (e, "\ntype 'yes' or 'no' in console to vote\n");
				}
				e = find (e, classname, "player");
			}

		// Feature request for Toyo.  XXX Remove this at some point?
		if (self.impulse == IMP_VOTE_EXIT && !forced_nextmap && self.runevar == 3)
		{
			e		= spawn ();
			e.owner		= self.owner;
			e.think		= toyo_bot;
			e.nextthink	= time + 3;
		}

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

	// prevent auto-vote on exit votes of different levels
	if (LAST_VOTE_IMPULSE == IMP_VOTE_EXIT)
	{
		if (LAST_VOTE_LEVEL != forced_nextmap)
			LAST_VOTE_IMPULSE = 0;
	}

	// compare new vote to last vote and auto-vote if necessary
	if (LAST_VOTE_IMPULSE == self.impulse)
	{
		e = find (world, classname, "player");
		while (e)
		{
			if (e != self)
			{
				if (e.vote_flags & VOTE_LAST_YES)
					e.vote_flags = e.vote_flags | VOTE_YES;
				else if (e.vote_flags & VOTE_LAST_NO)
					e.vote_flags = e.vote_flags | VOTE_NO;
			}
			e = find (e, classname, "player");
		}
	}
	else
	{
		LAST_VOTE_IMPULSE = self.impulse;
		LAST_VOTE_LEVEL = string_null;
		remove_bit_from_players (vote_flags, VOTE_LAST_YES | VOTE_LAST_NO);
	}

	self.vote_flags = self.vote_flags | VOTE_YES | VOTE_LAST_YES;

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

		LAST_VOTE_LEVEL	= forced_nextmap;

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
		e.think1	= toggle_teamplay_real;
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
		e.think1	= change_mode_to_practice;
		e.noise1	= "change";
		e.noise2	= " mode to practice";

		if (mode_practice ())
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
		e.think1	= change_mode_to_normal;
		e.noise1	= "change";
		e.noise2	= " mode to normal";

		if (mode_normal ())
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

		if (NO_QUAD)
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

		if (NO_PENT)
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

		if (NO_RING)
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

		if (NO_SUIT)
			e.noise1	= "enable";
		else
			e.noise1	= "disable";
	}
	else if (self.impulse == IMP_VOTE_ARMOR)
	{
		// cancel	= 1;
		e.frag_rate	= 0.51; // XXX
		e.think1	= setarmor;
		e.noise2	= " armor ";

		if (NO_ARMOR)
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

		if (NO_ARMOR)
		{
			if (!cancel)
				self_sprint (self, "enable armor first\n");
			cancel = 1;
		}
	}
	else if (self.impulse == IMP_VOTE_RUNES)
	{
		// cancel	= 1;
		e.frag_rate	= 0.51; // XXX
		e.think1	= setrunes;
		e.noise2	= " runes ";

		if (NO_RUNES)
			e.noise1	= "enable";
		else
			e.noise1	= "disable";
	}
	else if (self.impulse == IMP_VOTE_ALTS)
	{
		// cancel	= 1;
		e.frag_rate	= 0.51; // XXX
		e.think1	= setalts;
		e.noise2	= " alternate weapons ";

		if (NO_ALT_WEAPONS)
			e.noise1	= "enable";
		else
			e.noise1	= "disable";

		if (mode_practice ())
		{
			if (!cancel)
				self_sprint (self, "disable practice mode first\n");
			cancel = 1;
		}
	}
	else if (self.impulse == IMP_VOTE_SHIELDS)
	{
		// cancel	= 1;
		e.frag_rate	= 0.51; // XXX
		e.think1	= setshields;
		e.noise2	= " spawn shields ";

		if (NO_SPAWN_SHIELDS)
			e.noise1	= "enable";
		else
			e.noise1	= "disable";

		if (!SPAWN_PROTECT_DURATION)
		{
			if (!cancel)
				self_sprint (self, "Spawn shields voting disabled\n");
			cancel = 1;
		}
	}
	else if (self.impulse == IMP_VOTE_HOOK_DAMAGE)
	{
		// cancel	= 1;
		e.frag_rate	= 0.51; // XXX
		e.think1	= sethookdamage;
		e.noise2	= " hook damage ";

		if (NO_HOOK_DAMAGE)
			e.noise1	= "enable";
		else
			e.noise1	= "disable";

		i = hook_type (temp1);
		if ((i == 1 && !HOOK_DAMAGE_FREE)
				|| (i == 2 && !HOOK_DAMAGE_LITHIUM)
				|| (!i && !HOOK_DAMAGE_RUNE))
		{
			if (!cancel)
				self_sprint (self, "Hook damage voting disabled\n");
			cancel = 1;
		}
	}
	else if (self.impulse == IMP_VOTE_ARENA)
	{
		// cancel	= 1;	//
		e.frag_rate	= 0.51;	// XXX move to settings.
		e.think1	= change_mode_to_arena;
		e.noise1	= "change";
		e.noise2	= " mode to arena";

		if (mode_arena ())
		{
			if (!cancel)
				self_sprint (self, "already in arena mode\n");
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
		self.vote_flags = self.vote_flags - self.vote_flags & (VOTE_NO | VOTE_LAST_NO);
		self_sprint (self, "You recalled your \bno\b vote\n");
		return;
	}

	if (self.vote_flags & VOTE_YES || is_observer ())
	{
		count_votes (1);
		return;
	}

	self.vote_flags = self.vote_flags | VOTE_YES | VOTE_LAST_YES;

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
		self.vote_flags = self.vote_flags - self.vote_flags & (VOTE_YES | VOTE_LAST_YES);
		self_sprint (self, "You recalled your \byes\b vote\n");
		return;
	}

	if (self.vote_flags & VOTE_NO || is_observer ())
	{
		count_votes (1);
		return;
	}

	self.vote_flags = self.vote_flags | VOTE_NO | VOTE_LAST_NO;

	count_votes (1);
};

void ()
show_votes =
{
	local entity e, vip;
	local float yes, no, tot;

	vip = find_vip ();
	if (vip)
	{
		self_sprint (self, "Vote: ");
		self_sprint (self, vip.noise1);
		self_sprint (self, vip.noise2);
		self_sprint (self, vip.noise3);
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
			if (vip.owner == e)
				self_sprint (self, " \{133}");
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
			if (vip.owner == e)
				self_sprint (self, " \{133}");
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
		self_sprint (self, "no votes\n");
};
