/*  $Id: develop.qc,v 1.58 2004/04/11 06:35:01 slotzero Exp $

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

void (float mode)
change_practice_mode =
{
	local float new_deathmatch, bits;
	local string s;

	bits = DM_MODE_PRACTICE | DM_NO_ALT_WEAPONS;
	new_deathmatch = cvar ("deathmatch");

	if (mode)
	{
		if (!new_deathmatch & DM_MODE_PRACTICE)
			new_deathmatch = new_deathmatch | bits;
	}
	else
	{
		if (new_deathmatch & DM_MODE_PRACTICE)
			new_deathmatch = new_deathmatch - new_deathmatch & bits;
	}

	s = ftos (new_deathmatch);
	cvar_set ("deathmatch", s);
	admin_changelevel (mapname);
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

void ()
Test_Button =
{
	SUB_Null ();
};

float HUNK_CLIENT_DISCONNECT	= %100;

void ()
Log_Client_Disconnect =
{	IN_QW(return;)
	local float i, n, max, offset, e_time, elapsed;
	local string e_name;

	if (MAX_CLIENT_DISCONNECT_LOG < 1 || MAX_CLIENT_DISCONNECT_LOG > 20)
		return;

	offset	= HUNK_CLIENT_DISCONNECT;
	max 	= n = (MAX_CLIENT_DISCONNECT_LOG - 1) * %1;
	elapsed	= server_time ();

	for (i = max; i >= %0; i = i - %1)
	{
		e_name = Read_Hunk_Max (HUNK_CONTEXT, offset + (i * 5), 16);
		if (e_name == self.netname)
			n = i;
	}

	if (n != max)
		max = n;

	for (i = max; i >= %0; i = i - %1)
	{
		if (i != max)
		{
			e_name = Read_Hunk_Max (HUNK_CONTEXT, offset + (i * 5), 16);
			Write_Hunk_Max (HUNK_CONTEXT, offset + ((i + %1) * 5), e_name, 16);
			e_time = Read_Hunk_Float (HUNK_CONTEXT, offset + %4 + (i * 5));
			Write_Hunk_Float (HUNK_CONTEXT, offset + %4 + ((i + %1) * 5), e_time);
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

	if (MAX_CLIENT_DISCONNECT_LOG < 1 || MAX_CLIENT_DISCONNECT_LOG > 20)
	{
		self_sprint (self, "The \blast\b command has been disabled.\n");
		return;
	}

	offset	= HUNK_CLIENT_DISCONNECT;
	max 	= (MAX_CLIENT_DISCONNECT_LOG - 1) * %1;

	self_sprint (self, "\n");
	self_sprintf_len (self, "Name", -16);
	self_sprintf_len (self, "Time", 10);
	self_sprint (self, "\n----                  ----\n\n");

	server_t = server_time ();
	for (i = max; i >= %0; i = i - %1)
	{
		e_time = floor (Read_Hunk_Float (HUNK_CONTEXT, offset + %4 + (i * 5)));
		e_away = server_t - e_time;

		if (e_time)
		{
			e_name = Read_Hunk_Max (HUNK_CONTEXT, offset + (i * 5), 16);
			self_sprintf_len (self, e_name, -16);
			e_name = parse_time (e_away);
			self_sprintf_len (self, e_name, 10);
			self_sprint (self, "\n");
		}
	}
	if (!e_time)
		self_sprint (self, "No entries found.\n");
};
