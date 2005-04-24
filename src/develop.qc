/*  $Id: develop.qc,v 1.87 2005/04/24 20:03:02 slotzero Exp $

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

float DEVELOPER_MODE = 1;

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

void (entity e)
client_ping =
{
	local float i, ping;
	local string s;

	for (i = 0 ; i < %16 ; i = i + %1)
		ping = ping + (e.cl[CL_PING_TIMES + i] * 1000);

	ping = rint (ping / 16);
	if (ping > 9999)
		ping = 9999;

	s = ftos (ping);
	self_sprintf_len (world, s, 4);
};

void ()
client_ping_times =
{
	local entity e;

	dprint_force ("Client ping times:\n");

	e = find (world, classname, "player");
	while (e)
	{
		client_ping (e);
		dprint_force (" ");
		dprint_force (e.netname);
		dprint_force ("\n");
		e = find (e, classname, "player");
	}
};

void ()
pqc_team_reset =
{
	WriteByte(MSG_ALL, SVC_STUFFTEXT);
	WriteByte(MSG_ALL, 1); // init
	WriteByte(MSG_ALL, 6); // command
	WriteString(MSG_ALL, string_null);

	WriteByte(MSG_ALL, 17);
	WriteByte(MSG_ALL, 0);
	WriteByte(MSG_ALL, 17);
};

void (entity e, float tm)
pqc_erase_team =
{
	local float msg_type;

	if (e == world)
		msg_type = MSG_ALL;
	else
	{
		msg_entity = e;
		msg_type = MSG_ONE;
	}

	WriteByte(msg_type, SVC_STUFFTEXT);
	WriteByte(msg_type, 1); // init
	WriteByte(msg_type, 3); // case pqc_erase_team
	WriteByte(msg_type, 15 + tm); //team
	WriteString(msg_type, string_null);
};

void (entity e, float tm)
pqc_new_team =
{
	local float msg_type;

	if (e == world)
		msg_type = MSG_ALL;
	else
	{
		msg_entity = e;
		msg_type = MSG_ONE;
	}

	WriteByte (msg_type, SVC_STUFFTEXT);
	WriteByte (msg_type, 1); // MOD_PROQUAKE
	WriteByte (msg_type, 2); // case pqc_new_team
	WriteByte (msg_type, 15 + tm); //team
	WriteByte (msg_type, 15 + tm); //team
	WriteString (msg_type, string_null);
};

void (float to, float f)
WriteShortPQ =
{
	local float i;

	if (f < 0)
		f = f + 65536;

	i = floor (f / 4096);
	f = f - (i * 4096);
	WriteByte (to, 16 + i);	// x 4096

	i = floor (f / 256);
	f = f - (i * 256);
	WriteByte (to, 16 + i);	// x 256

	i = floor (f / 16);
	f = f - (i * 16);
	WriteByte (to, 16 + i);	// x 16

	WriteByte (to, 16 + f);	// x 1
};

void (entity e, float tm, float tf)
pqc_team_frags =
{
	local float msg_type, i;

	if (!teamplay & TEAM_TEAM_MASK)
		return;

	if (e == world)
		msg_type = MSG_ALL;
	else
	{
		msg_entity = e;
		msg_type = MSG_ONE;
	}

	WriteByte (msg_type, SVC_STUFFTEXT);
	WriteByte (msg_type, 1); // MOD_PROQUAKE
	WriteByte (msg_type, 4); // case pqc_team_frags
	WriteByte (msg_type, 15 + tm); //team
	WriteShortPQ (msg_type, tf);
	WriteString (msg_type, string_null);
};

float (float c)
color_to_bit =
{
	local string s;

	     if (c ==  0)	return 1;
	else if (c ==  1)	return 2;
	else if (c ==  2)	return 4;
	else if (c ==  3)	return 8;
	else if (c ==  4)	return 16;
	else if (c ==  5)	return 32;
	else if (c ==  6)	return 64;
	else if (c ==  7)	return 128;
	else if (c ==  8)	return 256;
	else if (c ==  9)	return 512;
	else if (c == 10)	return 1024;
	else if (c == 11)	return 2048;
	else if (c == 12)	return 4096;
	else if (c == 13)	return 8192;
	else
	{
		dprint ("color_to_bit(): invalid color\n");
		return 0;
	}
};

/* float (float c)
color_to_teamfrags =
{
	     if (c ==  0)	return tf_1;
	else if (c ==  1)	return tf_2;
	else if (c ==  2)	return tf_3;
	else if (c ==  3)	return tf_4;
	else if (c ==  4)	return tf_5;
	else if (c ==  5)	return tf_6;
	else if (c ==  6)	return tf_7;
	else if (c ==  7)	return tf_8;
	else if (c ==  8)	return tf_9;
	else if (c ==  9)	return tf_10;
	else if (c == 10)	return tf_11;
	else if (c == 11)	return tf_12;
	else if (c == 12)	return tf_13;
	else if (c == 13)	return tf_14;
	else
	{
		dprint ("color_to_teamfrags(): invalid color\n");
		return 0;
	}
}; */

void (entity client)
teamscores_on =
{
	local entity e;
	local float i, bit, bits, e_teams, tf, msg_type;
	local string s;

	if (client == world)
		msg_type = MSG_ALL;
	else
	{
		msg_entity = client;
		msg_type = MSG_ONE;
 	}

	e_teams = enforced_teams ();

	if (e_teams > 1)
	{
		// name
		WriteByte (msg_type, SVC_UPDATENAME);
		WriteByte (msg_type, 0);
		s = color_to_name (TEAM_1 - 1);
		WriteString (msg_type, s);

		// frags
		WriteByte (msg_type, SVC_UPDATEFRAGS);
		WriteByte (msg_type, 0);
		tf = color_to_teamfrags (TEAM_1 - 1);
		if (tf == -23000) tf = 0;
		WriteShort (msg_type, tf);

		// color
		WriteByte(msg_type, SVC_UPDATECOLORS);
		WriteByte(msg_type, 0);
		WriteByte(msg_type, 16 * (TEAM_1 - 1) + (TEAM_1 - 1));


		// name
		WriteByte (msg_type, SVC_UPDATENAME);
		WriteByte (msg_type, 1);
		s = color_to_name (TEAM_2 - 1);
		WriteString (msg_type, s);

		// frags
		WriteByte (msg_type, SVC_UPDATEFRAGS);
		WriteByte (msg_type, 1);
		tf = color_to_teamfrags (TEAM_2 - 1);
		if (tf == -23000) tf = 0;
		WriteShort (msg_type, tf);

		// color
		WriteByte(msg_type, SVC_UPDATECOLORS);
		WriteByte(msg_type, 1);
		WriteByte(msg_type, 16 * (TEAM_2 - 1) + (TEAM_2 - 1));
	}

	// Add more team support here.

	if (e_teams)
		return;

	e = nextent (world);
	for (i = 0; i < 16; i = i + 1)
	{
		if (e.classname == "bodyque")
			return;

		if (e.cl[CL_ACTIVE] == %1)
		{
			bit = color_to_bit (e.team - 1);

			if (!bits & bit)
			{
				// name
				WriteByte (msg_type, SVC_UPDATENAME);
				WriteByte (msg_type, i);
				s = color_to_name (e.team - 1);
				WriteString (msg_type, s);

				// frags
				WriteByte (msg_type, SVC_UPDATEFRAGS);
				WriteByte (msg_type, i);
				tf = color_to_teamfrags (e.team - 1);
				if (tf == -23000) tf = 0;
				WriteShort (msg_type, tf);

				// color
				WriteByte(msg_type, SVC_UPDATECOLORS);
				WriteByte(msg_type, i);
				WriteByte(msg_type, e.cl[CL_COLORS] / %1);

				bits = bits | bit;
			}
			else
			{
				WriteByte (msg_type, SVC_UPDATENAME);
				WriteByte (msg_type, i);
				WriteString (msg_type, string_null);
			}
		}
		else
		{
			WriteByte (msg_type, SVC_UPDATENAME);
			WriteByte (msg_type, i);
			WriteString (msg_type, string_null);
		}

		e = nextent (e);
	}
};

void (entity client)
teamscores_off =
{
	local entity e;
	local float i, msg_type;

	if (client == world)
		msg_type = MSG_ALL;
	else
	{
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
			// name
			WriteByte (msg_type, SVC_UPDATENAME);
			WriteByte (msg_type, i);
			WriteString (msg_type, e.netname);

			// frags
			WriteByte (msg_type, SVC_UPDATEFRAGS);
			WriteByte (msg_type, i);
			WriteShort (msg_type, e.frags);

			// color
			WriteByte(msg_type, SVC_UPDATECOLORS);
			WriteByte(msg_type, i);
			WriteByte(msg_type, e.cl[CL_COLORS] / %1);
		}
		else
		{
			WriteByte (msg_type, SVC_UPDATENAME);
			WriteByte (msg_type, i);
			WriteString (msg_type, string_null);
		}

		e = nextent (e);
	}
};

void ()
Test_Button =
{
	SUB_Null ();
};
