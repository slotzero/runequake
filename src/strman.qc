/*
    Copyright (C) 2001-2013  David 'Slot Zero' Roberts.

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
// STRING STORAGE
//-------------------------------------------------------------------

// strlen()
string STRING_256 =	"                                                                "
			"                                                                "
			"                                                                "
			"                                                               ";

// allocate_string_size() [source string -- do not overwrite!]
string STRING_257 =	"                                                                "
			"                                                                "
			"                                                                "
			"                                                                ";

// PlayerPreThink()
string READY_NAME_16 =	"READY_NAME_1601":"READY_NAME_1602":"READY_NAME_1603":"READY_NAME_1604":
			"READY_NAME_1605":"READY_NAME_1606":"READY_NAME_1607":"READY_NAME_1608":
			"READY_NAME_1609":"READY_NAME_1610":"READY_NAME_1611":"READY_NAME_1612":
			"READY_NAME_1613":"READY_NAME_1614":"READY_NAME_1615":"READY_NAME_1616";

//-------------------------------------------------------------------
// STRING MANIPULATION FUNCTIONS
//-------------------------------------------------------------------

//
//  S T R L E N _ Q C
//
//  Return the length of a string (&s must be positive and less than 2^24)
//
float (string s)
strlen_qc =
{
	local float i;

	i = %0;
	while (i < %256)
 	{
		if (s[i] == string_null)
			return i / %1;
		i = i + %1;
	}

	dprint ("strlen_qc(): string too big\n");

	return 0;
};

//
//  S T R L E N
//
//  Return the length of a string (s must be less than 256 characters)
//
float (string s)
strlen =
{
	IN_QW([-
		return strlen_qc (s);
	-])
	if (MOD_PROTOCOL)
		return xstof (s, 1);

	strcpy (STRING_256, s);
	return strlen_qc (STRING_256);
};

// base is the dword offset
// max is the highest base can go
// allocate_hunk holds the current position
float ALLOCATE_HUNK_BASE	= %3000;
float ALLOCATE_HUNK_MAX		= %4000;

float ALLOCATE_HUNK, ALLOCATE_HUNK_NEXT;

float (float bytes)
allocate_hunk =
{
	local float f, dword;

	f = bytes / 4;
	dword = ceil (f);
	if (dword == f)
		dword = dword + 1;
	dword = dword * %1;

	ALLOCATE_HUNK = ALLOCATE_HUNK_NEXT;
	if (ALLOCATE_HUNK_NEXT)
		ALLOCATE_HUNK_NEXT = ALLOCATE_HUNK_NEXT + dword;

	if (!ALLOCATE_HUNK_NEXT || ALLOCATE_HUNK_NEXT > ALLOCATE_HUNK_MAX)
	{
		ALLOCATE_HUNK = ALLOCATE_HUNK_BASE;
		ALLOCATE_HUNK_NEXT = ALLOCATE_HUNK_BASE + dword;
	}

	return ALLOCATE_HUNK;
};

string (float bytes)
allocate_string_size =
{
	local entity array;
	local float p, alloc_hunk;

	if (bytes < 1 || bytes > 255)
	{
		dprint ("allocate_string_size(): bytes < 1 or bytes > 255\n");
		return string_null;
	}

	alloc_hunk = allocate_hunk (bytes);
	array = Get_Hunk (HUNK_CONTEXT, alloc_hunk);
	if (!array)
	{
		dprint ("allocate_string_size(): array is null\n");
		return string_null;
	}

	p = AddInt (&array, PQUAKEC_TO_PSTRING);
	strcpy (@p, STRING_257[(256 - bytes) * %1]);

	return @p;
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
	local float p, len1, len2, total, alloc_hunk;
	local string dst;

	len1 = strlen (s1);
	if (!len1) s1 = string_null;

	len2 = strlen (s2);
	if (!len2) s2 = string_null;

	total = len1 + len2;
	if (!total) return string_null;

	alloc_hunk = allocate_hunk (total);
	hunk = Get_Hunk (HUNK_CONTEXT, alloc_hunk);
	if (!hunk) return string_null;

	dst = @AddInt(&hunk, PQUAKEC_TO_PSTRING);
	if (s1) strcpy (dst, s1);
	if (s2)
	{
		p = AddInt (&dst, len1 * %1);
		strcpy (@p, s2);
	}

	return dst;
};

//
//  S U B S T R
//
//  Extracts a substring out of 'expr'.  The substring is extracted starting
//  at 'offset' characters from the front of the string.  If 'length' is greater
//  than the remaining length of 'expr', everything to the end of the string is
//  returned.
//
string (string expr, float offset, float length)
substr =
{
	local entity hunk;
	local float i, p1, p2, alloc_hunk;

	if (offset < 0)
		return string_null;

	if (length <= 0)
		return string_null;

	i = strlen (expr);
	if (!i) return string_null;

	if (offset > i)
		return string_null;

	alloc_hunk = allocate_hunk (i);
	hunk = Get_Hunk (HUNK_CONTEXT, alloc_hunk);
	if (!hunk)
		return string_null;

	p1 = AddInt (&hunk, PQUAKEC_TO_PSTRING);
	strcpy (@p1, expr);

	p1 = AddInt (p1, offset * %1);
	if (length >= (i - offset))
		return @p1;

	p2 = AddInt (p1, length * %1);
	strcpy (@p2, string_null);

	return @p1;
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
	local float p1, p2, p3, len1, len2, alloc_hunk;

	if (offset < 0)
		return string_null;

	if (length < 0)
		return string_null;

	len1 = strlen (expr);
	if (!len1)
		return string_null;

	//  'if (replace)' always true when 'replace' not defined in qc
	if (replace != string_null)
	{
		len2 = strlen (replace);
		if (!len2)
			return string_null;
	}

	alloc_hunk = allocate_hunk (len1 + len2);
	hunk = Get_Hunk (HUNK_CONTEXT, alloc_hunk);
	if (!hunk)
		return string_null;

	p1 = p3 = AddInt (&hunk, PQUAKEC_TO_PSTRING);
	strcpy (@p1, expr);

	if (offset > len1) offset = len1;
	p1 = AddInt (p1, offset * %1);

	if (replace != string_null) strcpy (@p1, replace);
	p1 = AddInt (p1, len2 * %1);

	if (offset + length > len1)
		length = len1 - offset;

	p2 = AddInt (&expr, PSTRING_TO_PQUAKEC);
	p2 = AddInt (p2, (offset + length) * %1);
	p2 = AddInt (p2, PQUAKEC_TO_PSTRING);
	strcpy (@p1, @p2);

	return @p3;
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
	local float slen, side;
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
		space = allocate_string_size (max - slen);
		if (side)
			return strcat (s, space);
		else
			return strcat (space, s);
	}
	else if	(slen > max)
	{
		if (side)
			return substr (s, (slen - max), max);
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

IN_POQ([-
float (string s)
stof =
{
	if (MOD_PROTOCOL)
		return xstof (s);

	cvar_set ("skill", s);
	return cvar ("skill");
};
-])
