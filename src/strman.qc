/*  $Id: strman.qc,v 1.16 2003/07/06 00:29:04 slotzero Exp $

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
// STRING MANIPULATION FUNCTIONS
//-------------------------------------------------------------------

//
//  S T R L E N
//
//  Return the length of a string
//
float (string s)
strlen =
{
	local float i, ps;

	i = %0;
	while (i < %256)
 	{
		if (s[i] == string_null)
			return i / %1;
		i = i + %1;
	}

	ps = AddInt (&s, PSTRING_TO_PQUAKEC);
	for (i = 0; i < 256; i = i + 1)
	{
		if (@AddInt (ps, PQUAKEC_TO_PSTRING) == string_null)
			return i;
		ps = AddInt (ps, %1);
	}

	dprint ("strlen(): length > 255\n");
	return 0;
};

string (float bytes)
allocate_string_size =
{
	local entity e, array;
	local float p, i, dword;

	if (bytes < 1 || bytes > 255)
	{
		dprint ("allocate_string_size(): bytes < 1 or bytes > 255\n");
		return string_null;
	}

	e	= spawn ();
	array	= *(&e + %600);
	p	= AddInt (&"    ", PSTRING_TO_PQUAKEC);

	dword	= floor (bytes / 4) * %1;
	while (bytes > 3)
		bytes = bytes - 4;

	for (i = %0; i < dword; i = i + %1)
		array[i] = (*p)[%0];

 	if (bytes)
	{
		p = AddInt (p, (4 - bytes) * %1);
		array[i] = (*p)[%0];
 	}

	remove (e);
	return (@AddInt (&array, PQUAKEC_TO_PSTRING));
};

string (string s)
allocate_string =
{
	return allocate_string_size (strlen (s));
};

//
//  S T R C A T
//

string (string s1, string s2, string s3, string s4, string s5, string s6, string s7)
strcat7 =
{
	local entity hunk;
	local float max;

	max = %16200;

	if (!(hunk = Get_Hunk (HUNK_CONTEXT, max)))
		return string_null;

	if (s1) { Write_Hunk_e (hunk, s1); hunk = *AddInt (strlen (s1) * %1, &hunk);}
	if (s2) { Write_Hunk_e (hunk, s2); hunk = *AddInt (strlen (s2) * %1, &hunk);}
	if (s3) { Write_Hunk_e (hunk, s3); hunk = *AddInt (strlen (s3) * %1, &hunk);}
	if (s4) { Write_Hunk_e (hunk, s4); hunk = *AddInt (strlen (s4) * %1, &hunk);}
	if (s5) { Write_Hunk_e (hunk, s5); hunk = *AddInt (strlen (s5) * %1, &hunk);}
	if (s6) { Write_Hunk_e (hunk, s6); hunk = *AddInt (strlen (s6) * %1, &hunk);}
	if (s7) { Write_Hunk_e (hunk, s7); hunk = *AddInt (strlen (s7) * %1, &hunk);}

	Write_Hunk_e (hunk, string_null);

	return Read_Hunk (HUNK_CONTEXT, max);
};

string (string s1, string s2, string s3, string s4, string s5, string s6)
strcat6 =
{
	return strcat7 (s1, s2, s3, s4, s5, s6, string_null);
};

string (string s1, string s2, string s3, string s4, string s5)
strcat5 =
{
	return strcat7 (s1, s2, s3, s4, s5, string_null, string_null);
};

string (string s1, string s2, string s3, string s4)
strcat4 =
{
	return strcat7 (s1, s2, s3, s4, string_null, string_null, string_null);
};

string (string s1, string s2, string s3)
strcat3 =
{
	return strcat7 (s1, s2, s3, string_null, string_null, string_null, string_null);
};

string (string s1, string s2)
strcat =
{
	return strcat7 (s1, s2, string_null, string_null, string_null, string_null, string_null);
};

//
//  S U B S T R
//
//  Extracts a substring out of 'expr'.  The substring is extracted starting
//  at 'offset' characters from the front of the string.  If 'length' is zero
//  or greater than the remaining length of 'expr', everything to the end of
//  the string is returned.
//
string (string expr, float offset, float length)
substr =
{
	local float sub_length;
	local string s, sub;

	if (offset < 0)
		return expr;

	s = allocate_string (expr);
	strcpy (s, expr);
	sub = s[offset * %1];
	if (length < 1)
		return sub;

	sub_length = strlen (sub);
	if (length >= sub_length)
		return sub;

	strcpy (s[(length + offset) * %1], string_null);

	return sub;
};

//
//  S U B S T R _ R E P L A C E
//
//  Replace a substring in 'expr' with 'replace'.  The substring is replaced
//  starting at 'offset' characters from the front of the string.  If 'length'
//  is zero, 'replace' is inserted at 'offset'.
//
string (string expr, float offset, float length, string replace)
substr_replace =
{
	local string s1, s2;

	s1 = substr (expr, 0, offset);
	offset = offset + length;
	s2 = substr (expr, offset, 0);
	s1 = strcat (s1, replace);

	return strcat (s1, s2);
};

//
//  F L E N
//
//  Return 's' to the size of 'max'.  If 'max' is negative, the string is left
//  justified.
//
string (string s, float max)
flen =
{
	local float i, slen, side;
	local string space;

	if (max < 0)
	{
		side = 1;
		max = fabs (max);
	}

	slen = strlen (s);
	if (slen == max)
		return s;
	else if (slen < max)
	{
		i = max - slen;
		space = allocate_string_size (max);
		space = substr (space, 0, i);
		if (side)
			return strcat (s, space);
		else
			return strcat (space, s);
	}
	else if	(slen > max)
	{
		i = slen - max;
		if (side)
			return substr (s, i, 0);
		else
			return substr (s, 0, max);
	}
	return string_null;
};

float (string ch)
hex_ctof =
{
	local float i;

	for (i = %0; i < %16; i = i + %1)
	{
		if (ch == hex[i * 2])
			return i / %1;
	}

	return -1;
};

float (string ch)
dec_ctof =
{
	local float i;

	for (i = %0; i < %10; i = i + %1)
	{
		if (ch == hex[i * 2])
			return i / %1;
	}

	return -1;
};

string (float n)
atoc =
{
	local float i, asc;

	i = %0;
	for (asc = 48; asc < 58; asc = asc + 1)
	{
		if (n == asc)
			return hex[i * 2];

		i = i + %1;
	}

	return string_null;
};

float (float n)
atof =
{
	local float i, asc;

	i = 0;
	for (asc = 48; asc < 58; asc = asc + 1)
	{
		if (n == asc)
			return i;

		i = i + 1;
	}

	return 0;
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
stof_any =
{
	local float n, ps, cmp, frac, tot, neg;
	local string ch, clean;

	&%116 = 0;
	ps = AddInt(AddInt(&s, PSTRING_TO_PQUAKEC), %-3);

	cmp = strlen (s);
	for (n = 0; n < cmp; n = n + 1)
	{
		&%113 = (*ps)[0];

		if (world[%5] == '-' && !tot)
			neg = 1;
		else if (world[%5] == '.')
		{
			if (!tot)
				frac = -1;
			else
				frac = tot;
		}

		ch = atoc (world[%5] / %1);
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

IN_POQ([-
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
