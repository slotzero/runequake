/*  $Id: client.qc,v 1.59 2004/07/18 10:25:39 slotzero Exp $

    Copyright (C) 1996, 1997  Id Software, Inc.

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

float modelindex_eyes, modelindex_player;

/*
=============================================================================

				LEVEL CHANGING / INTERMISSION

=============================================================================
*/

/*QUAKED info_intermission (1 0.5 0.5) (-16 -16 -16) (16 16 16)
This is the camera point for the intermission.
Use mangle instead of angle, so you can set pitch or roll as well as yaw.  'pitch roll yaw'
*/
void ()
info_intermission =
{
};

// SetNewParms() is called both by me and by the game.  It's called by
// the game for fully new players.  When I call it I always call this
// directly after.  I also call this from SetChangeParms().

void ()
persistent_parms =
{
	//if (self.aqflags & AQ_ADMIN)
	//	parm1 = parm1 | IT_KEYx;
	parm11 = self.aqflags - self.aqflags & AQ_HOOK;
	parm14 = self.rqflags;
};

void ()
SetChangeParms =
{
	// Prevent SetNewParms() for dead phoenix rune holders.
	if (self.health <= 0 && self.runetype == RN_PHOENIX)
		self.health = 100;

	if (self.health <= 0 || SET_PARMS_WITH_NEW_LEVEL)
	{
		SetNewParms ();
		persistent_parms ();
		return;
	}

	switchfire_off ();
	// remove items
	self.items = self.items
		- self.items & (IT_KEY1 | IT_KEY2 | IT_INVISIBILITY
				| IT_INVULNERABILITY | IT_SUIT | IT_QUAD
				| IT_SUPERHEALTH);

	// cap super health
	if (self.health > self.max_health)
		self.health = self.max_health;
	if (self.health < 50)
		self.health = 50;
	parm1 = self.items;
	parm2 = self.health;
	parm3 = get_max_armor ();
	if (self.armorvalue < parm3)
		parm3 = self.armorvalue;
	if (self.ammo_shells < 25)
		parm4 = 25;
	else
		parm4 = self.ammo_shells;
	parm5 = self.ammo_nails;
	parm6 = self.ammo_rockets;
	parm7 = self.ammo_cells;
	parm8 = self.weapon;
	parm9 = self.armortype * 100;
	parm10 = self.runetype;
	parm12 = 0;	// observers, negative duration in game queue
	parm13 = 0;	// observers, ridee
	parm14 = self.rqflags;

	if (is_observer ())
	{
		if (self.runevar)
			parm12 = 0 - (time - self.runevar);
		if (self.owner)
		{
			// The low bits store the track mode, the rest
			// the entity number.
			parm13 = 4 * player_ent_to_num (self.owner);
			parm13 = parm13 + (self.aqstate & AQS_RIDE_MASK)
						/ AQS_RIDE_DIV;
		}
	}

	persistent_parms ();
	parm11 = parm11 | (self.aqflags & AQ_HOOK);
};

void ()
SetNewParms =
{
	parm1 = IT_SHOTGUN | IT_AXE;
	if (deathmatch & DM_DM_MASK)
		parm1 = parm1 | (self.items & IT_KEY2);
	parm2 = MAX_HEALTH_NORMAL;
	parm3 = 0;
	parm4 = 25;
	parm5 = 0;
	parm6 = 0;
	parm7 = 0;
	parm8 = 1;
	parm9 = 0;

	parm10 = 0;	// runetype
	parm11 = 0;	// aqflags
	parm14 = 0;	// rqflags

	// Parms 12 and 13 are only valid for observers, and they never
	// get run here.  This sets them for new players coming in and
	// starting as observers.
	parm12 = 0;
	parm13 = 0;
};

void ()
DecodePracticeParms =
{
	self.items		= parm1 = IT_AXE | IT_SHOTGUN | IT_SUPER_SHOTGUN | IT_NAILGUN | IT_SUPER_NAILGUN
						| IT_GRENADE_LAUNCHER | IT_ROCKET_LAUNCHER | IT_LIGHTNING
						| IT_ARMOR3;
	self.health		= MAX_HEALTH_NORMAL;
	self.armorvalue		= MAX_ARMOR_3;
	self.ammo_shells	= MAX_SHELLS;
	self.ammo_nails		= MAX_NAILS;
	self.ammo_rockets	= MAX_ROCKETS;
	self.ammo_cells		= MAX_CELLS;

	// Setting self.weapon is necessary because you retain your
	// weapon setting across deaths.  If you die with the single
	// shotgun set_weapon() won't do anything when this tries to set
	// your weapon because it thinks you're already wielding that.
	self.weapon = 0;
	set_weapon (IT_ROCKET_LAUNCHER);

	// XXX For some strange reason, multiplying parm9 by 0.01 returns
	// the wrong value for red armor (0.79 instead of 0.80).  The result
	// is picking up red armor when you don't need it.  I work around it
	// by dividing by 100 instead.
	self.armortype = ARMOR_TYPE_3;

	Rune_Activate (parm10, 0);
	self.aqflags		= parm11;
	self.rqflags		= parm14;
};

void ()
DecodeLevelParms =
{
	if (deathmatch & DM_MODE_PRACTICE)
	{
		DecodePracticeParms ();
		return;
	}

	self.items		= parm1;
	self.health		= parm2;
	self.armorvalue		= parm3;
	self.ammo_shells	= parm4;
	self.ammo_nails		= parm5;
	self.ammo_rockets	= parm6;
	self.ammo_cells		= parm7;

	// Setting self.weapon is necessary because you retain your
	// weapon setting across deaths.  If you die with the single
	// shotgun set_weapon() won't do anything when this tries to set
	// your weapon because it thinks you're already wielding that.
	self.weapon = 0;
	set_weapon (parm8);

	// XXX For some strange reason, multiplying parm9 by 0.01 returns
	// the wrong value for red armor (0.79 instead of 0.80).  The result
	// is picking up red armor when you don't need it.  I work around it
	// by dividing by 100 instead.
	self.armortype = parm9 / 100;

	Rune_Activate (parm10, 0);
	self.aqflags		= parm11;
	self.rqflags		= parm14;
};

/*
============
FindIntermission

Returns the entity to view from
============
*/
entity ()
FindIntermission =
{
	local entity spot;
	local float cyc;

	// look for info_intermission first
	spot = find (world, classname, "info_intermission");
	if (spot)
	{
		// in rune cheat (debugging) mode, always use the same
		// spot, for testing proper behavior at intermission (so
		// you set something up at the place you'll see during
		// intermission)
		if (temp1 & T1_RUNE_CHEAT)
			return spot;
		// pick a random one
		cyc = random () * 4;
		while (cyc > 1)
		{
			spot = find (spot, classname, "info_intermission");
			if (!spot)
				spot = find (spot, classname, "info_intermission");
			cyc = cyc - 1;
		}
		return spot;
	}

	// then look for the start position
	spot = find (world, classname, "info_player_start");
	if (spot)
		return spot;

	// testinfo_player_start is only found in regioned levels
	spot = find (world, classname, "testplayerstart");
	if (spot)
		return spot;

	objerror ("FindIntermission: no spot");
	return world;
};

entity intermission_pos;
string nextmap;

void ()
GotoNextMap =
{
	update_server_time ();

	IN_QW([-
		local string newmap;

		if (cvar_infokey ("infokey_maps"))
		{
			newmap = infokey (world, "next_map");
			if (forced_nextmap)
			{
				if (!newmap)
				{
					newmap = infokey (world, mapname);
					if (newmap)
						cvar_set_infokey ("next_map", newmap);
				}
			}
			else
			{
				if (newmap != string_null && newmap != mapname)
					forced_nextmap = newmap;
				else
				{
					newmap = infokey (world, mapname);
					if (newmap)
						forced_nextmap = newmap;
				}
				cvar_set_infokey ("next_map", "\"\"");
			}
		}
	-])

	if (forced_nextmap)
		changelevel (forced_nextmap);
	else if (cvar ("samelevel") & 1)	// if samelevel is set, stay on same level
		changelevel (mapname);
	else
	{
		// Select the level which will actually be played.
		// This is here so that it runs as late as possible.
		// Often some people will drop during the pause between
		// levels, but NextLevel() runs before then so it has
		// the wrong idea about the number of people who will
		// be playing on the next level.
		nextmap = select_map ();
		changelevel (nextmap);
	}
};

void ()
ExitIntermission =
{
	GotoNextMap ();
};

/*
============
IntermissionThink

When the player presses attack or jump, change to the next level
============
*/
void ()
IntermissionThink =
{
	// If you go into intermission with the lightning or nail
	// guns switchfiring they'll keep right on firing until the
	// intermission exits without this.
	if (self.aqstate & AQS_SWITCHFIRING)
		switchfire_off ();

	spawn_protect_off ();

	if (time < intermission_exittime)
		return;

	if (self.button0 || self.button1 || self.button2)
		ExitIntermission ();
};

// XXX People who connect during intermission don't get their angles set.

void (entity e)
move_to_intermission =
{
	IN_POQ([-
		e.view_ofs	 = VEC_ORIGIN;

		if (world.impulse)
		{
			if (lastspawn)
				intermission_pos 	= lastspawn;
			e.angles			= intermission_pos.angles;

			makevectors (intermission_pos.angles);
			spawn_tfog (intermission_pos.origin + 16 * v_forward);
		}
		else
			e.angles			= e.v_angle = intermission_pos.mangle;

		e.fixangle	 = TRUE;		// turn this way immediately
		e.nextthink	 = time + 0.5;

		setorigin (e, intermission_pos.origin);
	-])
	e.takedamage	= DAMAGE_NO;
	e.solid		= SOLID_NOT;
	e.movetype	= MOVETYPE_NONE;
	e.modelindex	= 0;

	self_stuffcmd (e, CSHIFT_NONE);
};

void (float who)
proto_intermission =
{
	IN_POQ(if (!world.impulse))
		WriteByte (who, SVC_INTERMISSION);
	IN_QW([-
		WriteCoord (who, intermission_pos.origin_x);
		WriteCoord (who, intermission_pos.origin_y);
		WriteCoord (who, intermission_pos.origin_z);
		WriteAngle (who, intermission_pos.mangle_x);
		WriteAngle (who, intermission_pos.mangle_y);
		WriteAngle (who, intermission_pos.mangle_z);
	-])
};

/*
============
execute_changelevel

The global "nextmap" has been set previously.
Take the players to the intermission spot
============
*/
void ()
execute_changelevel =
{
	intermission_running = 1;
	if (teamplay & TEAM_TEAM_MASK)
		team_stats (1);

	// enforce a wait time before allowing changelevel
	if (temp1 & T1_RUNE_CHEAT)
		intermission_exittime = time;
	else if (deathmatch & DM_DM_MASK)
		intermission_exittime = time + 5;
	else
		intermission_exittime = time + 2;

	intermission_pos = FindIntermission ();

	other = find (world, classname, "player");
	while (other != world)
	{
		move_to_intermission (other);
		other = find (other, classname, "player");
	}

	proto_intermission (MSG_ALL);

	// hack
	if (world.impulse < 0)
		GotoNextMap ();
};

void ()
changelevel_touch =
{
	if (other.classname != "player")
		return;

	if ((noexit & NOEXIT_NO_EXITING || noexit == 2)
			&& (mapname != "start"
				|| !noexit & NOEXIT_ALLOW_EXITING_START))
	{
		if (!deathmatch & DM_EXIT_NON_FATAL)
			T_Damage (other, self, self, 50000, "changelevel");
		return;
	}

	if (coop || deathmatch & DM_DM_MASK)
	{
		bprint (other.netname);
		bprint (" exited the level\n");
	}

	nextmap = self.map;
	// If the DM levels don't loop and the user chose the end
	// level, play the DM maps.
	if (nextmap == "end" && noexit & NOEXIT_DM_NO_LOOP)
		nextmap = "dm1";

	SUB_UseTargets ();

	if (self.spawnflags & 1 && !deathmatch & DM_DM_MASK)
	{	// NO_INTERMISSION
		GotoNextMap ();
		return;
	}

	self.touch = SUB_Null;

	// we can't move people right now, because touch functions are
	// called in the middle of C movement code, so set a think time
	// to do it
	self.think = execute_changelevel;
	self.nextthink = time + sys_ticrate;
};

/*QUAKED trigger_changelevel (0.5 0.5 0.5) ? NO_INTERMISSION
When the player touches this, he gets sent to the map listed in the "map" variable.  Unless the NO_INTERMISSION flag is set, the view will go to the info_intermission spot and display stats.
*/
void ()
trigger_changelevel =
{
	if (!self.map)
		self.map = "start";

	if (place_my_targets ())
		self.touch = teleport_touch;
	else
		self.touch = changelevel_touch;

	InitTrigger ();
};

/*
=============================================================================

				PLAYER GAME EDGE FUNCTIONS

=============================================================================
*/

// called by ClientKill and DeadThink
void ()
respawn =
{
	//RUNE SERV: remove color shifts
	stuffcmd (self, CSHIFT_NONE);
	//RUNE SERV: Phoenix rune
	if (self.runetype == RN_PHOENIX && self.runevar > 0)
	{
		CopyToBodyQue (self);
		Resurrect (1);
		return;
	}
	if (coop)
	{
		// make a copy of the dead body for appearances sake
		CopyToBodyQue (self);
		// get the spawn parms as they were at level start
		setspawnparms (self);
		// respawn
		PutClientInServer ();
	}
	else if (deathmatch & DM_DM_MASK)
	{
		// make a copy of the dead body for appearances sake
		CopyToBodyQue (self);
		// set default spawn parms
		SetNewParms ();
		persistent_parms ();
		// respawn
		PutClientInServer ();
	}
	else
	{	// restart the entire server
		localcmd ("restart\n");
	}
};

/*
============
ClientKill

Player entered the suicide command
============
*/
void ()
ClientKill =
{
	if (!is_player ())
	{
		sprint (self, "Observers can't suicide!\n");
		return;
	}

	see_damage (self, self, self.health + self.armorvalue);
	self.health = 0;
	Killed (self, self, "suicide");
	kick_suicider ();
};

float (vector v)
CheckSpawnPoint =
{
	dprint_vec (v);
	dprint ("\n");

	return FALSE;
};

/*
============
SelectSpawnPoint

Returns the entity to spawn at
============
*/
entity ()
SelectSpawnPoint =
{
	local entity spot;

	// testinfo_player_start is only found in regioned levels
	spot = find (world, classname, "testplayerstart");
	if (spot)
		return spot;

	// choose a info_player_deathmatch point
	if (coop)
	{
		lastspawn = find (lastspawn, classname, "info_player_coop");
		if (lastspawn == world)
			lastspawn = find (lastspawn, classname, "info_player_start");
		if (lastspawn != world)
			return lastspawn;
	}

	else if (deathmatch & DM_DM_MASK)
	{
		// If all the spawn spots are taken, try spawning on
		// weapons, health and ammo boxes.  This isn't perfect
		// in that some of these are in rooms which start out
		// closed.  I use weapons first because I suspect there
		// are fewer of these with that problem.
		spot = find_spawn_point_class ("info_player_deathmatch", lastspawn);
		if (!spot)
			spot = find_spawn_point_class ("weapon_supershotgun", lastspawn);
		if (!spot)
			spot = find_spawn_point_class ("weapon_nailgun", lastspawn);
		if (!spot)
			spot = find_spawn_point_class ("weapon_supernailgun", lastspawn);
		if (!spot)
			spot = find_spawn_point_class ("weapon_grenadelauncher", lastspawn);
		if (!spot)
			spot = find_spawn_point_class ("weapon_rocketlauncher", lastspawn);
		if (!spot)
			spot = find_spawn_point_class ("weapon_lightning", lastspawn);
		if (!spot)
			spot = find_spawn_point_class ("item_health", lastspawn);
		if (!spot)
			spot = find_spawn_point_class ("item_shells", lastspawn);
		if (!spot)
			spot = find_spawn_point_class ("item_spikes", lastspawn);
		if (!spot)
			spot = find_spawn_point_class ("item_rockets", lastspawn);
		if (!spot)
			spot = find_spawn_point_class ("item_cells", lastspawn);
		// Fall back to fragging somebody on a normal spot if
		// necessary.
		if (!spot)
			spot = find (lastspawn, classname, "info_player_deathmatch");
		// Loop to the beginning of the entity list.
		if (!spot)
			spot = find (spot, classname, "info_player_deathmatch");
		lastspawn = spot;
		return spot;
	}

	if (serverflags & SERVERFLAGS_RUNE_MASK)
	{	// return with a rune to start
		spot = find (world, classname, "info_player_start2");
		if (spot)
			return spot;
	}

	spot = find (world, classname, "info_player_start");
	if (!spot)
		error ("PutClientInServer: no info_player_start on level");

	return spot;
};

/*
===========
PutClientInServer

called each time a player is spawned
============
*/

void ()
PutClientInServer =
{
	local entity spot;
	local float newplayer, spawn_as_observer;

	spot = SelectSpawnPoint ();

	self.last_thought = time;
	self.classname = "player";
	self.max_health = MAX_HEALTH_NORMAL;
	self.health = self.max_health;
	self.takedamage = DAMAGE_AIM;
	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_WALK;
	self.show_hostile = 0;
	self.flags = FL_CLIENT;
	self.air_finished = time + 12;
	self.dmg = 2;   		// initial water damage
	self.super_damage_finished = 0;
	self.radsuit_finished = 0;
	self.invisible_finished = 0;
	self.invincible_finished = 0;
	self.effects = 0;
	self.invincible_time = 0;
	self.last_drop_delay = 0;

	//RUNE SERV: Stuff when entering
	self.touch = misc_touch;
	self.runetime = time;
	self.runevar = 0;
	self.runevector = VEC_ORIGIN;
	self.grenade_spam_time = 0;

	DecodeLevelParms ();

	// Do not allow firing immediately after you respawn to prevent
	// your from losing your spawn shield.
	if (!deathmatch & DM_MODE_PRACTICE)
		self.attack_finished = time + 1.5;

	self.th_pain = player_pain;
	self.th_die = PlayerDie;

	self.deadflag = DEAD_NO;
	self.volume = 0;
	// paustime is set by teleporters to keep the player from moving
	// a while
	self.pausetime = 0;

	if (!is_player_start_class (spot.classname))
		self.origin = spot.origin + SPAWN_ITEM_OFFSET;
	else
		self.origin = spot.origin + '0 0 1';
	self.angles = spot.angles;
	self.fixangle = TRUE;		// turn this way immediately

	// oh, this is a hack!
	setmodel (self, "progs/eyes.mdl");
	modelindex_eyes = self.modelindex;

	setmodel (self, "progs/player.mdl");
	modelindex_player = self.modelindex;

	setsize (self, VEC_HULL_MIN, VEC_HULL_MAX);

	self.view_ofs = PLAYER_VIEW_OFFSET;
	self.velocity = VEC_ORIGIN;
	self.state = 0;
	self.aqstate = self.aqstate - self.aqstate & AQS_SWITCHFIRING;

	player_stand ();

	//RUNE SERV:  Player initialization
	if (!self.aqflags & AQ_INIT_DONE)
		newplayer = 1;
	else
		newplayer = 0;
	if (newplayer || is_observer())
		spawn_as_observer = 1;
	else
		spawn_as_observer = 0;

	// You can't do the player init here because stuffcmd doesn't
	// work yet, but doing it from a newly spawned entity's think
	// function works.  Go figure.
	if (newplayer)
	{
		self.aqflags = self.aqflags | AQ_INIT_DONE | AQ_NO_HUD;
		self.rqflags = self.rqflags | RQ_CYCLE_ALTERNATES;
		player_init_spawn ();
	}

	if (spawn_as_observer)
	{
		obs_become (0);
		self.runevar = parm12;
		// If she was a rider, get her back on the right horse.
		if (parm13)
		{
			self.aqstate = self.aqstate | ((parm13 & 3)
							* AQS_RIDE_DIV);
			parm13 = (parm13 - parm13 & 3) / 4;
			spot = spawn ();
			spot.owner = self;
			spot.enemy = player_num_to_ent (parm13);
			spot.think = rider_wait_think;
			spot.runetime = time + 20;	// time out
			if (spot.enemy)
				spot.nextthink = time;
			else
				remove (spot);
		}
	}
	else
	{
		if ((deathmatch & DM_DM_MASK || coop) && self.runetype != RN_CLOAK)
		{
			makevectors (self.angles);
			spawn_tfog (self.origin + v_forward*20);
		}
		spawn_tdeath (self.origin, self);
		if (SPAWN_PROTECT_DURATION > 0)
		{
			self.invincible_finished
				= time + SPAWN_PROTECT_DURATION;
			self.takedamage = DAMAGE_NO;
			self.aqstate = self.aqstate | AQS_SPAWN_PROTECT;
			self.effects = self.effects | EF_BRIGHTFIELD;
		}
	}

	if (self.aqflags & AQ_HOOK)
		current_hooks = current_hooks + 1;

	// Time at which to check name.
	self.lip = time + 1 + random ();

	// Originally I called draw_hud() here but that didn't do
	// anything.  I have a tickle of memory about prints not
	// working this early.
	//
	// Forcing cnt to be 0 here causes the HUD to come up right
	// away.  I don't know why this is necessary, since it should
	// start at 0, but it is.  Perhaps it's because it's getting
	// printed too early again, before prints start working.
	self.cnt = 0;

	// Bizarrely, QW sets rj here.
	IN_QW([-
		if (stof (infokey (world, "rj")) != 0)
			rj = stof (infokey (world, "rj"));
	-])
};

/*
=============================================================================

				QUAKED FUNCTIONS

=============================================================================
*/

/*QUAKED info_player_start (1 0 0) (-16 -16 -24) (16 16 24)
The normal starting point for a level.
*/
void ()
info_player_start =
{
};

/*QUAKED info_player_start2 (1 0 0) (-16 -16 -24) (16 16 24)
Only used on start map for the return point from an episode.
*/
void ()
info_player_start2 =
{
};

/*
saved out by quaked in region mode
*/
void ()
testplayerstart =
{
};

/*QUAKED info_player_deathmatch (1 0 1) (-16 -16 -24) (16 16 24)
potential spawning position for deathmatch games
*/
void ()
info_player_deathmatch =
{
	// This spawn spot is positioned badly, it sticks the player in
	// something.  This triggers the game's stuck player avoidance
	// and causes the player to pop up where she died.
	if (world.model == "maps/e3m7.bsp" && self.origin == '-720 528 24')
		remove (self);
};

/*QUAKED info_player_coop (1 0 1) (-16 -16 -24) (16 16 24)
potential spawning position for coop games
*/
void ()
info_player_coop =
{
};

/*
===============================================================================

RULES

===============================================================================
*/

/*
go to the next level for deathmatch
only called if a time or frag limit has expired
*/
void ()
NextLevel =
{
	local entity o;
	local float svrf;

	update_server_time ();

	// Console exited level.
	if (world.impulse > 0)
		GotoNextMap ();

	if (serverflags & SERVERFLAGS_RUNE_MASK == 0
			&& orig_serverflags & SERVERFLAGS_RUNE_MASK == SERVERFLAGS_RUNE_MASK)
		serverflags = serverflags | SERVERFLAGS_RUNE_MASK;
	svrf = serverflags;

	if (mapname == "start")
	{
		o = spawn ();
		if (!cvar ("registered"))
		{
			o.map = "e1m1";
		}
		else if (!(serverflags & 1))
		{
			o.map = "e1m1";
			serverflags = serverflags | 1;
		}
		else if (!(serverflags & 2))
		{
			o.map = "e2m1";
			serverflags = serverflags | 2;
		}
		else if (!(serverflags & 4))
		{
			o.map = "e3m1";
			serverflags = serverflags | 4;
		}
		else if (!(serverflags & 8))
		{
			o.map = "e4m1";
			serverflags = serverflags | 8;
		}
		else if (noexit & NOEXIT_DM_NO_LOOP)
		{
			o.map = "dm1";
			serverflags = serverflags - 15;
		}
		else
		{
			o.map = "e1m1";
			serverflags = serverflags
					- serverflags & SERVERFLAGS_RUNE_MASK
					+ 1;
		}
	}
	else
	{
		// find a trigger changelevel
		o = find (world, classname, "trigger_changelevel");

		// go back to start if no trigger_changelevel or (if
		// requested) at the end of the deathmatch maps
		// (which loop by default)
		if (!o || (o.map == "dm1" && noexit & NOEXIT_DM_NO_LOOP))
		{
			o = spawn ();
			o.map = "start";
		}
	}

	nextmap = o.map;
	gameover = TRUE;

	if (o.nextthink < time)
	{
		o.think = execute_changelevel;
		o.nextthink = time + sys_ticrate;
	}

	// Don't mess with the runes in the user's display if they
	// aren't actually used to select maps.
	if (select_map_ignores_serverflags ())
		serverflags = svrf;
};

/*
============
CheckRules

Exit deathmatch games upon conditions
============
*/
void ()
CheckRules =
{
	if (gameover)	// someone else quit the game already
		return;

	timelimit = cvar ("timelimit") * 60;
	fraglimit  = cvar ("fraglimit");

	if (timelimit && time >= timelimit)
	{
		NextLevel ();
		return;
	}

	if (TIMELIMIT_COUNTDOWN)
		timelimit_countdown ();
};

//============================================================================

void ()
PlayerDeathThink =
{
	local float forward;

	IN_QW([-
		// XXX The phoenix rune allows you to respawn at odd locations.
		// Occasionally you can get stuck in walls.  In addtion, when you
		// die in liquid, you don't hit the ground immediately and since
		// you can't fire until you've stopped moving, this can be annoying.
		//
		// Mr. Happy requested that I implement the old-style phoenix until
		// a fix is implemented.
		local float OLD_STYLE_PHOENIX = 1;
	-])

	// Warn phoenix users.

	IN_QW([-
		if (!OLD_STYLE_PHOENIX)
	-])
	if (self.runetype == RN_PHOENIX)
		centerprint (self, "\<\bwarning\b\>\nphoenix rune detected\nuse jump to respawn");

	if (self.flags & FL_ONGROUND)
	{
		forward = vlen (self.velocity);
		forward = forward - 20;
		if (forward <= 0)
			self.velocity = VEC_ORIGIN;
		else
			self.velocity = forward * normalize (self.velocity);
	}

	// Make people who sit idle as corpses for too long into
	// observers.
	if (AUTO_CORPSE_OBSERVER > 0)
	{
		if (!self.volume)
			self.volume = time + AUTO_CORPSE_OBSERVER;
		else if (time <= self.volume)
			SUB_Null ();
		else
		{
			if (corpse_to_observer (2))
				return;
			// She couldn't become an observer, don't try
			// again immediately.
			self.volume = time + AUTO_CORPSE_OBSERVER;
		}
	}

	IN_QW([-
		if (!OLD_STYLE_PHOENIX)
	-])
	// Don't let phoenixes respawn until they come to a rest.
	// Allows you to respawn if your corpse gets pushed outside the level.
	if ((self.runetype == RN_PHOENIX && !self.flags & FL_ONGROUND)
				&& pointcontents (self.origin) != CONTENT_SOLID)
		return;

	// wait for all buttons released
	if (self.deadflag == DEAD_DEAD)
	{
		if (self.button2 || self.button1 || self.button0)
			return;
		self.deadflag = DEAD_RESPAWNABLE;
		return;
	}

	// Prevent phoenix holders from firing.
	if (self.runetype == RN_PHOENIX
		IN_QW(&& !OLD_STYLE_PHOENIX)
			)
	{
		if ((!self.button2 && !self.button1) || self.aqflags & AQ_KICKED)
			return;
	}
	else
	{
		// wait for any button down
		if ((!self.button2 && !self.button1 && !self.button0)
			|| self.aqflags & AQ_KICKED)
		return;
	}

	self.button0 = 0;
	self.button1 = 0;
	self.button2 = 0;

	respawn ();
};

void ()
PlayerJump =
{
	if (self.flags & FL_WATERJUMP)
		return;

	if (self.waterlevel >= 2)
	{
		IN_POQ([-
			if (self.watertype == CONTENT_WATER)
				self.velocity_z = 100;
			else if (self.watertype == CONTENT_SLIME)
				self.velocity_z = 80;
			else
				self.velocity_z = 50;
		-])

		// play swiming sound
		if (self.swim_flag < time)
		{
			self.swim_flag = time + 1;
			random_sound2 (self, CHAN_JUMP, "misc/water1.wav",
					"misc/water2.wav", 1, ATTN_NORM);
		}
		return;
	}

	if (self.runetype == RN_FLY && self.runevar)
	{
		self.velocity_z = self.velocity_z + 270;
		return;
	}

	if (!(self.flags & FL_ONGROUND))
		return;

	if (!(self.flags & FL_JUMPRELEASED))
		return;		// don't pogo stick

	self.flags = self.flags - (self.flags & FL_JUMPRELEASED);

	IN_POQ([-
		self.flags = self.flags - FL_ONGROUND;	// don't stairwalk
	-])

	self.button2 = 0;

	// player jumping sound
	if (self.attack_finished <= time + 15)
		sound (self, CHAN_JUMP, "player/plyrjmp8.wav", 1, ATTN_NORM);

	IN_POQ([-
		self.velocity_z = self.velocity_z + 270;
	-])
};

/*
===========
WaterMove

============
*/

.float	dmgtime;

void ()
WaterMove =
{
	if (self.movetype == MOVETYPE_NOCLIP)
		return;
	if (self.health <= 0)
		return;

	if (self.waterlevel > 0)
	{
		if (!(self.flags & FL_INWATER))
		{
			// player enters water sound
			if (self.watertype == CONTENT_LAVA)
				sound (self, CHAN_BODY, "player/inlava.wav", 1, ATTN_NORM);
			if (self.watertype == CONTENT_WATER)
				sound (self, CHAN_BODY, "player/inh2o.wav", 1, ATTN_NORM);
			if (self.watertype == CONTENT_SLIME)
				sound (self, CHAN_BODY, "player/slimbrn2.wav", 1, ATTN_NORM);

			self.flags = self.flags + FL_INWATER;
			self.dmgtime = 0;
		}

		// electric rune: discharge in water
		if (self.runetype == RN_ZAP
				&& !ZAP_RUNE_SAFE_IN_WATER
				&& self.ammo_cells > 0
				&& self.radsuit_finished < time)
		{
			sound (self, CHAN_AUTO, "weapons/lstart.wav", 1, ATTN_NORM);
			discharge_hack = 1;
			T_RadiusDamage (RADIUS_NORMAL, self, self, 20 * self.ammo_cells, world, "waterzap");
			discharge_hack = 0;
			self.ammo_cells = 0;
			return;
		}
		// environmental protection rune: heal in liquids
		else if (self.runetype == RN_ENVIRO)
		{
			self.next_breath = time + 1;
			self.dmgtime = time + 1;
			Rune_Enviro ();
		}
		// human torch: injur in water
		else if (self.runetype == RN_TORCH
				&& self.watertype == CONTENT_WATER
				&& self.dmgtime < time
				&& self.radsuit_finished < time)
		{
			self.dmgtime = time + 0.5;
			T_Damage (self, world, world, 4*self.waterlevel, "waterdouse");
		}

		if (self.watertype == CONTENT_LAVA)
		{
			// human torch: allow lava baths
			if (self.runetype != RN_TORCH && self.dmgtime < time)
			{
				if (self.radsuit_finished > time)
					self.dmgtime = time + 1;
				else
					self.dmgtime = time + 0.2;

				T_Damage (self, world, world, 10 * self.waterlevel, "lava");
			}
		}
		else if (self.watertype == CONTENT_SLIME)
		{
			if (self.dmgtime < time && self.radsuit_finished < time)
			{
				self.dmgtime = time + 1;
				T_Damage (self, world, world, 4 * self.waterlevel, "slime");
			}
		}
	}
	else
	{
		if (self.flags & FL_INWATER)
		{
			// play leave water sound
			sound (self, CHAN_BODY, "misc/outwater.wav", 1, ATTN_NORM);
			self.flags = self.flags - FL_INWATER;
		}
	}

	if (self.waterlevel != 3)
	{
		// environmental protection rune & suit: no gasp sound leaving water
		if (self.runetype != RN_ENVIRO && self.radsuit_finished < time)
		{
			if (self.air_finished < time)
				sound (self, CHAN_VOICE, "player/gasp2.wav", 1, ATTN_NORM);
			else if (self.air_finished < time + 9)
				sound (self, CHAN_VOICE, "player/gasp1.wav", 1, ATTN_NORM);
		}

		// athletics & zen monk rune: larger lungs
		if (self.runetype == RN_ATHLETE || self.runetype == RN_MONK)
			self.air_finished = time + 24;
		else
			self.air_finished = time + 12;

		self.dmg = 2;
	}
	else
	{
		if (self.air_finished < time)
		{
			if (self.next_breath < time)
			{
				self.dmg = self.dmg + 2;
				if (self.dmg > 15)
					self.dmg = 10;
				T_Damage (self, world, world, self.dmg, "drown");
				self.next_breath = time + 1;
			}
		}
	}
	IN_POQ([-
		if (!(self.flags & FL_WATERJUMP))
			self.velocity = self.velocity - 0.8*self.waterlevel*frametime*self.velocity;
	-])
};

void ()
CheckWaterJump =
{
	local vector start, end;

	// check for a jump-out-of-water
	makevectors (self.angles);
	start = self.origin;
	start_z = start_z + 8;
	v_forward_z = 0;
	normalize (v_forward);
	end = start + v_forward*24;
	traceline (start, end, TRUE, self);
	if (trace_fraction < 1)
	{	// solid at waist
		start_z = start_z + self.maxs_z - 8;
		end = start + v_forward*24;
		self.movedir = trace_plane_normal * -50;
		traceline (start, end, TRUE, self);
		if (trace_fraction == 1)
		{	// open at eye level
			self.flags = self.flags | FL_WATERJUMP;
			self.velocity_z = 225;
			self.flags = self.flags - (self.flags & FL_JUMPRELEASED);
			self.teleport_time = time + 2;	// safety net
			return;
		}
	}
};

/*
================
PlayerPreThink

Called every frame before physics are run
================
*/
void ()
PlayerPreThink =
{
	local float i, obs;

	self.last_thought = time;
	if (!is_valid_player ())
		return;
	obs = is_observer ();

	if (intermission_running)
	{
		IntermissionThink ();	// otherwise a button could be missed between
		return;					// the think tics
	}

	if (self.view_ofs == VEC_ORIGIN)
		return;		// intermission or finale

	if (self.aqstate & AQS_MENU_MASK && time > self.count)
		aq_menu_print ();

	if (self.waitmax)
	{
		if (self.deadflag || (obs && self.owner.deadflag))
			rune_tell_stop (0);
		else if (self.waitmax > 0 && time > self.waitmax)
			rune_tell_refresh ();	// refresh
		else if (self.waitmax < 0
				&& 0 - self.waitmax + CENTERPRINT_TIME < time)
			self.waitmax = 0;	// it just went away
	}

	// I let admins use bad names mainly so Qsmack can use an empty
	// one.  I also don't rename somebody in the middle of a Qsmack
	// password sequence, since otherwise this is likely to trigger
	// while Qsmack is logging in.
	//
	// XXX This is still a race (this could trigger before Qsmack
	// sends the first impulse, probably).
	if (time > self.lip) if (!self.aqflags & AQ_ADMIN
				    && self.aqstate & AQS_IMPOVER_MASK != AQS_IMPOVER_QSMACK_PASSWORD)
	{
		self.lip = time + 5;
		i = FALSE;
		// There are lots of ways users can make a blank-looking
		// name that this doesn't catch, The characters 10 12 13
		// 32 34 138 140 all display as blank in Quake.  See the
		// Configuring file for a Qsmack ban command which will
		// prevent any of them from being used.
		if (self.netname == string_null
				|| self.netname == " "
				|| self.netname == "  "
				|| self.netname == "   "
				|| self.netname == "    "
				|| self.netname == "     "
				|| self.netname == "      "
				|| self.netname == "       "
				|| self.netname == "        "
				|| self.netname == "         "
				|| self.netname == "          "
				|| self.netname == "           "
				|| self.netname == "            "
				|| self.netname == "             "
				|| self.netname == "              "
				|| self.netname == "               "
				|| self.netname == "                ")
			i = TRUE;

		// XXX This doesn't work, there's a race with legimitate
		// players having this name.
		//else if (self.netname == "unconnected"
		//	    || self.netname == "Unconnected"
		//	    || self.netname == "UNCONNECTED")
		//	i = TRUE;

		if (i)
		{
			if (self.aqflags & AQ_NAME_WARN)
				kick ("for using an obnoxious name", string_null);
			else
			{
				local string newname;

				sprint (self, "Don't use such an obnoxious name.  If you use such a name again you will be kicked.\n");
				self.aqflags = self.aqflags | AQ_NAME_WARN;
				self_stuffcmd (self, "name \"");
				newname = random_name ();
				self_stuffcmd (self, newname);
				self_stuffcmd (self, "\"\n");
			}
		}
	}

	// Enforce teams if appropriate
	if (teamplay & TEAM_TEAM_MASK) if (!is_correct_team ())	// no short circuiting!
	{
		if (is_allowable_team ())
		{
			set_team_e (self, self.team);
		}
		else if (self.aqflags & AQ_TEAM_MASK && !obs)
		{
			sure_kill ("teamchange");
			kick_suicider ();
			i = correct_team ();
			set_team_e (self, i);
		}
		else
		{
			assign_teams (self);
		}
	}

	makevectors (self.v_angle);

	if (obs)
	{
		obs_pre_think ();
		return;
	}

	// The call of CheckRules() moved to StartFrame().
	if (fraglimit && self.frags >= fraglimit)
		NextLevel ();
	WaterMove ();

	IN_POQ([-
		if (self.waterlevel == 2)
			CheckWaterJump ();
	-])

	if (self.deadflag >= DEAD_DEAD)
	{
		PlayerDeathThink ();
		return;
	}

	if (self.deadflag == DEAD_DYING)
		return;	// dying, so do nothing

	if (self.button2)
	{
		PlayerJump ();
	}
	else
		self.flags = self.flags | FL_JUMPRELEASED;

	//RUNE SERV: Runes that need thinking
	if (self.runetype > 0)
		Rune_Think ();

	// teleporters can force a non-moving pause time
	if (time < self.pausetime)
		self.velocity = VEC_ORIGIN;

	if (time > self.attack_finished && self.currentammo == 0
			&& self.weapon != IT_AXE && self.weapon != WEAPON_HOOK)
		set_weapon (W_BestWeapon ());
};

/*
================
CheckPowerups

Check for turning off powerups
================
*/
void ()
CheckPowerups =
{
	if (self.health <= 0)
		return;

	// invisibility
	if (self.invisible_finished)
	{
		// sound and screen flash when items starts to run out
		if (self.invisible_sound < time)
		{
			sound (self, CHAN_AUTO, "items/inv3.wav", 0.5, ATTN_IDLE);
			self.invisible_sound = time + ((random () * 3) + 1);
		}

		if (self.invisible_finished < time + 3)
		{
			if (self.invisible_time < 0)
			{
				if (!deathmatch & DM_DM_MASK)
					sprint (self, "Ring of Shadows magic is fading\n");
				stuffcmd (self, "bf\n");
				sound (self, CHAN_AUTO, "items/inv2.wav", 1, ATTN_NORM);
				self.invisible_time = time + 1;
			}

			if (self.invisible_time < time)
			{
				self.invisible_time = time + 1;
				stuffcmd (self, "bf\n");
			}
		}

		if (self.invisible_finished < time)
		{	// just stopped
			self.items = self.items - IT_INVISIBILITY;
			self.invisible_finished = 0;
			self.invisible_time = 0;
		}

	// use the eyes
		self.frame = 0;
		self.modelindex = modelindex_eyes;
	}

	//RUNE SERV: Cloaky rune thing.
	else if (self.runetype == RN_CLOAK && self.runevar == 1)
	{
		self.frame = 0;
		self.modelindex = modelindex_eyes;
	}

	//RUNE SERV: Camo rune.
	else if (self.runetype == RN_CAMO && self.runevar == 1)
		self.modelindex = 0;

	else
		self.modelindex = modelindex_player;	// don't use eyes

	// invincibility
	if (self.invincible_finished)
	{
		local float spawnpro;

		spawnpro = self.aqstate & AQS_SPAWN_PROTECT;

		// sound and screen flash when items starts to run out
		if (self.invincible_finished < time + 3 && !spawnpro)
		{
			if (self.invincible_time < 0)
			{
				if (!deathmatch & DM_DM_MASK)
					sprint (self, "Protection is almost burned out\n");
				stuffcmd (self, "bf\n");
				sound (self, CHAN_AUTO, "items/protect2.wav", 1, ATTN_NORM);
				self.invincible_time = time + 1;
			}

			if (self.invincible_time < time)
			{
				self.invincible_time = time + 1;
				stuffcmd (self, "bf\n");
			}
		}

		if (spawnpro)
		{
			if (self.invincible_finished < time)
				spawn_protect_off ();
		}
		else
		{
			if (self.invincible_finished < time)
			{	// just stopped
				self.items = self.items - IT_INVULNERABILITY;
				self.invincible_time = 0;
				self.invincible_finished = 0;
			}
			if (self.invincible_finished > time)
				self.effects = self.effects | EF_DIMLIGHT;
			else
				self.effects = self.effects - (self.effects & EF_DIMLIGHT);
		}
	}

	// super damage
	if (self.super_damage_finished)
	{

		// sound and screen flash when items starts to run out

		if (self.super_damage_finished < time + 3)
		{
			if (self.super_time < 0)
			{
				if (!deathmatch & DM_DM_MASK)
					sprint (self, "Quad Damage is wearing off\n");
				stuffcmd (self, "bf\n");
				sound (self, CHAN_AUTO, "items/damage2.wav", 1, ATTN_NORM);
				self.super_time = time + 1;
				self.super_sound = time + 3;
			}

			if (self.super_time < time)
			{
				self.super_time = time + 1;
				stuffcmd (self, "bf\n");
			}
		}

		if (self.super_damage_finished < time)
		{	// just stopped
			self.items = self.items - self.items & IT_QUAD;
			self.super_damage_finished = 0;
			self.super_time = 0;
		}
		if (self.super_damage_finished > time)
			self.effects = self.effects | EF_DIMLIGHT;
		else
			self.effects = self.effects - (self.effects & EF_DIMLIGHT);
	}

	// suit
	if (self.radsuit_finished)
	{
		self.air_finished = time + 12;		// don't drown

		// sound and screen flash when items starts to run out
		if (self.radsuit_finished < time + 3)
		{
			if (self.rad_time < 0)
			{
				if (!deathmatch & DM_DM_MASK)
					sprint (self, "Air supply in Biosuit expiring\n");
				stuffcmd (self, "bf\n");
				sound (self, CHAN_AUTO, "items/suit2.wav", 1, ATTN_NORM);
				self.rad_time = time + 1;
			}

			if (self.rad_time < time)
			{
				self.rad_time = time + 1;
				stuffcmd (self, "bf\n");
			}
		}

		if (self.radsuit_finished < time)
		{	// just stopped
			self.items = self.items - IT_SUIT;
			self.rad_time = 0;
			self.radsuit_finished = 0;
		}
	}

};

/*
================
PlayerPostThink

Called every frame after physics are run
================
*/
void ()
PlayerPostThink =
{
	if (!is_valid_player ())
		return;
	if (self.view_ofs == VEC_ORIGIN)
		return;		// intermission or finale
	if (self.deadflag)
	{
		if (self.deadflag >= DEAD_DEAD && self.impulse)
			dead_impulses ();
		return;
	}
	if (is_observer ())
	{
		obs_post_think ();
		return;
	}

	// do weapon stuff

	W_WeaponFrame ();

	//RUNE SERV: delete rune if requested
	if (self.dropdelay < 0 && time >= (0 - self.dropdelay))
		Rune_Delete (1);

	// check to see if player landed and play landing sound
	if ((self.jump_flag < -300) && (self.flags & FL_ONGROUND) && (self.health > 0))
	{
		if (self.watertype == CONTENT_WATER)
			sound (self, CHAN_JUMP, "player/h2ojump.wav", 1, ATTN_NORM);
		else if (self.runetype != RN_ENVIRO
				&& !self.items & IT_SUIT
				&& self.runetype != RN_FLY
				&& self.runetype != RN_MONK
				&& (self.jump_flag < -850
				|| (self.runetype != RN_ATHLETE
				&& self.jump_flag < -650)))
			T_Damage (self, world, world, 5, "falling");
		else
			sound (self, CHAN_VOICE, "player/land.wav", 1, ATTN_NORM);

		IN_POQ([-
			self.jump_flag = 0;
		-])
	}

	IN_POQ([-if (!(self.flags & FL_ONGROUND))-])
		self.jump_flag = self.velocity_z;

	CheckPowerups ();

	if (self.runetype)
		Rune_PostThink ();

	if (!self.aqflags & AQ_NO_HUD)
		draw_hud (0);
};

void ()
client_ip =
{
	local float px, pch, i;
	local string new;

	new = net_address ();
	self.address = @AddInt (&new, %32);
	strcpy (self.address, new);

	px = AddInt(&"\{0}  ", PSTRING_TO_PQUAKEC);
	pch = AddInt(AddInt(&self.address, PSTRING_TO_PQUAKEC), %-3);

	&%116 = 0;
	for (i = 0; i < 16; i = i + 1)
	{
		pch = AddInt (pch, %1);
		&%113 = (*pch)[0];

		if (world[%5] == ':')
			i = 16;
	}

	pch = AddInt(pch, %3);
	(*pch)[0] = (*px)[0];
};

/*
===========
ClientConnect

called when a player connects to a server
============
*/
void ()
ClientConnect =
{	IN_QW(return;)
	self.cl = *SubInt(AddInt(PSTRING_TO_PQUAKEC, &self.netname), 4 * CL_NAME);
	self.netconnection = *AddInt(self.cl[CL_NETCONNECTION], PC_TO_PQUAKEC);
	client_ip ();

	// I wanted to change the "Foo entered the game" message
	// depending on whether this is a new connection or a new
	// level.  This function is called before DecodeLevelParms(),
	// though, so you don't know anything about the player yet.
	// So, I moved that message to player_init().

	// Id's code would cause intermission to exit here because "a
	// client connecting during an intermission can cause problems",
	// but I just fixed the problems.  I can't move the client from
	// here, so I do that from player_init(), too.
};

/*
===========
ClientDisconnect

called when a player disconnects from a server
============
*/
void ()
ClientDisconnect =
{
	qsmack_status_valid = 0;

	// let everyone else know
	if (!self.aqstate & AQS_FORWARDED)
	{
		bprint (self.netname);
		bprint (" left the game with ");
		bprint_float (self.frags);
		bprint (" frags\n");
		sound (self, CHAN_BODY, "player/tornoff2.wav", 1, ATTN_NONE);
	}

	//RUNE SERV: Various
	spawn_protect_off ();
	forget_rune_owner ();
	if (is_rider ())
		obs_rider_drop (0);
	self.classname = "deader";
	self.health = 0;
	self.runetype = 0;
	self.aqflags = 0;	// for AQ_INIT_DONE, for is_valid_player()
	self.rqflags = 0;
	self.vote_flags = 0;
	self.effects = 0;
	// Set frags so the "unconnected" status list entry for the next
	// player to get this slot (which can last for a while) isn't
	// confusing.
	self.frags = -99;
	set_suicide_frame ();
	obs_process_game_queue ();
	lose_riders ();
	setmodel (self, string_null);
	Log_Client_Disconnect ();
};

/*
===========
ClientObituary

called when a player dies
============
*/
void (entity targ, entity attacker, string dt)
ClientObituary =
{
	local float attacker_player, rnum, f;
	local string attacker_name, s1, s2;

	if (targ.classname != "player")
		return;

	attacker_player = (attacker.classname == "player"
				|| attacker.classname == "deader");
	if (attacker.classname == "deader")
		attacker_name = "somebody";
	else
		attacker_name = attacker.netname;
	rnum = random ();

	if (0)
	{
		bprint ("deathtype ");
		bprint (dt);
		bprint (" targ ");
		bprint (targ.netname);
		bprint ("\n");
	}

	if (attacker.classname == "shambler_slave")
	{
		if (attacker.owner.classname == "player")
		{
			bprint (targ.netname);
			bprint (" was smashed by ");
			bprint (attacker.owner.netname);
			if (attacker.trigger_field.runevar)
				bprint ("'s angry shambler\n");
			else
				bprint ("'s pet shambler\n");
			add_frag (attacker.owner, 1);
		}
		else
		{
			bprint (targ.netname);
			bprint (" was smashed by a rogue shambler\n");
		}
		return;
	}

	if (attacker.classname == "zombie_camper")
	{
		if (attacker.owner.classname == "player")
		{
			bprint (targ.netname);
			bprint (" joined ");
			bprint (attacker.owner.netname);
			bprint ("'s zombies\n");
			add_frag (attacker.owner, 1);
		}
		else
		{
			bprint (targ.netname);
			bprint (" joined somebody's zombies\n");
		}
		return;
	}

	if (targ.classname == "player" && dt == "squish")
	{
		if (teamplay & TEAM_FRAG_PENALTY
				&& targ.team > 0
				&& targ.team == attacker.team
				&& targ != attacker)
		{
			add_frag (attacker, -1);
			bprint (attacker_name);
			bprint (" squishes teammate ");
			bprint (targ.netname);
			bprint ("\n");
		}
		else if (attacker_player && targ != attacker)
		{
			add_frag (attacker, 1);
			bprint (attacker_name);
			bprint (" squishes ");
			bprint (targ.netname);
			bprint ("\n");
		}
		else
		{
			add_frag (targ, -1);
			bprint (targ.netname);
			bprint (" was squished\n");
		}
		return;
	}

	if (attacker_player)
	{

		if (targ == attacker)
		{
			// killed self
			f = -1;
			bprint (targ.netname);

			if (dt == "suicide")
				bprint (" suicides\n");
			else if (dt == "kamiself")
			{
				f = 0;
				bprint (" detonated in a blaze of glory\n");
			}
			else if (attacker.runetype == RN_BOMB)
				bprint (" blew up after killing himself\n");
			else if (dt == "teamchange")
			{
				// Don't penalize, this can be done by
				// mistake (if two people change at
				// once, eg).
				f = 0;
				bprint (" tried to change teams\n");
			}
			else if (dt == "waterzap")
				bprint (" jumped into the water, while ELECTRIFIED!\n");
			else if (dt == "dspotexplode")
				bprint (" was there when his own death spot exploded\n");
			else if (dt == "dspot")
				bprint (" gibbed in his own death spot!\n");
			else if (dt == "radioactive")
				bprint (" died of his own radioactivity\n");
			else if (dt == "dspotdrop")
				bprint (" placed one too many death spots\n");
			else if (dt == "admin-kill")
			{
				f = 0;
				bprint (" was killed by an admin\n");
			}
			else if (dt == "discharge")
			{
				bprint (" discharges into the ");
				if (targ.watertype == CONTENT_SLIME)
					bprint ("slime\n");
				else if (targ.watertype == CONTENT_LAVA)
					bprint ("lava\n");
				else
					bprint ("water\n");
			}
			else if (dt == "barrel")
				bprint (" blew up\n");
			else if (dt == "ftraptouch")
				bprint (" tripped his own fire trap\n");
			else if (dt == "ftrapexplode")
				bprint (" was there when his own fire trap exploded\n");

			// Put deaths which are caused by killing
			// yourself with your weapon after this, so
			// these more specific one takes precedence.
			else if (attacker.super_damage_finished > time)
				bprint (" was too powerful for his own good\n");
			else if (attacker.runetype == RN_STRENGTH)
				bprint (" didn't know his own strength\n");
			else if (attacker.runetype == RN_BERSERK)
				bprint (" berserked himself into an early grave\n");
			else if (attacker.runetype == RN_PIERCING && targ.armorvalue > 0)
				bprint (" pierced himself to the core\n");
			else if (dt == "sniped")
				bprint (" sniped a little too much\n");
			else if (dt == "betty")
				bprint (" was chased down by his own betty\n");
			else if (dt == "tornado")
				bprint (" chased after his own tornado\n");
			else if (dt == "magic-shotgun")
				bprint (" performs his magic death trick\n");
			else if (dt == "bombhit")
				bprint (" struck himself with his own bomb\n");
			else if (dt == "bombed")
				bprint (" was attached to his own bomb\n");
			else if (dt == "bomb")
				bprint (" was there when his own bomb blew\n");
			else if (dt == "gas")
				bprint (" likes the smell of his own gas\n");
			else if (dt == "mortar")
				bprint (" shelled himself\n");
			else if (dt == "bfgblast")
				bprint (" was too close to his own BFG\n");
			else if (dt == "grenade" || dt == "gasbomb")
				bprint (" tries to put the pin back in\n");
			else if (dt == "lavagun")
				bprint (" sizzled himself\n");
			else if (dt == "flamethrower")
				bprint (" incinerated himself\n");
			else if (dt == "burn")
				bprint (" burned himself up\n");
			else
				bprint (" becomes bored with life\n");

			if (f)
				add_frag (attacker, f);
			return;
		}

		if (teamplay & TEAM_FRAG_PENALTY
				&& targ.team > 0
				&& targ.team == attacker.team)
		{
			if (rnum < 0.25)
				s1 = " mows down a teammate\n";
			else if (rnum < 0.50)
				s1 = " checks his glasses\n";
			else if (rnum < 0.75)
				s1 = " gets a frag for the other team\n";
			else
				s1 = " loses another friend\n";
			bprint (attacker_name);
			bprint (s1);
			add_frag (attacker, -1);
			return;
		}

		add_frag (attacker, 1);

		if (dt == "kamikaze")
		{
			s1 = " was taken out in ";
			s2 = "'s blast\n";
		}
		else if (dt == "kamikilled")
		{
			s1 = " shouldn't have shot at ";
			s2 = "\n";
		}
		else if (dt == "zapped")
		{
			s1 = " was zapped within ";
			s2 = "'s electric field\n";
		}
		else if (dt == "waterzap")
		{
			s1 = " was zapped when ";
			s2 = " jumped into the water\n";
		}
		else if (dt == "vengeance")
		{
			s1 = " got a taste of his own medicine from ";
			s2 = "\n";
		}
		else if (dt == "dspotexplode")
		{
			s1 = " was there when ";
			s2 = "'s death spot exploded\n";
		}
		else if (dt == "dspot")
		{
			s1 = " gibbed in ";
			s2 = "'s death spot\n";
		}
		else if (dt == "radioactive")
		{
			s1 = " died of ";
			s2 = "'s radioactivity\n";
		}
		else if (dt == "gfire")
		{
			s1 = "'s legs were burned off by ";
			s2 = "'s fire\n";
		}
		else if (dt == "deathorb")
		{
			s1 = " got attacked by ";
			s2 = "'s death orb\n";
		}
		else if (dt == "deathorb-random")
		{
			s1 = " wandered in to ";
			s2 = "'s death orb\n";
		}
		else if (dt == "spikeball")
		{
			s1 = " ate chaff from ";
			s2 = "'s floating spiky death cloud\n";
		}
		else if (dt == "bodycheck")
		{
			s1 = " was bodychecked by ";
			s2 = "\n";
		}
		else if (dt == "sucker")
		{
			s1 = " was crushed in ";
			s2 = "'s gravity well\n";
		}
		else if (dt == "sniped")
		{
			s1 = " couldn't escape ";
			s2 = "'s scope\n";
		}
		else if (dt == "betty")
		{
			s1 = " was chased down by ";
			s2 = "'s betty\n";
		}
		else if (dt == "tornado")
		{
			s1 = " was torn apart in ";
			s2 = "'s tornado\n";
		}
		else if (dt == "hook")
		{
			s1 = " was grappled down by ";
			s2 = "\n";
		}
		else if (dt == "teledeath")
		{
			s1 = " was telefragged by ";
			s2 = "\n";
		}
		else if (dt == "teledeath2")
		{
			s1 = " feels Satan's power deflect a telefrag from ";
			s2 = "\n";
		}
		else if (dt == "barrel")
		{
			s1 = " exploded with ";
			s2 = "'s barrel\n";
		}
		else if (attacker.runetype == RN_PIERCING
				&& targ.armorvalue > 0)
		{
			s1 = " was pierced to the core by ";
			s2 = "\n";
		}
		else if (dt == "ftraptouch")
		{
			s1 = " tripped ";
			s2 = "'s fire trap\n";
		}
		else if (dt == "ftrapexplode")
		{
			s1 = " was there when ";
			s2 = "'s fire trap exploded\n";
		}
		// Put weapon-specific messages after this.
		else if (dt == "nail")
		{
			s1 = " was nailed by ";
			s2 = "\n";
		}
		else if (dt == "supernail")
		{
			s1 = " was punctured by ";
			s2 = "\n";
		}
		else if (dt == "grenade")
		{
			if (targ.health < -40)
			{
				s1 = " was gibbed by ";
				s2 = "'s grenade\n";
			}
			else
			{
				s1 = " eats ";
				s2 = "'s pineapple\n";
			}
		}
		else if (dt == "missile")
		{
			if (targ.health < -40)
				s1 = " was gibbed by ";
			else
				s1 = " rides ";
			s2 = "'s rocket\n";
		}
		else if (dt == "magic-shotgun")
		{
			s1 = " feels the spell of ";
			s2 = "'s magic shotgun\n";
		}
		else if (dt == "lavagun")
		{
			s1 = " was sizzled by ";
			s2 = "'s lavagun\n";
		}
		else if (dt == "flamethrower")
		{
			s1 = " was incinerated by ";
			s2 = "'s flamethrower\n";
		}
		else if (dt == "bombhit")
		{
			s1 = " was struck by ";
			s2 = "'s bomb\n";
		}
		else if (dt == "bombed")
		{
			s1 = " was attached to ";
			s2 = "'s bomb\n";
		}
		else if (dt == "bomb")
		{
			s1 = " was there when ";
			s2 = "'s bomb blew\n";
		}
		else if (dt == "gas")
		{
			s1 = " took a deep breath of ";
			s2 = "'s gas\n";
		}
		else if (dt == "gasbomb")
		{
			s1 = " exploded along with ";
			s2 = "'s gas grenade\n";
		}
		else if (dt == "mortar")
		{
			s1 = " was shelled by ";
			s2 = "'s mortar\n";
		}
		else if (dt == "bfgzap")
		{
			s1 = " was zapped by ";
			s2 = "'s BFG\n";
		}
		else if (dt == "bfgtouch")
		{
			s1 = " made a connection with ";
			s2 = "'s BFG\n";
		}
		else if (dt == "bfgblast")
		{
			s1 = " was too close to ";
			s2 = "'s BFG\n";
		}
		else if (dt == "burn")
		{
			s1 = " was burned up by ";
			s2 = "\n";
		}
		else if (dt == "lumber")
		{
			s1 = " was chopped down by ";
			s2 = "\n";
		}
		else if (dt == "axe")
		{
			s1 = " was ax-murdered by ";
			s2 = "\n";
		}
		else if (dt == "shotgun")
		{
			s1 = " chewed on ";
			s2 = "'s boomstick\n";
		}
		else if (dt == "supershotgun")
		{
			s1 = " ate 2 loads of ";
			s2 = "'s buckshot\n";
		}
		else if (dt == "discharge")
		{
			s1 = " accepts ";
			s2 = "'s discharge\n";
		}
		else if (dt == "lightning")
		{
			s1 = " accepts ";
			s2 = "'s shaft\n";
		}
		else
		{
			s1 = " was mysteriously killed by ";
			s2 = "\n";
		}

		bprint (targ.netname);
		bprint (s1);
		bprint (attacker_name);
		bprint (s2);
		return;
	}

	add_frag (targ, -1);
	bprint (targ.netname);

	// killed by a montser?
	if (attacker.flags & FL_MONSTER)
	{
		if (attacker.classname == "monster_army")
			bprint (" was shot by a Grunt\n");
		else if (attacker.classname == "monster_demon1")
			bprint (" was eviscerated by a Fiend\n");
		else if (attacker.classname == "monster_dog")
			bprint (" was mauled by a Rottweiler\n");
		else if (attacker.classname == "monster_dragon")
			bprint (" was fried by a Dragon\n");
		else if (attacker.classname == "monster_enforcer")
			bprint (" was blasted by an Enforcer\n");
		else if (attacker.classname == "monster_fish")
			bprint (" was fed to the Rotfish\n");
		else if (attacker.classname == "monster_hell_knight")
			bprint (" was slain by a Death Knight\n");
		else if (attacker.classname == "monster_knight")
			bprint (" was slashed by a Knight\n");
		else if (attacker.classname == "monster_ogre")
			bprint (" was destroyed by an Ogre\n");
		else if (attacker.classname == "monster_oldone")
			bprint (" became one with Shub-Niggurath\n");
		else if (attacker.classname == "monster_shalrath")
			bprint (" was exploded by a Vore\n");
		else if (attacker.classname == "monster_shambler")
			bprint (" was smashed by a Shambler\n");
		else if (attacker.classname == "monster_tarbaby")
			bprint (" was slimed by a Spawn\n");
		else if (attacker.classname == "monster_vomit")
			bprint (" was vomited on by a Vomitus\n");
		else if (attacker.classname == "monster_wizard")
			bprint (" was scragged by a Scrag\n");
		else if (attacker.classname == "monster_zombie")
			bprint (" joins the Zombies\n");
		else
		{
			bprint (" was mysteriously killed by a ");
			bprint (attacker.classname);
			bprint ("\n");
		}
		return;
	}

	// tricks and traps
	if (attacker.classname == "trap_shooter" || attacker.classname == "trap_spikeshooter")
		bprint (" was spiked\n");
	else if (attacker.classname == "trigger_hurt")
		bprint (" got hurt\n");
	else if (dt == "lavaball")
		bprint (" ate a lavaball\n");
	else if (dt == "changelevel")
		bprint (" tried to leave\n");

	// in-water deaths
	else if (dt == "drown")
	{
		if (self.watertype == CONTENT_LAVA && rnum < 0.5)
			bprint (" sleeps with the imps\n");
		else if (self.watertype == CONTENT_LAVA)
			bprint (" drowned in a pool of lava\n");
		else if (self.watertype == CONTENT_SLIME)
			bprint (" breathes slime\n");
		else if (rnum < 0.5)
			bprint (" sleeps with the fishes\n");
		else
			bprint (" sucks it down\n");
	}
	else if (dt == "slime")
	{
		if (rnum < 0.5)
			bprint (" gulped a load of slime\n");
		else
			bprint (" can't exist on slime alone\n");
	}
	else if (dt == "lava")
	{
		if (targ.health < -15)
		{
			bprint (" burst into flames\n");
			return;
		}
		if (rnum < 0.5)
			bprint (" turned into hot slag\n");
		else
			bprint (" visits the volcano god\n");
	}
	else if (dt == "waterdouse")
	{
		if (rnum < 0.5)
			bprint (" learned about fire and water\n");
		else
			bprint ("'s fire was extinguished\n");
	}

	// fell to their death?
	else if (dt == "falling")
		bprint (" fell to his death\n");

	// hell if I know; he's just dead!!!
	else
	{
		bprint (" mysteriously died (");
		bprint (attacker.classname);
		if (dt != string_null)
		{
			bprint ("/");
			bprint (dt);
		}
		bprint (")\n");
	}

};
