/*  $Id: strman.qc,v 1.2 2003/04/14 00:56:20 slotzero Exp $

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

	dword	= (bytes / 4 + 1) * %1;
	for (i = %0; i < dword; i = i + %1)
		array[i] = (*p)[%0];

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
//  Concatenate 's1' and 's2'.
//
string (string s1, string s2)
strcat =
{
	local float s1_len, s2_len, pconcat, ps2, dword, i;
	local string concat;

	s1_len	= strlen (s1);
	s2_len	= strlen (s2);

	if (!s1_len || !s2_len || s1_len + s2_len > 255)
	{
		dprint ("strcat(): argument(s) is null or total length > 255\n");
		return string_null;
	}

	concat	= allocate_string_size (s1_len + s2_len);
	strcpy (concat, s1);

	s1_len	= s1_len * %1;
	pconcat	= AddInt (AddInt (&concat, PSTRING_TO_PQUAKEC), s1_len);
	ps2	= AddInt (&s2, PSTRING_TO_PQUAKEC);
	dword	= (s2_len / 4 + 1) * %1;

	for (i = %0; i < dword; i = i + %1)
		(*pconcat)[i] = (*ps2)[i];

	s1_len	= NegInt (SubInt (s1_len, s1_len * %2));
	pconcat	= AddInt (pconcat, s1_len);

	return @AddInt (pconcat, PQUAKEC_TO_PSTRING);
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
	local float p, psub, sublen;
	local string s, sub;

	if (offset < 0)
		return expr;

	s = allocate_string (expr);
	strcpy (s, expr);
	sub = s[offset * %1];
	if (length < 1)
		return sub;

	sublen = strlen (sub);
	if (length >= sublen)
		return sub;

	psub = AddInt (AddInt (&sub, PSTRING_TO_PQUAKEC), length * %1);
	p = AddInt (&string_null, PSTRING_TO_PQUAKEC);
	(*psub)[%0] = (*p)[%0];
	return sub;
};

//
//  S U B S T R _ R E P L A C E
//
//  Replace a substring in 's' with 'replace'.  The substring is extracted
//  starting at 'off' characters from the front of the string.  If 'len'
//  is zero or greater than the remaining length of 's', everything to the
//  end of the string is returned.
//
string (string s, float off, float len, string replace)
substr_replace =
{
	local string s1, s2;

	s1 = substr (s, 0, off);
	off = off + len;
	s2 = substr (s, off, 0);

	s1 = strcat (s1, replace);
	return strcat (s1, s2);
};

//
// F L E N
//
// Return 's' to the size of 'max'.  The string is right justified unless
// 'side' is true.
//
string (string s, float max, float side)
flen =
{
	local float i, slen;
	local string space;

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