/*  $Id: lp.qc,v 1.6 2003/06/24 22:17:39 slotzero Exp $

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

// These are the lp_* functions.  lp stands for levels played.  The
// idea is not to repeat levels even when using random level selection.
// This is hard in standard quake because it's difficult to retain data
// across levels.
//
// My original implementation was to give each possible map a bit and to
// store these bits in the serverflags variable (with the bits numbered
// starting at 16 because Quake uses the first 4 bits to tell which
// runes you've got).  This didn't work, though.  The first problem was
// that it seems that serverflags is at 32 bit signed int, not a float,
// in the engine, so it couldn't actually store enough data to track all
// 38 levels.  The second is that there seems to be a math bug in Quake
// C having to do with bit 25.  Adding 1 to 33554430 yields 33554432,
// not 33554431 as it should.
//
// The current implementation works around these problems by only using
// bits 5-24 of serverflags, and to use bits 2-24 of samelevel.  Bits
// 1-4 of serverflags are unused because of the way Quake uses them
// (though I could override it, it doesn't seem worth the bother), and
// bit 1 of samelevel is left alone to serve its original purpose.
//
// Bit 24 isn't actually used in either variable, it's reserved as a
// flag which tells which variable a particular map should use.  If it's
// unset the map is in serverflags, else it's in samelevel.

float LP_24 = 8388608;

float (string m)
lp_map_to_code =
{
	     if (m == "start") { return 16	; } //  5 Welcome to Quake
	else if (m == "e1m1") { return 32	; } //  6 Slipgate Complex
	else if (m == "e1m2") { return 64	; } //  7 Castle of the Damned
	else if (m == "e1m3") { return 128	; } //  8 The Necropolis
	else if (m == "e1m4") { return 256	; } //  9 The Grisly Grotto
	else if (m == "e1m8") { return 512	; } // 10 Ziggurat Vertigo
	else if (m == "e1m5") { return 1024	; } // 11 Gloom Keep
	else if (m == "e1m6") { return 2048	; } // 12 The Door To Chthon
	else if (m == "e1m7") { return 4096	; } // 13 The House of Chthon
	else if (m == "e2m1") { return 8192	; } // 14 The Installation
	else if (m == "e2m2") { return 16384	; } // 15 Ogre Citadel
	else if (m == "e2m3") { return 32768	; } // 16 Crypt of Decay
	else if (m == "e2m4") { return 65536	; } // 17 The Ebon Fortress
	else if (m == "e2m5") { return 131072	; } // 18 The Wizard's Manse
	else if (m == "e2m6") { return 262144	; } // 19 The Dismal Oubliette
	else if (m == "e2m7") { return 524288	; } // 20 Underearth
	else if (m == "e3m1") { return 1048576	; } // 21 Termination Central
	else if (m == "e3m2") { return 2097152	; } // 22 The Vaults of Zin
	else if (m == "e3m3") { return 4194304	; } // 23 The Tomb of Terror

	else if (m == "e3m4") { return LP_24|2		; } //  2 Satan's Dark Delight
	else if (m == "e3m5") { return LP_24|4		; } //  3 Wind Tunnels
	else if (m == "e3m6") { return LP_24|8		; } //  4 Chambers of Torment
	else if (m == "e3m7") { return LP_24|16		; } //  5 The Haunted Halls
	else if (m == "e4m1") { return LP_24|32		; } //  6 The Sewage System
	else if (m == "e4m2") { return LP_24|64		; } //  7 The Tower of Despair
	else if (m == "e4m3") { return LP_24|128	; } //  8 The Elder God Shrine
	else if (m == "e4m4") { return LP_24|256	; } //  9 The Palace of Hate
	else if (m == "e4m5") { return LP_24|512	; } // 10 Hell's Atrium
	else if (m == "e4m6") { return LP_24|1024	; } // 11 The Pain Maze
	else if (m == "e4m7") { return LP_24|2048	; } // 12 Azure Agony
	else if (m == "e4m8") { return LP_24|4096	; } // 13 The Nameless City
	else if (m == "end" ) { return LP_24|8192	; } // 14 Shub-Niggurath's Pit
	else if (m == "dm1" ) { return LP_24|16384	; } // 15 Place of Two Deaths
	else if (m == "dm2" ) { return LP_24|32768	; } // 16 Claustrophobopolis
	else if (m == "dm3" ) { return LP_24|65536	; } // 17 The Abandoned Base
	else if (m == "dm4" ) { return LP_24|131072	; } // 18 The Bad Place
	else if (m == "dm5" ) { return LP_24|262144	; } // 19 The Cistern
	else if (m == "dm6" ) { return LP_24|524288	; } // 20 The Dark Zone

	else
		return 0;
};

void (string m)
lp_set_map =
{
	local float c, samelevel;
	local string s;

	samelevel = cvar ("samelevel");
	c = lp_map_to_code (m);
	if (c & LP_24)
	{
		c = c - LP_24;
		samelevel = samelevel | c;
	}
	else
		serverflags = serverflags | c;
	s = ftos (samelevel);
	cvar_set ("samelevel", s);
	dprint_bitfield ("serverflags", serverflags);
	dprint_bitfield ("samelevel", samelevel);
};

void (string m)
lp_unset_map =
{
	local float c, samelevel;
	local string s;

	samelevel = cvar ("samelevel");
	c = lp_map_to_code (m);
	if (c & LP_24)
	{
		c = c - LP_24;
		samelevel = samelevel - (samelevel & c);
	}
	else
		serverflags = serverflags - (serverflags & c);
	s = ftos (samelevel);
	cvar_set ("samelevel", s);
};

float (string m)
lp_isset_map =
{
	local float c, samelevel;

	samelevel = cvar ("samelevel");
	c = lp_map_to_code (m);
	if (c & LP_24)
	{
		c = c - LP_24;
		return samelevel & c;
	}
	else
		return serverflags & c;
};

void (float levsize)
lp_clear_levsize =
{
	local float i, nmaps;
	local string s;

	bprint ("Replaying ");
	s = levsize_to_name (levsize);
	bprint (s);
	bprint (" levels\n");

	nmaps = sized_map_count (levsize);
	i = 1;
	while (i <= nmaps)
	{
		s = sized_map (levsize, i);
		lp_unset_map (s);
		i = i + 1;
	}
};

void ()
lp_clear_all =
{
	local float samelevel;
	local string s;

	serverflags = serverflags & SERVERFLAGS_RUNE_MASK;
	samelevel = cvar ("samelevel");
	samelevel = samelevel & 1;
	s = ftos (samelevel);
	cvar_set ("samelevel", s);
};
