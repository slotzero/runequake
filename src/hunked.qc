/*  $Id: hunked.qc,v 1.4 2003/07/08 05:12:34 slotzero Exp $

    Copyright (C) 2001, 2002  David 'Slot Zero' Roberts.

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

float ()
server_time =
{
	local float i;

	i = stof (Read_Hunk_Max (HUNK_CONTEXT, %10, 8));
	i = i + floor (time - LAST_TIME_UPDATE);

	return i;
};

void ()
update_server_time =
{
	local string s;

	s = ftos (server_time ());
	Write_Hunk_Max (HUNK_CONTEXT, %10, s, 8);
	LAST_TIME_UPDATE = time;
};
