/*  $Id: customap.qc,v 1.13 2005/01/11 23:27:20 slotzero Exp $

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

float HUNK_CUSTOM_SMALL		= %200;
float HUNK_CUSTOM_MEDIUM	= %300;
float HUNK_CUSTOM_LARGE		= %400;

float (float levsize)
sized_customs_count =
{
	if	(levsize == 1)	return floor (Read_Hunk_Float (HUNK_CONTEXT, HUNK_CUSTOM_SMALL  + %99));
	else if	(levsize == 2)	return floor (Read_Hunk_Float (HUNK_CONTEXT, HUNK_CUSTOM_MEDIUM + %99));
	else if (levsize == 3)	return floor (Read_Hunk_Float (HUNK_CONTEXT, HUNK_CUSTOM_LARGE  + %99));
	else			return 0;
};

void (float levsize, float total)
update_customs_count =
{
	if	(levsize == 1)	Write_Hunk_Float (HUNK_CONTEXT, HUNK_CUSTOM_SMALL  + %99, total);
	else if	(levsize == 2)	Write_Hunk_Float (HUNK_CONTEXT, HUNK_CUSTOM_MEDIUM + %99, total);
	else if (levsize == 3)	Write_Hunk_Float (HUNK_CONTEXT, HUNK_CUSTOM_LARGE  + %99, total);
};

float (float levsize)
customs_hunk_pos =
{
	if	(levsize == 1)	return HUNK_CUSTOM_SMALL;
	else if	(levsize == 2)	return HUNK_CUSTOM_MEDIUM;
	else if	(levsize == 3)	return HUNK_CUSTOM_LARGE;
	else			return %0;
};

float ()
total_customs =
{
	local float i, total;

	total = 0;
	for (i = 1; i < 4; i = i + 1)
		total = total + sized_custom_count (i);
	return total;
};

float (float levsize)
customs_to_hunk =
{
	local float i, n, max, pos, total;
	local string level;

	max = sized_custom_count (levsize) * %1;
	if (!max)
		return 0;

	pos = customs_hunk_pos (levsize);
	if (!pos)
		return 0;

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
			Write_Hunk_Float (HUNK_CONTEXT, pos + i, n);
		}
	}
	update_customs_count (levsize, total);

	return total;
};

void (float levsize)
sized_customs_to_hunk =
{	IN_QW(return;)
	local float total;
	local string s;

	total = 0;

	// small
	if (!levsize || levsize == 1)
		total = total + customs_to_hunk (1);

	// medium
	if (!levsize || levsize == 2)
		total = total + customs_to_hunk (2);

	// large
	if (!levsize || levsize == 3)
		total = total + customs_to_hunk (3);

	if (!total)
		return;

	s = ftos (total);
	dprint_force (s);
	if (levsize)
	{
		dprint_force (" ");
		dprint_force (levsize_to_name (levsize));
	}
	dprint_force (" custom maps added to hunk\n");
};

string (float levsize, float pos)
remove_custom_from_hunk =
{
	local float hunk_pos, max, total;
	local float new_map, last_map;
	// local string new;

	// It's possible that there are custom levels, but none
	// for a particular levsize.  Rather then return string_null
	// and play a standard level, search for other custom levsizes.
	if (!sized_custom_count (levsize))
	{
		if (sized_custom_count (1))
			levsize = 1;
		else if (sized_custom_count (2))
			levsize = 2;
		else if (sized_custom_count (3))
			levsize = 3;
		else
			return string_null;
	}

	total = sized_customs_count (levsize);
	if (!total)
	{
		dprint ("No more maps for levsize, populating hunk\n");
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
	new_map = Read_Hunk_Float (HUNK_CONTEXT, hunk_pos + pos);

	if (*max != *pos)
	{
		// Replace current map in hunk with last map name in hunk.
		last_map = Read_Hunk_Float (HUNK_CONTEXT, hunk_pos + max);
		Write_Hunk_Float (HUNK_CONTEXT, hunk_pos + pos, last_map);
	}
	update_customs_count (levsize, total);

	return sized_custom (levsize, new_map);
};

void ()
custom_maps =
{
	if (noexit & NOEXIT_NO_CUSTOM_LEVELS)
		return;

	if (!total_customs ())
		return;

	sized_customs_to_hunk (0);
};

string (float levsize)
select_custom =
{
	local float i, nmaps, randomly;

	randomly = noexit & NOEXIT_RANDOMIZE;

	if (!total_customs ())
		return string_null;

	dprint ("select_custom()\n");

	if (levsize)
	{
		nmaps = sized_customs_count (levsize);
		if (!nmaps && !noexit & NOEXIT_CUSTOM_LEVELS_ONLY)
			return string_null;
		if (randomly)
		{
			i = ceil (random () * nmaps + 0.01);
			if (i > nmaps)
				i = nmaps;
			return remove_custom_from_hunk (levsize, i);
		}
		else
			return remove_custom_from_hunk (levsize, 0);
	}
	else
	{
		// XXX Do the checking in another function?
		i = ceil (random () * 3);
		if (i == 1)
		{
			nmaps = sized_customs_count (1);
			if (!nmaps)
			{
				nmaps = sized_customs_count (2);
				i = 2;
			}
			if (!nmaps)
			{
				nmaps = sized_customs_count (3);
				i = 3;
			}
			if (!nmaps)
				i = 1;
		}
		else if (i == 2)
		{
			nmaps = sized_customs_count (2);
			if (!nmaps)
			{
				nmaps = sized_customs_count (1);
				i = 1;
			}
			if (!nmaps)
			{
				nmaps = sized_customs_count (3);
				i = 3;
			}
			if (!nmaps)
				i = 2;
		}
		else
		{
			i = 3;
			nmaps = sized_customs_count (3);
			if (!nmaps)
			{
				nmaps = sized_customs_count (1);
				i = 1;
			}
			if (!nmaps)
			{
				nmaps = sized_customs_count (2);
				i = 2;
			}
			if (!nmaps)
				i = 3;
		}

		if (!nmaps)
		{
			sized_customs_to_hunk (0);
			nmaps = sized_customs_count (i);
		}

		randomly = ceil (random () * nmaps);
		return remove_custom_from_hunk (i, randomly);
	}
};

IN_QW([-
string ()
rand_custom_qw =
{
	local float i, tot;
	local string s;

	i = cvar_infokey ("random_custom");
	tot = total_customs ();

	i = i - 1;
	if (i <= 1 || i > tot)
		i = tot;

	s = ftos (i);
	cvar_set_infokey ("random_custom", s);

	return rand_custom (i);
};
-])
