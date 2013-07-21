/*  $Id: misc.qc,v 1.24 2005/11/05 23:52:05 slotzero Exp $

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

/*QUAKED info_null (0 0.5 0) (-4 -4 -4) (4 4 4)
Used as a positional target for spotlights, etc.
*/
void ()
info_null =
{
	remove (self);
};

/*QUAKED info_notnull (0 0.5 0) (-4 -4 -4) (4 4 4)
Used as a positional target for lightning.
*/
/* void ()
info_notnull =
{
};
*/

//============================================================================

/*QUAKED misc_fireball (0 .5 .8) (-8 -8 -8) (8 8 8)
Lava Balls
*/
void ()
misc_fireball =
{
	self.classname	= "fireball";
	self.nextthink	= time + 0.1 + (random () * 5);
	self.think	= fireball_think;

	if (!self.speed)
		self.speed = 1000;
};

void ()
fireball_think =
{
	local entity e;

	e		= spawn ();
	e.solid		= SOLID_TRIGGER;
	e.movetype	= MOVETYPE_TOSS;
	e.velocity	= '0 0 1000';
	e.velocity_x	= (random () * 100) - 50;
	e.velocity_y	= (random () * 100) - 50;
	e.velocity_z	= self.speed + (random () * 200);
	e.classname	= "fireball";

	setmodel (e, "progs/lavaball.mdl");
	setsize (e, VEC_ORIGIN, VEC_ORIGIN);
	setorigin (e, self.origin);

	e.nextthink	= time + 5;
	e.think		= SUB_Remove;
	e.touch		= fireball_touch;

	self.nextthink	= time + (random () * 5) + 3;
	self.think	= fireball_think;
};

void ()
fireball_touch =
{
	T_Damage (other, self, self, 20, "lavaball");
	remove (self);
};

//============================================================================

void ()
respawn_barrel =
{
	if (!safe_spawn_point (self))
	{
		self.nextthink = time + 5;
		return;
	}

	self.health	= self.max_health;
	self.takedamage	= DAMAGE_AIM;
	self.solid	= SOLID_BBOX;
	self.model	= self.mdl;

	sound (self, CHAN_VOICE, "items/itembk2.wav", 1, ATTN_NORM);

	setorigin (self, self.origin);
};

void ()
barrel_explode_real =
{
	self.takedamage = DAMAGE_NO;

	T_RadiusDamage (RADIUS_NORMAL, self, self.oldenemy, 160, world, "barrel");

	if (deathmatch & DM_DM_MASK && BARREL_RESPAWN_TIME > 0)
	{
		local entity e;

		self.solid	= SOLID_NOT;
		self.model	= string_null;
		self.think	= respawn_barrel;
		self.nextthink	= time + BARREL_RESPAWN_TIME;
		// Create a new entity to make the explosion.
		e		= spawn ();
		e.origin	= self.origin;
		self		= e;
	}
	IN_POQ([-
		particle (self.origin, VEC_ORIGIN, PARTICLE_BARREL, 255);
	-])
	self.origin_z = self.origin_z + 32;
	create_te_explosion (self.origin, 1);
};

void ()
barrel_explode =
{
	// I've modified Killed() so it sets other to the attacker which
	// exploded me.
	self.oldenemy = other;
	self.think = barrel_explode_real;
	self.nextthink = time;
};

/*QUAKED misc_explobox (0 .5 .8) (0 0 0) (32 32 64)
TESTING THING
*/
void ()
misc_explobox =
{
	local float oldz;

	self.solid	= SOLID_BBOX;
	self.touch	= misc_touch;
	self.movetype	= MOVETYPE_NONE;
	self.mdl	= "maps/b_explob.bsp";

	precache_model (self.mdl);
	setmodel (self, self.mdl);
	IN_QW([-
		setsize (self, VEC_ORIGIN, '32 32 64');
	-])

	self.health	= self.max_health = 20;
	self.th_die	= barrel_explode;
	self.takedamage	= DAMAGE_AIM;

	self.origin_z	= self.origin_z + 2;
	oldz = self.origin_z;
	droptofloor ();
	if (oldz - self.origin_z > 250)
	{
		dprint ("item fell out of level at ");
		dprint_vec (self.origin);
		dprint ("\n");
		remove (self);
	}
};

/*QUAKED misc_explobox2 (0 .5 .8) (0 0 0) (32 32 64)
Smaller exploding box, REGISTERED ONLY
*/
void ()
misc_explobox2 =
{
	local float oldz;

	self.solid	= SOLID_BBOX;
	self.touch	= misc_touch;
	self.movetype	= MOVETYPE_NONE;
	self.mdl	= "maps/b_exbox2.bsp";

	precache_model (self.mdl);
	setmodel (self, self.mdl);
	IN_QW([-
		setsize (self, VEC_ORIGIN, '32 32 32');
	-])

	self.health	= self.max_health = 20;
	self.th_die	= barrel_explode;
	self.takedamage	= DAMAGE_AIM;

	self.origin_z	= self.origin_z + 2;
	oldz = self.origin_z;
	droptofloor ();
	if (oldz - self.origin_z > 250)
	{
		dprint ("item fell out of level at ");
		dprint_vec (self.origin);
		dprint ("\n");
		remove (self);
	}
};

//============================================================================

float SPAWNFLAG_SUPERSPIKE	= 1;
float SPAWNFLAG_LASER		= 2;

void ()
Laser_Touch =
{
	local vector org;

	if (other == self.owner)
		return;		// don't explode on owner

	if (pointcontents (self.origin) == CONTENT_SKY)
	{
		remove (self);
		return;
	}

	sound (self, CHAN_WEAPON, "enforcer/enfstop.wav", 1, ATTN_STATIC);
	org = self.origin - 8*normalize (self.velocity);

	if (other.health)
	{
		SpawnBlood (org, self.velocity*0.2, IN_POQ(15, 1));
		T_Damage (other, self, self.owner, 15, string_null);
	}
	else
		create_te_gunshot (org, 1);

	remove (self);
};

void (vector org, vector vec)
LaunchLaser =
{
//nomonster	if (self.classname == "monster_enforcer")
//nomonster		sound (self, CHAN_WEAPON, "enforcer/enfire.wav", 1, ATTN_NORM);

	vec		= normalize (vec);

	newmis		= spawn ();
	newmis.owner	= self;
	newmis.movetype	= MOVETYPE_FLY;
	newmis.solid	= SOLID_BBOX;
	newmis.effects	= EF_DIMLIGHT;

	setmodel (newmis, "progs/laser.mdl");
	setsize (newmis, VEC_ORIGIN, VEC_ORIGIN);
	setorigin (newmis, org);

	newmis.velocity	= vec * 600;
	newmis.angles	= vectoangles (newmis.velocity);

	newmis.nextthink = time + 5;
	newmis.think	= SUB_Remove;
	newmis.touch	= Laser_Touch;
};

void ()
spikeshooter_use =
{
	if (environmental (activator))
		return;

	if (self.spawnflags & SPAWNFLAG_LASER)
	{
		sound (self, CHAN_VOICE, "enforcer/enfire.wav", 1, ATTN_NORM);
		LaunchLaser (self.origin, self.movedir);
	}
	else
	{
		sound (self, CHAN_VOICE, "weapons/spike2.wav", 1, ATTN_NORM);
		launch_spike (self.origin, self.movedir);
		newmis.velocity = self.movedir * 500;
		if (self.spawnflags & SPAWNFLAG_SUPERSPIKE)
			newmis.touch = superspike_touch;
	}
};

void ()
shooter_think =
{
	spikeshooter_use ();

	self.nextthink	= time + self.wait;

	newmis.velocity	= self.movedir * 500;
};

/*QUAKED trap_spikeshooter (0 .5 .8) (-8 -8 -8) (8 8 8) superspike laser
When triggered, fires a spike in the direction set in QuakeEd.
Laser is only for REGISTERED.
*/
void ()
trap_spikeshooter =
{
	SetMovedir ();
	self.use = spikeshooter_use;
	if (self.spawnflags & SPAWNFLAG_LASER)
	{
		precache_model ("progs/laser.mdl");
		precache_sound ("enforcer/enfire.wav");
		precache_sound ("enforcer/enfstop.wav");
	}
	else
		precache_sound ("weapons/spike2.wav");
};

/*QUAKED trap_shooter (0 .5 .8) (-8 -8 -8) (8 8 8) superspike laser
Continuously fires spikes.
"wait" time between spike (1.0 default)
"nextthink" delay before firing first spike, so multiple shooters can be stagered.
*/
void ()
trap_shooter =
{
	trap_spikeshooter ();

	if (self.wait == 0)
		self.wait = 1;

	self.nextthink	= self.nextthink + self.wait + self.ltime;
	self.think	= shooter_think;
};

/*
===============================================================================

===============================================================================
*/

/*QUAKED air_bubbles (0 .5 .8) (-8 -8 -8) (8 8 8)
testing air bubbles
*/
void ()
air_bubbles =
{
	remove (self);
};

void ()
make_bubbles =
{
	local entity e;

	e		= spawn ();
	e.movetype	= MOVETYPE_NOCLIP;
	e.solid		= SOLID_NOT;
	e.velocity	= '0 0 15';
	e.nextthink	= time + 0.5;
	e.think		= bubble_bob;
	e.touch		= bubble_remove;
	e.classname	= "bubble";
	e.frame		= 0;
	e.cnt		= 0;

	setmodel (e, "progs/s_bubble.spr");
	setorigin (e, self.origin);
	setsize (e, '-8 -8 -8', '8 8 8');

	self.nextthink	= time + random () + 0.5;
	self.think	= make_bubbles;
};

void ()
bubble_split =
{
	local entity e;

	e		= spawn ();
	e.movetype	= MOVETYPE_NOCLIP;
	e.solid		= SOLID_NOT;
	e.velocity	= self.velocity;
	e.nextthink	= time + 0.5;
	e.think		= bubble_bob;
	e.touch		= bubble_remove;
	e.classname	= "bubble";
	e.frame		= 1;
	e.cnt		= 10;
	e.effects	= EF_MAYBE_DRAW;

	setmodel (e, "progs/s_bubble.spr");
	setorigin (e, self.origin);
	setsize (e, '-8 -8 -8', '8 8 8');

	self.frame	= 1;
	self.cnt	= 10;

	if (self.waterlevel != 3)
		remove (self);
};

void ()
bubble_remove =
{
	if (other.classname == self.classname)
		return;

	remove (self);
};

void ()
bubble_bob =
{
	local float rnd1, rnd2, rnd3;

	self.cnt = self.cnt + 1;
	if (self.cnt == 4)
		bubble_split ();
	if (self.cnt == 20)
		remove (self);

	rnd1 = self.velocity_x + (-10 + (random () * 20));
	rnd2 = self.velocity_y + (-10 + (random () * 20));
	rnd3 = self.velocity_z + 10 + random () * 10;

	if (rnd1 > 10)
		rnd1 = 5;
	if (rnd1 < -10)
		rnd1 = -5;

	if (rnd2 > 10)
		rnd2 = 5;
	if (rnd2 < -10)
		rnd2 = -5;

	if (rnd3 < 10)
		rnd3 = 15;
	if (rnd3 > 30)
		rnd3 = 25;

	self.velocity_x = rnd1;
	self.velocity_y = rnd2;
	self.velocity_z = rnd3;

	self.nextthink	= time + 0.5;
	self.think	= bubble_bob;
};

/*~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>
~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~*/

/*QUAKED viewthing (0 .5 .8) (-8 -8 -8) (8 8 8)
Just for the debugging level.  Don't use
*/
/* void ()
viewthing =
{
	self.movetype	= MOVETYPE_NONE;
	self.solid	= SOLID_NOT;

	precache_model ("progs/player.mdl");
	setmodel (self, "progs/player.mdl");
};
*/

/*
==============================================================================

SIMPLE BMODELS

==============================================================================
*/

void ()
func_wall_use =
{
	self.frame = 1 - self.frame; // change to alternate textures
};

/*QUAKED func_wall (0 .5 .8) ?
This is just a solid wall if not inhibitted
*/
void ()
func_wall =
{
	self.angles	= VEC_ORIGIN;
	self.movetype	= MOVETYPE_PUSH; // so it doesn't get pushed by anything
	self.solid	= SOLID_BSP;
	self.use	= func_wall_use;

	setmodel (self, self.model);
};

/*QUAKED func_illusionary (0 .5 .8) ?
A simple entity that looks solid but lets you walk through it.
*/
void ()
func_illusionary =
{
	self.angles	= VEC_ORIGIN;
	self.movetype	= MOVETYPE_NONE;
	self.solid	= SOLID_NOT;

	setmodel (self, self.model);

	makestatic (self);
};

/*QUAKED func_episodegate (0 .5 .8) ? E1 E2 E3 E4
This bmodel will appear if the episode has already been completed,
so players can't reenter it.
*/
void ()
func_episodegate =
{
	if (!(serverflags & self.spawnflags))
		return; // can still enter episode

	func_wall ();
};

/*QUAKED func_bossgate (0 .5 .8) ?
This bmodel appears unless players have all of the episode sigils.
*/
void ()
func_bossgate =
{
	if ((serverflags & SERVERFLAGS_RUNE_MASK) == SERVERFLAGS_RUNE_MASK)
		return; // all episodes completed

	func_wall ();
};

//============================================================================

void ()
misc_touch =
{
	if (other.classname != "player")
		return;

	if (other.health <= 0)
		return;

	if (!other.flags & FL_ONGROUND && other.absmin_z >= self.absmax_z - 2)
		other.flags = other.flags + FL_ONGROUND;
};

//============================================================================

void (string samp, float vol)
ambient_sound =
{
	if (scratch1 & S1_AMBIENT_SOUND_OFF)
	{
		remove (self);
		return;
	}

	precache_sound (samp);
	ambientsound (self.origin, samp, vol, ATTN_STATIC);
};

/*QUAKED ambient_* (0.3 0.1 0.6) (-10 -10 -8) (10 10 8)
*/

void () ambient_comp_hum	= { ambient_sound ("ambience/comp1.wav", 1); };
void () ambient_drip		= { ambient_sound ("ambience/drip1.wav", 0.5); };
void () ambient_drone		= { ambient_sound ("ambience/drone6.wav", 0.5);	};
void () ambient_flouro_buzz	= { ambient_sound ("ambience/buzz1.wav", 1); };
void () ambient_light_buzz	= { ambient_sound ("ambience/fl_hum1.wav", 0.5); };
void () ambient_suck_wind	= { ambient_sound ("ambience/suck1.wav", 1); };
void () ambient_swamp1		= { ambient_sound ("ambience/swamp1.wav", 0.5); };
void () ambient_swamp2		= { ambient_sound ("ambience/swamp2.wav", 0.5); };
void () ambient_thunder		= { ambient_sound ("ambience/thunder1.wav", 0.5); };
