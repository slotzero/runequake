
//-------------------------------------------------------------------
// OFFSETS FOR INTERNAL QUAKE.EXE DATA STRUCTURES
//-------------------------------------------------------------------

float SV_ACTIVE				;// = %0; - might need to change this for linux/mac
float SV_PAUSED				;// = %1; - might need to change this for linux/mac
float SV_LOADGAME			;// = %2; - might need to change this for linux/mac
float SV_TIME				;// = %4; - might need to change this for linux/mac
float SV_LASTCHECK			;// = %6; - might need to change this for linux/mac
float SV_LASTCHECKTIME			= %8;
float SV_NAME					= %10;
float SV_MODELNAME				= %26;
float SV_WORLDMODEL				= %42;
float SV_MODEL_PRECACHE			= %43;
float SV_MODELS					= %299;
float SV_SOUND_PRECACHE			= %555;
float SV_LIGHTSTYLES			= %811;
float SV_NUM_EDICTS				= %875;
float SV_MAX_EDICTS				= %876;
float SV_EDICTS					= %877;
float SV_STATE					= %878;
float SV_DATAGRAM				= %879;
float SV_DATAGRAM_BUF			= %884;
float SV_RELIABLE_DATAGRAM		= %1140;
float SV_RELIABLE_DATAGRAM_BUF	= %1145;
float SV_SIGNON					= %1401;
float SV_SIGNON_DATA			= %1403;
float SV_SIGNON_MAXSIZE			= %1404;
float SV_SIGNON_CURSIZE			= %1405;
float SV_SIGNON_BUF				= %1406;

float CL_ACTIVE			;// = %0; - might need to change this for linux/mac
float CL_SPAWNED		;// = %1; - might need to change this for linux/mac
float CL_DROPASAP		;// = %2; - might need to change this for linux/mac
float CL_PRIVILEGED		;// = %3; - might need to change this for linux/mac
float CL_SENDSIGNON		;// = %4; - might need to change this for linux/mac
float CL_LAST_MESSAGE		= %6;
float CL_NETCONNECTION		= %8;
float CL_CMD				= %9;
float CL_CMD_FORWARD		= %12;
float CL_CMD_SIDE			= %13;
float CL_CMD_UP				= %14;
float CL_WISHDIR			= %15;
float CL_MESSAGE			= %18;
float CL_MESSAGE_DATA		= %20;
float CL_MESSAGE_MAXSIZE	= %21;
float CL_MESSAGE_CURSIZE	= %22;
float CL_MSGBUF				= %23;
float CL_EDICT				= %2023;
float CL_NAME				= %2024;
float CL_COLORS				= %2032;
float CL_PING_TIMES			= %2033;
float CL_NUM_PINGS			= %2049;
float CL_SPAWN_PARMS		= %2050;
float CL_OLD_FRAGS			= %2066;

float QS_ADDR			;// = %4118; - might need to change this for linux/mac
float QS_IN_ADDR		;// = %4119; - might need to change this for linux/mac
float QS_ADDRESS		;// = %4122; - might need to change this for linux/mac

float PR_VERSION		= %0;
float PR_CRC			= %1;
float PR_OFS_STATEMENTS	= %2;
float PR_NUMSTATEMENTS	= %3;
float PR_OFS_GLOBALDEFS	= %4;
float PR_NUMGLOBALDEFS	= %5;
float PR_OFS_FIELDDEFS	= %6;
float PR_NUMFIELDDEFS	= %7;
float PR_OFS_FUNCTIONS	= %8;
float PR_NUMFUNCTIONS	= %9;
float PR_OFS_STRINGS	= %10;
float PR_NUMSTRINGS		= %11;
float PR_OFS_GLOBALS	= %12;
float PR_NUMGLOBALS		= %13;
float PR_ENTITYFIELDS	= %14;

//-------------------------------------------------------------------
// INTERNAL CONSTANTS
//-------------------------------------------------------------------

float PR_EDICT_SIZE;
float HUNK_SENTINAL = 0x1df001ed;
float ED_FREE	= %-24;

// big/little endian stuff
float NOALIGN;
float BIG_ENDIAN;
float B546L542;
float B542L546;
float B457L463;

// conversions
float PSTRING_TO_PQUAKEC;
float PQUAKEC_TO_PSTRING;
float PC_TO_PQUAKEC;
float PC_TO_PSTRING;
float PQUAKEC_TO_PC;
float PSTRING_TO_PC;

// progs header - SET BY COMPILER
entity progs;

// quake sv data structure
entity sv;

//-------------------------------------------------------------------
// HEXADECIMAL PRINTING FUNCTIONS
//-------------------------------------------------------------------

float (float i) NegInt;

string hex = "0":"1":"2":"3":"4":"5":"6":"7":"8":"9":"a":"b":"c":"d":"e":"f";

//
//  H E X  1 6
//
void (float i) hex16 = 
{
	local float d;
	d = floor(i / 4096);
	i = i - d * 4096;
	dprint(hex[d * %2]);
	d = floor(i / 256);
	i = i - d * 256;
	dprint(hex[d * %2]);
	d = floor(i / 16);
	i = i - d * 16;
	dprint(hex[d * %2], hex[i * %2]);
};

//
//  H E X  3 2
//
void (float i) hex32 = 
{
	local float high, low;

	&%544 = i;
	&B546L542 = %0;
	low = world[%112];
	&B542L546 = i;
	high = world[%112];

	hex16(high / %1);
	hex16(low / %1);

	local string s;
	if (high < %256)
		s = ftos(i / %1);
	else if (high > %65280)
		s = ftos(-1 * (NegInt(i) / %1));
	else
		s = ftos(low / %1);
	dprint("  (", s, ")\n");
};

//-------------------------------------------------------------------
// INTEGER ARITHMETIC
//-------------------------------------------------------------------

//
//  A D D  I N T
//
float (float a, float b) AddInt = 
{
	local vector va, vb, sum;

	&%544 = a;
	&B546L542 = %0;
	va_x = world[%112];
	&B542L546 = a;
	va_y = world[%112];

	&%544 = b;
	&B546L542 = %0;
	vb_x = world[%112];
	&B542L546 = b;
	vb_y = world[%112];

	sum = va + vb;
	if (sum_x > %65535)
	{
		sum_x = sum_x - %65536;
		sum_y = sum_y + %1;
	}
	&%544 = sum_x;
	&B546L542 = sum_y;
	return world[%112];
};

//
//  S U B  I N T
//
float (float a, float b) SubInt = 
{
	local vector va, vb, sum;

	&%544 = a;
	&B546L542 = %0;
	va_x = world[%112];
	&B542L546 = a;
	va_y = world[%112];

	&%544 = b;
	&B546L542 = %0;
	vb_x = world[%112];
	&B542L546 = b;
	vb_y = world[%112];

	vb_x = %65536 - vb_x;
	vb_y = %65535 - vb_y;
	if (vb_x > %65535)
	{
		vb_x = %0;
		vb_y = vb_y + %1;
	}

	sum = va + vb;
	if (sum_x > %65535)
	{
		sum_x = sum_x - %65536;
		sum_y = sum_y + %1;
	}
	&%544 = sum_x;
	&B546L542 = sum_y;
	return world[%112];
};

//
//  N E G  I N T
//
float (float a) NegInt = 
{
	local float high, low;

	&%544 = a;
	&B546L542 = %0;
	low = world[%112];
	&B542L546 = a;
	high = world[%112];

	low = %65536 - low;
	high = %65535 - high;
	if (low > %65535)
	{
		low = %0;
		high = high + %1;
	}
	&%544 = low;
	&B546L542 = high;
	return world[%112];
};

//-------------------------------------------------------------------
// STRING UTILITIES
//-------------------------------------------------------------------

//
//  F N S T R I N G
//
//  Print out the name of a function given a pointer to the function
//
void (float f) fnstring = 
{
	local float p;

	p = AddInt(&progs, progs[PR_OFS_FUNCTIONS]);
	p = AddInt(p, f * 36);
	dprint(@(*p)[%4], "\n");

};

//
//  S T R C P Y
//
//  Copy the source string to the destination string
//
float (string dst, string src) strcpy = 
{
	local float data, cursize;

	data = sv[SV_SIGNON_DATA];
	cursize = sv[SV_SIGNON_CURSIZE];

	sv[SV_SIGNON_CURSIZE] = 0;
	sv[SV_SIGNON_DATA] = AddInt(&dst, PSTRING_TO_PC);
	WriteString(MSG_INIT, src);

	sv[SV_SIGNON_DATA] = data;
	sv[SV_SIGNON_CURSIZE] = cursize;
};

//-------------------------------------------------------------------
// INITIALIZATION
//-------------------------------------------------------------------

//
//  I N T E R N A L  I N I T
//
void () InternalInit = 
{
	local float p, p2;

	&%548 = %0;
	&%550 = %1;

	BIG_ENDIAN = world[%113];
	if (BIG_ENDIAN)
	{
		dprint("Big Endian architecture detected\n");
		B542L546 = %542;
		B546L542 = %546;
		B457L463 = %457;
	}
	else
	{
		dprint("Little Endian architecture detected\n");
		B542L546 = %546;
		B546L542 = %542;
		B457L463 = %463;
	}

	PSTRING_TO_PQUAKEC = AddInt(&progs, progs[PR_OFS_STRINGS]);
	PQUAKEC_TO_PSTRING = NegInt(PSTRING_TO_PQUAKEC);
	p = AddInt(&mapname, PSTRING_TO_PQUAKEC);
	p2 = NegInt((*p)[%33]);
	PC_TO_PQUAKEC = AddInt(PSTRING_TO_PQUAKEC, p2);
	PC_TO_PSTRING = AddInt(PC_TO_PQUAKEC, PQUAKEC_TO_PSTRING);
	PQUAKEC_TO_PC = NegInt(PC_TO_PQUAKEC);
	PSTRING_TO_PC = NegInt(PC_TO_PSTRING);

	sv = *AddInt(p, %-40);

	PR_EDICT_SIZE = 4 * (progs[PR_ENTITYFIELDS] / %1) + 96;

	if ((BIG_ENDIAN && sv[%5]) || (!BIG_ENDIAN && sv[%4]))
	{
		dprint("Alignment detected\n");

		NOALIGN = 0;

		SV_ACTIVE			= %0;
		SV_PAUSED			= %1;
		SV_LOADGAME			= %2;
		SV_TIME				= %4;
		SV_LASTCHECK		= %6;

		CL_ACTIVE			= %0;
		CL_SPAWNED			= %1;
		CL_DROPASAP			= %2;
		CL_PRIVILEGED		= %3;
		CL_SENDSIGNON		= %4;

		QS_ADDR				= %4118;
		QS_IN_ADDR			= %4119;
		QS_ADDRESS			= %4122;
	}
	else
	{
		dprint("No alignment detected\n");

		NOALIGN = 1;

		SV_ACTIVE			= %2;
		SV_PAUSED			= %3;
		SV_LOADGAME			= %4;
		SV_TIME				= %5;
		SV_LASTCHECK		= %7;

		CL_ACTIVE			= %1;
		CL_SPAWNED			= %2;
		CL_DROPASAP			= %3;
		CL_PRIVILEGED		= %4;
		CL_SENDSIGNON		= %5;

		QS_ADDR				= %4117;
		QS_IN_ADDR			= %4118;
		QS_ADDRESS			= %4121;
	}
};

//--------------------------------------------------------------------
// HUNK STUFF
//--------------------------------------------------------------------

entity lasth, currh;

// Create some storage space for hunk names.
// NOTE: the two string constants *must* be different or only one of them 
// will be allocated with the /Od option is used.
//
string hunkname = "00000000";
string prevname = "00000001";

void () InitHunkSearch = 
{
	lasth = currh = *AddInt(&progs, %-16);
};

void (float h) GetHunkName = 
{
	local float p, p2;
	p = AddInt(&hunkname, PSTRING_TO_PQUAKEC);
	p2 = AddInt(&prevname, PSTRING_TO_PQUAKEC);
	(*p2)[%0] = (*p)[%0];
	(*p2)[%1] = (*p)[%1];
	(*p)[%0] = (*h)[%2];
	(*p)[%1] = (*h)[%3];
};

float (float h) PrintHunk = 
{
	local float samecount;
	local float samesize;
	local float h2;

	samecount = 0;
	samesize = 0;

	dprint("--- HUNK ---\n");

	h2 = h;
	while (1)
	{
		GetHunkName(h);
		if (hunkname == prevname && (!samecount || samesize == (*h)[%1]))
		{
			samecount = samecount + 1;
			samesize = (*h)[%1];
		}
		else
		{
			if (samecount)
			{
				dprint(ftos(samecount), " x ", prevname, " : ");
				dprint(ftos(samesize / %1), "\n");
			}
			samecount = 1;
			samesize = (*h)[%1];
		}
		if (prevname == "edicts")
			return h2;

		h = AddInt(h, (*h)[%1]);
	}
};

void () SearchHunk = 
{
	local float i;
	local string hname = "XXXXXXXX";
	local float p;

	p = AddInt(&hname, PSTRING_TO_PQUAKEC);

	dprint("-- SeachHunk --\n");

	currh = *AddInt(&currh, %-131072);
	for (i = %32764 ; i >= %0 ; i = i - %4)
	{
		if (*currh[i] == *HUNK_SENTINAL)
		{
			if (currh[i + %1] == SubInt(SubInt(&lasth, &currh), 4 * i))
			{
				(*p)[%0] = currh[i + %2];
				(*p)[%1] = currh[i + %3];
				dprint("found ", hname, "\n");
				lasth = *AddInt(&currh, 4 * i);
				if (hname == "zone")
				{
					PrintHunk(&lasth);
					dprint("Found start of hunk in ");
					dprint(ftos(framecount), " frames\n");
					lasth = *0;
					return;
				}
			}
		}
	}
};

