/*
    Copyright (C) 2001-2014  David 'Slot Zero' Roberts.

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

void () item_megahealth_rot =
{
	other = self.owner;

	if (other.health > other.max_health)
	{
		other.health = other.health - 1;
		self.nextthink = time + 1;
		return;
	}

	// it is possible for a player to die and respawn between rots,
	// so don't just blindly subtract the flag off
	other.items = other.items - (other.items & IT_SUPERHEALTH);

	if (deathmatch & DM_RESPAWN)
	{
		self.nextthink = time + HEALTH_RESPAWN_TIME;
		self.think = SUB_regen;
	}
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

float (float w) RankForWeapon =
{
	if (w == IT_LIGHTNING)
		return 1;
	if (w == IT_ROCKET_LAUNCHER)
		return 2;
	if (w == IT_SUPER_NAILGUN)
		return 3;
	if (w == IT_GRENADE_LAUNCHER)
		return 4;
	if (w == IT_SUPER_SHOTGUN)
		return 5;
	if (w == IT_NAILGUN)
		return 6;
	return 7;
};

/*
=============
Deathmatch_Weapon

Deathmatch weapon change rules for picking up a weapon

.float		ammo_shells, ammo_nails, ammo_rockets, ammo_cells;
=============
*/
void (float old, float new) Deathmatch_Weapon =
{
	local float or, nr;

	// change self.weapon if desired
	or = RankForWeapon (self.weapon);
	nr = RankForWeapon (new);
	if (nr < or)
		set_weapon (new);
};

// XXX This is an alternate way to write accurate string data
// to the hunk.  I'm not finished exploring this idea though.
void (float type, float offset, string data, float bytes)
Write_Hunk_String_Dev =
{
	local entity hunk;
	local float length, pdata;
	local string s;

	hunk = Get_Hunk (type, offset);
	if (!hunk)
		return dprint ("Write_Hunk_String_Max: hunk is null\n");

	// s is a pointer to temp string
	s = allocate_string (data);

	// copy data to temp string
	strcpy (s, data);

	length = strlen (data);
	if (length >= bytes)
	{
		// pdata is a pointer to temp string
		pdata = AddInt (&s, PSTRING_TO_PQUAKEC);

		// shift offset of pdata to size of bytes
		pdata = AddInt (pdata, bytes * %1);

		// insert termination to temp string so that its the size of bytes
		strcpy (@AddInt (pdata, PQUAKEC_TO_PSTRING), string_null);

		// shift offset of pdata down to its original offset
		pdata = SubInt (pdata, bytes * %1);
	}

	// copy string to hunk
	Write_Hunk_String_e (hunk, s);
};

void ()
blind_think =
{
	local float lev;
	local string s;

	if (self.cnt <= 0 || self.owner.health <= 0)
	{
		stuffcmd (self.owner, CSHIFT_NONE);
		remove (self);
		return;
	}

	// With cnt starting at 20, this drops from 250 to 206 by 4s,
	// then from 175 to 50 by 25s.
	self.cnt = self.cnt - 1;
	if (self.cnt < 6)
		lev = 25 * (self.cnt + 2);
	else
		lev = 254 - 4 * (18 - self.cnt);
	s = ftos (lev);
	stuffcmd (self.owner, "v_cshift 256 256 256 ");
	stuffcmd (self.owner, s);
	stuffcmd (self.owner, "\n");

	self.nextthink = time + 0.2;
};

void (entity inflictor, float radius)
T_RadiusLight =
{
	local entity old_self, head, e;

	old_self = self;
	head = findradius (inflictor.origin, radius);
	while (head)
	{
		self = head;
		if (head.classname == "player"
			&& head.runetype != RN_ENVIRO
			&& !head.items & IT_SUIT
			&& infront (inflictor))
		{
			// Have flash grenades report.
			if (old_self.owner == self)
				sprint (old_self.owner, "You've blinded yourself!\n");
			else
			{
				sprint (self, "You were blinded by ");
				sprint (self, old_self.owner.netname);
				sprint (self, "'s flash grenade!\n");

				sprint (old_self.owner, self.netname);
				sprint (old_self.owner, " was blinded by your flash grenade\n");
			}
			e = world;
			do
				e = find (e, classname, "light_think");
			while (e != world && e.owner != head);
			if (!e)
			{
				e = spawn ();
				e.classname = "light_think";
				e.owner = head;
				e.think = blind_think;
			}
			e.cnt = 18;
			e.nextthink = time;
		}
		head = head.chain;
	}
	if (e.owner == head)
		sprint (old_self.owner, "Your flash grenade exploded\n");
	self = old_self;
};

/*
============
T_BeamDamage
============
*/
void (entity attacker, float damage, string dtype)
T_BeamDamage =
{
	local	float 	points;
	local	entity	head;

	head = findradius (attacker.origin, damage+40);

	while (head)
	{
		if (head.takedamage)
		{
			points = 0.5*vlen (attacker.origin - head.origin);
			if (points < 0)
				points = 0;
			points = damage - points;
			if (head == attacker)
				points = points * 0.5;
			if (points > 0)
			{
				if (CanDamage (head, attacker))
				{
					if (head.classname == "monster_shambler")
						T_Damage (head, attacker, attacker, points*0.5, dtype);
					else
						T_Damage (head, attacker, attacker, points, dtype);
				}
			}
		}
		head = head.chain;
	}
};

/*QUAKED item_deathball (.3 .3 1) (0 0 0) (32 32 32)
*/
void ()
item_deathball =
{
	self.touch = deathball_touch;
};

void ()
bodyque =
{	// just here so spawn functions don't complain after the world
	// creates bodyques
};

// There seems to be a problem with referencing a string as a float on
// some engine builds.  When the problem occurs, the wrong strlen function
// gets called.
// /* float (string s)
strlen =
{
	IN_QW([-
		return strlen_qc (s);
	-])

	if (&s < 0)
		return strlen_any (s);

	if (&s > %16777216)
		return strlen_any (s);

	return strlen_qc (s);
}; */

//
//  S T R L E N _ A N Y
//
//  Return the length of a string
//
float (string s)
strlen_any =
{
	local float i, ps;

	ps = AddInt (&s, PSTRING_TO_PQUAKEC);
	for (i = 0; i < 256; i = i + 1)
	{
		if (@AddInt (ps, PQUAKEC_TO_PSTRING) == string_null)
			return i;
		ps = AddInt (ps, %1);
	}

	dprint ("strlen_any(): string too big\n");

	return 0;
};

float (string ch)
dec_ctof =
{
	local float i;

	for (i = %0; i < %10; i = i + %1)
	{
		if (ch == hex[i * 2])
			return i / %1;
	}

	return -1;
};

float (float n)
atof =
{
	local float i, asc;

	i = 0;
	for (asc = 48; asc < 58; asc = asc + 1)
	{
		if (n == asc)
			return i;

		i = i + 1;
	}

	return -1;
};

float (float n)
eval_exponent =
{
	local float i;

	for (i = 1; n > 1; n = n - 1)
		i = i * 10;

	return i;
};

float (string s)
stof_any =
{
	local float n, ps, cmp, frac, tot, neg;
	local string ch, clean;

	&%116 = 0;
	ps = AddInt(AddInt(&s, PSTRING_TO_PQUAKEC), %-3);

	cmp = strlen (s);
	for (n = 0; n < cmp; n = n + 1)
	{
		&%113 = (*ps)[0];

		if (world[%5] == '-' && !tot)
			neg = 1;
		else if (world[%5] == '.')
		{
			if (!tot)
				frac = -1;
			else
				frac = tot;
		}

		ch = atoc (world[%5] / %1);
		if (ch)
		{
			clean = strcat (clean, ch);
			tot = tot + 1;
		}

		ps = AddInt (ps, %1);
	}
	ps = AddInt (ps, %3);

	if (frac)
	{
		if (frac < 0)
			frac = 0;

		frac = tot - frac;
		frac = eval_exponent (frac + 1);
	}

	n = stof (clean);

	if (frac)
		n = n / frac;

	if (neg)
		n = n - n * 2;

	return n;
};

float (string s)
stof =
{
	local float f, i, ps, cmp, sum;

	&%116 = 0;
	ps = AddInt(AddInt(&s, PSTRING_TO_PQUAKEC), %-3);

	cmp = strlen (s);
	for (i = 0; i < cmp; i = i + 1)
	{
		&%113 = (*ps)[0];

		f = atof (world[%5] / %1);
		if (f < 0) return 0;
		f = f * (eval_exponent (cmp - i));
		sum = sum + f;

		ps = AddInt (ps, %1);
	}
	ps = AddInt (ps, %3);

	return sum;
};

// The mortar gun comes from Expert Quake.  I reimplemented it but I
// used their specific numbers, except for the taper.  They use a 30%
// taper, I use 10%.  The difference is:
//
//                rocket   30% mortar   10% mortar
//     dist  25      107           82           87
//     dist  50       95           75           85
//     dist  75       82           67           82
//     dist 100       70           60           80
//     dist 125       57            -            -
//     dist 150       45            -            -
//
// The mortar with 10% taper is still worse than a rocket except for at
// the extreme end of its radius.  Since the blast radius is also less
// than 2/3 that of a rocket (100 vs. 160), I don't think this makes it
// too powerful (even though it can fire slightly faster).

float MORTAR_REFIRE		= 1.4;
float MORTAR_DAMAGE		= 90;
float MORTAR_RADIUS		= 100;
float MORTAR_TAPER		= 0.1;

float (float bits)
bits_set =
{
	local float n;

	n = 0;
	if (bits & 1)		n = n + 1;
	if (bits & 2)		n = n + 1;
	if (bits & 4)		n = n + 1;
	if (bits & 8)		n = n + 1;
	if (bits & 16)		n = n + 1;
	if (bits & 32)		n = n + 1;
	if (bits & 64)		n = n + 1;
	if (bits & 128)		n = n + 1;
	if (bits & 256)		n = n + 1;
	if (bits & 512)		n = n + 1;
	if (bits & 1024)	n = n + 1;
	if (bits & 2048)	n = n + 1;
	if (bits & 4096)	n = n + 1;
	if (bits & 8192)	n = n + 1;
	if (bits & 16384)	n = n + 1;
	if (bits & 32768)	n = n + 1;
	if (bits & 65536)	n = n + 1;
	if (bits & 131072)	n = n + 1;
	if (bits & 262144)	n = n + 1;
	if (bits & 524288)	n = n + 1;
	if (bits & 1048576)	n = n + 1;
	if (bits & 2097152)	n = n + 1;
	if (bits & 4194304)	n = n + 1;
	if (bits & 8388608)	n = n + 1;
	return n;
};
