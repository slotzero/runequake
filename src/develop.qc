/*  $Id: develop.qc,v 1.19 2003/06/12 21:06:49 slotzero Exp $

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

float DEVELOPER_MODE = 0;

void ()
Test_Button =
{
	SUB_Null ();
};

void (float n)
parse_time =
{
	local float hours, minutes, seconds;

	seconds	= floor (n);
	minutes	= floor (seconds / 60);
	hours	= floor (minutes / 60);
	seconds	= seconds - floor (minutes * 60);
	minutes	= minutes - floor (hours * 60);

	if (hours)
	{
		bprint_float (hours);
		bprint (":");
		if (minutes < 10) bprint ("0");
	}
	bprint_float (minutes);
	bprint (":");
	if (seconds < 10) bprint ("0");
	bprint_float (seconds);
};
