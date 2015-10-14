/*
    Copyright (C) 2003-2014  David 'Slot Zero' Roberts.

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
*/

void ()
vote_impulse_commands =
{
	if (is_observer ())
	{
		// allow queued players to vote in arena mode
		if (gamemode & MODE_ARENA && self.runevar)
			vote ();
		// allow observers to vote except during match
		else if (gamemode == MODE_MATCH && !match.state)
			vote ();
		else
			count_votes (2);
	}
	else if (self.impulse >= 1 && self.impulse <= IMP_VOTE_MAX)
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
			|| gamemode & MODE_ARENA
			|| gamemode == MODE_MATCH
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
	if (options2 & VOTE_HOOK_DISABLED || VOTE_HOOK_PERCENTAGE <= 0 || VOTE_HOOK_PERCENTAGE > 1)
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
	else if (vip.noise2 == " match length to ")
	{
		if (!match.state)
		{
			bprint ("match length changed to ");
			bprint (vip.noise3);
			bprint (" minutes\n");
		}
	}
	else if (vip.noise1 == "change")
	{
		bprint ("changing");
		bprint (vip.noise2);
		bprint (vip.noise3);
		bprint ("...\n");
	}
	else
	{
		bprint (vip.noise4);
	}

	if (vip.think1)
		vip.think1 ();
	else
		dprint ("vote_action: think1 is null\n");

	// an option may have changed, so force set_gamemode() when all players leave
	gamemode_set = 0;

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
		{
			if (gamemode & MODE_ARENA)
				self_sprint (self, "Join the queue to vote\n");
			else if (gamemode == MODE_MATCH && match.state)
				self_sprint (self, "Observers can't vote while match in progress\n");
			else
				self_sprint (self, "Join the game to vote\n");
		}
		return 0;
	}

	is_queue = LEVEL_RECONNECT_ALLOWANCE > time;

	tot = voted = 0;
	e = find (world, classname, "player");
	while (e)
	{
		i = 0;
		if (is_observer_e (e))
		{
			if (gamemode & MODE_ARENA && e.runevar)
				i = 1;
			else if (gamemode == MODE_MATCH && !match.state)
				i = 1;
		}

		if (is_player_e (e))
			i = 1;

		// only count afk with vote flags
		if (e.rqstate & RQS_AFK)
		{
			if (i)
			{
				if (!e.vote_flags & (VOTE_YES | VOTE_NO))
					i = 0;
			}
		}

		if (i)
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
	// lack = lack + no;
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

		if (self.impulse == IMP_VOTE_EXIT)
			forced_nextmap = string_null;
		else if (self.impulse == IMP_VOTE_TIMESET)
			VOTE_TIMESET = 0;
		self.owner.last_vote = time + 30; // prevent vote flood
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

	// prevent players from voting too often
	if (self.last_vote > time)
	{
		if (!is_admin ())
		{
			if (count_players (1) > 1)
			{
				self.last_vote = time + 15; // reset
				return self_sprint (self, "\{141} you can't initiate a vote so soon\n");
			}
		}
	}

	// match mode timeset
	if (!VOTE_TIMESET && self.impulse == IMP_VOTE_TIMESET)
	{
		print_timeset_menu ();
		return;
	}

	// prevent auto-vote on exit votes of different levels
	if (LAST_VOTE_IMPULSE == IMP_VOTE_EXIT)
	{
		if (LAST_VOTE_LEVEL != forced_nextmap)
			LAST_VOTE_IMPULSE = 0;
	}

	// compare new vote to last vote and auto-vote if necessary
	if (LAST_VOTE_IMPULSE == self.impulse)
		i = 1;
	else
	{
		i = 0;
		LAST_VOTE_IMPULSE = self.impulse;
		LAST_VOTE_LEVEL = string_null;
		remove_bit_from_players (vote_flags, VOTE_LAST_YES | VOTE_LAST_NO);
	}

	e = find (world, classname, "player");
	while (e)
	{
		if (e != self)
		{
			// remove vote flags from afk and prevent auto vote
			if (e.rqstate & RQS_AFK)
				e.vote_flags = 0;
			else if (e.rqflags & RQ_AUTO_VOTE_NO && !e.vote_flags & VOTE_LAST_YES)
				e.vote_flags = e.vote_flags | VOTE_NO | VOTE_LAST_NO;
			else if (i)
			{
				if (e.vote_flags & VOTE_LAST_YES)
					e.vote_flags = e.vote_flags | VOTE_YES;
				else if (e.vote_flags & VOTE_LAST_NO)
					e.vote_flags = e.vote_flags | VOTE_NO;
			}
		}
		e = find (e, classname, "player");
	}

	self.vote_flags = self.vote_flags | VOTE_YES | VOTE_LAST_YES;
	self.afk = time;

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

			// weight frequently voted levels higher
			if (track_level_duplicate (forced_nextmap))
				e.frag_rate = 1;
		}
		else
			e.noise2	= " to a random map";

		if (gamemode == MODE_MATCH && match.state)
		{
			self_sprint (self, "Cannot change level while match is in progress\n");
			LAST_VOTE_LEVEL = forced_nextmap = string_null;
			cancel = 1;
		}
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

		i = hook_type (options2);
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

		if (hook_type (options2) == 1)
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

		if (hook_type (options2) == 2)
		{
			if (!cancel)
				self_sprint (self, "lithium hook already enabled\n");
			cancel	= 1;
		}
	}
	else if (self.impulse == IMP_VOTE_PRACTICE)
	{
		cancel		= options & MODE_LOCKED;
		e.frag_rate	= 0.51;	// XXX move to settings.
		e.think1	= change_mode_to_practice;
		e.noise1	= "change";
		e.noise2	= " mode to practice";

		if (cancel)
			self_sprint (self, "mode is locked\n");
		else if (gamemode == MODE_PRACTICE)
		{
			self_sprint (self, "already in practice mode\n");
			cancel = 1;
		}
	}
	else if (self.impulse == IMP_VOTE_NORMAL)
	{
		cancel		= options & MODE_LOCKED;
		e.frag_rate	= 0.51; // XXX move to settings (share with practice?)
		e.think1	= change_mode_to_normal;
		e.noise1	= "change";
		e.noise2	= " mode to normal";

		if (cancel)
			self_sprint (self, "mode is locked\n");
		else if (gamemode == MODE_NORMAL)
		{
			self_sprint (self, "already in normal mode\n");
			cancel = 1;
		}
	}
	else if (self.impulse == IMP_VOTE_QUAD)
	{
		cancel		= !find (world, classname, "item_artifact_super_damage");
		e.frag_rate	= 0.51; // XXX
		e.think1	= setquad;
		e.noise2	= " quad ";

		if (options & NO_QUAD)
			e.noise1	= "enable";
		else
			e.noise1	= "disable";

		if (cancel)
			self_sprint (self, "this level has no quads\n");
	}
	else if (self.impulse == IMP_VOTE_PENT)
	{
		cancel		= !find (world, classname, "item_artifact_invulnerability");
		e.frag_rate	= 0.51; // XXX
		e.think1	= setpent;
		e.noise2	= " pentagram ";

		if (options & NO_PENT)
			e.noise1	= "enable";
		else
			e.noise1	= "disable";

		if (cancel)
			self_sprint (self, "this level has no pents\n");
	}
	else if (self.impulse == IMP_VOTE_RING)
	{
		cancel		= !find (world, classname, "item_artifact_invisibility");
		e.frag_rate	= 0.51; // XXX
		e.think1	= setring;
		e.noise2	= " ring of shadows ";

		if (options & NO_RING)
			e.noise1	= "enable";
		else
			e.noise1	= "disable";

		if (cancel)
			self_sprint (self, "this level has no rings\n");
	}
	else if (self.impulse == IMP_VOTE_SUIT)
	{
		cancel		= !find (world, classname, "item_artifact_envirosuit");
		e.frag_rate	= 0.51; // XXX
		e.think1	= setsuit;
		e.noise2	= " environmental suit ";

		if (options & NO_SUIT)
			e.noise1	= "enable";
		else
			e.noise1	= "disable";

		if (cancel)
			self_sprint (self, "this level has no suits\n");
	}
	else if (self.impulse == IMP_VOTE_ARMOR)
	{
		cancel		= !find (world, netname, "item_armor_all");
		e.frag_rate	= 0.51; // XXX
		e.think1	= setarmor;
		e.noise2	= " armor ";

		if (options & NO_ARMOR)
			e.noise1	= "enable";
		else
			e.noise1	= "disable";

		if (cancel)
			self_sprint (self, "this level has no armors\n");
	}
	else if (self.impulse == IMP_VOTE_ROTATE)
	{
		cancel		= !find (world, netname, "item_armor_all");
		e.frag_rate	= 0.51; // XXX
		e.think1	= setrotate;
		e.noise2	= " rotating armor ";

		if (options & ARMOR_ROTATE)
			e.noise1	= "disable";
		else
			e.noise1	= "enable";

		if (cancel)
			self_sprint (self, "this level has no armors\n");
		else
		{
			if (options & NO_ARMOR)
			{
				self_sprint (self, "enable armor first\n");
				cancel = 1;
			}
		}
	}
	else if (self.impulse == IMP_VOTE_RUNES)
	{
		// cancel	= 1;
		e.frag_rate	= 0.51; // XXX
		e.think1	= setrunes;
		e.noise2	= " runes ";

		if (options & NO_RUNES)
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

		if (options & NO_ALT_WEAPONS)
			e.noise1	= "enable";
		else
			e.noise1	= "disable";

		if (gamemode == MODE_PRACTICE)
		{
			if (!cancel)
				self_sprint (self, "alt weapons disabled in practice\n");
			cancel = 1;
		}
	}
	else if (self.impulse == IMP_VOTE_SHIELDS)
	{
		// cancel	= 1;
		e.frag_rate	= 0.51; // XXX
		e.think1	= setshields;
		e.noise2	= " spawn shields ";

		if (options & NO_SPAWN_SHIELDS)
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

		if (options & NO_HOOK_DAMAGE)
			e.noise1	= "enable";
		else
			e.noise1	= "disable";

		i = hook_type (options2);
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
		cancel		= options & MODE_LOCKED;
		e.frag_rate	= 0.51;	// XXX move to settings.
		e.think1	= change_mode_to_arena;
		e.noise1	= "change";
		e.noise2	= " mode to arena";

		if (cancel)
			self_sprint (self, "mode is locked\n");
		else if (gamemode == MODE_ARENA)
		{
			self_sprint (self, "already in arena mode\n");
			cancel = 1;
		}
	}
	else if (self.impulse == IMP_VOTE_MEGA)
	{
		// cancel	= 1;
		e.frag_rate	= 0.51; // XXX
		e.think1	= setmega;
		e.noise2	= " mega-health boxes ";

		if (options & NO_MEGA)
			e.noise1	= "enable";
		else
			e.noise1	= "disable";
	}
	else if (self.impulse == IMP_VOTE_WEAPONS_STAY)
	{
		// cancel	= 1;
		e.frag_rate	= 0.51; // XXX
		e.think1	= toggle_weapons_stay;
		e.noise2	= " weapons stay ";

		if (!options & WEAPONS_STAY)
			e.noise1	= "enable";
		else
			e.noise1	= "disable";
	}
	else if (self.impulse == IMP_VOTE_MATCH)
	{
		cancel		= IN_POQ(options & MODE_LOCKED, 1);
		e.frag_rate	= 0.51;	// XXX move to settings.
		e.think1	= change_mode_to_match;
		e.noise1	= "change";
		e.noise2	= " mode to match";

		if (cancel)
			self_sprint (self, "mode is locked\n");
		else if (gamemode == MODE_MATCH)
		{
			self_sprint (self, "already in match mode\n");
			cancel = 1;
		}
	}
	else if (self.impulse == IMP_VOTE_TIMESET)
	{
		// cancel	= 1;
		e.frag_rate	= 0.51; // XXX
		e.think1	= vote_timeset;
		e.noise1	= "change";
		e.noise2	= " match length to ";
		e.noise3	= timeset[((VOTE_TIMESET - 1) * 3) * %1];
	}
	else if (self.impulse == IMP_VOTE_ARMOR_DROP)
	{
		// cancel	= 1;
		e.frag_rate	= 0.51; // XXX
		e.think1	= toggle_armor_drop;
		e.noise2	= " armor drop ";

		if (options & NO_DROP_ARMOR)
			e.noise1	= "enable";
		else
			e.noise1	= "disable";
	}
	else if (self.impulse == IMP_VOTE_FASTSTART)
	{
		// cancel	= 1;
		e.frag_rate	= 0.51; // XXX
		e.think1	= setfaststart;
		e.noise2	= " fast match starts ";

		if (options & FASTSTART)
			e.noise1	= "disable";
		else
			e.noise1	= "enable";
	}
	else if (self.impulse == IMP_VOTE_UNLOCK)
	{
		// cancel	= 1;
		e.frag_rate	= 0.51; // XXX
		e.think1	= setmatchlock;
		e.noise1	= "allow new players to join";

		if (!match.state)
		{
			if (!cancel)
				self_sprint (self, "No match in progress\n");
			cancel = 1;
		}
		else if (MATCHLOCK)
			e.noise4 = "Match has been unlocked\nNew players may join at will\n";
		else
		{
			if (!cancel)
				self_sprint (self, "Match is already unlocked\n");
			cancel = 1;
		}
	}
	else if (self.impulse == IMP_VOTE_LOCK)
	{
		// cancel	= 1;
		e.frag_rate	= 0.51; // XXX
		e.think1	= setmatchlock;
		e.noise1	= "lock the match";

		if (!match.state)
		{
			if (!cancel)
				self_sprint (self, "No match in progress\n");
			cancel = 1;
		}
		else if (!MATCHLOCK)
			e.noise4 = "Match has been locked\n";
		else
		{
			if (!cancel)
				self_sprint (self, "Match is already locked\n");
			cancel = 1;
		}
	}
	else if (self.impulse == IMP_VOTE_BACKPACKS)
	{
		// cancel	= 1;
		e.frag_rate	= 0.51; // XXX
		e.think1	= setbackpacks;
		e.noise2	= " backpacks ";

		if (options & NO_BACKPACKS)
			e.noise1	= "enable";
		else
			e.noise1	= "disable";
	}
	else if (self.impulse == IMP_VOTE_MIDAIR)
	{
		cancel		= options & MODE_LOCKED;
		e.frag_rate	= 0.51;	// XXX move to settings.
		e.think1	= change_mode_to_midair;
		e.noise1	= "change";
		e.noise2	= " mode to midair";

		if (cancel)
			self_sprint (self, "mode is locked\n");
		else if (gamemode == MODE_MIDAIR)
		{
			self_sprint (self, "already in midair mode\n");
			cancel = 1;
		}
	}
	else if (self.impulse == IMP_VOTE_POWERUP_DROP)
	{
		// cancel	= 1;
		e.frag_rate	= 0.51; // XXX
		e.think1	= toggle_powerup_drop;
		e.noise2	= " powerup drop ";

		if (options & NO_DROP_POWERUP)
			e.noise1	= "enable";
		else
			e.noise1	= "disable";
	}
	else if (self.impulse == IMP_VOTE_RUNE_DROP)
	{
		// cancel	= 1;
		e.frag_rate	= 0.51; // XXX
		e.think1	= toggle_rune_drop;
		e.noise2	= " rune dropping ";

		if (options & NO_DROP_ON_DEATH)
			e.noise1	= "enable";
		else
			e.noise1	= "disable";
	}
	else if (self.impulse == IMP_VOTE_LG_DISCHARGE)
	{
		// cancel	= 1;
		e.frag_rate	= 0.51; // XXX
		e.think1	= toggle_lightning_discharge;
		e.noise2	= " lightning discharge ";

		if (options & NO_DISCHARGE)
			e.noise1	= "enable";
		else
			e.noise1	= "disable";
	}
	else if (self.impulse == IMP_VOTE_CLASSIC_MEGA)
	{
		// cancel	= 1;
		e.frag_rate	= 0.51; // XXX
		e.think1	= setclassicmega;
		e.noise2	= " classic mega ";

		if (options & CLASSIC_MEGA)
			e.noise1	= "disable";
		else
			e.noise1	= "enable";
	}
	else if (self.impulse == IMP_VOTE_HEADS)
	{
		cancel		= options & MODE_LOCKED;
		e.frag_rate	= 0.51;	// XXX
		e.think1	= change_mode_to_heads;
		e.noise1	= "change";
		e.noise2	= " mode to head hunters";

		if (cancel)
			self_sprint (self, "mode is locked\n");
		else if (gamemode == MODE_HEADS)
		{
			self_sprint (self, "already in head hunters mode\n");
			cancel = 1;
		}
	}
	else if (self.impulse == IMP_VOTE_RANDOM_SPAWN)
	{
		// cancel	= 1;
		e.frag_rate	= 0.51; // XXX
		e.think1	= toggle_random_spawn;
		e.noise2	= " random spawn ";

		if (options & RANDOM_SPAWN)
			e.noise1	= "disable";
		else
			e.noise1	= "enable";
	}
	else if (self.impulse == IMP_VOTE_SHOOT_BUTTONS)
	{
		cancel	= !find (world, netname, "func_button_shootable");
		e.frag_rate	= 0.51; // XXX
		e.think1	= toggle_shoot_buttons;
		e.noise2	= " shootable buttons ";

		if (options & SHOOT_BUTTONS)
			e.noise1	= "disable";
		else
			e.noise1	= "enable";

		if (cancel)
			self_sprint (self, "this level has no shootable buttons\n");
	}
	else if (self.impulse == IMP_VOTE_POWERUP_HATS)
	{
		// cancel	= 1;
		e.frag_rate	= 0.51; // XXX
		e.think1	= toggle_powerup_hats;
		e.noise2	= " powerup hats ";

		if (options & NO_POWERUP_HATS)
			e.noise1	= "enable";
		else
			e.noise1	= "disable";
	}
	else if (self.impulse == IMP_VOTE_DEFAULT)
	{
		cancel		= scratch1 & S1_NO_DEFAULT;
		e.frag_rate	= 0.33; // XXX [Lowered this for Sprax, was 51]
		e.think1	= set_gamemode_default;
		e.noise2	= "reset all vote options to default";
		e.noise4	= "Resetting all gamemode vote options\n"; // XXX To which mode?

		if (cancel)
			self_sprint (self, "this feature is disabled on this server\n");
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
	local float i;

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

	i = 0;
	if (is_observer ())
	{
		if (gamemode & MODE_ARENA && self.runevar)
			i = 0;
		else if (gamemode == MODE_MATCH && !match.state)
			i = 0;
		else
			i = 1;
	}

	if (self.vote_flags & VOTE_YES || i)
	{
		count_votes (1);
		return;
	}

	self.vote_flags = self.vote_flags | VOTE_YES | VOTE_LAST_YES;
	self.afk = time;

	if (count_votes (1) <= 0)
		vote_action (vip);
};

void ()
vote_no =
{
	local entity vip;
	local float i;

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

	i = 0;
	if (is_observer ())
	{
		if (gamemode & MODE_ARENA && self.runevar)
			i = 0;
		else if (gamemode == MODE_MATCH && !match.state)
			i = 0;
		else
			i = 1;
	}

	if (self.vote_flags & VOTE_NO || i)
	{
		count_votes (1);
		return;
	}

	self.vote_flags = self.vote_flags | VOTE_NO | VOTE_LAST_NO;
	self.afk = time;

	count_votes (1);
};

void ()
show_votes =
{
	local entity e, vip;
	local float i, yes, no, tot;

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
		i = 0;
		if (is_observer_e (e))
		{
			if (gamemode & MODE_ARENA && e.runevar)
				i = 1;
			else if (gamemode == MODE_MATCH && !match.state)
				i = 1;
		}

		if (is_player_e (e))
			i = 1;

		if (e.vote_flags & VOTE_YES && i)
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
		i = 0;
		if (is_observer_e (e))
		{
			if (gamemode & MODE_ARENA && e.runevar)
				i = 1;
			else if (gamemode == MODE_MATCH && !match.state)
				i = 1;
		}

		if (is_player_e (e))
			i = 1;

		if (e.vote_flags & VOTE_NO && i)
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
