/*  $Id: develop.qc,v 1.62 2004/07/03 09:29:59 slotzero Exp $

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
remove_bit_from_players =
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

float ()
maxplayers =
{
	local entity e;
	local float i;

	e = nextent (world);
	for (i = 0; i < 16; i = i + 1)
	{
		if (e.classname == "bodyque")
			return i;
		e = nextent (e);
	}
	return 16;
};

float HUNK_DENIED_MAPS	= %799;
float HUNK_DENIED_MAP	= %700;

float ()
denied_maps =
{
	return Read_Hunk_Float (HUNK_CONTEXT, HUNK_DENIED_MAPS);
};

void (float n)
update_denied_maps =
{
	Write_Hunk_Float (HUNK_CONTEXT, HUNK_DENIED_MAPS, n);
};

void (string s)
add_denied_map =
{
	local float total;

	total = denied_maps ();

	// does map exist in hunk already? Check first

	Write_Hunk_Max (HUNK_CONTEXT, HUNK_DENIED_MAP + ((total * %1) * 2), s, 8);
	update_denied_maps (total + 1);
	dprint (s, " was added to the hunk. "); dprint_float (total + 1);
	dprint (" maps total. \n");
};

void ()
read_denied_maps =
{
	local float i, total;
	local string s;

	total = denied_maps ();
	for (i = 0; i < total; i = i + 1)
	{
		s = Read_Hunk_String_Max (HUNK_CONTEXT, HUNK_DENIED_MAP + ((i * %1) * 2), 8);
		dprint (s, "\n");
	}
};

void ()
Test_Button =
{
	SUB_Null ();
};
