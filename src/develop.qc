/*  $Id: develop.qc,v 1.36 2003/07/11 02:44:18 slotzero Exp $

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

void ()
Test_Button =
{
	SUB_Null ();
};

void ()
Log_Client_Disconnect =
{
	IN_QW(return;)
	local float i, n, max, offset;
	local string e_name, e_time, elapsed;

	// hunk offset [must match Client_Disconnect_Log]
	offset = %100;	// position in hunk
	max = n = %6;	// length of list (actual length is + 1)

	elapsed = ftos (server_time ());

	for (i = max; i >= %0; i = i - %1)
	{
		e_name = Read_Hunk_Max (HUNK_CONTEXT, offset + (i * 6), 16);
		if (e_name == self.netname)
		{
			Write_Hunk_Max (HUNK_CONTEXT, offset + (i * 6), "removed", 8);
			Write_Hunk_Max (HUNK_CONTEXT, offset + %4 + (i * 6), "0", 8);
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
			e_time = Read_Hunk_Max (HUNK_CONTEXT, offset + %4 + (i * 6), 8);
			Write_Hunk_Max (HUNK_CONTEXT, offset + %4 + ((i + %1) * 6), e_time, 8);
		}
	}

	Write_Hunk_Max (HUNK_CONTEXT, offset, self.netname, 16);
	Write_Hunk_Max (HUNK_CONTEXT, offset + %4, elapsed, 8);
};

void ()
Client_Disconnect_Log =
{
	IN_QW(return;)
	local float i, max, offset, e_time, e_away, server_t;
	local string e_name;

	// hunk offset [must match Log_Client_Disconnect]
	offset = %100;	// position in hunk
	max = %6;	// length of list (actual length is + 1)

	self_sprint (self, "\n");
	self_sprintf_len (self, "Name", -16);
	self_sprintf_len (self, "Time", 10);
	self_sprint (self, "\n----                  ----\n\n");

	server_t = server_time ();
	for (i = max; i >= %0; i = i - %1)
	{

		e_time = stof (Read_Hunk_Max (HUNK_CONTEXT, offset + %4 + (i * 6), 8));
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
	local entity cl;
	local float i, d, sum;
	local string s1, s2, s3;

	cl = *SubInt(AddInt(PSTRING_TO_PQUAKEC, &self.netname), 4 * CL_NAME);
	cl = *AddInt(cl[CL_NETCONNECTION], PC_TO_PQUAKEC);
	i = cl[QS_MOD] / %1;

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

/* void ()
Log_Client_Disconnect =
{
	IN_QW(return;)
	local float i, offset;
	local string e_name, e_time, elapsed;

	// hunk offset
	offset = %100;

	elapsed = ftos (server_time ());

	// check last entry for duplicate, update time only.
	e_name = Read_Hunk_Max (HUNK_CONTEXT, offset, 16);
	if (e_name == self.netname)
	{
		Write_Hunk_Max (HUNK_CONTEXT, offset + %16, elapsed, 8);
		return;
	}

	for (i = %6; i >= %0; i = i - %1)
	{
		e_name = Read_Hunk_Max (HUNK_CONTEXT, offset + (i * 24), 16);
		Write_Hunk_Max (HUNK_CONTEXT, offset + ((i + %1) * 24), e_name, 16);
		e_time = Read_Hunk_Max (HUNK_CONTEXT, offset + %16 + (i * 24), 8);
		Write_Hunk_Max (HUNK_CONTEXT, offset + %16 + ((i + %1) * 24), e_time, 16);
	}

	Write_Hunk_Max (HUNK_CONTEXT, offset, self.netname, 16);
	Write_Hunk_Max (HUNK_CONTEXT, offset + %16, elapsed, 8);
	update_server_time ();
}; */

/* void (float hunk_offset, float max_entries, string entry, float entry_size, float timed, float e_remove)
Hunk_Write_List =
{
	IN_QW(return;)
	local float i, n, offset;
	local string e_name, e_time, elapsed;

	// hunk offset
	offset = %100;

	offset = entry_size;
	if (timed)
	{
		elapsed = ftos (server_time ());
		offset = offset + 8;
	}

	n = %0;
	if (e_remove)
	{
		for (i = max_entries; i >= %0; i = i - %1)
		{
			e_name = Read_Hunk_Max (HUNK_CONTEXT, hunk_offset + (i * offset), entry_size);
			if (e_name == entry)
			{
				Write_Hunk_Max (HUNK_CONTEXT, hunk_offset + (i * offset), "0", 8);
				Write_Hunk_Max (HUNK_CONTEXT, hunk_offset + (entry_size * %1) + (i * offset), "0", 8);
				if (i) n = i - %1;
				else n = %-1;
			}
		}
	}

	if (n)
		max_entries = n;

	for (i = max_entries; i >= %0; i = i - %1)
	{
		e_name = Read_Hunk_Max (HUNK_CONTEXT, hunk_offset + (i * offset), entry_size);
		Write_Hunk_Max (HUNK_CONTEXT, hunk_offset + ((i + %1) * offset), e_name, entry_size);
		e_time = Read_Hunk_Max (HUNK_CONTEXT, hunk_offset + (entry_size * %1) + (i * offset), 8);
		Write_Hunk_Max (HUNK_CONTEXT, hunk_offset + (entry_size * %1) + ((i + %1) * offset), e_time, 8);
	}

	Write_Hunk_Max (HUNK_CONTEXT, hunk_offset, entry, entry_size);
	Write_Hunk_Max (HUNK_CONTEXT, hunk_offset + (entry_size * %1), elapsed, 8);
}; */

/* void ()
Log_Client_Disconnect =
{
	Hunk_Write_List (%100, %6, self.netname, 16, TRUE, TRUE);
}; */
