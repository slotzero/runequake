/*  $Id: customap.qc,v 1.1 2003/10/26 08:04:44 slotzero Exp $

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

float (float levsize)
sized_customs_count =
{
	if (levsize == 1)	return floor (Read_Hunk_Float (HUNK_CONTEXT, %21));
	else if (levsize == 2)	return floor (Read_Hunk_Float (HUNK_CONTEXT, %22));
	else if (levsize == 3)	return floor (Read_Hunk_Float (HUNK_CONTEXT, %23));
	else			return floor (Read_Hunk_Float (HUNK_CONTEXT, %20));
};

void (float levsize, float total)
update_customs_count =
{
	if (levsize == 1)	Write_Hunk_Float (HUNK_CONTEXT, %21, total);
	else if (levsize == 2)	Write_Hunk_Float (HUNK_CONTEXT, %22, total);
	else if (levsize == 3)	Write_Hunk_Float (HUNK_CONTEXT, %23, total);
	else			Write_Hunk_Float (HUNK_CONTEXT, %20, total);
};

float (float levsize)
customs_hunk_pos =
{
	if (levsize == 1)	return %1000;
	else if (levsize == 2)	return %2000;
	else			return %3000;
};

float (float levsize, float pos)
customs_to_hunk =
{
	local float i, n, max, total;
	local string level;

	max = sized_custom_count (levsize) * %1;

	total = 0;
	for (i = %0; i < max; i = i + %1)
	{
		n = (i / %1) + 1;
		level = sized_custom (levsize, n);
		if (level == string_null)
			i = max;
		else
		{
			total = total + 1;
			if (pos)
				Write_Hunk (HUNK_CONTEXT, pos + (i * 3), level);
		}
	}
	return total;
};

void (float levsize)
sized_customs_to_hunk =
{
	local float i, pos, total;

	total = 0;

	// small
	if (!levsize || levsize == 1)
	{
		pos = customs_hunk_pos (1);
		i = customs_to_hunk (1, pos);
		update_customs_count (1, i);
		total = i;
	}

	// medium
	if (!levsize || levsize == 2)
	{
		pos = customs_hunk_pos (2);
		i = customs_to_hunk (2, pos);
		update_customs_count (2, i);
		total = total + i;
	}

	// large
	if (levsize == 3 || !levsize)
	{
		pos = customs_hunk_pos (3);
		i = customs_to_hunk (3, pos);
		update_customs_count (3, i);
		total = total + i;
	}

	// all
	if (!levsize)
		update_customs_count (0, total);

	dprint_float (total);
	if (levsize)
	{
		dprint (" ");
		dprint (levsize_to_name (levsize));
	}
	dprint (" custom maps added to hunk\n");
};

string (float levsize, float pos)
remove_custom_from_hunk =
{
	local float hunk_pos, max, total;
	local string new;

	if (levsize < 1 || levsize > 3)
		levsize = 1;

	total = sized_customs_count (levsize);
	if (!total)
	{
		dprint ("No more maps for size, refreshing hunk\n");
		sized_customs_to_hunk (levsize);
		total = sized_customs_count (levsize);
	}

	total = total - 1;
	max = total * %1;
	pos = pos * %1;
	hunk_pos = customs_hunk_pos (levsize);

	if (pos > max || pos < %0)
		pos = max;

	// Store current in hunk.
	new = Read_Hunk (HUNK_CONTEXT, hunk_pos + (pos * 3));
	Write_Hunk (HUNK_CONTEXT, %30, new);

	if (*max != *pos)
	{
		// Replace current map in hunk with last map name in hunk.
		new = Read_Hunk (HUNK_CONTEXT, hunk_pos + (max * 3));
		Write_Hunk (HUNK_CONTEXT, hunk_pos + (pos * 3), new);
	}
	update_customs_count (levsize, total);

	return Read_Hunk_Max (HUNK_CONTEXT, %30, 12);
};

void ()
custom_maps =
{
	if (noexit & NOEXIT_NO_CUSTOM_LEVELS)
		return;

	sized_customs_to_hunk (0);
};
