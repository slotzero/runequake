/*  $Id: camera.qc,v 1.7 2003/10/18 17:24:18 slotzero Exp $

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

// #####################
// ### chase cam mod ###
// main code block

// defaults reset every time level starts
float chasecam_alt, chasecam_dist = 72, chasecam_zofs = 24;

// Resets weapon model after changing view
// called by chase cam or player entities
void (entity player_ent)
Chase_cam_setweapon =
{
	local entity e;

	e = self;
	self = player_ent;
	W_SetCurrentAmmo ();
	self = e;
};

// called either by player or chase cam entities (to restart)
void (entity cam_owner)
Start_chase_cam =
{
	local entity chase_cam;

	chase_cam = spawn ();

	chase_cam.owner=cam_owner;

	// turn on bit-flag
	chase_cam.owner.speed = chase_cam.owner.speed | CHSCAM_ON;

	chase_cam.solid = SOLID_NOT;
	chase_cam.movetype = MOVETYPE_FLYMISSILE;

	chase_cam.angles = chase_cam.owner.angles;

	setmodel (chase_cam, "progs/eyes.mdl");
	setsize (chase_cam, VEC_ORIGIN, VEC_ORIGIN);
	setorigin (chase_cam, chase_cam.owner.origin);
	chase_cam.classname = "chase_cam";

	chase_cam.nextthink = time + 0.1;
	chase_cam.think = Keep_cam_chasing_owner;

	msg_entity = chase_cam.owner;			// target of message
	WriteByte (MSG_ONE, SVC_SETVIEWPORT);
	WriteEntity (MSG_ONE, chase_cam);		// view port

	//RUNE SERV TEMP MOD:
	//Chase_cam_setweapon (cam_owner);
	cam_owner.weaponmodel = "";

	// distance clipping
	chase_cam.ammo_shells = chasecam_dist;
	// offset choice
	chase_cam.ammo_cells = 0;
};

// secondary think for cam entities
void ()
Reable_chase_cam =
{
	self.nextthink = time + 0.1;

	// debug
	//sprint (self.owner, "Reable_chase_cam was called\n");

	// clears bug of not being able to hit fire to restart
	// after dying in water
	if (self.owner.health <= 0)
	{
		remove (self);
		return;
	}

	if (self.owner.waterlevel > 0)
		return;

	Start_chase_cam (self.owner);
	remove (self);
};

// called only by chase cam entities
// opt values
// TRUE = remove completely
// FALSE = remove view but keep alive with Reable_chase_cam();
void (float opt)
Remove_chase_cam =
{
	// turn off bit-flag
	if ((self.owner.speed & CHSCAM_ON))
		self.owner.speed = self.owner.speed - CHSCAM_ON;

	// makes entity appear gone even if going into keep alive state
	setmodel (self, "");
	self.velocity = VEC_ORIGIN;

	// set view-point back to normal
	msg_entity = self.owner;      // target of message
	WriteByte (MSG_ONE, SVC_SETVIEWPORT);
	WriteEntity (MSG_ONE, self.owner);           // view port

	Chase_cam_setweapon (self.owner);

	if (!opt)
	{
		self.nextthink = time + 0.1;
		self.think = Reable_chase_cam;
	}
	else
		remove (self);
};

/*
###########
 main think function for cam entities
 self.ammo_shells = distance clipping
 self.ammo_nails = hang-up flag
 self.ammo_cells = view offset direction
   0 = up
   1 = left
   2 = right
###########
*/
void ()
Keep_cam_chasing_owner =
{
	local vector spot2, dir;
	local float dist, cap;
	local float f_f, f_r;

	self.nextthink = time + 0.1;

	// check if player turned off
	// or in water
	if (!(self.owner.speed & CHSCAM_ON))
	{
		Remove_chase_cam (TRUE);
			return;
	}
	if (self.owner.waterlevel > 0)
	{
		if (self.owner.health > 0)
		{
			Remove_chase_cam (FALSE);
			return;
		}
	}

	// get player velocity relative to player's
	// current yaw
	// f_f (based on running calcs (maxspeed = 400)
	//  (back ~= 640, forward ~= 0)
	// f_r
	//  (left ~= 640, right ~= 0)
	dir_y = self.owner.v_angle_y;
	makevectors (dir);
	f_f = vlen ((v_forward * 320) - self.owner.velocity);
	f_r = vlen ((v_right * 320) - self.owner.velocity);

	// held for use after second makevectors call for
	// v_forward based only on yaw
	dir = v_forward;

	/*
	local string s;
	sprint (self.owner, "\n\n f_f = ");
	s = ftos (f_f);
	sprint (self.owner, s);
	sprint (self.owner, "\n f_r = ");
	s = ftos (f_r);
	sprint (self.owner, s);
	sprint (self.owner, "\n");
	*/

	if (self.owner.speed & CHSCAM_ALT)
	{
		if (f_f < 160 || self.owner.v_angle_x < -45)
			self.ammo_cells = 0;
		else if (f_r < 80)
			self.ammo_cells = 1;
		else if (f_r > 560)
		self.ammo_cells = 2;
	}
	else
		self.ammo_cells = 0;

	makevectors (self.owner.v_angle);

	// set spot before clipping
	spot2 = self.owner.origin - (v_forward * self.ammo_shells);

	if (!self.ammo_cells)
	{
		if (self.owner.v_angle_x > 16)
		{
			// dir is first v_forward based on yaw only
			spot2 = spot2 + (dir * (self.owner.v_angle_x - 16));
			cap = chasecam_zofs - ((self.owner.v_angle_x - 16) * 0.2);
			if (cap < 0) cap = 0;
	 		spot2_z = spot2_z + cap;
		}
		else
			spot2_z = spot2_z + chasecam_zofs;
	}
	else if (self.ammo_cells == 1)
		spot2 = spot2 - (v_right * (chasecam_zofs));
	else
		spot2 = spot2 + (v_right * (chasecam_zofs));

	traceline (self.owner.origin, spot2, FALSE, self.owner);

	// avoids most hang-ups along walls
	spot2 = trace_endpos + (v_forward * 2);

	// for fading from walls and up-aim auto rising
	self.ammo_shells = 10 + vlen (trace_endpos - self.owner.origin);

	// clip from ceiling if too close
	traceline (spot2, spot2 + '0 0 32', FALSE, self.owner);
	if (trace_fraction < 1)
	{
		dir = trace_endpos - '0 0 32';

		traceline (spot2, spot2 - '0 0 32', FALSE, self.owner);
		if (trace_fraction == 1)
			spot2 = dir;
	}

	dir = normalize (spot2 - self.origin);
	dist = vlen (spot2 - self.origin);

	traceline (self.origin, spot2, FALSE, self.owner);
	if (trace_fraction == 1)
	{
		self.angles = self.owner.angles;

		cap = dist * 0.2;

		if (cap > 5.2)
			self.velocity = dir * dist * 5.2;
		else if (cap > 1)
			self.velocity = dir * dist * cap;
		else
			self.velocity = dir * dist;

		// tighten up if owner running backwards
		if (f_f > 560)
		{
			self.velocity = self.velocity * 2;
		}
	}
	else
		setorigin (self, spot2);

	// fade back from walls
	self.ammo_shells = self.ammo_shells + 4;
	if (self.ammo_shells > chasecam_dist)
	self.ammo_shells = chasecam_dist;

	// respawn if missile ent. get's hung up
	if (self.oldorigin == self.origin)
	{
		if (dist > 30)
		self.ammo_nails = self.ammo_nails + 1;

	}
	if (self.ammo_nails > 3)
	{
		Start_chase_cam (self.owner);
		remove (self);
		return;
	}
	self.oldorigin = self.origin;
};

// called by player only
void ()
Toggle_chase_cam =
{
	if ((self.speed & CHSCAM_ON))
	{
		// will be noticed by next think
		// of player's chase cam entity
		self.speed = self.speed - CHSCAM_ON;
	}
	else
	{
		Start_chase_cam (self);
	}
};

// called by player only
void ()
Toggle_chase_type =
{
	if ((self.speed & CHSCAM_ALT))
	{
		self.speed = self.speed - CHSCAM_ALT;
		sprint (self, "View tracking: normal\n");
	}
	else
	{
		self.speed = self.speed | CHSCAM_ALT;
		sprint (self, "View tracking: strafeing\n");
	}
};

////////////////////////////////////////////
// laser targeter functions

/*void () SDR_SightThink =
{
	local vector org;

	makevectors (self.owner.v_angle);
	org = self.owner.origin + v_up*16;

	traceline (org, org + v_forward*2048, FALSE, self);

	if (trace_fraction == 1.0)
	{
		// move sight inside player if can hit anything
		setorigin (self, self.owner.origin);
		return;
	}

	// check if target is damageable and set proper model
	if (trace_ent.takedamage)
		setmodel (self, "progs/cross2.mdl");
	else
		setmodel (self, "progs/cross1.mdl");

	// move sight at line of sight collision
	self.angles = vectoangles (v_forward);
	setorigin (self, trace_endpos);

	// mark think to update sight position
	self.nextthink = time + 0.05;
};
*/

/*void ()	SDR_SightMake =
{
	local entity cross;

	self.sight_out = TRUE;

	cross = spawn ();
	cross.owner = self;
	cross.movetype = MOVETYPE_NOCLIP;
	cross.solid = SOLID_NOT;

	setmodel (cross, "progs/cross1.mdl");
	cross.classname = "laser_sight";

	setorigin (cross, self.origin);

	cross.think = SDR_SightThink;
	cross.nextthink = time + 0.05;
};
*/

// targeter ent. think function
void () LaserTargeterTrack =
{
	local vector dir, src;

	if (!(self.owner.speed & LASERTARG_ON))
	{
		remove (self);
		return;
	}

	makevectors (self.owner.v_angle);

	src = self.owner.origin;
	src = self.owner.origin + v_forward * 10;
	src_z = self.owner.absmin_z + self.owner.size_z * 0.7;

	dir = aim (self.owner, 100000);
	traceline (src,  src + dir * 320, FALSE, self.owner);

	src = 0.1 * src + 0.9 * trace_endpos;

	setorigin (self, src);

	self.nextthink = time + 0.1;
};

void (entity targ_owner)
LaserTargeterToggle =
{
	local entity e;

	if ((targ_owner.speed & LASERTARG_ON))
		targ_owner.speed = targ_owner.speed - LASERTARG_ON;
	else
	{
		targ_owner.speed = targ_owner.speed | LASERTARG_ON;

		e = spawn ();
		e.owner = targ_owner;
		e.movetype = MOVETYPE_NONE;
		e.solid = SOLID_NOT;

		setmodel (e, "progs/s_bubble.spr");
		setsize (e, VEC_ORIGIN, VEC_ORIGIN);
		setorigin (e, e.owner.origin);

		e.nextthink = time + 0.1;
		e.think = LaserTargeterTrack;
	}
};
////////////////////////////////////////////

void ()
Chase_cam_lvlstart_think =
{
	local string s;

	if ((self.owner.speed & CHSCAM_ON))
		Start_chase_cam (self.owner);
	if ((self.owner.speed & LASERTARG_ON))
	{
		self.owner.speed = self.owner.speed - LASERTARG_ON;
		LaserTargeterToggle (self.owner);
	}
	remove (self);
};

// called in CLIENT.QC by PutClientInServer
// player.speed is set and saved between levels using parm16
// in CLIENT.QC
void ()
Chase_cam_level_start =
{
	local entity e;

	e = spawn ();
	e.owner = self;

	e.movetype = MOVETYPE_NONE;
	e.solid = SOLID_NOT;

	setmodel (e, "");
	setsize (e, VEC_ORIGIN, VEC_ORIGIN);
	setorigin (e, e.owner.origin);

	e.nextthink = time + 0.2;
	e.think = Chase_cam_lvlstart_think;
};

// ### chase cam mod ###
// #####################
