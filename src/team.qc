/*
    Copyright (C) 1998-2001  Roderick Schertler.

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

float ()
enforced_teams =
{
	local float t;

	t = teamplay & TEAM_ENFORCE_MASK;
	if (t == TEAM_2_TEAMS)
		return 2;
	else if (t == TEAM_3_TEAMS)
		return 3;
	else if (t == TEAM_4_TEAMS)
		return 4;
	else
		return 0;
};

float (float tm)
is_valid_team =
{
	local float t;

	t = enforced_teams ();
	if (!t)
		return 1;
	return (tm == TEAM_1 || tm == TEAM_2
		|| (t >= 3 && tm == TEAM_3)
		|| (t >= 4 && tm == TEAM_4));
};

float ()
correct_team =
{
	local float aqfteam;

	if (!enforced_teams ())
		return -1;
	aqfteam = self.aqflags & AQ_TEAM_MASK;
	if (aqfteam == AQ_TEAM_NIL) return TEAM_NIL;
	if (aqfteam == AQ_TEAM_1) return TEAM_1;
	if (aqfteam == AQ_TEAM_2) return TEAM_2;
	if (aqfteam == AQ_TEAM_3) return TEAM_3;
	if (aqfteam == AQ_TEAM_4) return TEAM_4;
	return 0;
};

float ()
is_correct_team =
{
	local float tm, tc;

	tm = correct_team ();
	tc = team_top_color (tm);

	return (tm == -1 || (self.team == tm && self.team == tc));
};

float (float tm)
team_to_color =
{
	return tm - 1;
};

float (float tm)
team_to_particle =
{
	tm = (tm - 1) * 16;
	if (tm < 128)
		tm = tm + 8;

	return tm;
};

float (float tm)
team_top_color =
{
	local float tc;

	tc = (self.cl[CL_COLORS] / %1 - (tm - 1)) / 16;

	return tc + 1;
};

float (float bc)
random_top_color =
{
	local float tc, i, t1, t2, t3, t4;

	t1 = team_to_color (TEAM_1);
	t2 = team_to_color (TEAM_2);
	t3 = team_to_color (TEAM_3);
	t4 = team_to_color (TEAM_3);
	i = 0;
	while (i < 100)
	{
		tc = floor (random () * 14);
		if (tc != t1 && tc != t2 && tc != t3 && tc != t4)
			return tc;
		i = i + 1;
	}
	return bc;
};

float (float tm)
count_team =
{
	local entity e;
	local float n;

	n = 0;
	e = find (world, classname, "player");
	while (e)
	{
		if (is_valid_player_e (e) && e.team == tm)
			n = n + 1;
		e = find (e, classname, "player");
	}
	return n;
};

float (float tm)
count_team_observers =
{
	local entity e;
	local float n;

	n = 0;
	e = find (world, classname, "player");
	while (e)
	{
		if (e.team == tm && is_observer_e (e))
			n = n + 1;
		e = find (e, classname, "player");
	}
	return n;
};

void (entity e, float tm)
set_team_e =
{
	local float tc, bc, bits;
	local string s;

	e.team = tm;

	if (tm == TEAM_NIL)
		bits = AQ_TEAM_NIL;
	else if (tm == TEAM_1)
		bits = AQ_TEAM_1;
	else if (tm == TEAM_2)
		bits = AQ_TEAM_2;
	else if (tm == TEAM_3)
		bits = AQ_TEAM_3;
	else if (tm == TEAM_4)
		bits = AQ_TEAM_4;
	else
	{
		bprint_float (tm);
		bprint (" invalid team\n");
		error ("invalid team");
	}
	e.aqflags = e.aqflags - e.aqflags & AQ_TEAM_MASK + bits;

	bc = team_to_color (tm);
	self_stuffcmd (e, "color ");
	if (0 && tm != TEAM_NIL)
	{
		tc = random_top_color (bc);
		s = ftos (tc); self_stuffcmd (e, s);
		self_stuffcmd (e, " ");
	}
	s = ftos (bc); self_stuffcmd (e, s);
	self_stuffcmd (e, "\n");
};

// Return true if self is on a fair team.  This is called if a player
// joins the server with a valid team color or if she changes teams.
// So, it should return false if the player shouldn't be allowed to join
// that team, because it was already bigger than another team.

float ()
is_allowable_team =
{
	local float tm, n_teams, any_valid, n1, n2, n3, n4;

	tm = self.team;
	n_teams = enforced_teams ();
	if (!n_teams)
		return 1;

	// In match mode, team nil is for observing admins, but admins
	// can also be on teams.
	if (gamemode == MODE_MATCH)
	{
		if (tm == TEAM_NIL && (!is_observer () || !self.aqflags & AQ_ADMIN))
			return 0;
	}
	// When not in match mode, team nil is == observers.
	else if (is_observer ())
		return tm == TEAM_NIL;

	// In TEAM_CHANGE_ANY mode, there are no limits on which
	// team you join, as long as you join a valid team.
	if (teamplay & TEAM_CHANGE_MASK == TEAM_CHANGE_ANY)
		any_valid = 1;
	// This mode allows the top dog to change teams (one hopes to
	// switch to a worse team).
	else if (teamplay & TEAM_CHANGE_MASK == TEAM_CHANGE_TOPDOG
			&& is_topdog ())
		any_valid = 1;
	else
		any_valid = 0;
	if (any_valid)
	{
		if (tm == TEAM_1
				|| tm == TEAM_2
				|| (n_teams > 2 && tm == TEAM_3)
				|| (n_teams > 3 && tm == TEAM_4))
			return 1;
		else
			return 0;
	}

	n1 = count_team (TEAM_1);
	n2 = count_team (TEAM_2);
	n3 = count_team (TEAM_3);
	n4 = count_team (TEAM_4);

	// Remove myself from the team counts, to see if this team was
	// bigger than any other before I joined it.
	if (tm == TEAM_1)			n1 = n1 - 1;
	else if (tm == TEAM_2)			n2 = n2 - 1;
	else if (n_teams > 2 && tm == TEAM_3)	n3 = n3 - 1;
	else if (n_teams > 3 && tm == TEAM_4)	n4 = n4 - 1;
	else					return 0;

	if (n_teams > 3)
	{
		if (tm == TEAM_4 && n4 <= n3 && n4 <= n2 && n4 <= n1)		return 1;
		else if (tm == TEAM_3 && n3 <= n4 && n3 <= n1 && n3 <= n1)	return 1;
		else if (tm == TEAM_2 && n2 <= n4 && n2 <= n3 && n2 <= n1)	return 1;
		else if (tm == TEAM_1 && n1 <= n4 && n1 <= n3 && n1 <= n2)	return 1;
	}
	else if (n_teams > 2)
	{
		if (tm == TEAM_3 && n3 <= n2 && n3 <= n1)	return 1;
		else if (tm == TEAM_2 && n2 <= n3 && n2 <= n1)	return 1;
		else if (tm == TEAM_1 && n1 <= n3 && n1 <= n2)	return 1;
	}
	else
	{
		if (tm == TEAM_2 && n2 <= n1)			return 1;
		else if (tm == TEAM_1 && n1 <= n2)		return 1;
	}
	return 0;
};

float (float n_teams, float n1, float n2, float n3, float n4)
pick_team =
{
	if (n_teams > 3 && n4 <= n1 && n4 <= n2 && n4 <= n3)	return TEAM_4;
	if (n_teams > 2 && n3 <= n1 && n3 <= n2)		return TEAM_3;
	if (n2 <= n1)						return TEAM_2;
	return TEAM_1;
};

void (entity e)
assign_teams =
{
	local float just_one, n_teams, n1, n2, n3, n4, new_team, c;
	local string s;

	just_one = (e != world);

	n_teams = enforced_teams ();
	if (!n_teams)
		return;
	n1 = count_team (TEAM_1);
	pqc_new_team (e, ((TEAM_1 - 1) * 16) + (TEAM_1 - 1));
	c = team_to_teamfrags (TEAM_1);
	pqc_team_frags (e, TEAM_1 - 1, c);
	if (n_teams > 1)
	{
		n2 = count_team (TEAM_2);
		pqc_new_team (e, ((TEAM_2 - 1) * 16) + (TEAM_2 - 1));
		c = team_to_teamfrags (TEAM_2);
		pqc_team_frags (e, TEAM_2 - 1, c);
	}
	else
		n2 = -1;
	if (n_teams > 2)
	{
		n3 = count_team (TEAM_3);
		pqc_new_team (e, ((TEAM_3 - 1) * 16) + (TEAM_3 - 1));
		c = team_to_teamfrags (TEAM_3);
		pqc_team_frags (e, TEAM_3 - 1, c);
	}
	else
		n3 = -1;
	if (n_teams > 3)
	{
		n4 = count_team (TEAM_4);
		pqc_new_team (e, ((TEAM_4 - 1) * 16) + (TEAM_4 - 1));
		c = team_to_teamfrags (TEAM_4);
		pqc_team_frags (e, TEAM_4 - 1, c);
	}
	else
		n4 = -1;

	if (just_one)
	{
		// Don't include e in the team counts.
		if (e.team == TEAM_1)				n1 = n1 - 1;
		else if (e.team == TEAM_2)			n2 = n2 - 1;
		else if (e.team == TEAM_3 && n_teams > 2)	n3 = n3 - 1;
		else if (e.team == TEAM_4 && n_teams > 3)	n4 = n4 - 1;
	}
	else
	{
		e = find (world, classname, "player");
	}
	while (e)
	{
		if (is_observer_e (e) && gamemode != MODE_MATCH)
			set_team_e (e, TEAM_NIL);
		else
		{
			if (just_one || (is_valid_player_e (e) && !is_valid_team (e.team)))
			{
				new_team = pick_team (n_teams, n1, n2, n3, n4);
				if (new_team == TEAM_1)		n1 = n1 + 1;
				else if (new_team == TEAM_2)	n2 = n2 + 1;
				else if (new_team == TEAM_3)	n3 = n3 + 1;
				else if (new_team == TEAM_4)	n4 = n4 + 1;
				else
					error ("invalid team");
				set_team_e (e, new_team);
				sprint (e, "You have been assigned to the ");
				c = team_to_color (new_team);
				s = color_to_name (c);
				sprint (e, s);
				sprint (e, "\n");
			}
		}
		if (just_one)
			return;
		e = find (e, classname, "player");
	}
};

void (float new_teamplay, float update_cvar)
change_teamplay =
{
	local float old_teamplay, old_teams, new_teams;
	local entity e;
	local string s, poq;

	dprint ("new_teamplay(");
	dprint_float (new_teamplay);
	dprint (")\n");

	if (update_cvar)
	{
		if (HUNK_CONTEXT_MAX)
		{
			poq = ftos (new_teamplay);
			if (FORWARD_MAX_PLAYERS_REAL < 0)
				poq = strcat (poq, " [forward server]");
			else
			{
				poq = strcat (poq, " Rune Quake ");
				poq = strcat (poq, version);
			}

			cvar_set ("teamplay", poq, 2);
		}
		else
		{
			localcmd ("teamplay \"");
			s = ftos (new_teamplay);
			localcmd (s);
			localcmd (" Rune Quake ");
			localcmd (version);
			if (FORWARD_MAX_PLAYERS_REAL < 0)
				localcmd (" [forward server]");
				localcmd ("\"\n");
		}
	}

	old_teamplay = teamplay;
	old_teams = enforced_teams ();
	teamplay = new_teamplay;
	new_teams = enforced_teams ();

	// Don't allow enforced teams in arena or match.
	if (gamemode & MODE_ARENA || gamemode == MODE_MATCH)
		return;

	if ((!old_teams && new_teams) || (new_teams && old_teams > new_teams))
	{
		frag_init ();
		assign_teams (world);
	}
	else if (old_teams && !new_teams)
	{
		// Enforced teamplay turned off, forget everybody's team.
		frag_init ();
		e = find (world, classname, "player");
		while (e)
		{
			e.aqflags = e.aqflags - e.aqflags & AQ_TEAM_MASK;
			set_random_colors (e);
			e = find (e, classname, "player");
		}
	}
};

// I used to do an initial change_teamplay() in rjs_worldspawn().
// When I added START_LEVEL_EXEC, though, that broke.  A teamplay
// set in startlevel.cfg isn't seen for a second or two after
// that for some reason.  So, when the change_teamplay() there
// ran, it would still see the teamplay in place from before
// startlevel.cfg ran.  The change_teamplay() would do its own
// localcmd() to set teamplay and that would overwrite the value
// set in startlevel.cfg.
//
// I want to see both the value from before startlevel.cfg and
// the value from after, so that I assign people to teams or
// randomize their colors if enforced teams are turned on or
// off.  I do an initial set of teamplay here as early as
// possible, but I don't use localcmd() to set it at that point
// so the value from startlevel.cfg doesn't get overwritten.  I
// then do nothing for a couple of seconds, after which I check
// it again and do the localcmd() even if it hasn't changed
// (because a startlevel.cfg which sets it to the same value it
// had last level would have lost the mod string in the teamplay
// cvar).  After that I treat it naturally, doing the
// change_teamplay() whenever it changes.

float teamplay_set_state;
float initial_obs_process_game_queue;

void ()
check_teamplay =
{
	local float i;

	i = cvar ("teamplay");
	if (time > 3 && (teamplay_set_state < 2 || teamplay != i))
	{
		teamplay_set_state = 2;
		change_teamplay (i, 1);
	}
	else if (teamplay_set_state < 1)
	{
		teamplay_set_state = 1;
		change_teamplay (i, 0);
	}

	if (!initial_obs_process_game_queue)
	{
		if (time > LEVEL_RECONNECT_ALLOWANCE)
		{
			initial_obs_process_game_queue = 1;
			obs_process_game_queue ();
		}
	}
};

void (float check_state)
toggle_teamplay =
{
	if (teamplay & TEAM_TEAM_MASK)
	{
		if (check_state < 1)
			change_teamplay (0, 1);
	}
	else
	{
		if (check_state >= 0)
			change_teamplay (VOTE_TEAM_MODE, 1);
	}
};

void ()
toggle_teamplay_real =
{
	if (teamplay & TEAM_TEAM_MASK)
	{
		change_teamplay (0, 1);
		pqc_match_reset ();
	}
	else
		change_teamplay (VOTE_TEAM_MODE, 1);
};

float (float tm, float total_teams)
next_team =
{
	if (tm == TEAM_1)
		return TEAM_2;
	else if (tm == TEAM_2 && total_teams > 2)
		return TEAM_3;
	else if (tm == TEAM_3 && total_teams > 3)
		return TEAM_4;
	else
		return TEAM_1;
};

void (entity by_e)
team_rotate =
{
	local float by_admin, any, ok, total_teams, new_team, first_new_team, orig_team;

	by_admin = 1;
	if (!by_e)
	{
		by_admin = 0;
		by_e = self;
	}

	total_teams = enforced_teams ();
	if (!total_teams)
	{
		sprint (by_e, "Teams are not enforced\n");
		return;
	}

	if (is_observer ())
	{
		sprint (by_e, "Observers can't change teams\n");
		return;
	}

	any = 0;
	if (by_admin)
		any = 1;
	else if (teamplay & TEAM_CHANGE_MASK == TEAM_CHANGE_ANY)
		any = 1;
	else if (teamplay & TEAM_CHANGE_MASK == TEAM_CHANGE_TOPDOG && is_topdog ())
		any = 1;

	// I test against first_new_team instead of the original
	// correct_team() so that this doesn't runaway for observers
	// in match mode or people who somehow had an invalid team.
	orig_team = self.team;
	new_team = correct_team ();
	first_new_team = new_team = next_team (new_team, total_teams);
	ok = 0;
	do
	{
		self.team = new_team;	// used by is_allowable_team()
		if (any || is_allowable_team ())
			ok = 1;
		else
			new_team = next_team (new_team, total_teams);
	} while (!ok && new_team != first_new_team);
	self.team = orig_team;

	if (!ok || new_team == self.team)
	{
		sprint (by_e, "There aren't any teams you're allowed to switch to right now\n");
		return;
	}

	set_team_e (self, new_team);
	sprint (self, "You have been assigned to the ");
	sprint_team (self, new_team);
	sprint (self, " team\n");
};

void ()
describe_team_mode =
{
	// centerprint (self, "Note:  Team mode is on");
	sprint (self, "Team settings:");
	if (teamplay & TEAM_HEALTH_PROT)	sprint (self, " health-prot");
	if (teamplay & TEAM_ARMOR_PROT)		sprint (self, " armor-prot");
	if (teamplay & TEAM_FRAG_PENALTY)	sprint (self, " frag-penalty");
	if (teamplay & TEAM_ENFORCE_MASK)	sprint (self, " enforced");
	if (gamemode == MODE_MATCH)		sprint (self, " match");

	if (teamplay & TEAM_CHANGE_MASK == TEAM_CHANGE_ANY)
		sprint (self, " change-any");
	else if (teamplay & TEAM_CHANGE_MASK == TEAM_CHANGE_TOPDOG)
		sprint (self, " change-topdog");

	sprint (self, "\n");
};

void (entity e, float tm)
sprint_team =
{
	local string s;

	tm = team_to_color (tm);
	s = color_to_name (tm);
	sprint (e, s);
};

void ()
team_fraglimit =
{
	local float i;

	if (!teamplay & TEAM_TEAM_MASK)
		return;

	if (fraglimit)
	{
		// I put the most common team colors first, which will help speed
		// things up.
		if 	(tf_0 >= fraglimit)	i = 1;
		else if (tf_5 >= fraglimit)	i = 1;
		else if (tf_14 >= fraglimit)	i = 1;
		else if (tf_1 >= fraglimit)	i = 1;
		else if (tf_2 >= fraglimit)	i = 1;
		else if (tf_3 >= fraglimit)	i = 1;
		else if (tf_4 >= fraglimit)	i = 1;
		else if (tf_6 >= fraglimit)	i = 1;
		else if (tf_7 >= fraglimit)	i = 1;
		else if (tf_8 >= fraglimit)	i = 1;
		else if (tf_9 >= fraglimit)	i = 1;
		else if (tf_10 >= fraglimit)	i = 1;
		else if (tf_11 >= fraglimit)	i = 1;
		else if (tf_12 >= fraglimit)	i = 1;
		else if (tf_13 >= fraglimit)	i = 1;

		if (i)
		{
			forced_nextmap = string_null;
			NextLevel ();
		}
	}
};

void (float is_end)
team_stats =
{
	local entity pe;
	local float t;

	if (is_end)
		pe = world;
	else
		pe = self;

	t = team_stats_1 (pe);
	if (!is_end)
		sprint (pe, "Current winner: ");
	else
		sprint (pe, "Winner: ");
	if (t == -1)
		sprint (pe, "No frags scored");
	else if (t == -2)
		sprint (pe, "Tie!");
	else
	{
		sprint_team (pe, t);
		if (team_stats_1_lead != NO_FRAGS)
		{
			sprint (pe, " by ");
			sprint_float (pe, team_stats_1_lead);
		}
	}
	sprint (pe, "\n");
};

float (float n)
num_to_bit =
{
	     if (n ==  1)	return 1;
	else if (n ==  2)	return 2;
	else if (n ==  3)	return 4;
	else if (n ==  4)	return 8;
	else if (n ==  5)	return 16;
	else if (n ==  6)	return 32;
	else if (n ==  7)	return 64;
	else if (n ==  8)	return 128;
	else if (n ==  9)	return 256;
	else if (n == 10)	return 512;
	else if (n == 11)	return 1024;
	else if (n == 12)	return 2048;
	else if (n == 13)	return 4096;
	else if (n == 14)	return 8192;
	else if (n == 15)	return 16384;
	else if (n == 16)	return 32768;
	else if (n == 17)	return 65536;
	else if (n == 18)	return 131072;
	else if (n == 19)	return 262144;
	else if (n == 20)	return 524288;
	else if (n == 21)	return 1048576;
	else if (n == 22)	return 2097152;
	else if (n == 23)	return 4194304;
	else if (n == 24)	return 8388608;
	else			return 0;
};

// This function will refresh the scoreboard for all players with +teamscores active each time
// pqc_match_time() is called so that the timer is synchronized.
void ()
teamscores_update =
{
	local entity e;

	e = find (world, classname, "player");
	while (e)
	{
		if (e.rqflags & RQ_TEAMSCORES_ON)
			e.lefty = time;

		e = find (e, classname, "player");
	}
};

void (entity client)
teamscores_on =
{	IN_QW(return;)
	local entity e;
	local float i, n, tm, tf, bit, bits, ignore, n_teams, msg_type;
	local string s;

	if (client == world)
		msg_type	= MSG_ALL;
	else
	{
		client.rqflags = client.rqflags | RQ_TEAMSCORES_ON;
		msg_entity	= client;
		msg_type	= MSG_ONE;
 	}

	n_teams = enforced_teams ();

	if (gamemode == MODE_MATCH)
	{
		bits = 1; // include white for remaining time / match over
		for (i = %1;i <= %14;i = i + %1)
		{
			if (match.aiment[i])
				bits = bits | num_to_bit (i / %1);
		}
	}

	e = nextent (world);
	for (i = 0; i < 16; i = i + 1)
	{
		if (e.classname == "bodyque")
			return;

		if (gamemode == MODE_MATCH)
		{
			// normal scoreboard
			if ((!(match.state || match.cnt || match.delay))) // parens needed
			{
				if (e.cl[CL_ACTIVE] == %1)
				{
					svc_updatename_hack (client, e);
					svc_updatefrags (msg_type, i, e.frags);
					svc_updatecolors (msg_type, i, e.cl[CL_COLORS] / %1);
				}
				else
					svc_updatename (msg_type, i, string_null);
			}
			// countdown
			else if (match.cnt)
			{
				if (!e.team_colors && !ignore)
				{
					ignore = 1;
					s = ftos (match.cnt);
					s = strcat ("T Minus ",  s);
					svc_updatename (msg_type, i, s);
					svc_updatefrags (msg_type, i, -99);
					svc_updatecolors (msg_type, i, 0);
				}
				else
					svc_updatename (msg_type, i, string_null);
			}
			// match in progress | match over
			else if ((match.state || match.delay) && bits)
			{
				// XXX In CRMod, only clients with active colors are shown in the teamscores
				// scoreboard.  So, if it's 1v1 and someone disconnects, only one team name
				// will appear.  I workaround this by forcing the colors on to a disconnected
				// client.  This also works when the match is over so that team scores are preserved
				// even after everyone leaves.  This method is far from perfect, and can still
				// produce missing scoreboard names if there are too many players and teams with
				// mismatched colors.  [Further testing is needed to make sure colors don't switch
				// when clients connect/disconnect.  If that happens, abandon this method]

				// active client
				if (e.cl[CL_ACTIVE] == %1)
				{
					bit = 0;
					tm = colors_to_team (e.team_colors / %1);
					if (tm == e.team)
						bit = num_to_bit (tm);
				}
				// disconnected client
				else
				{
					for (n = 1;n <= 14; n = n + 1)
					{
						bit = num_to_bit (n);
						if (bits & bit)
						{
							tm = n;
							n = 16;
						}
					}
				}

				if (bits & bit)
				{
					bits = bits - bits & bit;
					// time reminaing / match over
					if (tm == 1)
					{
						if (match.delay)
							s = "Match Over";
						else
						{
							s = parse_time ((match.count + 1) - time);
							s = strcat (s, " remaining");
						}

						svc_updatename (msg_type, i, s);
						svc_updatefrags (msg_type, i, -99);
						svc_updatecolors (msg_type, i, 0);
					}
					// team names
					else
					{
						s = team_to_name (tm);
						tf = team_to_teamfrags (tm);
						svc_updatename (msg_type, i, s);
						svc_updatefrags (msg_type, i, tf);
						svc_updatecolors (msg_type, i, match.aiment[tm * %1] / %1);
					}
				}
				else
					svc_updatename (msg_type, i, string_null);

			}
			else
				svc_updatename (msg_type, i, string_null);
		}
		else if (e.cl[CL_ACTIVE] == %1)
		{
			bit = num_to_bit (e.team);

			if (!bits & bit)
			{
				bits	= bits | bit;

				if (n_teams && e.team == TEAM_NIL)
					svc_updatename (msg_type, i, string_null);
				else
				{
					s = team_to_name (e.team);
					tf = team_to_teamfrags (e.team);
					svc_updatename (msg_type, i, s);
					svc_updatefrags (msg_type, i, tf);
					svc_updatecolors (msg_type, i, e.cl[CL_COLORS] / %1);
				}
			}
			else
				svc_updatename (msg_type, i, string_null);
		}
		else
			svc_updatename (msg_type, i, string_null);

		e = nextent (e);
	}
};

void (entity client)
teamscores_off =
{	IN_QW(return;)
	local entity e;
	local float i, msg_type;

	if (client == world)
		msg_type = MSG_ALL;
	else
	{
		client.rqflags = client.rqflags - client.rqflags & RQ_TEAMSCORES_ON;
		msg_entity = client;
		msg_type = MSG_ONE;
 	}

	e = nextent (world);
	for (i = 0; i < 16; i = i + 1)
	{
		if (e.classname == "bodyque")
			return;

		if (e.cl[CL_ACTIVE] == %1)
		{
			svc_updatename_hack (client, e);
			svc_updatefrags (msg_type, i, e.frags);
			svc_updatecolors (msg_type, i, e.cl[CL_COLORS] / %1);
		}
		else
			svc_updatename (msg_type, i, string_null);

		e = nextent (e);
	}
};

string (float mode)
gamemode_map =
{
	//if (mode == MODE_NORMAL)
	//	return

	if (mode == MODE_PRACTICE)
		return "dm6";

	//if (mode == MODE_ARENA)
	//	return

	//if (mode == MODE_MATCH)
	//	return

	//if (mode == MODE_MIDAIR)
	//	return

	//if (mode == MODE_HEADS)
	//	return

	return mapname;
};

string (float mode)
current_gamemode =
{
	if (mode == MODE_NORMAL)
		return "normal";

	if (mode == MODE_PRACTICE)
		return "practice";

	if (mode == MODE_ARENA)
		return "arena";

	if (mode == MODE_MATCH)
		return "match";

	if (mode == MODE_MIDAIR)
		return "midair";

	if (mode == MODE_HEADS)
		return "heads";

	return "invalid gamemode";
};

void (float mode)
gamemode_default =
{
	if (scratch1 & S1_NO_DEFAULT)
		return;

	if (scratch1 & S1_DEFAULT_USES_CONFIGS)
	{
		//local float i;
		local string s;

		// XXX put directory in settings.qc
		localcmd ("exec defaults/");
		s = current_gamemode (mode);
		localcmd (s);
		// this only works with manquake 1.00-2.75 or later
		/*i = cvar ("port");
		if (i)
		{
			localcmd ("-");
			s = ftos (i);
			localcmd (s);
		}*/
		localcmd (".cfg\n");
		return;
	}

	if (mode == MODE_NORMAL)
		normal_defaults ();

	else if (mode == MODE_PRACTICE)
		practice_defaults ();

	else if (mode == MODE_ARENA)
		arena_defaults ();

	else if (mode == MODE_MATCH)
		match_defaults ();

	else if (mode == MODE_MIDAIR)
		arena_defaults ();

	else if (mode == MODE_HEADS)
		normal_defaults ();
};

void (float mode)
change_mode_to =
{
	local string s;

	if (gamemode == mode)
	{
		self_sprint (self, "Already in ");
		s = current_gamemode (mode);
		self_sprint (self, s);
		self_sprint (self, " mode\n");
		return;
	}

	gamemode_default (mode);

	s = ftos (mode);
	cvar_set_infokey (CVAR_C3, s);

	s = gamemode_map (mode);
	admin_changelevel_now (s);
};

void ()
change_mode_to_heads =
{
	change_mode_to (MODE_HEADS);
};

void ()
change_mode_to_midair =
{
	change_mode_to (MODE_MIDAIR);
};

void ()
change_mode_to_match =
{
	change_mode_to (MODE_MATCH);
};

void ()
change_mode_to_arena =
{
	change_mode_to (MODE_ARENA);
};

void ()
change_mode_to_practice =
{
	change_mode_to (MODE_PRACTICE);
};

void ()
change_mode_to_normal =
{
	change_mode_to (MODE_NORMAL);
};

//-----------------------------------------------------------------------------
// DEFAULT SETTINGS FOR MATCH, ARENA, PRACTICE, AND NORMAL
//-----------------------------------------------------------------------------

void ()
match_defaults =
{
	// allow mm2 in match mode
	if (teamplay != 32)
		change_teamplay (32, 1);

	// hook off (0=off|1=free|2=lithium)
	set_hook (0);

	// hook damage on
	if (options & NO_HOOK_DAMAGE)
		sethookdamage ();

	// powerups on
	if (options & NO_QUAD)
		setquad ();
	if (options & NO_PENT)
		setpent ();
	if (options & NO_RING)
		setring ();
	if (options & NO_SUIT)
		setsuit ();

	// armor on
	if (options & NO_ARMOR)
		setarmor ();

	// rotate off
	if (options & ARMOR_ROTATE)
		setrotate ();

	// armor drop off
	if (!options & NO_DROP_ARMOR)
		toggle_armor_drop ();

	// megahealth on
	if (options & NO_MEGA)
		setmega ();

	// classic mega on
	if (!options & CLASSIC_MEGA)
		setclassicmega ();

	// runes off
	if (!options & NO_RUNES)
		setrunes ();

	// runes drop off
	if (!options & NO_DROP_ON_DEATH)
		toggle_rune_drop ();

	// alt weapons off
	if (!options & NO_ALT_WEAPONS)
		setalts ();

	// weapons stay off
	if (options & WEAPONS_STAY)
		toggle_weapons_stay ();

	// spawn shields off
	if (!options & NO_SPAWN_SHIELDS)
		setshields ();

	// drop backpacks on
	if (options & NO_BACKPACKS)
		setbackpacks ();

	// powerup drop off
	if (!options & NO_DROP_POWERUP)
		toggle_powerup_drop ();

	// lightning discharge on
	if (options & NO_DISCHARGE)
		toggle_lightning_discharge ();

	// random spawn on
	if (!options & RANDOM_SPAWN)
		toggle_random_spawn ();

	// shootable buttons off
	if (options & SHOOT_BUTTONS)
		toggle_shoot_buttons ();

	// powerup hats off
	if (!options & NO_POWERUP_HATS)
		toggle_powerup_hats ();
};

void ()
arena_defaults =
{
	// turn off teams
	if (teamplay)
		change_teamplay (0, 1);

	// hook off (0=off|1=free|2=lithium)
	set_hook (0);

	// hook damage on
	if (options & NO_HOOK_DAMAGE)
		sethookdamage ();

	// powerups, no default
	//if (options & NO_QUAD)
	//	setquad ();
	//if (options & NO_PENT)
	//	setpent ();
	//if (options & NO_RING)
	//	setring ();
	//if (options & NO_SUIT)
	//	setsuit ();

	// armor, no default
	//if (options & NO_ARMOR)
	//	setarmor ();

	// rotate, no default
	//if (options & ARMOR_ROTATE)
	//	setrotate ();

	// armor drop off
	if (!options & NO_DROP_ARMOR)
		toggle_armor_drop ();

	// megahealth, no default
	//if (options & NO_MEGA)
	//	setmega ();

	// classic mega, no default
	//if (options & CLASSIC_MEGA)
	//	setclassicmega ();

	// runes off
	if (!options & NO_RUNES)
		setrunes ();

	// runes drop off
	if (!options & NO_DROP_ON_DEATH)
		toggle_rune_drop ();

	// alt weapons off
	if (!options & NO_ALT_WEAPONS)
		setalts ();

	// weapons stay, no default
	//if (options & WEAPONS_STAY)
	//	toggle_weapons_stay ();

	// spawn shields off
	if (!options & NO_SPAWN_SHIELDS)
		setshields ();

	// drop backpacks off
	if (!options & NO_BACKPACKS)
		setbackpacks ();

	// powerup drop on, no default
	//if (options & NO_DROP_POWERUP)
	//	toggle_powerup_drop ();

	// lightning discharge off
	if (!options & NO_DISCHARGE)
		toggle_lightning_discharge ();

	// random spawn off
	if (options & RANDOM_SPAWN)
		toggle_random_spawn ();

	// shootable buttons on
	if (!options & SHOOT_BUTTONS)
		toggle_shoot_buttons ();

	// powerup hats on
	if (options & NO_POWERUP_HATS)
		toggle_powerup_hats ();
};

void ()
practice_defaults =
{
	// turn off teams
	if (teamplay)
		change_teamplay (0, 1);

	// hook off (0=off|1=free|2=lithium)
	set_hook (0);

	// hook damage on
	if (options & NO_HOOK_DAMAGE)
		sethookdamage ();

	// powerups on
	if (options & NO_QUAD)
		setquad ();
	if (options & NO_PENT)
		setpent ();
	if (options & NO_RING)
		setring ();
	if (options & NO_SUIT)
		setsuit ();

	// armor on
	if (options & NO_ARMOR)
		setarmor ();

	// rotate off
	if (options & ARMOR_ROTATE)
		setrotate ();

	// armor drop off
	if (!options & NO_DROP_ARMOR)
		toggle_armor_drop ();

	// megahealth on
	if (options & NO_MEGA)
		setmega ();

	// classic mega on
	if (!options & CLASSIC_MEGA)
		setclassicmega ();

	// runes off
	if (!options & NO_RUNES)
		setrunes ();

	// runes drop off
	if (!options & NO_DROP_ON_DEATH)
		toggle_rune_drop ();

	// alt weapons off
	if (!options & NO_ALT_WEAPONS)
		setalts ();

	// weapons stay, no default
	//if (options & WEAPONS_STAY)
	//	toggle_weapons_stay ();

	// spawn shields off
	if (!options & NO_SPAWN_SHIELDS)
		setshields ();

	// drop backpacks off
	if (!options & NO_BACKPACKS)
		setbackpacks ();

	// powerup drop on
	if (options & NO_DROP_POWERUP)
		toggle_powerup_drop ();

	// lightning discharge off
	if (!options & NO_DISCHARGE)
		toggle_lightning_discharge ();

	// random spawn on
	if (!options & RANDOM_SPAWN)
		toggle_random_spawn ();

	// shootable buttons off
	if (options & SHOOT_BUTTONS)
		toggle_shoot_buttons ();

	// powerup hats off
	if (!options & NO_POWERUP_HATS)
		toggle_powerup_hats ();
};

void ()
normal_defaults =
{
	// turn off teams
	if (teamplay)
		change_teamplay (0, 1);

	// free hook on (0=off|1=free|2=lithium)
	set_hook (1);

	// hook damage on
	if (options & NO_HOOK_DAMAGE)
		sethookdamage ();

	// powerups on
	if (options & NO_QUAD)
		setquad ();
	if (options & NO_PENT)
		setpent ();
	if (options & NO_RING)
		setring ();
	if (options & NO_SUIT)
		setsuit ();

	// armor on
	if (options & NO_ARMOR)
		setarmor ();

	// rotate on
	if (!options & ARMOR_ROTATE)
		setrotate ();

	// armor drop on
	if (options & NO_DROP_ARMOR)
		toggle_armor_drop ();

	// megahealth on
	if (options & NO_MEGA)
		setmega ();

	// classic mega off
	if (options & CLASSIC_MEGA)
		setclassicmega ();

	// runes on
	if (options & NO_RUNES)
		setrunes ();

	// runes drop off
	if (!options & NO_DROP_ON_DEATH)
		toggle_rune_drop ();

	// alt weapons on
	if (options & NO_ALT_WEAPONS)
		setalts ();

	// weapons stay on
	if (!options & WEAPONS_STAY)
		toggle_weapons_stay ();

	// spawn shields on
	if (options & NO_SPAWN_SHIELDS)
		setshields ();

	// drop backpacks on
	if (options & NO_BACKPACKS)
		setbackpacks ();

	// powerup drop on
	if (options & NO_DROP_POWERUP)
		toggle_powerup_drop ();

	// lightning discharge on
	if (!options & NO_DISCHARGE)
		toggle_lightning_discharge ();

	// random spawn off
	if (options & RANDOM_SPAWN)
		toggle_random_spawn ();

	// shootable buttons on
	if (!options & SHOOT_BUTTONS)
		toggle_shoot_buttons ();

	// powerup hats on
	if (options & NO_POWERUP_HATS)
		toggle_powerup_hats ();
};
