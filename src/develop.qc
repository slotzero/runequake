/*  $Id: develop.qc,v 1.47 2003/10/25 01:08:21 slotzero Exp $

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
remove_player_bit =
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

string EPISODE_ONE = "e1m1   ":"e1m2   ":"e1m3   ":"e1m4   ":"e1m5   ":"e1m6   ":"e1m7   ":"e1m8   ":;

float ()
num_levels_in_hunk =
{
	return floor (Read_Hunk_Float (HUNK_CONTEXT, %20));
};

void ()
Write_Levels_To_Hunk =
{
	local float x, tot;
	local string s;

	tot = 0;

	for (x = %0; x < %8; x = x + %1)
	{
		s = EPISODE_ONE[x * 8];
		if (s != string_null)
		{
			Write_Hunk (HUNK_CONTEXT, %200 + (x * 2), s);
			tot = tot + 1;
		}
	}

	Write_Hunk_Float (HUNK_CONTEXT, %20, tot);
	bprint_float (tot);
	bprint (" levels written to hunk\n");
};

void ()
Read_Levels_From_Hunk =
{
	local float x, tot;

	tot = num_levels_in_hunk ();
	if (!tot)
		return bprint ("No levels in hunk\n");

	tot = tot * %1;
	for (x = %0; x < tot; x = x + %1)
	{
		bprint (">");
		bprint (Read_Hunk (HUNK_CONTEXT, %200 + (x * 2)));
		bprint ("<\n");
	}
};

float (float pos)
pop_level_from_hunk =
{
	local float i, max, tot;
	local string new;

	tot = num_levels_in_hunk ();
	bprint_float (tot);
	bprint (" levels total\n");
	if (!tot)
	{
		dprint ("No levels in hunk\n");
		return 0;
	}

	max = (tot - 1) * %1;
	pos = pos * %1;
	if (*max == *pos)
	{
		tot = tot - 1;
		bprint (Read_Hunk (HUNK_CONTEXT, %200 + (pos * 2)));
		bprint (" is the current level, last in hunk\n");
	}
	else if (max < pos)
	{
		dprint ("Level position too high\n");
		return 0;
	}
	else
	{
		tot = tot - 1;
		bprint (Read_Hunk (HUNK_CONTEXT, %200 + (pos * 2)));
		bprint (" is the current level\n");
		new = Read_Hunk (HUNK_CONTEXT, %200 + (max * 2));
		Write_Hunk (HUNK_CONTEXT, %200 + (pos * 2), new);
		bprint (new);
		bprint (" replaced the previous level\n");
	}
	Write_Hunk_Float (HUNK_CONTEXT, %20, tot);
	bprint_float (tot);
	bprint (" levels total\n");
	return 1;
};

void ()
Test_Button =
{
	SUB_Null ();
};

void ()
Log_Client_Disconnect =
{	IN_QW(return;)
	local float i, n, max, offset, e_time, elapsed;
	local string e_name;

	// hunk offset [must match Client_Disconnect_Log]
	offset = %100;	// position in hunk
	max = n = %9;	// length of list (actual length is + 1)

	elapsed = server_time ();

	for (i = max; i >= %0; i = i - %1)
	{
		e_name = Read_Hunk_Max (HUNK_CONTEXT, offset + (i * 6), 16);
		if (e_name == self.netname)
		{
			Write_Hunk_Max (HUNK_CONTEXT, offset + (i * 6), "removed", 8);
			Write_Hunk_Float (HUNK_CONTEXT, offset + %4 + (i * 6), 0);
			n = i;
		}
	}

	if (n != max)
		max = n;

	for (i = max; i >= %0; i = i - %1)
	{
		if (i != max)
		{
			e_name = Read_Hunk_Max (HUNK_CONTEXT, offset + (i * 6), 16);
			Write_Hunk_Max (HUNK_CONTEXT, offset + ((i + %1) * 6), e_name, 16);
			e_time = Read_Hunk_Float (HUNK_CONTEXT, offset + %4 + (i * 6));
			Write_Hunk_Float (HUNK_CONTEXT, offset + %4 + ((i + %1) * 6), e_time);
		}
	}

	Write_Hunk_Max (HUNK_CONTEXT, offset, self.netname, 16);
	Write_Hunk_Float (HUNK_CONTEXT, offset + %4, elapsed);
};

void ()
Client_Disconnect_Log =
{	IN_QW(return;)
	local float i, max, offset, e_time, e_away, server_t;
	local string e_name;

	// hunk offset [must match Log_Client_Disconnect]
	offset = %100;	// position in hunk
	max = %9;	// length of list (actual length is + 1)

	self_sprint (self, "\n");
	self_sprintf_len (self, "Name", -16);
	self_sprintf_len (self, "Time", 10);
	self_sprint (self, "\n----                  ----\n\n");

	server_t = server_time ();
	for (i = max; i >= %0; i = i - %1)
	{
		e_time = floor (Read_Hunk_Float (HUNK_CONTEXT, offset + %4 + (i * 6)));
		e_away = server_t - e_time;

		if (e_time)
		{
			e_name = Read_Hunk_Max (HUNK_CONTEXT, offset + (i * 6), 16);
			self_sprintf_len (self, e_name, -16);
			e_name = parse_time (e_away);
			self_sprintf_len (self, e_name, 10);
			self_sprint (self, "\n");
		}
	}
	if (!e_time)
		self_sprint (self, "No entries found.\n");
};

string ()
ProQuake_Version =
{
	local float i, d, sum;
	local string s1, s2, s3;

	i = self.netconnection[QS_MOD] / %1;

	if (!i)
		return " with a non-proquake client";
	// XXX Mod version hasn't always been present, I forget what version
	// it was introduced, so I'm using 3.00 until I research it.
	else if (i == 1)
		return " with proquake version \b<\b 3.00";

	s1 = " with proquake version ";

	d = floor (i / 4096);
	i = i - d * 4096;
	sum = hex_ctof (hex[d * %2]) * 16;
	d = floor (i / 256);
	i = i - d * 256;
	sum = sum + hex_ctof (hex[d * %2]);
	d = floor (sum / 10);
	s2 = ftos (d);
	s3 = ".";

	s1 = strcat3 (s1, s2, s3);
	sum = sum - (d * 10);
	s2 = ftos (sum);
	s3 = "0";
	return strcat3 (s1, s2, s3);
};
