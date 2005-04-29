/*  $Id: hunked.qc,v 1.27 2005/04/29 23:30:37 slotzero Exp $

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
// HUNK FUNCTIONS
//-------------------------------------------------------------------

float LAST_TIME_UPDATE;
float HUNK_SERVER_TIME		= %10;
float HUNK_CLIENT_DISCONNECT	= %100;
float HUNK_NO_QUAD		= %1008;
float HUNK_NO_PENT		= %1009;
float HUNK_NO_RING		= %1010;
float HUNK_NO_SUIT		= %1011;
float HUNK_NO_ARMOR		= %1012;
float HUNK_ROTATE		= %1013;
float HUNK_NO_RUNES		= %1014;
float HUNK_NO_ALT_WEAPONS	= %1015;
float HUNK_NO_SPAWN_SHIELDS	= %1016;
float HUNK_NO_HOOK_DAMAGE	= %1017;
float HUNK_NO_MEGA		= %1019;
float HUNK_MODE_MIDAIR		= %1020;

float ()
server_time =
{
	local float i;

	if (!HUNK_CONTEXT_MAX)
		return 0;

	i = Read_Hunk_Float (HUNK_CONTEXT, HUNK_SERVER_TIME);
	i = i + time - LAST_TIME_UPDATE;

	return i;
};

void ()
update_server_time =
{
	local float i;

	if (!HUNK_CONTEXT_MAX)
		return;

	i = server_time ();
	Write_Hunk_Float (HUNK_CONTEXT, HUNK_SERVER_TIME, i);
	LAST_TIME_UPDATE = time;
};

string (float n)
parse_time =
{
	local float i, hours, minutes, seconds;
	local string format = "0000:00:00";
	local string x;

	if (!HUNK_CONTEXT_MAX)
		return "Command not supported on this server.";

	seconds	= floor (n);
	minutes	= floor (seconds / 60);
	hours	= floor (minutes / 60);
	seconds	= seconds - floor (minutes * 60);
	minutes	= minutes - floor (hours * 60);

	i = %0;
	if (hours)
	{
		x = ftos (hours);
		strcpy (format[i], x);

		if (hours < 10)		i = i + %1;
		else if (hours < 100)	i = i + %2;
		else if (hours < 1000)	i = i + %3;
		else if (hours < 10000) i = i + %4;

		strcpy (format[i], ":");
		i = i + %1;
		if (minutes < 10)	{ strcpy (format[i], "0"); i = i + %1; }
	}

	x = ftos (minutes);
	strcpy (format[i], x);

	if (minutes < 10)	i = i + %1;
	else			i = i + %2;

	strcpy (format[i], ":");
	i = i + %1;
	if (seconds < 10)	{ strcpy (format[i], "0"); i = i + %1; }

	x = ftos (seconds);
	strcpy (format[i], x);

	return format;
};

string ()
PQ_Version =
{
	local float i, ch, sum;
	local string format = " with proquake version 0.00";
	local string x;

	i = self.netconnection[QS_MOD] / %1;
	if (!i)
		return " with a non-proquake client";
	else if (i == 1)
		return " with an unknown proquake client";
	else if (i == 2)
		return " as a qsmack client";

	ch = floor (i / 4096);
	i = i - ch * 4096;
	sum = hex_ctof (hex[ch * %2]) * 16;
	ch = floor (i / 256);
	i = i - ch * 256;
	sum = sum + hex_ctof (hex[ch * %2]);
	ch = floor (sum / 10);
	x = ftos (ch);

	i = %23;
	strcpy (format[i], x);		i = i + %1;
	strcpy (format[i], ".");	i = i + %1;

	sum = sum - (ch * 10);
	x = ftos (sum);
	strcpy (format[i], x);		i = i + %1;
	strcpy (format[i], "0");

	return format;
};

void ()
Log_Client_Disconnect =
{
	local float i, n, max, offset, e_time, elapsed;
	local string e_name;

	if (!HUNK_CONTEXT_MAX)
		return;

	if (MAX_CLIENT_DISCONNECT_LOG < 1 || MAX_CLIENT_DISCONNECT_LOG > 20)
		return;

	offset	= HUNK_CLIENT_DISCONNECT;
	max 	= n = (MAX_CLIENT_DISCONNECT_LOG - 1) * %1;
	elapsed	= server_time ();

	for (i = max; i >= %0; i = i - %1)
	{
		e_name = Read_Hunk_String_Max (HUNK_CONTEXT, offset + (i * 5), 16);
		if (e_name == self.netname)
			n = i;
	}

	if (n != max)
		max = n;

	for (i = max; i >= %0; i = i - %1)
	{
		if (i != max)
		{
			e_name = Read_Hunk_String_Max (HUNK_CONTEXT, offset + (i * 5), 16);
			Write_Hunk_String_Max (HUNK_CONTEXT, offset + ((i + %1) * 5), e_name, 16);
			e_time = Read_Hunk_Float (HUNK_CONTEXT, offset + %4 + (i * 5));
			Write_Hunk_Float (HUNK_CONTEXT, offset + %4 + ((i + %1) * 5), e_time);
		}
	}

	Write_Hunk_String_Max (HUNK_CONTEXT, offset, self.netname, 16);
	Write_Hunk_Float (HUNK_CONTEXT, offset + %4, elapsed);
};

void ()
Client_Disconnect_Log =
{
	local float i, max, offset, e_time, e_away, server_t;
	local string e_name;

	if (!HUNK_CONTEXT_MAX)
	{
		self_sprint (self, "Command not supported on this server.\n");
		return;
	}

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
			e_name = Read_Hunk_String_Max (HUNK_CONTEXT, offset + (i * 5), 16);
			self_sprintf_len (self, e_name, -16);
			e_name = parse_time (e_away);
			self_sprintf_len (self, e_name, 10);
			self_sprint (self, "\n");
		}
	}
	if (!e_time)
		self_sprint (self, "No entries found.\n");
};

IN_QW([-
// My awful attempt to keep QW compatible...
float (float offset, float value)
fput =
{
	local string s;

	s = ftos (value);

	if	(*offset == *HUNK_NO_QUAD)		cvar_set_infokey ("NO_QUAD",		s);
	else if (*offset == *HUNK_NO_PENT)		cvar_set_infokey ("NO_PENT",		s);
	else if (*offset == *HUNK_NO_RING)		cvar_set_infokey ("NO_RING",		s);
	else if (*offset == *HUNK_NO_SUIT)		cvar_set_infokey ("NO_SUIT",		s);
	else if (*offset == *HUNK_NO_ARMOR)		cvar_set_infokey ("NO_ARMOR",		s);
	else if (*offset == *HUNK_ROTATE)		cvar_set_infokey ("ROTATE",		s);
	else if (*offset == *HUNK_NO_RUNES)		cvar_set_infokey ("NO_RUNES",		s);
	else if (*offset == *HUNK_NO_ALT_WEAPONS)	cvar_set_infokey ("NO_ALT_WEAPONS",	s);
	else if (*offset == *HUNK_NO_SPAWN_SHIELDS)	cvar_set_infokey ("NO_SPAWN_SHIELDS",	s);
	else if (*offset == *HUNK_NO_HOOK_DAMAGE)	cvar_set_infokey ("HO_HOOK_DAMAGE",	s);
	else if (*offset == *HUNK_NO_MEGA)		cvar_set_infokey ("NO_MEGA",		s);
	else if (*offset == *HUNK_MODE_MIDAIR)		cvar_set_infokey ("MODE_MIDAIR",	s);

	return value;
};

float (float offset, float default)
fget =
{
	local float i;
	if (0) default = default; // frikqcc

	if	(*offset == *HUNK_NO_QUAD)		i = NO_QUAD		= cvar_infokey ("NO_QUAD");
	else if (*offset == *HUNK_NO_PENT)		i = NO_PENT		= cvar_infokey ("NO_PENT");
	else if (*offset == *HUNK_NO_RING)		i = NO_RING		= cvar_infokey ("NO_RING");
	else if (*offset == *HUNK_NO_SUIT)		i = NO_SUIT		= cvar_infokey ("NO_SUIT");
	else if (*offset == *HUNK_NO_ARMOR)		i = NO_ARMOR		= cvar_infokey ("NO_ARMOR");
	else if (*offset == *HUNK_ROTATE)		i = ROTATE		= cvar_infokey ("ROTATE");
	else if (*offset == *HUNK_NO_RUNES)		i = NO_RUNES		= cvar_infokey ("NO_RUNES");
	else if (*offset == *HUNK_NO_ALT_WEAPONS)	i = NO_ALT_WEAPONS	= cvar_infokey ("NO_ALT_WEAPONS");
	else if (*offset == *HUNK_NO_SPAWN_SHIELDS)	i = NO_SPAWN_SHIELDS	= cvar_infokey ("NO_SPAWN_SHIELDS");
	else if (*offset == *HUNK_NO_HOOK_DAMAGE)	i = NO_HOOK_DAMAGE	= cvar_infokey ("NO_HOOK_DAMAGE");
	else if (*offset == *HUNK_NO_MEGA)		i = NO_MEGA		= cvar_infokey ("NO_MEGA");
	else if (*offset == *HUNK_MODE_MIDAIR)		i = MODE_MIDAIR		= cvar_infokey ("MODE_MIDAIR");

	return i;
};
-])

IN_POQ([-
float (float offset, float value)
fput =
{
	Write_Hunk_Float (HUNK_CONTEXT, offset, value);
	return value;
};

float (float offset, float default)
fget =
{
	local float i;

	i = Read_Hunk_Float (HUNK_CONTEXT, offset);
	if (i == 0x20202020)
	{
		fput (offset, default);
		return default;
	}

	return i;
};
-])

void ()
Hunk_Settings =
{
	NO_QUAD			= fget (HUNK_NO_QUAD,		0);
	NO_PENT			= fget (HUNK_NO_PENT,		0);
	NO_RING			= fget (HUNK_NO_RING,		0);
	NO_SUIT			= fget (HUNK_NO_SUIT,		0);
	NO_ARMOR		= fget (HUNK_NO_ARMOR,		0);
	ROTATE			= fget (HUNK_ROTATE,		0);
	NO_RUNES		= fget (HUNK_NO_RUNES,		0);
	NO_ALT_WEAPONS		= fget (HUNK_NO_ALT_WEAPONS,	0);
	NO_SPAWN_SHIELDS	= fget (HUNK_NO_SPAWN_SHIELDS,	0);
	NO_HOOK_DAMAGE		= fget (HUNK_NO_HOOK_DAMAGE,	0);
	NO_MEGA			= fget (HUNK_NO_MEGA,		0);
	MODE_MIDAIR		= fget (HUNK_MODE_MIDAIR,	0);

	set_runemax ();
};
