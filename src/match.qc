/*  $Id: match.qc,v 1.5 2005/04/29 06:58:00 slotzero Exp $

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
	local string s;

	if (self.pants)
	{
		if (self.team != self.pants)
		{
			self_sprint (self, "You are already committed\n");
			self_stuffcmd (self, "color ");

			// make this a function
			s = ftos (self.shirt - 1);
			self_stuffcmd (self, s);
			self_stuffcmd (self, " ");
			s = ftos (self.pants - 1);
			self_stuffcmd (self, s);
			self_stuffcmd (self, "\n");
		}
	}
};
