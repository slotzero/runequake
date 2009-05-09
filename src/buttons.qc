/*  $Id: buttons.qc,v 1.17 2009/05/09 05:45:27 slotzero Exp $

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

// button and multiple button

void ()
button_wait =
{
	self.state	= STATE_TOP;
	self.nextthink	= self.ltime + self.wait;
	self.think	= button_return;
	activator	= self.enemy;

	SUB_UseTargets ();

	self.frame	= 1; // use alternate textures
};

void ()
button_done =
{
	self.state = STATE_BOTTOM;
};

void ()
button_return =
{
	self.state = STATE_DOWN;

	SUB_CalcMove (self.pos1, self.speed, button_done);

	self.frame = 0; // use normal textures

	if (self.health)
		self.takedamage = DAMAGE_YES; // can be shot again
};

void ()
button_blocked =
{
	// do nothing, just don't come all the way back out
};

void ()
button_fire =
{
	if (self.state == STATE_UP || self.state == STATE_TOP)
		return;

	sound (self, CHAN_VOICE, self.noise, 1, ATTN_NORM);

	self.state = STATE_UP;

	SUB_CalcMove (self.pos2, self.speed, button_wait);
};

void ()
button_use =
{
	self.enemy = activator;

	button_fire ();
};

void ()
button_touch =
{
	if (other.classname != "player" && other.classname != "hook-head")
		return;

    	// don't trigger when dead
	if (other.classname == "player" && other.health <= 0)
		return;

	if (other.classname == "hook-head")
		self.enemy = other.owner;
	else
		self.enemy = other;

	// dmg hack
   	self.runevar = 1;

	if (self.health)
		button_killed ();
	else
		button_fire ();
};

void ()
button_killed =
{
	// dmg hack
	if (self.runevar)
		self.runevar	= 0;
	else
		self.enemy	= damage_attacker;

	self.health	= self.max_health;
	self.takedamage	= DAMAGE_NO; // wil be reset upon return

	button_fire ();
};

/*QUAKED func_button (0 .5 .8) ?
When a button is touched, it moves some distance in the direction of it's angle,
triggers all of it's targets, waits some time,
then returns to it's original position where it can be triggered again.

"angle"		determines the opening direction
"target"	all entities with a matching targetname will be used
"speed"		override the default 40 speed
"wait"		override the default 1 second wait (-1 = never return)
"lip"		override the default 4 pixel lip remaining at end of move
"health"	if set, the button must be killed instead of touched
"sounds"
0) steam metal
1) wooden clunk
2) metallic click
3) in-out
*/
void ()
func_button =
{
	if (self.sounds == 0)
		precache_noise ("buttons/airbut1.wav");
	else if (self.sounds == 1)
		precache_noise ("buttons/switch21.wav");
	else if (self.sounds == 2)
		precache_noise ("buttons/switch02.wav");
	else if (self.sounds == 3)
		precache_noise ("buttons/switch04.wav");

	// Activate bridge button on E1M7.
	if (!scratch1 & S1_ORIGINAL_LEVELS && mapname == "e1m7"	&& self.target == "t9")
	{
		self.state = STATE_BOTTOM;
		self.speed = 40;

		button_use ();
	}

	// This button causes packet overflows.
	if (mapname == "xarena3")
		remove (self);

	SetMovedir ();

	self.movetype	= MOVETYPE_PUSH;
	self.solid	= SOLID_BSP;

	setmodel (self, self.model);

	self.blocked	= button_blocked;
	self.use	= button_use;

	if (!self.health)
		self.netname = "func_button_shootable";

	if (options & SHOOT_BUTTONS)
	{
		if (!self.health)
		{
			self.touch	= button_touch;
			self.health	= 1;
		}

		// allow damage to all buttons
		self.max_health	= self.health;
		self.th_die	= button_killed;
		self.takedamage	= DAMAGE_YES;
	}
	else
	{
		if (self.health)
		{
			self.max_health	= self.health;
			self.th_die	= button_killed;
			self.takedamage	= DAMAGE_YES;
		}
		else
			self.touch	= button_touch;
	}

	if (!self.speed)
		self.speed	= 40;

	if (!self.wait)
		self.wait	= 1;

	if (!self.lip)
		self.lip	= 4;

	self.state	= STATE_BOTTOM;
	self.pos1	= self.origin;
	self.pos2	= self.pos1 + self.movedir * (fabs (self.movedir*self.size) - self.lip);
};
