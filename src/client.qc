/*
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

void ()
SetChangeParms =
{
	// Prevent SetNewParms() for dead phoenix rune holders.
	if (self.health <= 0 && self.runetype == RN_PHOENIX)
		self.health = 100;

	if (self.health <= 0 || SET_PARMS_WITH_NEW_LEVEL)
	{
		SetParms ();
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
	parm11 = self.aqflags;
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


};

// This is the very first QC function to be called when a client
// connects.  It's only called once by the engine, but I call it
// every time someone dies and is about to respawn.
void ()
SetNewParms =
{
	parm1	= IT_SHOTGUN | IT_AXE;
	parm2	= MAX_HEALTH_NORMAL;
	parm3	= 0;
	parm4	= 25;
	parm5	= 0;
	parm6	= 0;
	parm7	= 0;
	parm8	= 1;
	parm9	= 0;
	parm10	= 0;
	parm11	= 0;
	parm12	= 0;
	parm13	= 0;
	parm14	= 0;
	parm15	= 0;
	parm16	= 0;
};

// Called directly before the client respawns.
void ()
SetParms =
{
	SetNewParms ();

	parm1	= parm1 | (self.items & IT_KEY2);
	parm11	= self.aqflags - self.aqflags & AQ_HOOK;
	parm14	= self.rqflags;
};

void ()
SetPracticeParms =
{
	self.items		= IT_AXE | IT_SHOTGUN | IT_SUPER_SHOTGUN | IT_NAILGUN | IT_SUPER_NAILGUN
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
	self.weapon		= 0;

	set_weapon (IT_ROCKET_LAUNCHER);

	self.armortype		= ARMOR_TYPE_3;
};

void ()
SetArenaParms =
{
	self.items		= IT_AXE | IT_SHOTGUN | IT_SUPER_SHOTGUN | IT_NAILGUN | IT_SUPER_NAILGUN
						| IT_GRENADE_LAUNCHER | IT_ROCKET_LAUNCHER | IT_LIGHTNING
						| IT_ARMOR3;

	self.health		= MAX_HEALTH_NORMAL;
	self.armorvalue		= MAX_ARMOR_3;
	self.ammo_shells	= 30;
	self.ammo_nails		= 80;
	self.ammo_rockets	= 30;
	self.ammo_cells		= 30;

	// Setting self.weapon is necessary because you retain your
	// weapon setting across deaths.  If you die with the single
	// shotgun set_weapon() won't do anything when this tries to set
	// your weapon because it thinks you're already wielding that.
	self.weapon		= 0;

	set_weapon (IT_ROCKET_LAUNCHER);

	self.armortype		= ARMOR_TYPE_3;
};

void ()
SetMidairParms =
{
	self.items		= IT_AXE | IT_ROCKET_LAUNCHER | IT_ARMOR3;
	self.health		= MAX_HEALTH_MIDAIR;
	self.armorvalue		= MAX_ARMOR_3;
	self.ammo_shells	= 0;
	self.ammo_nails		= 0;
	self.ammo_rockets	= 100;
	self.ammo_cells		= 0;

	// Setting self.weapon is necessary because you retain your
	// weapon setting across deaths.  If you die with the single
	// shotgun set_weapon() won't do anything when this tries to set
	// your weapon because it thinks you're already wielding that.
	self.weapon		= 0;

	set_weapon (IT_ROCKET_LAUNCHER);

	self.armortype		= ARMOR_TYPE_3;
};

void ()
DecodeLevelParms =
{
	if (gamemode == MODE_ARENA)
		SetArenaParms ();
	else if (gamemode == MODE_PRACTICE)
		SetPracticeParms ();
	else if (gamemode == MODE_MIDAIR)
		SetMidairParms ();
	else
	{
		if (gamemode == MODE_MATCH)
		{
			if (match.state)
			{
				if (match_restore_ghost ())
					return;
			}
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
		self.weapon		= 0;
		set_weapon (parm8);

		// XXX For some strange reason, multiplying parm9 by 0.01 returns
		// the wrong value for red armor (0.79 instead of 0.80).  The result
		// is picking up red armor when you don't need it.  I work around it
		// by dividing by 100 instead.
		self.armortype = parm9 / 100;
	}

	Rune_Activate (parm10, 0);
	self.aqflags			= parm11;
	self.rqflags			= parm14;
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

	//objerror ("FindIntermission: no spot");
	dprint_force ("FindIntermission: no spot");
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

/*
============
IntermissionThink

When the player presses attack or jump, change to the next level
============
*/
void ()
IntermissionThink =
{
	// Reset viewport for rider during intermission.
	if (self.viewentity)
		set_viewport (self);

	// If you go into intermission with the lightning or nail
	// guns switchfiring they'll keep right on firing until the
	// intermission exits without this.
	if (self.aqstate & AQS_SWITCHFIRING)
		switchfire_off ();

	spawn_protect_off ();

	if (time < intermission_exittime)
		return;

	if (self.button0 || self.button2)
		GotoNextMap ();
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
		if (other.rqflags & RQ_AUTOSTATS)
		{
			sprint_efficiency_e (other);
			sprint_killstats_e (other);
			sprint_stats_e (other);
		}
		move_to_intermission (other);
		other = find (other, classname, "player");
	}

	proto_intermission (MSG_ALL);

	if (console_warp)
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
	if (gamemode == MODE_HEADS)
	{
		if (self.runetype == RN_PHOENIX && self.runevar > 0)
		{
			if (self.movetarget.owner == self)
				remove (self.movetarget);
		}
		self.movetarget = world;
	}

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
		SetParms ();
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
	local string dt;

	if (intermission_running)
		return;

	if (!is_player ())
	{
		sprint (self, "Observers can't suicide!\n");
		return;
	}

	// allow frozen and glued players to suicide without being kicked
	if (!self.rqstate & RQS_GUIDED_MISSILE && self.effects & EF_FROZEN)
		dt = "trapavoid";
	else
		dt = "suicide";

	see_damage (self, self, self.health + self.armorvalue);
	self.health = 0;
	Killed (self, self, dt);

	if (dt == "suicide")
		kick_suicider ();
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

		// I would eventually like to create spawn spots for standard maps,
		// and modify the map to restrict certain areaa.  For now, I will
		// use the RA method of info_teleport_destinations.
		if (gamemode & MODE_ARENA && MAP_IS_CUSTOM)
		{
			spot = find_spawn_point_class ("info_teleport_destination", lastspawn);
			if (spot)
			{
				lastspawn = spot;
				return spot;
			}
		}

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
	local vector v;
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
	self.afk = time;

	// head hunters
	self.num_heads = 0;
	self.head_chain = world;
	self.movetarget = world;

	// Prevent damage when you join the game as an observer
	// in lava or slime.
	self.waterlevel = 0;

	DecodeLevelParms ();

	if (MOD_PROTOCOL)
	{
		if (self.rqflags & RQ_LOW_BANDWIDTH_CLIENT)
			self.flags = self.flags | FL_LOW_BANDWIDTH_CLIENT;

 		if (self.rqflags & RQ_IGNORE_MUTE_CLIENT)
			self.flags = self.flags | FL_IGNORE_MUTE_CLIENT;

		if (self.rqflags & RQ_MUTE)
			self.flags = self.flags | FL_MUTE_CLIENT;
	}

	// Do not allow firing immediately after you respawn to prevent
	// your from losing your spawn shield.
	if (SPAWN_PROTECT_DURATION && !options & NO_SPAWN_SHIELDS)
	{
		self.button1 = FALSE;
		self.attack_finished = time + 1.5;
	}

	self.th_pain = player_pain;
	self.th_die = PlayerDie;

	self.deadflag = DEAD_NO;
	self.aflag = 0;

	// hack to prevent spawning at charged offset
	if (spot.oldorigin)
		v = spot.oldorigin;
	else
		v = spot.origin;

	if (!is_player_start_class (spot.classname))
		v = v + SPAWN_ITEM_OFFSET;
	else
		v = v + '0 0 1';

	setorigin (self, v);

	// arena
	if (spot.classname == "info_teleport_destination")
	{
		self.angles = spot.mangle;
		makevectors (spot.mangle);
		self.velocity = v_forward * 300;
	}
	else
	{
		self.angles = spot.angles;
		self.velocity = VEC_ORIGIN;
	}

	self.fixangle = TRUE;		// turn this way immediately

	// oh, this is a hack!
	setmodel (self, "progs/eyes.mdl");
	modelindex_eyes = self.modelindex;

	setmodel (self, "progs/player.mdl");
	modelindex_player = self.modelindex;

	setsize (self, VEC_HULL_MIN, VEC_HULL_MAX);

	self.view_ofs = PLAYER_VIEW_OFFSET;
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
	{
		if (gamemode & MODE_ARENA)
		{
			self.takedamage = DAMAGE_NO;
			if (put_client_in_arena ())
				arena_init ();
			else
				spawn_as_observer = 1;
		}
	}

	// force all players observer at start of level
	if (gamemode == MODE_MATCH)
	{
		if (!self.lefty)
		{
			self.lefty = time;
			spawn_as_observer = 1;
			parm12 = 0;
			parm13 = 0;
		}
	}

	// You can't do the player init here because stuffcmd doesn't
	// work yet, but doing it from a newly spawned entity's think
	// function works.  Go figure.
	if (newplayer)
	{
		self.aqflags = self.aqflags | AQ_INIT_DONE | AQ_NO_HUD;
		self.rqflags = self.rqflags | RQ_CYCLE_ALTERNATES;
		player_init_spawn ();
	}
	else if (!self.rqflags & RQ_BINDINGS_RECEIVED)
	{
		local entity e;

		// check to make sure bindings aren't already being sent
		e = find (world, classname, "spawn_player_bindings");
		while (e)
		{
			if (e.owner == self)
				newplayer = 1;
			e = find (e, classname, "spawn_player_bindings");
		}

		if (!newplayer)
			spawn_player_bindings ();
	}

	if (spawn_as_observer)
	{
		obs_become (0);
		self.runevar = parm12;
		// If she was a rider, get her back on the right horse.
		if (parm13)
		{
			self.aqstate = self.aqstate | ((parm13 & 3) * AQS_RIDE_DIV);
			parm13 = (parm13 - parm13 & 3) / 4;
			spot = spawn ();
			spot.owner = self;
			spot.enemy = player_num_to_ent (parm13);
			spot.think = rider_wait_think;
			spot.runetime = time + 15;	// time out
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
		if (SPAWN_PROTECT_DURATION > 0 && !options & NO_SPAWN_SHIELDS)
		{
			self.invincible_finished = time + SPAWN_PROTECT_DURATION;
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
	if (gamemode == MODE_HEADS)
		altar_place ();
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
			serverflags = serverflags - serverflags & SERVERFLAGS_RUNE_MASK + 1;
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
	if (intermission_running)
	{
		if (INTERMISSION_AUTO_EXIT >= 0 && time >= intermission_exittime + INTERMISSION_AUTO_EXIT)
			GotoNextMap ();
	}

	if (gameover)	// someone else quit the game already
		return;

	timelimit = cvar ("timelimit") * 60;
	fraglimit = cvar ("fraglimit");

	if (!timelimit)
		return;

	if (gamemode == MODE_MATCH)
		return;

	if (gamemode & MODE_ARENA && arena.delay)
		return;

	if (time >= timelimit)
	{
		forced_nextmap = string_null;
		NextLevel ();
		return;
	}
};

//============================================================================

void ()
PlayerDeathThink =
{
	local float forward;

	if (gamemode == MODE_MATCH)
	{
		if (match.style > time)
			return;

		if (!match.state)
			self.style = 0;

		if (self.style < time)
		{
			respawn ();
			return;
		}
	}
	else if (gamemode & MODE_ARENA)
	{
		arena_death_think ();
		return;
	}
	else if (gamemode == MODE_HEADS)
		head_death_think ();

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
		if (!self.aflag)
			self.aflag = time + AUTO_CORPSE_OBSERVER;
		else if (time <= self.aflag)
			SUB_Null ();
		else
		{
			if (corpse_to_observer (2))
				return;
			// She couldn't become an observer, don't try
			// again immediately.
			self.aflag = time + AUTO_CORPSE_OBSERVER;
		}
	}

	// wait for all buttons released
	if (self.deadflag == DEAD_DEAD)
	{
		if (self.button2 || self.button0)
			return;
		self.deadflag = DEAD_RESPAWNABLE;
		return;
	}

	// Prevent phoenix holders from firing.
	if (self.runetype == RN_PHOENIX)
	{
		// Warn phoenix users.
		centerprint (self, "\<\bwarning\b\>\nphoenix rune detected\nuse jump to respawn");

		// Don't let phoenix holder respawn until she comes to a stop.
		if (!self.flags & FL_ONGROUND)
		{
			// Allows you to respawn if your corpse gets pushed outside the level
			// or takes too long to come to a complete stop.
			if (self.runetime > time && pointcontents (self.origin) != CONTENT_SOLID)
				return;
		}

		if (!self.button2 || self.aqflags & AQ_KICKED)
			return;
	}
	else
	{
		// wait for any button down
		if ((!self.button2 && !self.button0) || self.aqflags & AQ_KICKED)
			return;
	}

	// self.button0 = 0;
	self.button2 = 0;

	// prevent accidental discharge when respawning
	self.button1 = TRUE;

	respawn ();
};

void ()
PlayerJump =
{
	// Cancel guided missile.
	if (self.rqstate & RQS_GUIDED_MISSILE)
	{
		if (self.attack_finished <= time)
			restore_gmissile_owner (self);

		self.flags = self.flags - self.flags & FL_JUMPRELEASED;
		return;
	}

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

void ()
WaterMove =
{
	if (self.movetype == MOVETYPE_NOCLIP)
		return;

	if (self.health <= 0)
		return;

	if (self.deadflag)
		return;

	if (self.waterlevel)
	{
		// Player enters liquid.
		if (!self.flags & FL_INWATER)
		{
			if (self.watertype == CONTENT_WATER)
				sound (self, CHAN_BODY, "player/inh2o.wav", 1, ATTN_NORM);
			else if (self.watertype == CONTENT_SLIME)
				sound (self, CHAN_BODY, "player/slimbrn2.wav", 1, ATTN_NORM);
			else if (self.watertype == CONTENT_LAVA)
				sound (self, CHAN_BODY, "player/inlava.wav", 1, ATTN_NORM);

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
			set_current_ammo ();
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
			T_Damage (self, world, world, 4 * self.waterlevel, "waterdouse");
		}

		if (self.watertype == CONTENT_LAVA)
		{
			// human torch: allow lava baths
			if (self.dmgtime < time
					&& self.radsuit_finished < time
					&& self.runetype != RN_TORCH
					&& !(self.runetype == RN_FIREWALK && self.waterlevel == 1))
			{
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
		// Player exits liquid.
		if (self.flags & FL_INWATER)
		{
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
		if (!self.flags & FL_WATERJUMP)
			self.velocity = self.velocity - 0.8 * self.waterlevel * frametime * self.velocity;
		else if (self.velocity_z == 0)
			self.flags = self.flags - self.flags & FL_WATERJUMP;
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
	end = start + v_forward * 24;
	traceline (start, end, TRUE, self);
	if (trace_fraction < 1)
	{	// solid at waist
		start_z = start_z + self.maxs_z - 8;
		end = start + v_forward * 24;
		self.movedir = trace_plane_normal * -50;
		traceline (start, end, TRUE, self);
		if (trace_fraction == 1)
		{	// open at eye level
			self.flags = self.flags | FL_WATERJUMP;
			self.velocity_z = 225;
			self.flags = self.flags - (self.flags & FL_JUMPRELEASED);
			self.teleport_time = time + 2;	// safety net
		}
	}
};

float (entity e)
client_ping =
{	IN_QW(return 1;)
	local float i, ping;

	for (i = 0 ; i < %16 ; i = i + %1)
		ping = ping + (e.cl[CL_PING_TIMES + i] * 1000);

	ping = floor (ping / 16);
	if (ping < 0)
		ping = 0;
	else if (ping > 9999)
		ping = 9999;

	return ping;
};

void ()
client_ping_times =
{
	local entity e;
	local float ping;
	local string s;

	dprint_force ("Client ping times:\n");

	e = find (world, classname, "player");
	while (e)
	{
		ping = client_ping (e);
		s = ftos (ping);
		self_sprintf_len (world, s, 4);
		dprint_force (" ");
		dprint_force (e.netname);
		dprint_force ("\n");
		e = find (e, classname, "player");
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
	local float i, obs, mm;

	self.last_thought = time;
	if (intermission_running)
	{
		IntermissionThink ();	// otherwise a button could be missed between
		return;					// the think tics
	}
	if (!is_valid_player ())
		return;
	obs = is_observer ();
	mm = gamemode == MODE_MATCH;

	// player is afk, check every tick for his return
	if (self.rqstate & RQS_AFK)
	{
		if (self.button0 || self.button2)
			self.afk = time;
	}

	// updates
	if (self.lefty < time)
	{
		self.lefty = time + 1;

		// mute client
		if (!MOD_PROTOCOL)
		{
			if (self.rqflags & RQ_MUTE)
				self.cl[CL_SPAM_TIME + %1] = sv[SV_TIME + %1];
		}

		// ping
		self.delay = client_ping (self);

		// lagged notify
		if (self.delay == 9999)
		{
			if (!self.rqstate & RQS_LAGGED_OUT)
			{
				self.rqstate = self.rqstate | RQS_LAGGED_OUT;
				bprint (self.netname);
				bprint (" lagged out\n");
			}
		}
		else
		{
			if (self.rqstate & RQS_LAGGED_OUT)
				self.rqstate = self.rqstate - self.rqstate & RQS_LAGGED_OUT;
		}

		// +teamscores
		if (self.rqflags & RQ_TEAMSCORES_ON)
			teamscores_on (self);

		// update players activity so we know he's not afk
		if (self.button0 || self.button1 || self.cl[CL_CMD_FORWARD] || self.cl[CL_CMD_SIDE])
			self.afk = time;

		// check if a player is afk or returning from afk
		if (self.rqstate & RQS_AFK)
		{
			if (self.afk + 5 > time)
			{
				self.rqstate = self.rqstate - self.rqstate & RQS_AFK;
				svc_updatename_hack (world, self);
			}
		}
		else
		{
			if (AFK_TIME)
			{
				if (self.afk < time - AFK_TIME * 60 && !is_qsmack () IN_QW(&& 0))
				{
					self.rqstate = self.rqstate | RQS_AFK;
					svc_updatename_hack (world, self);
				}
			}
		}

		// check for name change of readied or afk player
		if (self.rqstate & RQS_AFK || (!match.state && self.rqstate & RQS_READY))
		{
			if (self.netname != READY_NAME_16[((self.colormap - 1) * %1) * 16])
			{
				strcpy (READY_NAME_16[((self.colormap - 1) * %1) * 16], self.netname);
				svc_updatename_hack (world, self);
			}
		}
	}

	if (self.aqstate & AQS_MENU_MASK && time > self.count)
		aq_menu_print ();

	if (self.waitmax)
	{
		if (self.deadflag || (obs && self.owner.deadflag))
			rune_tell_stop (0);
		else if (self.waitmax > 0 && time > self.waitmax)
			rune_tell_refresh ();	// refresh
		else if (self.waitmax < 0 && 0 - self.waitmax + CENTERPRINT_TIME < time)
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
	if (mm)
		match_pre_think ();
	else if (teamplay & TEAM_TEAM_MASK)
	{
		if (!is_correct_team ())	// no short circuiting!
		{
			if (is_allowable_team ())
				set_team_e (self, self.team);
			else if (self.aqflags & AQ_TEAM_MASK && !obs)
			{
				// sure_kill ("teamchange");
				// kick_suicider ();
				i = correct_team ();
				set_team_e (self, i);
			}
			else
				assign_teams (self);
		}
	}

	// The call of CheckRules() moved to StartFrame().
	if (fraglimit && self.frags >= fraglimit)
	{
		forced_nextmap = string_null;
		NextLevel ();
	}

	if (obs)
	{
		obs_pre_think ();
		return;
	}

	WaterMove ();

	if (self.deadflag)
	{
		if (self.deadflag >= DEAD_DEAD)
			PlayerDeathThink ();
  		return;
	}

	IN_POQ([-
		if (self.waterlevel == 2)
			CheckWaterJump ();
	-])

	if (self.button2)
		PlayerJump ();
	else
		self.flags = self.flags | FL_JUMPRELEASED;

	if (self.runetype > 0)
		Rune_Think ();

	if (time > self.attack_finished && self.currentammo == 0)
	{
		if (self.weapon != IT_AXE && self.weapon != WEAPON_HOOK)
			set_weapon (W_BestWeapon ());
	}
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
	if (intermission_running)
		return;

	if (!is_valid_player ())
		return;

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

	W_WeaponFrame ();

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

	if (gamemode == MODE_HEADS)
		head_carry ();

	if (self.runetype)
		Rune_PostThink ();

	if (!self.aqflags & AQ_NO_HUD)
		draw_hud (0);
};

void ()
client_ip =
{
	local float px, pch, i, oc, dot;
	local string new, ch;
	local string octet = "abc";

	new = net_address ();
	self.address = @AddInt (&new, %32);
	strcpy (self.address, new);

	px = AddInt(&"\{0}  ", PSTRING_TO_PQUAKEC);
	pch = AddInt(AddInt(&self.address, PSTRING_TO_PQUAKEC), %-4);

	&%116 = 0;
	for (i = 0; i < 16; i = i + 1)
	{
		pch = AddInt (pch, %1);
		&%113 = (*pch)[0];

		if (world[%5] == ':')
			i = 16;
		else if (world[%5] == '.')
		{
			dot = dot + 1;
			oc = 0;

			if (dot == 1)
				self.subnet_x = stof (octet);
			else if (dot == 2)
				self.subnet_y = stof (octet);
			else if (dot == 3)
				self.subnet_z = stof (octet);
		}
		else
		{
			if (oc < %3)
			{
				ch = atoc (world[%5] / %1);
				if (ch)
					strcpy (octet[oc], ch);
			}
			oc = oc + %1;
		}
	}

	pch = AddInt(pch, %3);
	(*pch)[0] = (*px)[0];

	self.packed = self.subnet_x + (self.subnet_y * 256) + (self.subnet_z * 65536);
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

	if (*HUNK_CONTEXT)
	{
		if (ban_check (self.packed) >= 0)
		{
			localcmd ("ban ");
			localcmd (self.address);
			localcmd (" 255.255.255.255\n");
			kick (string_null, string_null);
		}
	}

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
	local entity e;
	local float i;

	qsmack_status_valid = 0;

	i = !self.cl[CL_ACTIVE] / %1;

	// Don't print the disconnect message for players forwarding or
	// think()ing about forwarding.
	e = find (world, classname, "player_forward_think");
	while (e)
	{
		if (e.owner == self)
			i = 1;
		e = find (e, classname, "player_forward_think");
	}

	if (!i)
	{
		bprint (self.netname);
		bprint (" left the game with ");
		bprint_float (self.frags);
		bprint (" frags\n");
		sound (self, CHAN_BODY, "player/tornoff2.wav", 1, ATTN_NONE);
	}

	if (gamemode == MODE_MATCH)
		match_client_disconnect ();
	else if (gamemode & MODE_ARENA)
		arena_client_disconnect ();
	else if (gamemode == MODE_HEADS)
		head_drop ();

	spawn_protect_off ();
	forget_rune_owner ();

	if (is_rider ())
		obs_rider_drop (0);

	self.classname	= "deader";
	self.health	= 0;
	self.runetype	= 0;
	self.aqflags	= 0;	// for AQ_INIT_DONE, for is_valid_player()
	self.rqflags	= 0;
	self.effects	= 0;

	// Set frags so the "unconnected" status list entry for the next
	// player to get this slot (which can last for a while) isn't
	// confusing.
	self.frags	= -99;

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
	local float attacker_player, rnum, f, mm;
	local string attacker_name, s1, s2;

	if (targ.classname != "player")
		return;

	mm = gamemode == MODE_MATCH;
	if (mm)
	{
		if (!match.state)
			return;
	}

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
			IN_QW(logfrag (attacker.owner, targ);)
			attacker.owner.enemy_kills = attacker.owner.enemy_kills + 1; // killstats
			targ.killed = targ.killed + 1; // killstats
		}
		else
		{
			bprint (targ.netname);
			bprint (" was smashed by a rogue shambler\n");
			targ.killed = targ.killed + 1; // killstats
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
			IN_QW(logfrag (attacker.owner, targ);)
			attacker.owner.enemy_kills = attacker.owner.enemy_kills + 1; // killstats
			targ.killed = targ.killed + 1; // killstats
		}
		else
		{
			bprint (targ.netname);
			bprint (" joined somebody's zombies\n");
			targ.killed = targ.killed + 1; // killstats
		}
		return;
	}

	if (targ.classname == "player" && dt == "squish")
	{
		if ((teamplay & TEAM_FRAG_PENALTY || mm)
				&& targ.team > 0
				&& targ.team == attacker.team
				&& targ != attacker)
		{
			add_frag (attacker, -1);
			IN_QW(logfrag (attacker, attacker);)
			attacker.mate_kills = attacker.mate_kills + 1; // killstats
			bprint (attacker_name);
			bprint (" squishes teammate ");
			bprint (targ.netname);
			bprint ("\n");
		}
		else if (attacker_player && targ != attacker)
		{
			add_frag (attacker, 1);
			IN_QW(logfrag (attacker, targ);)
			attacker.enemy_kills = attacker.enemy_kills + 1; // killstats
			targ.killed = targ.killed + 1; // killstats
			bprint (attacker_name);
			bprint (" squishes ");
			bprint (targ.netname);
			bprint ("\n");
		}
		else
		{
			add_frag (targ, -1);
			IN_QW(logfrag (targ, targ);)
			targ.suicide = targ.suicide + 1; // killstats
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
			else if (dt == "trapavoid")
				bprint (" suicides to avoid a trap\n");
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
			else if (dt == "reflect")
				bprint (" pretends his rocket is a boomerang\n");
			else if (dt == "gmissile")
				bprint (" decided to use his rocket as a suppository\n");
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
			{
				add_frag (attacker, f);
				IN_QW(logfrag (attacker, attacker);)
				attacker.suicide = attacker.suicide + 1; // killstats
			}
			return;
		}

		if ((teamplay & TEAM_FRAG_PENALTY || mm)
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
			IN_QW(logfrag (attacker, attacker);)
			attacker.mate_kills = attacker.mate_kills + 1; // killstats
			return;
		}

		if (gamemode != MODE_HEADS)
		{
			add_frag (attacker, 1);
			IN_QW(logfrag (attacker, targ);)
		}

		attacker.enemy_kills = attacker.enemy_kills + 1; // killstats
		targ.killed = targ.killed + 1; // killstats

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
		else if (dt == "reflect")
		{
			s1 = " used his face to ricochet ";
			s2 = "'s rocket\n";
		}
		else if (dt == "gmissile")
		{
			s1 = " couldn't escape ";
			s2 = "'s guided missile\n";
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
	IN_QW(logfrag (targ, targ);)
	targ.suicide = targ.suicide + 1; // killstats
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
