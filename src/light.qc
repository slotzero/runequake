/*  $Id: light.qc,v 1.10 2003/06/24 22:17:39 slotzero Exp $

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

float START_OFF = 1;

//
// Setup light animation tables. 'a' is total darkness, 'z' is maxbright.
//
void ()
Light_Setup =
{
	if (scratch1 & S1_EQUALIZE_LIGHTSTYLE)
	{
		local float n;

		n = 0;
		while (n <= 63)
		{
			lightstyle (n, "r");
			n = n + 1;
		}
		return;
	}

	// 0 normal
	lightstyle (0, "r");

	// 1 FLICKER (first variety)
	lightstyle (1, "mmnmmommommnonmmonqnmmo");

	// 2 SLOW STRONG PULSE
	lightstyle (2, "abcdefghijklmnopqrstuvwxyzyxwvutsrqponmlkjihgfedcba");

	// 3 CANDLE (first variety)
	lightstyle (3, "mmmmmaaaaammmmmaaaaaabcdefgabcdefg");

	// 4 FAST STROBE
	lightstyle (4, "mamamamamama");

	// 5 GENTLE PULSE 1
	lightstyle (5, "jklmnopqrstuvwxyzyxwvutsrqponmlkj");

	// 6 FLICKER (second variety)
	lightstyle (6, "nmonqnmomnmomomno");

	// 7 CANDLE (second variety)
	lightstyle (7, "mmmaaaabcdefgmmmmaaaammmaamm");

	// 8 CANDLE (third variety)
	lightstyle (8, "mmmaaammmaaammmabcdefaaaammmmabcdefmmmaaaa");

	// 9 SLOW STROBE (fourth variety)
	lightstyle (9, "aaaaaaaazzzzzzzz");

	// 10 FLUORESCENT FLICKER
	lightstyle (10, "mmamammmmammamamaaamammma");

	// 11 SLOW PULSE NOT FADE TO BLACK
	lightstyle (11, "abcdefghijklmnopqrrqponmlkjihgfedcba");

	// styles 32-62 are assigned by the light program for switchable lights

	// 63 testing
	lightstyle (63, "a");
};

void ()
light_switch =
{
	if (self.spawnflags & START_OFF)
	{
		lightstyle (self.style, "r");
		self.spawnflags = self.spawnflags - self.spawnflags & START_OFF;
	}
	else
	{
		lightstyle (self.style, "a");
		self.spawnflags = self.spawnflags | START_OFF;
	}
};

void ()
light_use =
{
	if (self.style >= 32)
	{
		if (self.spawnflags & START_OFF)
			lightstyle (self.style, "a");
		else
			lightstyle (self.style, "r");

		self.use = light_switch;
	}
};

/*QUAKED light (0 1 0) (-8 -8 -8) (8 8 8) START_OFF
Non-displayed light.
Default light value is 300
Default style is 0
If targeted, it will toggle between on or off.
*/
void ()
light =
{
	if (!self.targetname)
	{
		remove (self);
		return;
	}

	light_use ();
};

/*QUAKED light_fluoro (0 1 0) (-8 -8 -8) (8 8 8) START_OFF
Non-displayed light.
Default light value is 300
Default style is 0
If targeted, it will toggle between on or off.
Makes steady fluorescent humming sound
*/
void ()
light_fluoro =
{
	light_use ();
	ambient_sound ("ambience/fl_hum1.wav", 0.5);
};

/*QUAKED light_fluorospark (0 1 0) (-8 -8 -8) (8 8 8)
Non-displayed light.
Default light value is 300
Default style is 10
Makes sparking, broken fluorescent sound
*/
void ()
light_fluorospark =
{
	if (!self.style)
		self.style = 10;

	light_use ();
	ambient_sound ("ambience/buzz1.wav", 0.5);
};

void (string s)
light_makestatic =
{
	if (scratch1 & S1_LIGHT_MAKESTATIC_OFF)
	{
		remove (self);
		return;
	}

	precache_model (s);
	setmodel (self, s);
	makestatic (self);
};

/*QUAKED light_globe (0 1 0) (-8 -8 -8) (8 8 8)
Sphere globe light.
Default light value is 300
Default style is 0
*/
void ()
light_globe =
{
	light_makestatic ("progs/s_light.spr");
};

void ()
ambient_fire1 =
{
	if (scratch1 & S1_AMBIENT_SOUND_OFF)
		return;

	precache_sound ("ambience/fire1.wav");
	ambientsound (self.origin, "ambience/fire1.wav", 0.5, ATTN_STATIC);
};

/*QUAKED light_torch_small_walltorch (0 .5 0) (-10 -10 -20) (10 10 20)
Short wall torch
Default light value is 200
Default style is 0
*/
void ()
light_torch_small_walltorch =
{
	ambient_fire1 ();
	light_makestatic ("progs/flame.mdl");
};

/*QUAKED light_flame_large_yellow (0 1 0) (-10 -10 -12) (12 12 18)
Large yellow flame ball
*/
void ()
light_flame_large_yellow =
{
	ambient_fire1 ();
	self.frame = 1;
	light_makestatic ("progs/flame2.mdl");
};

/*QUAKED light_flame_small_yellow (0 1 0) (-8 -8 -8) (8 8 8) START_OFF
Small yellow flame ball
*/
void ()
light_flame_small_yellow =
{
	ambient_fire1 ();
	light_makestatic ("progs/flame2.mdl");
};

/*QUAKED light_flame_small_white (0 1 0) (-10 -10 -40) (10 10 40) START_OFF
Small white flame ball
*/
void ()
light_flame_small_white =
{
	ambient_fire1 ();
	light_makestatic ("progs/flame2.mdl");
};
