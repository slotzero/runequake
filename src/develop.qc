/*  $Id: develop.qc,v 1.30 2003/07/06 10:19:38 slotzero Exp $

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
	local float i, offset;
	local string e_name, e_time, elapsed;

	// hunk offset
	offset = %100;

	elapsed = ftos (elapsed_time ());
	e_name = Read_Hunk_Max (HUNK_CONTEXT, offset, 16);

	// check last entry for duplicate, update time only.
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
};

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
		elapsed = ftos (elapsed_time ());
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

void ()
Read_Client_Disconnect_Log =
{
	IN_QW(return;)
	local float i, offset, e_time, e_away;
	local string e_name, display;

	// hunk offset
	offset = %100;

	self_sprint (self, "\n");
	display = flen ("Name", -16);
	self_sprint (self, display);
	display = flen ("Time", 8);
	self_sprint (self, display);
	self_sprint (self, "\n----                ----\n\n");

	for (i = %6; i >= %0; i = i - %1)
	{
		e_name = Read_Hunk (HUNK_CONTEXT, offset + (i * 24));
		e_time = stof (Read_Hunk_Max (HUNK_CONTEXT, offset + %16 + (i * 24), 8));
		e_away = elapsed_time () - e_time;

		if (e_time)
		{
			display = flen (e_name, -16);
			self_sprint (self, display);
			display = flen (parse_time (e_away), 8);
			self_sprint (self, display);
			self_sprint (self, "\n");
		}
	}
	if (!e_time)
		self_sprint (self, "No entries found.\n");
};

string (float n)
parse_time =
{
	local float hours, minutes, seconds;
	local string cat1, cat2, cat3, cat4, cat5, cat6, cat7;

	seconds	= floor (n);
	minutes	= floor (seconds / 60);
	hours	= floor (minutes / 60);
	seconds	= seconds - floor (minutes * 60);
	minutes	= minutes - floor (hours * 60);

	if (hours)
	{
		cat1 = ftos (hours);
		cat2 = ":";
		if (minutes < 10) cat3 = "0";
	}
	cat4 = ftos (minutes);
	cat5 = ":";
	if (seconds < 10) cat6 = "0";
	cat7 = ftos (seconds);

	return strcat7 (cat1, cat2, cat3, cat4, cat5, cat6, cat7);
};

string ()
ProQuake_Version =
{
	local entity cl;
	local float i, d, sum;
	local string cat1, cat2, cat3, cat4, cat5, cat6, cat7;

	cl = *SubInt(AddInt(PSTRING_TO_PQUAKEC, &self.netname), 4 * CL_NAME);
	cl = *AddInt(cl[CL_NETCONNECTION], PC_TO_PQUAKEC);
	i = cl[QS_MOD] / %1;

	if (!i)
		return " with an unrecognized client";
	// mod_version < 3.02
	else if (i == 1)
		return " with a proquake client";

	cat1 = " with proquake client version ";

	d = floor (i / 4096);
	i = i - d * 4096;
	sum = hex_ctof (hex[d * %2]) * 16;
	d = floor (i / 256);
	i = i - d * 256;
	sum = sum + hex_ctof (hex[d * %2]);
	d = floor (sum / 10);
	cat2 = ftos (d);
	cat3 = ".";
	sum = sum - (d * 10);
	cat4 = ftos (sum);
	cat5 = "0";

	return strcat5 (cat1, cat2, cat3, cat4, cat5);
};
