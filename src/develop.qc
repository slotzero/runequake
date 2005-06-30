/*  $Id: develop.qc,v 1.103 2005/06/30 00:10:20 slotzero Exp $

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

void (entity e)
sprint_eff_player =
{
	local float i;
	local string s;

	self_sprintf_len (self, e.netname, -15);

	// shells
	i = rint ((e.shell_dmg / e.shell_dmg_max) * 100);

	self_sprint (self, "\{252}");

	if (!e.shell_dmg_max)
		self_sprint (self, "N/A");
	else if (i < 100)
	{
		s = ftos (i);
		self_sprintf_len (self, s, 2);
		self_sprint (self, "%");
	}
	else
		self_sprint (self, "100");

	// nails
	i = rint ((e.nail_dmg / e.nail_dmg_max) * 100);

	self_sprint (self, "\{252}");

	if (!e.nail_dmg_max)
		self_sprint (self, "N/A");
	else if (i < 100)
	{
		s = ftos (i);
		self_sprintf_len (self, s, 2);
		self_sprint (self, "%");
	}
	else
		self_sprint (self, "100");

	// rockets
	i = rint ((e.rocket_dmg / e.rocket_dmg_max) * 100);

	self_sprint (self, "\{252}");

	if (!e.rocket_dmg_max)
		self_sprint (self, "N/A");
	else if (i < 100)
	{
		s = ftos (i);
		self_sprintf_len (self, s, 2);
		self_sprint (self, "%");
	}
	else
		self_sprint (self, "100");

	// cells
	i = rint ((e.cell_dmg / e.cell_dmg_max) * 100);

	self_sprint (self, "\{252}");

	if (!e.rocket_dmg_max)
		self_sprint (self, "N/A");
	else if (i < 100)
	{
		s = ftos (i);
		self_sprintf_len (self, s, 2);
		self_sprint (self, "%");
	}
	else
		self_sprint (self, "100");

	// total
	i = rint (((e.shell_dmg + e.nail_dmg + e.rocket_dmg + e.cell_dmg)
			/ (e.shell_dmg_max + e.nail_dmg_max + e.rocket_dmg_max + e.cell_dmg_max)) * 100);

	self_sprint (self, "\{252}");

	if (e == self)
		self_sprint (self, "\[");
	else
		self_sprint (self, " ");

	if (!(e.shell_dmg_max + e.nail_dmg_max + e.rocket_dmg_max + e.cell_dmg_max))
		self_sprint (self, "N/A");
	else if (i < 100)
	{
		s = ftos (i);
		self_sprintf_len (self, s, 2);
		self_sprint (self, "%");
	}
	else
		self_sprint (self, "100");

	if (e == self)
		self_sprint (self, "\]");
	else
		self_sprint (self, " ");

	self_sprint (self, "\n");
};

void ()
sprint_efficiency =
{
	local entity e;
	local float i, total;
	local string s;

	self_sprint (self, "\n     name      \{252}bul\{252}nls\{252}rox\{252}lg \{252}total\n");
	self_sprint (self, "\b---------------+---+---+---+---+-----\n");

	e = find (world, classname, "player");
	while (e)
	{
		sprint_eff_player (e);
		e = find (e, classname, "player");
	}
};

void ()
Test_Button =
{
	SUB_Null ();
};
