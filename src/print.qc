// $Id: print.qc,v 1.4 2002/06/15 19:27:29 slotzero Exp $

//=============================================================================
// bprint

void (float n)
bprint_float =
{
	local string s;

	s = ftos (n);
	bprint (s);
};

void (vector v)
bprint_vec =
{
	local string s;

	s = vtos (v);
	bprint (s);
};

void (string s)
bprint_timestamp =
{
	local string sx;

	sx = s;
	bprint_float (time);
	bprint (" ");
	bprint (sx);
	bprint ("\n");
};

//=============================================================================
// dprint

void (float n)
dprint_float =
{
	local string s;

	s = ftos (n);
	dprint (s);
};

void (vector v)
dprint_vec =
{
	local string s;

	s = vtos (v);
	dprint (s);
};

void (string s)
force_dprint =
{
	local float developer;

	developer = cvar ("developer");
	if (developer == 0)
	{
		cvar_set ("developer", "1");
		dprint (s);
		cvar_set ("developer", "0");
	}
	else
		dprint (s);
};

void (string s, float i)
dprint_bitfield =
{
	dprint (s);
	dprint (": ");
	if (i < 0)
		dprint ("negative ");
	dprint_float (i);

	if (i & 0.5)		dprint (" -1 (0.5)");
	if (i & 1)		dprint (" 1 (1)");
	if (i & 2)		dprint (" 2 (2)");
	if (i & 4)		dprint (" 3 (4)");
	if (i & 8)		dprint (" 4 (8)");
	if (i & 16)		dprint (" 5 (16)");
	if (i & 32)		dprint (" 6 (32)");
	if (i & 64)		dprint (" 7 (64)");
	if (i & 128)		dprint (" 8 (128)");
	if (i & 256)		dprint (" 9 (256)");
	if (i & 512)		dprint (" 10 (512)");
	if (i & 1024)		dprint (" 11 (1024)");
	if (i & 2048)		dprint (" 12 (2048)");
	if (i & 4096)		dprint (" 13 (4096)");
	if (i & 8192)		dprint (" 14 (8192)");
	if (i & 16384)		dprint (" 15 (16384)");
	if (i & 32768)		dprint (" 16 (32768)");
	if (i & 65536)		dprint (" 17 (65536)");
	if (i & 131072)		dprint (" 18 (131072)");
	if (i & 262144)		dprint (" 19 (262144)");
	if (i & 524288)		dprint (" 20 (524288)");
	if (i & 1048576)	dprint (" 21 (1048576)");
	if (i & 2097152)	dprint (" 22 (2097152)");
	if (i & 4194304)	dprint (" 23 (4194304)");
	if (i & 8388608)	dprint (" 24 (8388608)");
	if (i & 16777216)	dprint (" 25 (16777216)");
	if (i & 33554432)	dprint (" 26 (33554432)");
	if (i & 67108864)	dprint (" 27 (67108864)");
	if (i & 134217728)	dprint (" 28 (134217728)");
	if (i & 268435456)	dprint (" 29 (268435456)");
	if (i & 536870912)	dprint (" 30 (536870912)");
	// The bit ops failed for numbers larger than 32 bits, the division
	// works arounds it.
	i = i / 2; if (i & 536870912)	dprint (" 31 (1073741824)");
	i = i / 2; if (i & 536870912)	dprint (" 32 (2147483648)");
	i = i / 2; if (i & 536870912)	dprint (" 33 (4294967296)");
	i = i / 2; if (i & 536870912)	dprint (" 34 (8589934592)");
	i = i / 2; if (i & 536870912)	dprint (" 35 (17179869184)");
	i = i / 2; if (i & 536870912)	dprint (" 36 (34359738368)");
	i = i / 2; if (i & 536870912)	dprint (" 37 (68719476736)");
	i = i / 2; if (i & 536870912)	dprint (" 38 (137438953472)");
	i = i / 2; if (i & 536870912)	dprint (" 39 (274877906944)");
	i = i / 2; if (i & 536870912)	dprint (" 40 (549755813888)");
	i = i / 2; if (i & 536870912)	dprint (" 41 (1099511627776)");
	i = i / 2; if (i & 536870912)	dprint (" 42 (2199023255552)");
	i = i / 2; if (i & 536870912)	dprint (" 43 (4398046511104)");

	dprint ("\n");
};

//=============================================================================
// centerprint

void (entity e, string s1, string s2, string s3, string s4, string s5, string s6, string s7)
centerprint7 =
{
	local entity o;

	self_centerprint (e, s1, s2, s3, s4, s5, s6, s7);
	if (!in_hud_hack && e.classname == "player")
		e.cnt = time + CENTERPRINT_TIME;
	if (!in_runedesc_hack && e.classname == "player" && e.waitmax)
	{
		if (e.waitmax > 0)
			e.waitmax = time + CENTERPRINT_TIME;
		else
			e.waitmax = 0;
	}
	if (!e.aqstate & AQS_HAS_RIDERS)
		return;
	o = find (world, classname, "player");
	while (o)
	{
		if (ridee_e (o) == e && !aq_menu_get_e (o))
			self_centerprint (o, s1, s2, s3, s4, s5, s6, s7);
		o = find (o, classname, "player");
	}
};

void (entity e, string s1, string s2, string s3, string s4, string s5, string s6)
centerprint6 =
{
	centerprint7 (e, s1, s2, s3, s4, s5, s6, string_null);
};

void (entity e, string s1, string s2, string s3, string s4, string s5)
centerprint5 =
{
	centerprint7 (e, s1, s2, s3, s4, s5, string_null, string_null);
};

void (entity e, string s1, string s2, string s3, string s4)
centerprint4 =
{
	centerprint7 (e, s1, s2, s3, s4, string_null, string_null, string_null);
};

void (entity e, string s1, string s2, string s3)
centerprint3 =
{
	centerprint7 (e, s1, s2, s3, string_null, string_null, string_null, string_null);
};

void (entity e, string s1, string s2)
centerprint2 =
{
	centerprint7 (e, s1, s2, string_null, string_null, string_null, string_null, string_null);
};

void (entity e, string s1)
centerprint =
{
	centerprint7 (e, s1, string_null, string_null, string_null, string_null, string_null, string_null);
};

//=============================================================================
// rprint

void (entity e, float riders, string s1, string s2, string s3, string s4, string s5)
rprint5 =
{
	if (riders)
		sprint5 (e, s1, s2, s3, s4, s5);
	else
		self_sprint5 (e, s1, s2, s3, s4, s5);
};

void (entity e, float riders, string s1, string s2, string s3, string s4)
rprint4 =
{
	rprint5 (e, riders, s1, s2, s3, s4, string_null);
};

void (entity e, float riders, string s1, string s2, string s3)
rprint3 =
{
	rprint5 (e, riders, s1, s2, s3, string_null, string_null);
};

void (entity e, float riders, string s1, string s2)
rprint2 =
{
	rprint5 (e, riders, s1, s2, string_null, string_null, string_null);
};

void (entity e, float riders, string s1)
rprint =
{
	rprint5 (e, riders, s1, string_null, string_null, string_null, string_null);
};

void (entity e, float riders, float n)
rprint_float =
{
	local string s;

	s = ftos (n);
	rprint (e, riders, s);
};

void (entity pe, float riders, entity e)
rprint_entity =
{
	if (!e)
		rprint (pe, riders, "(null)");
	else if (e.netname)
		rprint (pe, riders, e.netname);
	else
		rprint (pe, riders, e.classname);
};

void (entity e, float riders, float n, string s)
rprint_numdesc =
{
	rprint_float (e, riders, n);
	rprint (e, riders, " ");
	rprint (e, riders, s);
	if (n != 1)
		rprint (e, riders, "s");
};

//=============================================================================
// sprint

void (entity e, string s1, string s2, string s3, string s4, string s5, string s6, string s7)
sprint7 =
{
	local entity o;

	if (!e)
	{
		bprint7 (s1, s2, s3, s4, s5, s6, s7);
		return;
	}
	self_sprint7 (e, s1, s2, s3, s4, s5, s6, s7);
	if (!e.aqstate & AQS_HAS_RIDERS)
		return;
	o = find (world, classname, "player");
	while (o)
	{
		if (ridee_e (o) == e)
			self_sprint7 (o, s1, s2, s3, s4, s5, s6, s7);
		o = find (o, classname, "player");
	}
};

void (entity e, string s1, string s2, string s3, string s4, string s5, string s6)
sprint6 =
{
	sprint7 (e, s1, s2, s3, s4, s5, s6, string_null);
};

void (entity e, string s1, string s2, string s3, string s4, string s5)
sprint5 =
{
	sprint7 (e, s1, s2, s3, s4, s5, string_null, string_null);
};

void (entity e, string s1, string s2, string s3, string s4)
sprint4 =
{
	sprint7 (e, s1, s2, s3, s4, string_null, string_null, string_null);
};

void (entity e, string s1, string s2, string s3)
sprint3 =
{
	sprint7 (e, s1, s2, s3, string_null, string_null, string_null, string_null);
};

void (entity e, string s1, string s2)
sprint2 =
{
	sprint7 (e, s1, s2, string_null, string_null, string_null, string_null, string_null);
};

void (entity e, string s1)
sprint =
{
	sprint7 (e, s1, string_null, string_null, string_null, string_null, string_null, string_null);
};

void (entity e, float n)
sprint_float =
{
	local string s;

	s = ftos (n);
	sprint (e, s);
};

void (entity e, entity of_e)
sprint_entity =
{
	if (!of_e)
		sprint (e, "(null)");
	else if (of_e.netname)
		sprint (e, of_e.netname);
	else
		sprint (e, of_e.classname);
};

void (string s1, string s2)
sprint_admin2 =
{
	local entity e;

	e = find (world, classname, "player");
	while (e)
	{
		if (is_admin_e (e))
			self_sprint2 (e, s1, s2);
		e = find (e, classname, "player");
	}
};

void (string s1)
sprint_admin =
{
	sprint_admin2 (s1, string_null);
};

void (string s1, string s2)
sprint_obs2 =
{
	local entity e;

	e = find (world, classname, "player");
	while (e)
	{
		if (is_observer_e (e))
			self_sprint2 (e, s1, s2);
		e = find (e, classname, "player");
	}
};

// Print an integer number right-justified in the given width.
void (entity e, float n, float width)
sprint_int_f =
{
	local float len, i;
	local string s;

	n = floor (n);
	len = 0;
	i = n;
	if (i < 0)
	{
		len = len + 1;
		i = 0 - i;
	}
	while (i >= 10)
	{
		len = len + 1;
		i = floor (i / 10);
	}
	len = len + 1;	// units
	while (len < width)
	{
		sprint (e, " ");
		len = len + 1;
	}
	s = ftos (n);
	sprint (e, s);
};

// Print a number with the given number of units and decimal places.
//
// XXX This doesn't round.
void (entity e, float n, float int_w, float frac_w)
sprint_float_f =
{
	local float whole, i;

	if (n < 0)
	{
		sprint (e, "-");
		n = 0 - n;
	}

	whole = floor (n);
	n = n - whole;
	if (int_w)
		sprint_int_f (e, whole, int_w);
	else
		sprint_float (e, whole);
	sprint (e, ".");

	i = frac_w;
	while (i > 0)
	{
		i = i - 1;
		n = n * 10;
		whole = floor (n);
		n = n - whole;
		sprint_float (e, whole);
	}
};

//=============================================================================
// self_sprint

void (entity e, float n)
self_sprint_float =
{
	local string s;

	s = ftos (n);
	self_sprint (e, s);
};

void (entity e, float b)
self_sprint_boolean =
{
	if (b)
		self_sprint (e, "on ");
	else
		self_sprint (e, "off");
};

void (entity e, float n, float int_w, float frac_w)
self_sprint_float_f =
{
	local float whole, i;

	if (n < 0)
	{
		self_sprint (e, "-");
		n = 0 - n;
	}

	whole = floor (n);
	n = n - whole;
	if (int_w)
		sprint_int_f (e, whole, int_w);
	else
		self_sprint_float (e, whole);
	self_sprint (e, ".");

	i = frac_w;
	while (i > 0)
	{
		i = i - 1;
		n = n * 10;
		whole = floor (n);
		n = n - whole;
		self_sprint_float (e, whole);
	}
};

void (entity e, string s, float i)
self_sprint_bitfield =
{
	self_sprint (e, s);
	self_sprint (e, ": ");
	if (i < 0)
		self_sprint (e, "negative ");
	self_sprint_float (e, i);

	if (i & 0.5)		self_sprint (e, " -1 (0.5)");
	if (i & 1)		self_sprint (e, " 1 (1)");
	if (i & 2)		self_sprint (e, " 2 (2)");
	if (i & 4)		self_sprint (e, " 3 (4)");
	if (i & 8)		self_sprint (e, " 4 (8)");
	if (i & 16)		self_sprint (e, " 5 (16)");
	if (i & 32)		self_sprint (e, " 6 (32)");
	if (i & 64)		self_sprint (e, " 7 (64)");
	if (i & 128)		self_sprint (e, " 8 (128)");
	if (i & 256)		self_sprint (e, " 9 (256)");
	if (i & 512)		self_sprint (e, " 10 (512)");
	if (i & 1024)		self_sprint (e, " 11 (1024)");
	if (i & 2048)		self_sprint (e, " 12 (2048)");
	if (i & 4096)		self_sprint (e, " 13 (4096)");
	if (i & 8192)		self_sprint (e, " 14 (8192)");
	if (i & 16384)		self_sprint (e, " 15 (16384)");
	if (i & 32768)		self_sprint (e, " 16 (32768)");
	if (i & 65536)		self_sprint (e, " 17 (65536)");
	if (i & 131072)		self_sprint (e, " 18 (131072)");
	if (i & 262144)		self_sprint (e, " 19 (262144)");
	if (i & 524288)		self_sprint (e, " 20 (524288)");
	if (i & 1048576)	self_sprint (e, " 21 (1048576)");
	if (i & 2097152)	self_sprint (e, " 22 (2097152)");
	if (i & 4194304)	self_sprint (e, " 23 (4194304)");
	if (i & 8388608)	self_sprint (e, " 24 (8388608)");
	if (i & 16777216)	self_sprint (e, " 25 (16777216)");
	if (i & 33554432)	self_sprint (e, " 26 (33554432)");
	if (i & 67108864)	self_sprint (e, " 27 (67108864)");
	if (i & 134217728)	self_sprint (e, " 28 (134217728)");
	if (i & 268435456)	self_sprint (e, " 29 (268435456)");
	if (i & 536870912)	self_sprint (e, " 30 (536870912)");
	// The bit ops failed for numbers larger than 32 bits, the division
	// works arounds it.
	i = i / 2; if (i & 536870912)	self_sprint (e, " 31 (1073741824)");
	i = i / 2; if (i & 536870912)	self_sprint (e, " 32 (2147483648)");
	i = i / 2; if (i & 536870912)	self_sprint (e, " 33 (4294967296)");
	i = i / 2; if (i & 536870912)	self_sprint (e, " 34 (8589934592)");
	i = i / 2; if (i & 536870912)	self_sprint (e, " 35 (17179869184)");
	i = i / 2; if (i & 536870912)	self_sprint (e, " 36 (34359738368)");
	i = i / 2; if (i & 536870912)	self_sprint (e, " 37 (68719476736)");
	i = i / 2; if (i & 536870912)	self_sprint (e, " 38 (137438953472)");
	i = i / 2; if (i & 536870912)	self_sprint (e, " 39 (274877906944)");
	i = i / 2; if (i & 536870912)	self_sprint (e, " 40 (549755813888)");
	i = i / 2; if (i & 536870912)	self_sprint (e, " 41 (1099511627776)");
	i = i / 2; if (i & 536870912)	self_sprint (e, " 42 (2199023255552)");
	i = i / 2; if (i & 536870912)	self_sprint (e, " 43 (4398046511104)");

	self_sprint (e, "\n");
};
