/*  $Id: develop.qc,v 1.11 2003/06/03 20:53:17 slotzero Exp $

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

float (string ch)
ctof =
{
	local float i;

	for (i = %0; i < %10; i = i + %1)
	{
		if (ch == hex[i * 2])
			return i / %1;
	}

	return -1;
};

float (float n)
eval_exponent =
{
	local float i;

	for (i = 1; n > 1; n = n - 1)
		i = i * 10;

	return i;
};

float (string s)
prepare_stof =
{
	local float i, cmp, ps, pch, n, n_tot, n_frac;
	local string s_clean, ch;

	ps = AddInt (AddInt (&s, PSTRING_TO_PQUAKEC), %-3);
	pch = AddInt (&"xxxx", PSTRING_TO_PQUAKEC);

	cmp = strlen (s);
	for (i = 0; i < cmp; i = i + 1)
	{
		(*pch)[%0] = (*ps)[%0];
		pch = AddInt (pch, %3);

		ch = @AddInt (pch, PQUAKEC_TO_PSTRING);
		if (ch == ".")
		{
			n_frac = n_tot;
			n = -1;
		}
		else
			n = ctof (ch);

		if (n != -1)
		{
			ch = @AddInt (pch, PQUAKEC_TO_PSTRING);
			s_clean = strcat (s_clean, ch);
			n_tot = n_tot + 1;
		}

		pch = AddInt (pch, %-3);
		ps = AddInt (ps, %1);
	}

	if (n_frac)
	{
		n_frac = n_tot - n_frac;
		n_frac = eval_exponent (n_frac + 1);
	}

	n_tot = stof (s_clean);

	if (n_frac)
		n_tot = n_tot / n_frac;

	return n_tot;
};

IN_POQ([-
float (string s)
stof =
{
	local float i, ps, pch, cmp, x, n, sum;

	ps = AddInt (AddInt (&s, PSTRING_TO_PQUAKEC), %-3);
	pch = AddInt (&"xxxx", PSTRING_TO_PQUAKEC);

	cmp = x = strlen (s);
	for (i = 0; i < cmp; i = i + 1)
	{
		(*pch)[%0] = (*ps)[%0];
		pch = AddInt (pch, %3);

		n = ctof (@AddInt (pch, PQUAKEC_TO_PSTRING));
		n = n * (eval_exponent (x));
		sum = sum + n;

		pch = AddInt (pch, %-3);
		ps = AddInt (ps, %1);
		x = x - 1;
	}

	return sum;
};
-])

string (float type, float offset)
Read_Hunk =
{
	local entity hunk;

	hunk = *AddInt(AddInt(&progs, %-16), type);
	if (*hunk[%0] != *HUNK_SENTINAL)
	{
		dprint ("Read_Hunk(): hunk != HUNK_SENTINAL\n");
		return string_null;
	}

	return @AddInt(AddInt(&hunk, 4 * offset), PQUAKEC_TO_PSTRING);
};

void (float type, float offset, string s)
Write_Hunk =
{
	local entity hunk;
	local string temp;

	hunk = *AddInt(AddInt(&progs, %-16), type);
	if (*hunk[%0] != *HUNK_SENTINAL)
		dprint ("Write_Hunk(): hunk != HUNK_SENTINAL\n");

	temp = @AddInt(AddInt(&hunk, 4 * offset), PQUAKEC_TO_PSTRING);
	strcpy (temp, s);
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
