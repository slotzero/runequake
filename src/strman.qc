/*  $Id: strman.qc,v 1.31 2004/12/25 00:42:28 slotzero Exp $

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
//  S T R I N G _ L E N G T H
//
//  Return the length of a string (&s must be positive and less than 2^24)
//
float (string s)
string_length =
{
	local float i;

	i = %0;
	while (i < %256)
 	{
		if (s[i] == string_null)
			return i / %1;
		i = i + %1;
	}

	dprint ("string_length(): string too big\n");
	return 0;
};

//
//  S T R L E N
//
//  Return the length of a string
//
float (string s)
strlen =
{
	IN_QW([-

	return string_length (s);

	-], [-
	local float i, ps;

	ps = AddInt (&s, PSTRING_TO_PQUAKEC);
	for (i = 0; i < 256; i = i + 1)
	{
		if (@AddInt (ps, PQUAKEC_TO_PSTRING) == string_null)
			return i;
		ps = AddInt (ps, %1);
	}

	dprint ("strlen(): string too big\n");

	-])

	return 0;
};

// base is the dword offset
// max is the highest base can go
// allocate_hunk holds the current position
float ALLOCATE_HUNK_BASE	= %3000;
float ALLOCATE_HUNK_MAX		= %4000;

float ALLOCATE_HUNK, ALLOCATE_HUNK_NEXT;

void (float bytes)
allocate_hunk =
{
	ALLOCATE_HUNK = ALLOCATE_HUNK_NEXT;
	if (ALLOCATE_HUNK_NEXT)
		ALLOCATE_HUNK_NEXT = ALLOCATE_HUNK_NEXT + (ceil (bytes / 4) * %1) + %1;

	if (!ALLOCATE_HUNK_NEXT || ALLOCATE_HUNK_NEXT > ALLOCATE_HUNK_MAX)
	{
		ALLOCATE_HUNK = ALLOCATE_HUNK_BASE;
		ALLOCATE_HUNK_NEXT = ALLOCATE_HUNK_BASE + (ceil (bytes / 4) * %1) + %1;
	}
};

string (float bytes)
allocate_string_size =
{
	local entity array;
	local float p, i, dword;

	if (bytes < 1 || bytes > 255)
	{
		dprint ("allocate_string_size(): bytes < 1 or bytes > 255\n");
		return string_null;
	}

	allocate_hunk (bytes);
	array = Get_Hunk (HUNK_CONTEXT, ALLOCATE_HUNK);
	p	= AddInt (&"    \{0}   ", PSTRING_TO_PQUAKEC);

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
	else
		array[i] = (*p)[%1];

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
//  Concatenate string
//
string (string s1, string s2)
strcat =
{
	local entity hunk;
	local float L1, L2, total, alloc_hunk;

	if (s1)
	{
		L1 = strlen (s1);
		if (!L1) s1 = string_null;
	}
	if (s2)
	{
		L2 = strlen (s2);
		if (!L2) s2 = string_null;
	}

	total = L1 + L2;
	if (!total) return string_null;

	allocate_hunk (total);
	alloc_hunk = ALLOCATE_HUNK;
	hunk = Get_Hunk (HUNK_CONTEXT, alloc_hunk);
	if (!hunk) return string_null;

	if (s1) { Write_Hunk_e (hunk, s1); }
	if (s2) { hunk = *AddInt (L1 * %1, &hunk); Write_Hunk_e (hunk, s2); }

	return Read_Hunk_String (HUNK_CONTEXT, alloc_hunk);
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
	local entity hunk;
	local float i;
	local string s;

	if (!length)
		return string_null;
	else if (offset < 0)
		offset = fabs (offset);

	i = strlen (expr);
	if (!i)
	{
		dprint ("substr(): expr < 1 or expr > 255\n");
		return string_null;
	}

	if (offset > i)
		return expr;

	allocate_hunk (i);
	hunk = Get_Hunk (HUNK_CONTEXT, ALLOCATE_HUNK);
	if (!hunk)
		return string_null;

	Write_Hunk_e (hunk, expr);

	hunk = *AddInt (&hunk, offset * %1);
	s = Read_Hunk_e (hunk);

	if (length < 0)
		length = fabs (length);

	i = i - offset;
	if (length >= i)
		return s;

 	hunk = *AddInt (&hunk, length * %1);
	Write_Hunk_e (hunk, string_null);

	return s;
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
	local entity hunk;
	local float L1, L2, alloc_hunk;
	local string s;

	L1 = strlen (expr);
	if (!L1)
	{
		dprint ("substr_replace(): expr < 1 or expr > 255\n");
		return string_null;
	}

	L2 = strlen (replace);

	allocate_hunk (L1 + L2);
	alloc_hunk = ALLOCATE_HUNK;
	hunk = Get_Hunk (HUNK_CONTEXT, alloc_hunk);
	if (!hunk)
		return string_null;

	Write_Hunk_e (hunk, expr);

	if (offset)
	{
		if (offset < 0)
			offset = fabs (offset);
		if (offset > L1)
			offset = L1;
		hunk = *AddInt (&hunk, offset * %1);
	}

	if (replace)
	{
		Write_Hunk_e (hunk, replace);
		hunk = *AddInt (L2 * %1, &hunk);
	}

	if (length)
	{
		if (length < 0)
			length = fabs (length);
		if (length > L1)
			length = L1;
	}

	if (offset + length <= L1)
		L1 = offset + length;

 	s = @AddInt (AddInt (AddInt (&expr, PSTRING_TO_PQUAKEC), L1 * %1), PQUAKEC_TO_PSTRING);
	Write_Hunk_e (hunk, s);

	return Read_Hunk_String (HUNK_CONTEXT, alloc_hunk);
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
		if (f < 0) return 0;
		f = f * (eval_exponent (cmp - i));
		sum = sum + f;

		ps = AddInt (ps, %1);
	}
	ps = AddInt (ps, %3);

	return sum;
};
-])
