/*  $Id: develop.qc,v 1.64 2004/07/05 09:34:20 slotzero Exp $

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

float VOTE_IN_PROGRESS;

float (float vote_type)
vote_type_valid =
{
	if (vote_type == 1)
		return TRUE;
	if (vote_type == 2)
		return TRUE;
	if (vote_type == 3)
		return TRUE;

	return FALSE;
};

void ()
xvote_think =
{
	if (self.runevar)
	{
		// XXX Check each entity to see bit flags and msg only those who didn't vote
		bprint ("Request to ");
		bprint (self.classname);
		self.runevar = self.runevar - 1;
	}
	else
	{
		bprint ("Vote cancelled\n");
		VOTE_IN_PROGRESS = 0;
		remove (self);
		return;
	}
	self.nextthink = time + 5;
};

void (string class, string net)
xvote =
{
	local entity e;

	if (VOTE_IN_PROGRESS)
		return self_sprint (self, "a vote is already in progress!\n");

   	if (!vote_type_valid)
		return dprint ("vote: invalid vote type\n");

	VOTE_IN_PROGRESS = 1;

	//self.vote_flags = 1;	// move this to something else and remove it

	e		= spawn ();
	e.classname	= class;
	e.netname	= net; // levels
	e.runevar	= 3;
	e.think		= xvote_think;
	e.nextthink	= time + sys_ticrate;
};

void ()
Test_Button =
{
	SUB_Null ();
};
