/*  $Id: develop.qc,v 1.18 2003/06/12 00:43:46 slotzero Exp $

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

float (string s)
stof1 =
{
	local float n, ps, cmp, frac, tot, neg;
	local string ch, clean;

	&%116 = 0;
	ps = AddInt(AddInt(&s, PSTRING_TO_PQUAKEC), %-3);

	cmp = strlen (s);
	for (n = 0; n < cmp; n = n + 1)
	{
		&%113 = (*ps)[0];

		if (world[%5] == '-' && !n)
			neg = 1;
		else if (world[%5] == '.')
		{
			if (!tot)
				frac = -1;
			else
				frac = tot;
		}

		ch = ftoc (world[%5] / %1);
		if (ch)
		{
			clean = strcat (clean, ch);
			tot = tot + 1;
		}

		ps = AddInt (ps, %1);
	}
	ps = AddInt (ps, %3);

	if (frac)
	{
		if (frac < 0)
			frac = 0;

		frac = tot - frac;
		frac = eval_exponent (frac + 1);
	}

	n = stof (clean);

	if (frac)
		n = n / frac;

	if (neg)
		n = n - n * 2;

	return n;
};

float (string s)
stof2 =
{
	local float i, cmp, ps, pch, n, tot, frac, neg;
	local string clean, ch;

	ps = AddInt (AddInt (&s, PSTRING_TO_PQUAKEC), %-3);
	pch = AddInt (&"xxxx", PSTRING_TO_PQUAKEC);

	cmp = strlen (s);
	for (i = 0; i < cmp; i = i + 1)
	{
		(*pch)[%0] = (*ps)[%0];
		pch = AddInt (pch, %3);

		n = -1;
		ch = @AddInt (pch, PQUAKEC_TO_PSTRING);
		if (ch == ".")
		{
			if (!tot)
				frac = -1;
			else
				frac = tot;
		}
		else if (ch == "-" && !i)
			neg = 1;
		else
			n = ctof (ch);

		if (n > -1)
		{
			clean = strcat (clean, ch);
			tot = tot + 1;
		}

		pch = AddInt (pch, %-3);
		ps = AddInt (ps, %1);
	}

	if (frac)
	{
		if (frac < 0)
			frac = 0;

		frac = tot - frac;
		frac = eval_exponent (frac + 1);
	}

	tot = stof (clean);

	if (frac)
		tot = tot / frac;

	if (neg)
		tot = tot - tot * 2;

	return tot;
};

IN_POQ([-
/* float (string s)
stof =
{
	local float i, ps, pch, cmp, n, sum;

	ps = AddInt (AddInt (&s, PSTRING_TO_PQUAKEC), %-3);
	pch = AddInt (&"xxxx", PSTRING_TO_PQUAKEC);

	cmp = x = strlen (s);
	for (i = 0; i < cmp; i = i + 1)
	{
		(*pch)[%0] = (*ps)[%0];
		pch = AddInt (pch, %3);

		n = ctof (@AddInt (pch, PQUAKEC_TO_PSTRING));
		n = n * (eval_exponent (cmp - i));
		sum = sum + n;

		pch = AddInt (pch, %-3);
		ps = AddInt (ps, %1);
	}

	return sum;
}; */

float (string s)
stof =
{
	local float f, i, ps, cmp, sum;

	&%116 = 0;
	ps = AddInt(AddInt(&s, PSTRING_TO_PQUAKEC), %-3);

	cmp = strlen (s);
	for (i = 0; i < cmp; i = i + 1)
	{
		&%113 = (*ps)[0];

		f = atof (world[%5] / %1);
		f = f * (eval_exponent (cmp - i));
		sum = sum + f;

		ps = AddInt (ps, %1);
	}
	ps = AddInt (ps, %3);

	return sum;
};
-])

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

//if (n == asc || n == (98 + asc) || n == (128 + asc))
// &800, &%767, %176
