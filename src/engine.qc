// $Id: engine.qc,v 1.3 2002/06/16 00:28:47 slotzero Exp $
//
// Copyright (c) 2001, 2002 Rune Quake Development Team.  All rights reserved.
// See the file `Copying' in the distribution for terms.

// These are functions which vary based on the engine (POQ or QW).

IN_POQ([-

void (vector where, float set)
multicast =
{
	SUB_Null ();
};

//-----------------------------------------------------------------------------

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
	WriteCoord (MSG_BROADCAST, self.origin_x);
	WriteCoord (MSG_BROADCAST, self.origin_y);
	WriteCoord (MSG_BROADCAST, self.origin_z);
	multicast (self.origin, MULTICAST_PHS);
};

void (float s, float e)
write_cdtrack =
{
	WriteByte (MSG_ALL, SVC_CDTRACK);
	WriteByte (MSG_ALL, s);
	IN_POQ([-
		WriteByte (MSG_ALL, e);
	-])
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
