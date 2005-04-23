/*  $Id: develop.qc,v 1.86 2005/04/23 16:32:07 slotzero Exp $

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

	if (tf < 0)
		tf = tf + 65536;

	i = floor (tf / 4096);
	tf = tf - (i * 4096);
	WriteByte (msg_type, 16 + i);	// x 4096

	i = floor (tf / 256);
	tf = tf - (i * 256);
	WriteByte (msg_type, 16 + i);	// x 256

	i = floor (tf / 16);
	tf = tf - (i * 16);
	WriteByte (msg_type, 16 + i);	// x 16

	WriteByte (msg_type, 16 + tf);	// x 1


	WriteString (msg_type, string_null);
};

void ()
Test_Button =
{
	SUB_Null ();
};
