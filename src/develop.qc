/*  $Id: develop.qc,v 1.27 2003/07/03 20:51:30 slotzero Exp $

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

/* void ()
Ban_Client_Level =
{
	local float i, offset;
	local string s, ip;

	// hunk offset
	offset = %100;
	ip = self.netname;

	for (i = %22; i >= %0; i = i - %1)
	{
		s = Read_Hunk_Max (HUNK_CONTEXT, offset + (i * 16), 16);
		Write_Hunk_Max (HUNK_CONTEXT, offset + ((i + %1) * 16), s, 16);
		dprint (">", s, "<\n");
	}
	Write_Hunk_Max (HUNK_CONTEXT, offset, ip, 16);
}; */

void ()
Log_Client =
{
	local float i, offset;
	local string s;

	// hunk offset
	offset = %100;

	s = Read_Hunk_Max (HUNK_CONTEXT, offset, 16);
	// check last entry for duplicate, update time only.
	if (s == self.netname)
	{
		// dprint ("duplicate entry removed\n");
		s = ftos (elapsed_time ());
		Write_Hunk_Max (HUNK_CONTEXT, offset + %16, s, 8);
		return;
	}

	for (i = %6; i >= %0; i = i - %1)
	{
		s = Read_Hunk_Max (HUNK_CONTEXT, offset + (i * 24), 16);
		Write_Hunk_Max (HUNK_CONTEXT, offset + ((i + %1) * 24), s, 16);
		s = Read_Hunk_Max (HUNK_CONTEXT, offset + %16 + (i * 24), 8);
		Write_Hunk_Max (HUNK_CONTEXT, offset + %16 + ((i + %1) * 24), s, 16);
	}
	Write_Hunk_Max (HUNK_CONTEXT, offset, self.netname, 16);
	s = ftos (elapsed_time ());
	Write_Hunk_Max (HUNK_CONTEXT, offset + %16, s, 8);
};

void ()
Read_Log =
{
	local float i, offset, last, real;
	local string name, display;

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
		name = Read_Hunk_Max (HUNK_CONTEXT, offset + (i * 24), 16);
		last = stof (Read_Hunk_Max (HUNK_CONTEXT, offset + %16 + (i * 24), 8));
		real = elapsed_time ();
		real = real - last;

		if (last)
		{
			display = flen (name, -16);
			self_sprint (self, display);
			display = flen (parse_time (real), 8);
			self_sprint (self, display);
			self_sprint (self, "\n");
		}
	}
	if (!last)
		self_sprint (self, "No entries found.\n");
};

void ()
Test_Button =
{
	Read_Log ();
};

string (float n)
parse_time =
{
	local float hours, minutes, seconds;
	local string s, x;

	seconds	= floor (n);
	minutes	= floor (seconds / 60);
	hours	= floor (minutes / 60);
	seconds	= seconds - floor (minutes * 60);
	minutes	= minutes - floor (hours * 60);

	if (hours)
	{
		s = ftos (hours);
		s = strcat (s, ":");
		if (minutes < 10) s = strcat (s, "0");
	}
	x = ftos (minutes);
	s = strcat (s, x);
	s = strcat (s, ":");
	if (seconds < 10) s = strcat (s, "0");
	x = ftos (seconds);
	return strcat (s, x);
};

void (float type, float offset, string ip)
ban_ip =
{
	local float i;
	local string s;

	// shift one down
	for (i = %14; i >= %0; i = i - %1)
	{
		s = Read_Hunk_Max (type, offset + (i * 16), 16);
		Write_Hunk_Max (type, offset + ((i + %1) * 16), s, 16);
		dprint (">", s, "<\n");
	}
	Write_Hunk_Max (type, offset, ip, 16);
};

string ()
ProQuake_Version =
{
	local entity cl;
	local float i, d, sum;
	local string v, x;

	cl = *SubInt(AddInt(PSTRING_TO_PQUAKEC, &self.netname), 4 * CL_NAME);
	cl = *AddInt(cl[CL_NETCONNECTION], PC_TO_PQUAKEC);
	i = cl[QS_MOD] / %1;

	if (!i)
		return "0";
	// XXX Mod version hasn't always been present, I forget what version
	// it was introduced, so I'm using 3.00 until I research it.
	else if (i == 1)
		return "< 3.00";

	d = floor (i / 4096);
	i = i - d * 4096;
	sum = hex_ctof (hex[d * %2]) * 16;
	d = floor (i / 256);
	i = i - d * 256;
	sum = sum + hex_ctof (hex[d * %2]);
	d = floor (sum / 10);
	v = ftos (d);
	v = strcat (v, ".");
	sum = sum - (d * 10);
	x = ftos (sum);
	v = strcat (v, x);
	return strcat (v, "0");
};
