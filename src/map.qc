/*  $Id: map.qc,v 1.20 2012/10/08 05:24:57 slotzero Exp $

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

string (float levsize)
levsize_to_name =
{
	if (levsize == 1)	{ return "small"; }
	else if (levsize == 2)	{ return "medium"; }
	else			{ return "large"; }
};

// XXX This causes bizarre results.  Perhaps there's a bug with string
// constants.
//string LAST_MAP = "dm6";

string (string m, float linear)
next_map =
{
	if (m == "start")
	{
		if (linear)
			return "e1m1";
		if (!serverflags & 1)
		{
			serverflags = serverflags | 1;
			return "e1m1";
		}
		if (!serverflags & 2)
		{
			serverflags = serverflags | 2;
			return "e2m1";
		}
		if (!serverflags & 4)
		{
			serverflags = serverflags | 4;
			return "e3m1";
		}
		if (!serverflags & 8)
		{
			serverflags = serverflags | 8;
			return "e4m1";
		}
		if (noexit & NOEXIT_DM_NO_LOOP)
		{
			serverflags = serverflags - 15;
			return "dm1";
		}
		serverflags = serverflags - serverflags & SERVERFLAGS_RUNE_MASK + 1;
		return "e1m1";
	}
	if (m == "e1m1") return "e1m2";
	if (m == "e1m2") return "e1m3";
	if (m == "e1m3") return "e1m4";
	if (m == "e1m4") return "e1m8";
	if (m == "e1m8") return "e1m5";
	if (m == "e1m5") return "e1m6";
	if (m == "e1m6") return "e1m7";
	if (m == "e1m7") if (!linear) return "start"; else return "e2m1";
	if (m == "e2m1") return "e2m2";
	if (m == "e2m2") return "e2m3";
	if (m == "e2m3") return "e2m7";
	if (m == "e2m7") return "e2m4";
	if (m == "e2m4") return "e2m5";
	if (m == "e2m5") return "e2m6";
	if (m == "e2m6") if (!linear) return "start"; else return "e3m1";
	if (m == "e3m1") return "e3m2";
	if (m == "e3m2") return "e3m3";
	if (m == "e3m3") return "e3m4";
	if (m == "e3m4") return "e3m7";
	if (m == "e3m7") return "e3m5";
	if (m == "e3m5") return "e3m6";
	if (m == "e3m6") if (!linear) return "start"; else return "e4m1";
	if (m == "e4m1") return "e4m2";
	if (m == "e4m2") return "e4m3";
	if (m == "e4m3") return "e4m4";
	if (m == "e4m4") return "e4m5";
	if (m == "e4m5") return "e4m8";
	if (m == "e4m8") return "e4m6";
	if (m == "e4m6") return "e4m7";
	if (m == "e4m7") if (!linear) return "start"; else return "end";
	if (m == "end") return "dm1";
	if (m == "dm1") return "dm2";
	if (m == "dm2") return "dm3";
	if (m == "dm3") return "dm4";
	if (m == "dm4") return "dm5";
	if (m == "dm5") return "dm6";
	if (m == "dm6") return "start";
	return "start";
};

/*float (float levsize, string target_map)
sized_map_name_to_num =
{
	local float ix, max_ix;
	local string this_map;

	max_ix = sized_map_count (levsize);
	ix = 0;
	while (ix < max_ix)
	{
		ix = ix + 1;
		this_map = sized_map (levsize, ix);
		if (this_map == target_map)
			return ix;
	}
	return 0;
};

/*void ()
sized_map_test =
{
	local float levsize, rev_levsize, ix, max_ix, rev_ix;
	local string s;

	levsize = 0;
	while (levsize < 3)
	{
		levsize = levsize + 1;
		max_ix = sized_map_count (levsize);
		dprint ("levsize ");
		dprint_float (levsize);
		dprint (" max_ix ");
		dprint_float (max_ix);
		dprint ("\n");
		ix = 0;
		while (ix < max_ix)
		{
			ix = ix + 1;
			s = sized_map (levsize, ix);
			dprint_float (ix);
			dprint (" ");
			dprint (s);
			dprint ("\n");
			rev_levsize = map_size (s);
			if (rev_levsize != levsize)
			{
				dprint ("levsize mismatch, reverse is ");
				dprint_float (rev_levsize);
				dprint ("\n");
			}
			rev_ix = sized_map_name_to_num (levsize, s);
			if (rev_ix != ix)
			{
				dprint ("mismatch, reverse number is ");
				dprint_float (rev_ix);
				dprint ("\n");
			}
		}
	}
};
*/

float ()
pick_map_size =
{
	local float players, i, levsize;

	players = count_players (1);

	// Breakdown by player ranges of chance for small/medium/large level:
	//   1-3  85/15/0
	//   4-7  10/80/10
	//   8+   10/40/50
	i = ceil (random () * 100);
	if (players <= 3)
	{
		if (LEVSIZE_NON_RANDOM)	{ levsize = 1; }
		else if (i <= 85)	{ levsize = 1; }
		else if (i <= 100)	{ levsize = 2; }
		else			{ levsize = 3; }
	}
	else if (players <= 7)
	{
		if (LEVSIZE_NON_RANDOM)	{ levsize = 2; }
		else if (i <= 10)	{ levsize = 1; }
		else if (i <= 90)	{ levsize = 2; }
		else			{ levsize = 3; }
	}
	else
	{
		if (LEVSIZE_NON_RANDOM)	{ levsize = 3; }
		else if (i <= 10)	{ levsize = 1; }
		else if (i <= 50)	{ levsize = 2; }
		else			{ levsize = 3; }
	}

	if (1)
	{
		local string s;

		bprint ("Server sees ");
		bprint_float (players);
		bprint (" player");
		if (players != 1)
			bprint ("s");
		bprint (", running ");
		s = levsize_to_name (levsize);
		bprint (s);
		bprint (" level\n");
		/* if (!LEVSIZE_NON_RANDOM)
		{
			bprint (" (");
			bprint_float (i);
			bprint ("%)");
		}
		bprint ("\n"); */
	}

	return levsize;
};

// This function is a wrapper for user_allowed_map() which includes the
// settings I use on my server.  I do it this way so that I use the same
// settings.qc on my system that I distribute.

float (string m)
allowed_map =
{
	local float i;

	if (gamemode != MODE_MIDAIR)
	{
		if (m == "endif") return 0;
	}

	if (noexit & NOEXIT_MARLINSPIKE_LEVELS)
	{
		if (m == "e1m4") return 0; // The Grisly Grotto
		if (m == "e1m6") return 0; // The Door To Chthon
		if (m == "e1m8") return 0; // Ziggurat Vertigo
		if (m == "e2m3") return 0; // Crypt Of Decay
		// if (m == "e2m7") return 0; // Underneath
		if (m == "e3m4") return 0; // Satan's Dark Delight
		if (m == "e3m5") return 0; // Wind Tunnels
		if (m == "e4m1") return 0; // The Sewage System
		if (m == "e4m6") return 0; // The Pain Maze
		if (m == "end")  return 0; // Shub-Niggurath's Pit
	}
	i = user_allowed_map (m);
	return i;
};

float ()
select_map_ignores_serverflags =
{
	return noexit & (NOEXIT_CHOOSE_BY_NPLAYERS | NOEXIT_RANDOMIZE);
};

// This function selects the next map to play depending on the bits set
// in the noexit cvar and the current nextmap setting.  (nextmap will
// have been set either by the exit the user chose or by the game if the
// time or fraglimit was reached.)

string ()
select_map =
{
	local float sized, randomly, use_lp, i, reps;
	local float levsize, nmaps, this_levsize;
	local string s, curmap, curnextmap;

	sized = noexit & NOEXIT_CHOOSE_BY_NPLAYERS;
	randomly = noexit & NOEXIT_RANDOMIZE;
	use_lp = (sized || randomly);
	curmap = mapname;
	curnextmap = nextmap;

	i = 0;
	if (!noexit & NOEXIT_NO_CUSTOM_LEVELS)
	{
		if (!total_customs ())
			i = 0;
		else if (noexit & NOEXIT_CUSTOM_LEVELS_ONLY)
			i = 2;
		else if (use_lp)
			i = floor (random () * 2);
	}

	dprint ("select_map()\n");

	if (sized)
	{
		levsize = pick_map_size ();
		nmaps = sized_map_count (levsize);
		// For non-random sized levels, always start searching
		// at the start (next_map(LAST_MAP, 1)).  Otherwise the
		// levels will end up in a semi-random order as maps of
		// different sizes are played as players join and leave
		// the server.
		if (!randomly)
			curmap = "dm6";
	}

	IN_POQ([-
		if (i)
			s = select_custom (levsize);
	-], [-
		if (i && noexit & NOEXIT_RANDOMIZE)
			s = rand_custom_qw ();
	-])
	else
		s = string_null;

	reps = 0;
	while (reps < 100 && s == string_null)
	{
		reps = reps + 1;

		if (sized)
		{
			if (randomly)
			{
				i = ceil (random () * nmaps + 0.01);
				if (i > nmaps) i = nmaps;
				s = sized_map (levsize, i);
			}
			else
			{
				dprint ("next_map(");
				dprint (curmap);
				dprint (", 1) = ");
				curmap = next_map (curmap, 1);
				dprint (curmap);
				dprint ("\n");
				this_levsize = map_size (curmap);
				if (this_levsize == levsize)
					s = curmap;
			}
		}
		else if (randomly)
			s = rand_map ();
		else
		{
			if (curnextmap != string_null)
			{
				// First time through, try the map the
				// game would have used on its own.
				dprint ("game selected ");
				dprint (curnextmap);
				dprint ("\n");
				curmap = curnextmap;
				curnextmap = string_null;
			}
			else
			{
				// That map didn't work, just move on
				// from there.
				dprint ("next_map(");
				dprint (curmap);
				dprint (", 0) = ");
				curmap = next_map (curmap, 0);
				dprint (curmap);
				dprint ("\n");
			}
			s = curmap;
		}

		dprint (s);
		dprint (" ");
		if (randomly && s == mapname)
		{
			dprint ("repeat\n");
			s = string_null;
		}
		else if (use_lp && lp_isset_map (s))
		{
			dprint ("already played\n");
			s = string_null;
		}
		else if (!allowed_map (s))
		{
			dprint ("disallowed by user\n");
			s = string_null;
		}

		if (use_lp && s == string_null && reps == 75)
		{
			// We probably played all the levels in this size group,
			// clear them out of levels_played.
			if (sized)
			{
				lp_clear_levsize (levsize);
				sized_customs_to_hunk (levsize);
			}
			else
			{
				lp_clear_all ();
				sized_customs_to_hunk (0);
			}
			// Start back at the current level.
			if (randomly)
				curmap = mapname;
			else
				curmap = "dm6";
		}
	}

	if (s != string_null)
		return s;
	else
		return mapname;
};
