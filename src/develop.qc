/*  $Id: develop.qc,v 1.101 2005/05/06 23:27:53 slotzero Exp $

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
			dprint ("Ghost player removed\n");
			os = self;
			self = e;
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

void ()
altar_spit =
{
	local float color;

	color		= random () * 255;

	IN_POQ([-
		particle (self.origin, '0 0 1000', color, 100);
	-])

	self.nextthink	= time + 0.1;
};

void (vector spot)
spawn_altar =
{
	local entity altar;

	altar			= spawn ();
	altar.classname		= "altar";

	setorigin (altar, spot);

	altar.think		= altar_spit;
	altar.nextthink		= time;
};

float (entity e)
client_ping =
{
	local float i, ping;

	for (i = 0 ; i < %16 ; i = i + %1)
		ping = ping + (e.cl[CL_PING_TIMES + i] * 1000);

	ping = rint (ping / 16);
	if (ping > 9999 || ping < 0)
		ping = 9999;

	return ping;
};

void ()
client_ping_times =
{
	local entity e;
	local float ping;
	local string s;

	dprint_force ("Client ping times:\n");

	e = find (world, classname, "player");
	while (e)
	{
		ping = client_ping (e);
		s = ftos (ping);
		self_sprintf_len (world, s, 4);
		dprint_force (" ");
		dprint_force (e.netname);
		dprint_force ("\n");
		e = find (e, classname, "player");
	}
};

float (float n)
num_to_bit =
{
	     if (n ==  1)	return 1;
	else if (n ==  2)	return 2;
	else if (n ==  3)	return 4;
	else if (n ==  4)	return 8;
	else if (n ==  5)	return 16;
	else if (n ==  6)	return 32;
	else if (n ==  7)	return 64;
	else if (n ==  8)	return 128;
	else if (n ==  9)	return 256;
	else if (n == 10)	return 512;
	else if (n == 11)	return 1024;
	else if (n == 12)	return 2048;
	else if (n == 13)	return 4096;
	else if (n == 14)	return 8192;
	else if (n == 15)	return 16384;
	else if (n == 16)	return 32768;
	else if (n == 17)	return 65536;
	else if (n == 18)	return 131072;
	else if (n == 19)	return 262144;
	else if (n == 20)	return 524288;
	else if (n == 21)	return 1048576;
	else if (n == 22)	return 2097152;
	else if (n == 23)	return 4194304;
	else if (n == 24)	return 8388608;
	else			return 0;
};

float (float bits)
bits_in_bits =
{
	local float n;

	if (bits & 1)
		n = n + 1;
	if (bits & 2)
		n = n + 1;
	if (bits & 4)
		n = n + 1;
	if (bits & 8)
		n = n + 1;
	if (bits & 16)
		n = n + 1;
	if (bits & 32)
		n = n + 1;
	if (bits & 64)
		n = n + 1;
	if (bits & 128)
		n = n + 1;
	if (bits & 256)
		n = n + 1;
	if (bits & 512)
		n = n + 1;
	if (bits & 1024)
		n = n + 1;
	if (bits & 2048)
		n = n + 1;
	if (bits & 4096)
		n = n + 1;
	if (bits & 8192)
		n = n + 1;
	if (bits & 16384)
		n = n + 1;
	if (bits & 32768)
		n = n + 1;
	if (bits & 65536)
		n = n + 1;
	if (bits & 131072)
		n = n + 1;
	if (bits & 262144)
		n = n + 1;
	if (bits & 524288)
		n = n + 1;
	if (bits & 1048576)
		n = n + 1;
	if (bits & 2097152)
		n = n + 1;
	if (bits & 4194304)
		n = n + 1;
	if (bits & 8388608)
		n = n + 1;

	return n;
};

void (entity client)
teamscores_on =
{	IN_QW(return;)
	local entity e;
	local float i, tf, bit, bits, n_teams, msg_type;
	local string s;

	if (client == world)
		msg_type	= MSG_ALL;
	else
	{
		client.rqflags = client.rqflags | RQ_TEAMSCORES_ON;
		msg_entity	= client;
		msg_type	= MSG_ONE;
 	}

	n_teams = enforced_teams ();

	bits = 0;
	e = nextent (world);
	for (i = 0; i < 16; i = i + 1)
	{
		if (e.classname == "bodyque")
			return;

		if (e.cl[CL_ACTIVE] == %1)
		{
			bit = num_to_bit (e.team);

			if (!bits & bit)
			{
				bits	= bits | bit;

				if (n_teams && e.team == TEAM_NIL)
					svc_updatename (msg_type, i, string_null);
				else
				{
					s	= team_to_name (e.team);
					tf	= team_to_teamfrags (e.team);

					svc_updatename (msg_type, i, s);
					svc_updatefrags (msg_type, i, tf);
					svc_updatecolors (msg_type, i, e.cl[CL_COLORS] / %1);
				}
			}
			else
				svc_updatename (msg_type, i, string_null);
		}
		else
			svc_updatename (msg_type, i, string_null);

		e = nextent (e);
	}
};

void (entity client)
teamscores_off =
{	IN_QW(return;)
	local entity e;
	local float i, msg_type;

	if (client == world)
		msg_type = MSG_ALL;
	else
	{
		client.rqflags = client.rqflags - client.rqflags & RQ_TEAMSCORES_ON;
		msg_entity = client;
		msg_type = MSG_ONE;
 	}

	e = nextent (world);
	for (i = 0; i < 16; i = i + 1)
	{
		if (e.classname == "bodyque")
			return;

		if (e.cl[CL_ACTIVE] == %1)
		{
			svc_updatename (msg_type, i, e.netname);
			svc_updatefrags (msg_type, i, e.frags);
			svc_updatecolors (msg_type, i, e.cl[CL_COLORS] / %1);
		}
		else
			svc_updatename (msg_type, i, string_null);

		e = nextent (e);
	}
};

float (float cl_colors)
cl_colors_to_shirt =
{
	return floor (cl_colors / %1 / 16);
};

float (float cl_colors)
cl_colors_to_pants =
{
	local float shirt;

	shirt = floor (cl_colors / %1 / 16);
	shirt = shirt * 16;
	return cl_colors / %1 - shirt;
};

void ()
Test_Button =
{
	SUB_Null ();
};
