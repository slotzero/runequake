/*  $Id: hunked.qc,v 1.5 2003/07/11 02:44:18 slotzero Exp $

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

string (float n)
parse_time =
{
	local float i, hours, minutes, seconds;
	local string format = "0000:00:00";
	local string x;

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
