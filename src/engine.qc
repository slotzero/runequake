/*  $Id: engine.qc,v 1.12 2003/12/27 05:13:19 slotzero Exp $

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

void (string s) bprint = { xbprint7 (PRINT_HIGH, s, string_null, string_null, string_null, string_null, string_null, string_null); };
void (string s, string s2) bprint2 = { xbprint7 (PRINT_HIGH, s, s2, string_null, string_null, string_null, string_null, string_null); };
void (string s, string s2, string s3) bprint3 = { xbprint7 (PRINT_HIGH, s, s2, s3, string_null, string_null, string_null, string_null); };
void (string s, string s2, string s3, string s4) bprint4 = { xbprint7 (PRINT_HIGH, s, s2, s3, s4, string_null, string_null, string_null); };
void (string s, string s2, string s3, string s4, string s5) bprint5 = { xbprint7 (PRINT_HIGH, s, s2, s3, s4, s5, string_null, string_null); };
void (string s, string s2, string s3, string s4, string s5, string s6) bprint6 = { xbprint7 (PRINT_HIGH, s, s2, s3, s4, s5, s6, string_null); };
void (string s, string s2, string s3, string s4, string s5, string s6, string s7) bprint7 = { xbprint7 (PRINT_HIGH, s, s2, s3, s4, s5, s6, s6); };

void (entity client, string s, string s2) self_sprint2 = { xself_sprint6 (client, PRINT_HIGH, s, s2, string_null, string_null, string_null, string_null); };
void (entity client, string s, string s2, string s3) self_sprint3 = { xself_sprint6 (client, PRINT_HIGH, s, s2, s3, string_null, string_null, string_null); };
void (entity client, string s, string s2, string s3, string s4) self_sprint4 = { xself_sprint6 (client, PRINT_HIGH, s, s2, s3, s4, string_null, string_null); };
void (entity client, string s, string s2, string s3, string s4, string s5) self_sprint5 = { xself_sprint6 (client, PRINT_HIGH, s, s2, s3, s4, s5, string_null); };
void (entity client, string s, string s2, string s3, string s4, string s5, string s6) self_sprint6 = { xself_sprint6 (client, PRINT_HIGH, s, s2, s3, s4, s5, s6); };
void (entity client, string s, string s2, string s3, string s4, string s5, string s6, string s7) self_sprint7 = { xself_sprint6 (client, PRINT_HIGH, s, s2, s3, s4, s5, s6); };
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

void (entity e)
trackvel =
{
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
	IN_POQ([-
		self.punchangle_x = -2;
	-], [-
		msg_entity = self;
		WriteByte (MSG_ONE, SVC_SMALLKICK);
	-])
};

void (float kick_size)
bigkick =
{
	IN_POQ([-
		if (!kick_size)
			kick_size = -4;
		self.punchangle_x = kick_size;
	-], [-
		if (0) kick_size = kick_size;	// prevent frikqcc compiler warning
		msg_entity = self;
		WriteByte (MSG_ONE, SVC_SMALLKICK);
	-])
};

void (entity e, float kick_size)
bigkick_e =
{
	local entity old_self;

	old_self = self;
	self = e;
	bigkick (kick_size);
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
