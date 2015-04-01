/*
    Copyright (C) 1998-2001  Roderick Schertler.

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

// These are functions which vary based on the engine (POQ or QW).

IN_POQ([-

void (vector where, float set)
multicast =
{
	// Prevent frikqcc warnings.
	if (0) { where = VEC_ORIGIN; set = FALSE; }

	SUB_Null ();
};

//-----------------------------------------------------------------------------
-], [-
//-----------------------------------------------------------------------------

void (string s) bprint = { xbprint (PRINT_HIGH, s); };
void (string s, string s2) bprint2 = { xbprint (PRINT_HIGH, s, s2); };
void (string s, string s2, string s3) bprint3 = { xbprint (PRINT_HIGH, s, s2, s3); };
void (string s, string s2, string s3, string s4) bprint4 = { xbprint (PRINT_HIGH, s, s2, s3, s4); };
void (string s, string s2, string s3, string s4, string s5) bprint5 = { xbprint (PRINT_HIGH, s, s2, s3, s4, s5); };
void (string s, string s2, string s3, string s4, string s5, string s6) bprint6 = { xbprint (PRINT_HIGH, s, s2, s3, s4, s5, s6); };
void (string s, string s2, string s3, string s4, string s5, string s6, string s7) bprint7 = { xbprint (PRINT_HIGH, s, s2, s3, s4, s5, s6, s6); };

void (entity client, string s, string s2) self_sprint2 = { xself_sprint (client, PRINT_HIGH, s, s2); };
void (entity client, string s, string s2, string s3) self_sprint3 = { xself_sprint (client, PRINT_HIGH, s, s2, s3); };
void (entity client, string s, string s2, string s3, string s4) self_sprint4 = { xself_sprint (client, PRINT_HIGH, s, s2, s3, s4); };
void (entity client, string s, string s2, string s3, string s4, string s5) self_sprint5 = { xself_sprint (client, PRINT_HIGH, s, s2, s3, s4, s5); };
void (entity client, string s, string s2, string s3, string s4, string s5, string s6) self_sprint6 = { xself_sprint (client, PRINT_HIGH, s, s2, s3, s4, s5, s6); };
void (entity client, string s, string s2, string s3, string s4, string s5, string s6, string s7) self_sprint7 = { xself_sprint (client, PRINT_HIGH, s, s2, s3, s4, s5, s6); };

void ()
update_deathmatch =
{
	deathmatch = cvar ("deathmatch");
};
-])

void (float type, entity e, vector o1, vector o2)
create_te_lightning =
{
	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, type);
	WriteEntity (MSG_BROADCAST, e);
	WriteCoord (MSG_BROADCAST, o1_x);
	WriteCoord (MSG_BROADCAST, o1_y);
	WriteCoord (MSG_BROADCAST, o1_z);
	WriteCoord (MSG_BROADCAST, o2_x);
	WriteCoord (MSG_BROADCAST, o2_y);
	WriteCoord (MSG_BROADCAST, o2_z);
	multicast (o1, MULTICAST_PHS);
};

void (vector o, float become)
create_te_explosion =
{
	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_EXPLOSION);
	WriteCoord (MSG_BROADCAST, o_x);
	WriteCoord (MSG_BROADCAST, o_y);
	WriteCoord (MSG_BROADCAST, o_z);
	multicast (o, MULTICAST_PHS);

	if (become)
	{
		IN_POQ([-
			BecomeExplosion ();
		-], [-
			remove (self);
		-])
	}
};

void (vector o)
create_te_lavasplash =
{
	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_LAVASPLASH);
	WriteCoord (MSG_BROADCAST, o_x);
	WriteCoord (MSG_BROADCAST, o_y);
	WriteCoord (MSG_BROADCAST, o_z);
	multicast (o, MULTICAST_PHS);
};

void (vector o, float c)
create_te_gunshot =
{
	IN_POQ([-
		while (c > 0)
		{
	-])
			WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
			WriteByte (MSG_BROADCAST, TE_GUNSHOT);
			IN_QW([-
				WriteByte (MSG_BROADCAST, c);
			-])
			WriteCoord (MSG_BROADCAST, o_x);
			WriteCoord (MSG_BROADCAST, o_y);
			WriteCoord (MSG_BROADCAST, o_z);
			multicast (o, MULTICAST_PVS);
	IN_POQ([-
			c = c - 1;
		}
	-])
};

IN_QW([-

void (vector o, float c)
create_te_blood =
{
	WriteByte (MSG_MULTICAST, SVC_TEMPENTITY);
	WriteByte (MSG_MULTICAST, TE_BLOOD);
	WriteByte (MSG_MULTICAST, c);
	WriteCoord (MSG_MULTICAST, o_x);
	WriteCoord (MSG_MULTICAST, o_y);
	WriteCoord (MSG_MULTICAST, o_z);
	multicast (o, MULTICAST_PVS);
};

// This has more orange than normal blood, and might scatter less.

void (vector o)
create_te_lightningblood =
{
	WriteByte (MSG_MULTICAST, SVC_TEMPENTITY);
	WriteByte (MSG_MULTICAST, TE_LIGHTNINGBLOOD);
	WriteCoord (MSG_MULTICAST, o_x);
	WriteCoord (MSG_MULTICAST, o_y);
	WriteCoord (MSG_MULTICAST, o_z);
	multicast (trace_endpos, MULTICAST_PVS);
};

-])

void (vector o)
create_te_teleport =
{
	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_TELEPORT);
	WriteCoord (MSG_BROADCAST, o_x);
	WriteCoord (MSG_BROADCAST, o_y);
	WriteCoord (MSG_BROADCAST, o_z);
	multicast (o, MULTICAST_PHS);
};

// Purple tarbaby explosion, in QW including sound.

void (vector o)
create_te_tarexplosion =
{
	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_TAREXPLOSION);
	WriteCoord (MSG_BROADCAST, o_x);
	WriteCoord (MSG_BROADCAST, o_y);
	WriteCoord (MSG_BROADCAST, o_z);
	multicast (o, MULTICAST_PVS);
};

void (float type, vector o)
create_te_spike =
{
	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, type);
	WriteCoord (MSG_BROADCAST, o_x);
	WriteCoord (MSG_BROADCAST, o_y);
	WriteCoord (MSG_BROADCAST, o_z);
	multicast (self.origin, MULTICAST_PHS);
};

void (entity targ)
set_viewport =
{
	IN_POQ([-
		if (self == targ)
			self.viewentity = world;
		else
			self.viewentity = targ;

		msg_entity = self;
		WriteByte (MSG_ONE, SVC_SETVIEWPORT);
		WriteEntity (MSG_ONE, targ);
	-], [-
		if (0) targ = targ;	// prevent frikqcc compiler warning
		SUB_Null ();
	-])
};

void (entity e)
trackvel =
{
	if (0) e = e; // frikqcc compiler warning
	IN_QW([-
		self.velocity = e.velocity;
	-])
};

// Return a variable which is a cvar in POQ but not in QW (so I keep it
// as an infokey).

float (string var)
cvar_infokey =
{
	return IN_POQ([-
		cvar (var)
	-], [-
		stof (infokey (world, var))
	-]);
};

void (string var, string val)
cvar_set_infokey =
{
	IN_POQ([-
		cvar_set (var, val);
	-], [-
		localcmd ("serverinfo ");
		localcmd (var);
		localcmd (" ");
		localcmd (val);
		localcmd ("\n");
	-])
};

void ()
muzzleflash =
{
	IN_POQ([-
		self.effects = self.effects | EF_MUZZLEFLASH;
	-], [-
		WriteByte (MSG_MULTICAST, SVC_MUZZLEFLASH);
		WriteEntity (MSG_MULTICAST, self);
		multicast (self.origin, MULTICAST_PVS);
	-])
};

void ()
smallkick =
{
	IN_QW([-
		msg_entity = self;
		WriteByte (MSG_ONE, SVC_SMALLKICK);
	-])
};

void ()
bigkick =
{
	IN_QW([-
		msg_entity = self;
		WriteByte (MSG_ONE, SVC_SMALLKICK);
	-])
};

void (entity e)
bigkick_e =
{
	local entity old_self;

	old_self = self;
	self = e;
	bigkick ();
	self = old_self;
};

float ()
samelevel_same_level =
{
	IN_POQ([-
		return cvar ("samelevel") & 1;
	-], [-
		return cvar ("samelevel") == 1;
	-])
};

// Don't call any of the svc functions inside of ClientDisconnect() because
// it will overwrite the engine's own svc updates.
void (float msg_type, float edict_num, string s)
svc_updatename =
{
	WriteByte (msg_type, SVC_UPDATENAME);
	WriteByte (msg_type, edict_num);
	WriteString (msg_type, s);
};

void (float msg_type, float edict_num, float f)
svc_updatefrags =
{
	WriteByte (msg_type, SVC_UPDATEFRAGS);
	WriteByte (msg_type, edict_num);
	WriteShort (msg_type, f);
};

void (float msg_type, float edict_num, float f)
svc_updatecolors =
{
	WriteByte (msg_type, SVC_UPDATECOLORS);
	WriteByte (msg_type, edict_num);
	WriteByte (msg_type, f);
};

//-------------------------------------------------------------------
// PROQUAKE BUILT-IN FEATURES
//-------------------------------------------------------------------

void (float to, float f)
WriteBytePQ =
{	IN_QW(return;)
	WriteByte (to, 16 + f / 16);
	WriteByte (to, 16 + f & 15);
};

void (float to, float f)
WriteShortPQ =
{	IN_QW(return;)
	local float i;

	i = floor (f / 4096);
	WriteBytePQ (to, i * 16 + (f & 3840 / 256));
	WriteBytePQ (to, f & 255);
};

void (entity e, float c)
pqc_new_team =
{	IN_QW(return;)
	local float msg_type;

	if (e.cl[CL_ACTIVE] == %1)
	{
		msg_entity = e;
		msg_type = MSG_ONE;
	}
	else
		msg_type = MSG_ALL;

	WriteByte (msg_type, SVC_STUFFTEXT);
	WriteByte (msg_type, 1);
	WriteByte (msg_type, PQC_NEW_TEAM);
	WriteByte (msg_type, 16 + c & 15); // pants
	WriteByte (msg_type, 16 + c / 16); // shirt
	WriteString (msg_type, string_null);
};

void (float tm)
pqc_erase_team =
{	IN_QW(return;)
	WriteByte (MSG_ALL, SVC_STUFFTEXT);
	WriteByte (MSG_ALL, 1);
	WriteByte (MSG_ALL, PQC_ERASE_TEAM);
	WriteByte (MSG_ALL, 16 + tm);
	WriteString (MSG_ALL, string_null);
};

void (entity e, float tm, float tf)
pqc_team_frags =
{	IN_QW(return;)
	local float msg_type;

	if (e.cl[CL_ACTIVE] == %1)
	{
		msg_entity = e;
		msg_type = MSG_ONE;
	}
	else
		msg_type = MSG_ALL;

	if (tf < 0)
		tf = tf + 65536;

	WriteByte (msg_type, SVC_STUFFTEXT);
	WriteByte (msg_type, 1);
	WriteByte (msg_type, PQC_TEAM_FRAGS);
	WriteByte (msg_type, 16 + tm);	// team
	WriteShortPQ (msg_type, tf);	// frags
	WriteString (msg_type, string_null);
};

void (entity e, float m, float s)
pqc_match_time =
{	IN_QW(return;)
	local float msg_type;

	// sync +teamscores
	if (!e)
		teamscores_update ();

	if (e.cl[CL_ACTIVE] == %1)
	{
		msg_entity = e;
		msg_type = MSG_ONE;
	}
	else
		msg_type = MSG_ALL;

	if (s < 0)
		s = fabs (s) + 128;

	WriteByte (msg_type, SVC_STUFFTEXT);
	WriteByte (msg_type, 1);
	WriteByte (msg_type, PQC_MATCH_TIME);
	WriteBytePQ (msg_type, m); // minutes
	WriteBytePQ (msg_type, s); // seconds
	WriteString (msg_type, string_null);
};

void ()
pqc_match_reset =
{	IN_QW(return;)
	WriteByte (MSG_ALL, SVC_STUFFTEXT);
	WriteByte (MSG_ALL, 1);
	WriteByte (MSG_ALL, PQC_MATCH_RESET);
	WriteString (MSG_ALL, string_null);
};

void ()
pqc_ping_times =
{	IN_QW(return;)

	local entity e;
	local float i, ping;

	WriteByte (MSG_ALL, SVC_STUFFTEXT);
	WriteByte (MSG_ALL, 1);
	WriteByte (MSG_ALL, PQC_PING_TIMES);

	e = world;
	for (i = 0; i < 16; i = i + 1)
	{
		e = nextent (e);
		if (e.classname == "bodyque")
			i = 16;
		else if (e.cl[CL_ACTIVE] == %1 && e.delay)
		{
			ping = e.delay;
			if (ping > 4095)
				ping = 666;
			WriteShortPQ (MSG_ALL, ping + (i * 4096));
		}
	}

	WriteShortPQ (MSG_ALL, 0);
	WriteString (MSG_ALL, string_null);
};
