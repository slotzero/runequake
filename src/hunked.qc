/*
    Copyright (C) 2003-2017  David 'Slot Zero' Roberts.

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
float HUNK_LAST_LEVEL		= %520;
float HUNK_LAST_LEVEL_POS	= %530;
float HUNK_BAN_OFFSET		= %800;
float HUNK_MUTE_OFFSET		= %1200;

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

float BAN_LIST_SIZE = %50;

float (float ip)
ban_check =
{
	local float i;
	local entity hunk_ip;

   	if (!ip)
		return -1;

	hunk_ip = Get_Hunk (HUNK_CONTEXT, HUNK_BAN_OFFSET);
	for (i = 0; i < BAN_LIST_SIZE; i = i + %1)
	{
		if (hunk_ip[i] == ip)
			return i;
	}

	return -1;
};

void ()
ban_list =
{
	if (MOD_PROTOCOL)
		return self_sprint (self, "Type '\bban\b' from console for list\n");
	local float i;
	local entity hunk_ip;

	self_sprint (self, "\bBan List\n\n");

	hunk_ip = Get_Hunk (HUNK_CONTEXT, HUNK_BAN_OFFSET);
	for (i = 0; i < BAN_LIST_SIZE; i = i + %1)
	{
		if (hunk_ip[i])
		{
			self_sprint_float (self, hunk_ip[i] & 255);
			self_sprint (self, ".");
			self_sprint_float (self, hunk_ip[i] & 65280 / 256);
			self_sprint (self, ".");
			self_sprint_float (self, hunk_ip[i] & 16711680 / 65536);
			self_sprint (self, ".xxx\n");
		}
	}
};

vector (string ip)
ip_to_vec =
{
	local vector v;
	local float i, oc, px, dot, pch;
	local string ch;
	local string octet = "abc";

	v	= '-1 -1 -1';
	px	= AddInt(&"\{0}  ", PSTRING_TO_PQUAKEC);
	pch	= AddInt(AddInt(&ip, PSTRING_TO_PQUAKEC), %-4);
	&%116	= 0;

	for (i = 0; i < 16; i = i + 1)
	{
		pch = AddInt (pch, %1);
		&%113 = (*pch)[0];

		if (world[%5] == 0 || world[%5] == ':')
			i = 16;
		else if (world[%5] == '.')
		{
			dot	= dot + 1;
			oc	= 0;

			if (dot == 1)
				v_x = stof (octet);
			else if (dot == 2)
				v_y = stof (octet);
			else if (dot == 3)
				v_z = stof (octet);
		}
		else
		{
			if (oc < %3)
			{
				ch = atoc (world[%5] / %1);
				if (ch)
				{
					strcpy (octet[oc], ch);
					oc = oc + %1;
				}
				else
					i = 16;
			}
			else
			{
				if (dot == 2 && oc == %3)
					v_z = stof (octet);

				i = 16;
			}
		}
	}

	pch = AddInt(pch, %3);
	// (*pch)[0] = (*px)[0];

	if (v_x < 0 || v_y < 0 || v_z < 0 || v_x > 255 || v_y > 255 || v_z > 255)
		return VEC_ORIGIN;

	return v;
};

void (float ip)
ban_remove =
{
	if (MOD_PROTOCOL)
		return self_sprint (self, "Type '\bban <ip address> off\b' from console to unban IP\n");
	local float pos;

	pos = ban_check (ip);
	if (pos < 0)
		return self_sprint (self, "ip doesn't exist\n");

	Write_Hunk_Float (HUNK_CONTEXT, HUNK_BAN_OFFSET + pos, 0);
	localcmd ("ban off\n");
	return self_sprint (self, "ip succesfully removed\n");
};

void (float ip)
ban_add =
{
	if (MOD_PROTOCOL)
		return self_sprint (self, "Type '\bban <ip address>\b' from console to ban IP\n");
	local float i;
	local entity hunk_ip;

	// check to make sure ban doesn't exist
	if (ban_check (ip) >= 0)
		return self_sprint (self, "ip already banned\n");

	// check hunk for available slot
	hunk_ip = Get_Hunk (HUNK_CONTEXT, HUNK_BAN_OFFSET);
	for (i = 0; i < BAN_LIST_SIZE; i = i + %1)
	{
		if (!hunk_ip[i])
		{
			hunk_ip[i] = ip;
			return self_sprint (self, "ip added to the ban list\n");
		}
	}

	// list is full
	return self_sprint (self, "ban list is full\n");
};

float MUTE_LIST_SIZE = %20;

float (float ip)
mute_check =
{
	local float i;
	local entity hunk_ip;

   	if (!ip)
		return -1;

	hunk_ip = Get_Hunk (HUNK_CONTEXT, HUNK_MUTE_OFFSET);
	for (i = 0; i < MUTE_LIST_SIZE; i = i + %1)
	{
		if (hunk_ip[i] == ip)
			return i;
	}

	return -1;
};

void ()
mute_list =
{
	local float i;
	local entity hunk_ip;

	self_sprint (self, "\bMute List\n\n");

	hunk_ip = Get_Hunk (HUNK_CONTEXT, HUNK_MUTE_OFFSET);
	for (i = 0; i < MUTE_LIST_SIZE; i = i + %1)
	{
		if (hunk_ip[i])
		{
			self_sprint_float (self, hunk_ip[i] & 255);
			self_sprint (self, ".");
			self_sprint_float (self, hunk_ip[i] & 65280 / 256);
			self_sprint (self, ".");
			self_sprint_float (self, hunk_ip[i] & 16711680 / 65536);
			self_sprint (self, ".xxx\n");
		}
	}
};

void (float ip)
mute_remove =
{
	local float pos;

	pos = mute_check (ip);
	if (pos < 0)
		return self_sprint (self, "ip doesn't exist\n");

	Write_Hunk_Float (HUNK_CONTEXT, HUNK_MUTE_OFFSET + pos, 0);
	return self_sprint (self, "ip succesfully removed\n");
};

void (float ip)
mute_add =
{
	local float i;
	local entity hunk_ip;

	// check to make sure ban doesn't exist
	if (mute_check (ip) >= 0)
		return self_sprint (self, "ip already banned\n");

	// check hunk for available slot
	hunk_ip = Get_Hunk (HUNK_CONTEXT, HUNK_MUTE_OFFSET);
	for (i = 0; i < MUTE_LIST_SIZE; i = i + %1)
	{
		if (!hunk_ip[i])
		{
			hunk_ip[i] = ip;
			return self_sprint (self, "ip added to the mute list\n");
		}
	}

	// list is full
	return self_sprint (self, "mute list is full\n");
};

float (string last_level)
track_level_duplicate =
{	IN_QW(return 0;)
	local float i;
	local string s;

	for (i = %0; i < %10; i = i + %2)
	{
		s = Read_Hunk_String_Max (HUNK_CONTEXT, HUNK_LAST_LEVEL + i, 8);
		if (s == last_level)
			return 1;
	}
	return 0;
};

void (string last_level)
track_last_level =
{	IN_QW(return;)
	local float pos;

	pos = Read_Hunk_Float (HUNK_CONTEXT, HUNK_LAST_LEVEL_POS);
	if (pos >=5)
		pos = 0;

	if (track_level_duplicate (last_level))
		return;

	Write_Hunk_String_Max (HUNK_CONTEXT, HUNK_LAST_LEVEL + ((pos * 2) * %1), last_level, 8);
	Write_Hunk_Float (HUNK_CONTEXT, HUNK_LAST_LEVEL_POS, pos + 1);
};

void ()
hunk_storage_init =
{
	local float i;

	custom_maps ();

	// initialize storage for ban
	for (i = 0; i < BAN_LIST_SIZE; i = i + %1)
		Write_Hunk_Float (HUNK_CONTEXT, HUNK_BAN_OFFSET + i, 0);

	// initialize storage for mute
	for (i = 0; i < MUTE_LIST_SIZE; i = i + %1)
		Write_Hunk_Float (HUNK_CONTEXT, HUNK_MUTE_OFFSET + i, 0);

	if (MOD_PROTOCOL)
		localcmd ("exec mute.txt\n");
	else
		localcmd ("exec ban.txt\n");
};
