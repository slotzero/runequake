/*  $Id: hunked.qc,v 1.9 2003/12/25 01:52:42 slotzero Exp $

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
// HUNK FUNCTIONS
//-------------------------------------------------------------------

float LAST_TIME_UPDATE;

float ()
server_time =
{	IN_QW(return 0;)
	local float i;

	i = Read_Hunk_Float (HUNK_CONTEXT, %10);
	i = i + floor (time - LAST_TIME_UPDATE);

	return i;
};

void ()
update_server_time =
{	IN_QW(return;)
	local float i;

	i = server_time ();
	Write_Hunk_Float (HUNK_CONTEXT, %10, i);
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

string ()
PQ_Version =
{
	local float i, ch, sum;
	local string format = "with proquake version 0.00";
	local string x;

	i = self.netconnection[QS_MOD] / %1;
	if (!i)
		return "with a non-proquake client";
	else if (i == 1)
		return "with an unknown proquake client";
	else if (i == 2)
		return "as a qsmack client";

	ch = floor (i / 4096);
	i = i - ch * 4096;
	sum = hex_ctof (hex[ch * %2]) * 16;
	ch = floor (i / 256);
	i = i - ch * 256;
	sum = sum + hex_ctof (hex[ch * %2]);
	ch = floor (sum / 10);
	x = ftos (ch);

	i = %22;
	strcpy (format[i], x);		i = i + %1;
	strcpy (format[i], ".");	i = i + %1;

	sum = sum - (ch * 10);
	x = ftos (sum);
	strcpy (format[i], x);		i = i + %1;
	strcpy (format[i], "0");

	return format;
};
