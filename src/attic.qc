/*  $Id: attic.qc,v 1.2 2003/04/14 00:56:09 slotzero Exp $

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
