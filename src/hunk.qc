/*  $Id: hunk.qc,v 1.2 2003/06/11 21:23:56 slotzero Exp $

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
// HUNK MANIPULATION FUNCTIONS
//-------------------------------------------------------------------


entity (float type, float offset)
Get_Hunk =
{
	local entity hunk;

	if (!HUNK_CONTEXT_MAX)
		return world;

	hunk = *AddInt(AddInt(&progs, %-16), type);
	if (*hunk[%0] != *HUNK_SENTINAL)
		dprint ("Write_Hunk(): hunk != HUNK_SENTINAL\n");

	return *AddInt(&hunk, 4 * offset);
};

string (entity hunk)
Read_Hunk_e =
{
	return @AddInt(&hunk, PQUAKEC_TO_PSTRING);
};

string (float type, float offset)
Read_Hunk =
{
	local entity hunk;

	hunk = Get_Hunk (type, offset);

	return @AddInt(&hunk, PQUAKEC_TO_PSTRING);
};

void (entity hunk, string s)
Write_Hunk_e =
{
	strcpy (@AddInt(&hunk, PQUAKEC_TO_PSTRING), s);
};

void (float type, float offset, string s)
Write_Hunk =
{
	local entity hunk;

	hunk = Get_Hunk (type, offset);
	Write_Hunk_e (hunk, s);
};

string (entity hunk, float bytes)
Read_Hunk_Bytes =
{
	local float i, pdata, dword;
	local string data;

	data = allocate_string_size (bytes);
	pdata = AddInt (&data, PSTRING_TO_PQUAKEC);

	dword	= floor (bytes / 4) * %1;
	while (bytes > 3)
		bytes = bytes - 4;

	for (i = %0; i < dword; i = i + %1)
		(*pdata)[i] = hunk[i];

 	if (bytes)
	{
		bytes = OppInt ((4 - bytes) * %1);
		hunk = *AddInt (&hunk, bytes);
		pdata = AddInt (pdata, bytes);
		(*pdata)[i] = hunk[i];
		bytes = OppInt (bytes);
		hunk = *AddInt (&hunk, bytes);
		pdata = AddInt (pdata, bytes);
 	}

	return (@AddInt (pdata, PQUAKEC_TO_PSTRING));
};
