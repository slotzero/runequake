/*  $Id: match.qc,v 1.7 2005/04/29 22:29:00 slotzero Exp $

    Copyright (C) 2005  David 'Slot Zero' Roberts.

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

float ()
mode_match =
{
	if (!match)
		return FALSE;

	if (!teamplay & TEAM_MODE_MATCH)
		return FALSE;

	return TRUE;
};


// match is over
// match in progress
// waiting for players

void ()
match_pre_think =
{
	SUB_Null ();
};

void ()
reset_colors =
{
	self_stuffcmd (self.owner, "color 1\n");
	self_stuffcmd (self.owner, "color 0\n");
	remove (self);
};

void ()
match_observer =
{
	local entity e;

	e		= spawn ();
	e.owner		= self;
	e.think		= reset_colors;
	e.nextthink	= time + 0.5;
};
