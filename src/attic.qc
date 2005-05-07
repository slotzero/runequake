/*  $Id: attic.qc,v 1.8 2005/05/07 06:15:38 slotzero Exp $

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

// These functions I no longer use.

void ()
jctrig =
{
	dprint ("here\n\n");
	lightstyle (0, "az");
};

/*QUAKED trigger_jctest (.5 .5 .5) ?
*/
void ()
trigger_jctest =
{
	setsize (self, self.mins, self.maxs);
	self.solid = SOLID_EDGE;
	self.touch = jctrig;
};

void ()
noise_think =
{
	self.nextthink = time + 0.5;
	sound (self, 1, "enforcer/enfire.wav", 1, ATTN_NORM);
	sound (self, 2, "enforcer/enfstop.wav", 1, ATTN_NORM);
	sound (self, 3, "enforcer/sight1.wav", 1, ATTN_NORM);
	sound (self, 4, "enforcer/sight2.wav", 1, ATTN_NORM);
	sound (self, 5, "enforcer/sight3.wav", 1, ATTN_NORM);
	sound (self, 6, "enforcer/sight4.wav", 1, ATTN_NORM);
	sound (self, 7, "enforcer/pain1.wav", 1, ATTN_NORM);
};

/*QUAKED misc_noisemaker (1 0.5 0) (-10 -10 -10) (10 10 10)
For optimzation testing, starts a lot of sounds.
*/
void ()
misc_noisemaker =

{
	precache_sound ("enforcer/enfire.wav");
	precache_sound ("enforcer/enfstop.wav");
	precache_sound ("enforcer/sight1.wav");
	precache_sound ("enforcer/sight2.wav");
	precache_sound ("enforcer/sight3.wav");
	precache_sound ("enforcer/sight4.wav");
	precache_sound ("enforcer/pain1.wav");
	precache_sound ("enforcer/pain2.wav");
	precache_sound ("enforcer/death1.wav");
	precache_sound ("enforcer/idle1.wav");

	self.nextthink = time + sys_ticrate + random ();
	self.think = noise_think;
};

/* QUAKED noclass (0 0 0) (-8 -8 -8) (8 8 8)
prints a warning message when spawned
*/
void ()
noclass =
{
	dprint ("noclass spawned at");
	dprint (vtos (self.origin));
	dprint ("\n");
	remove (self);
};

/*~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>
~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~*/

/*QUAKED test_teleport (0 .5 .8) ?
Teleporter testing
*/

void ()
test_teleport =
{
	precache_model ("sprites/s_aball.spr");
	setsize (self, self.mins, self.maxs);
	self.touch = test_teleport_touch;
	self.solid = 1;

	if (!self.target)
		objerror ("no target\n");
};

void ()
test_teleport_touch =
{
	local entity oldself;

	other.movetype = MOVETYPE_TOSS;
	//other.solid = SOLID_NOT;
	other.dest = '256 -128 -128';
	oldself = self;
	self = other;
	//SUB_CalcMove (self.dest, 200, tele_done);
	self.velocity = '1000 0 0 ';
	self = oldself;
};

void ()
tele_done =
{
	self.movetype = MOVETYPE_WALK;
	self.solid = SOLID_SLIDEBOX;
};

/*~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>
~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~*/

/*QUAKED test_fodder (0 .5 .8) ?
beating guy
*/
void ()
test_fodder =
{
	self.nextthink = time + 3;
	self.think = test_spawn;
};

void ()
test_spawn =
{
	local entity	body;

	makevectors (self.angles);
	body = spawn ();
	setmodel (body, "progs/soldier.mdl");
	setorigin (body, self.origin);
	body.classname = "player";
	body.health = 1000;
	body.frags = 0;
	body.takedamage = DAMAGE_AIM;
	body.solid = SOLID_SLIDEBOX;
	body.movetype = MOVETYPE_WALK;
	body.show_hostile = 0;
	body.weapon = 1;
	body.velocity = v_forward * 200;
	body.nextthink = time + 5;
	body.think = test_goaway;
	self.nextthink = time + 3;
	self.think = test_spawn;
};

void ()
test_goaway =
{
	remove (self);
};

/*
===========
ValidateUser
============
*/
float(entity e) ValidateUser =
{

	local string    s;
	local string    userclan;
	local float     rank, rankmin, rankmax;

//
// if the server has set "clan1" and "clan2", then it
// is a clan match that will allow only those two clans in
//
	s = serverinfo ("clan1");
	if (s)
	{
		userclan = masterinfo (e,"clan");
		if (s == userclan)
			return true;
		s = serverinfo ("clan2");
		if (s == userclan)
			return true;
		return false;
	}

//
// if the server has set "rankmin" and/or "rankmax" then
// the users rank must be between those two values
//
	s = masterinfo (e, "rank");
	rank = stof (s);

	s = serverinfo ("rankmin");
	if (s)
	{
		rankmin = stof (s);
		if (rank < rankmin)
			return false;
	}
	s = serverinfo ("rankmax");
	if (s)
	{
		rankmax = stof (s);
		if (rankmax < rank)
			return false;
	}

	return true;
};

// At one point this was called to calculate which spawn point to choose,
// but it caused problems as it fixed them.  It's annoying always to
// respawn as far away from everything as possible.
//
// I tried several algorithms for this before giving up on this idea.
// This algorithm is to return the distance from this point to the
// closest player, the caller would maximize this value in choosing the
// spawn point.

.float distance;

float (entity for_e, vector pos)
player_spawn_distance =
{
	local entity e;
	local float this_dist, min_dist;
	local vector v;

	if (0)
	{
		dprint ("player_spawn_distance ");
		dprint_vec (pos);
		dprint (":\n");
	}
	min_dist = -1;
	e = find (world, classname, "player");
	while (e)
	{
		if (e != for_e && !is_observer_e (e) && e.health >= 0)
		{
			v = pos - e.origin;
			this_dist = vlen (v);
			if (0)
			{
				dprint (" ");
				dprint_vec (e.origin);
				dprint (" yields ");
				dprint_float (this_dist);
				dprint ("\n");
			}
			if (min_dist == -1 || this_dist < min_dist)
				min_dist = this_dist;
		}
		e = find (e, classname, "player");
	}
	if (0)
	{
		dprint (" returning ");
		dprint_float (min_dist);
		dprint ("\n");
	}
	return min_dist;
};

//============================================================================

//
// globals
//
float	current_yaw;

/*
===========
ChangeYaw

Turns towards self.ideal_yaw at self.yaw_speed
Sets the global variable current_yaw
Called every sys_ticrate sec by monsters
============
*/
/*

void ()
ChangeYaw =
{
	local floa ideal, move;

	//current_yaw = self.ideal_yaw;
	// mod down the current angle
	current_yaw = anglemod (self.angles_y);
	ideal = self.ideal_yaw;

	if (current_yaw == ideal)
		return;

	move = ideal - current_yaw;
	if (ideal > current_yaw)
	{
		if (move > 180)
			move = move - 360;
	}
	else
	{
		if (move < -180)
			move = move + 360;
	}

	if (move > 0)
	{
		if (move > self.yaw_speed)
			move = self.yaw_speed;
	}
	else
	{
		if (move < 0-self.yaw_speed)
			move = 0-self.yaw_speed;
	}

	current_yaw = anglemod (current_yaw + move);

	self.angles_y = current_yaw;
};

*/

/*
============
CheatCommand
============
*/
void ()
CheatCommand =
{
	if (deathmatch & DM_DM_MASK || coop)
		return;

	self.ammo_rockets	= MAX_ROCKETS;
	self.ammo_nails		= MAX_NAILS;
	self.ammo_shells	= MAX_SHELLS;
	self.ammo_cells		= MAX_CELLS;
	self.items = self.items |
		IT_AXE |
		IT_SHOTGUN |
		IT_SUPER_SHOTGUN |
		IT_NAILGUN |
		IT_SUPER_NAILGUN |
		IT_GRENADE_LAUNCHER |
		IT_ROCKET_LAUNCHER |
		IT_LIGHTNING |
		IT_KEY1 | IT_KEY2;

	set_weapon (W_BestWeapon ());
};

/*
============
ServerflagsCommand

Just for development
============
*/
void ()
ServerflagsCommand =
{
	if (serverflags & SERVERFLAGS_RUNE_MASK == SERVERFLAGS_RUNE_MASK)
		serverflags = 0;
	else
		serverflags = serverflags
				- (serverflags & SERVERFLAGS_RUNE_MASK)
				+ ((serverflags & SERVERFLAGS_RUNE_MASK) * 2)
				+ 1;
};

void ()
QuadCheat =
{
	if (deathmatch & DM_DM_MASK || coop)
		return;
	self.super_time = -1;
	self.super_damage_finished = time + 30;
	self.items = self.items | IT_QUAD;
	dprint ("quad cheat\n");
};

float (float bits)
bits_in_bits =
{
	local float n;

	if (bits & 1)
		n = n + 1;
	if (bits & 2)
		n = n + 1;
	if (bits & 4)
		n = n + 1;
	if (bits & 8)
		n = n + 1;
	if (bits & 16)
		n = n + 1;
	if (bits & 32)
		n = n + 1;
	if (bits & 64)
		n = n + 1;
	if (bits & 128)
		n = n + 1;
	if (bits & 256)
		n = n + 1;
	if (bits & 512)
		n = n + 1;
	if (bits & 1024)
		n = n + 1;
	if (bits & 2048)
		n = n + 1;
	if (bits & 4096)
		n = n + 1;
	if (bits & 8192)
		n = n + 1;
	if (bits & 16384)
		n = n + 1;
	if (bits & 32768)
		n = n + 1;
	if (bits & 65536)
		n = n + 1;
	if (bits & 131072)
		n = n + 1;
	if (bits & 262144)
		n = n + 1;
	if (bits & 524288)
		n = n + 1;
	if (bits & 1048576)
		n = n + 1;
	if (bits & 2097152)
		n = n + 1;
	if (bits & 4194304)
		n = n + 1;
	if (bits & 8388608)
		n = n + 1;

	return n;
};

float (float cl_colors)
cl_colors_to_shirt =
{
	return floor (cl_colors / %1 / 16);
};

float (float cl_colors)
cl_colors_to_pants =
{
	local float shirt;

	shirt = floor (cl_colors / %1 / 16);
	shirt = shirt * 16;
	return cl_colors / %1 - shirt;
};
