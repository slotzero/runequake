/*  $Id: develop.qc,v 1.44 2003/09/20 02:55:58 slotzero Exp $

    Copyright (C) 2001, 2002  David 'Slot Zero' Roberts.

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
{
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
