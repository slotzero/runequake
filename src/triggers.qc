/*  $Id: triggers.qc,v 1.23 2004/06/24 20:35:13 slotzero Exp $

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

entity s_tfog;

void ()
trigger_reactivate =
{
	self.solid = SOLID_TRIGGER;
};

//=============================================================================

float SPAWNFLAG_NOMESSAGE	= 1;
float SPAWNFLAG_NOTOUCH		= 1;

// the wait time has passed, so set back up for another activation
void ()
multi_wait =
{
	if (self.max_health)
	{
		self.health	= self.max_health;
		self.takedamage	= DAMAGE_YES;
		self.solid	= SOLID_BBOX;
	}
};

// the trigger was just touched/killed/used
// self.enemy should be set to the activator so it can be held through a delay
// so wait for the delay time before firing
void ()
multi_trigger =
{
	if (self.nextthink > time)
		return; // already been triggered

	if (self.classname == "trigger_secret")
	{
		if (self.enemy.classname != "player")
			return;

		found_secrets = found_secrets + 1;
		WriteByte (MSG_ALL, SVC_FOUNDSECRET);
	}

	if (self.noise)
		sound (self, CHAN_VOICE, self.noise, 1, ATTN_NORM);

	self.takedamage	= DAMAGE_NO; // don't trigger again until reset
	activator	= self.enemy;

	SUB_UseTargets ();

	if (self.wait > 0)
	{
		self.think	= multi_wait;
		self.nextthink	= time + self.wait;
	}
	else
	{	// we can't just remove (self) here, because this is a touch function
		// called while C code is looping through area links.
		self.touch	= SUB_Null;
		self.nextthink	= time + sys_ticrate;
		self.think	= SUB_Remove;
	}
};

void ()
multi_killed =
{
	self.enemy = damage_attacker;

	multi_trigger ();
};

void ()
multi_use =
{
	self.enemy = activator;

	multi_trigger ();
};

void ()
multi_touch =
{
	if (other.classname != "player")
		return;

	// if the trigger has an angles field, check player's facing direction
	if (self.movedir != VEC_ORIGIN)
	{
		makevectors (other.angles);
		if (v_forward * self.movedir < 0)
			return; // not facing the right way
	}

	self.enemy = other;

	multi_trigger ();
};

/*QUAKED trigger_multiple (.5 .5 .5) ? notouch
Variable sized repeatable trigger.  Must be targeted at one or more entities.  If "health" is set, the trigger must be killed to activate each time.
If "delay" is set, the trigger waits some time after activating before firing.
"wait" : Seconds between triggerings. (.2 default)
If notouch is set, the trigger is only fired by other entities, not by touching.
NOTOUCH has been obsoleted by trigger_relay!
sounds
1)	secret
2)	beep beep
3)	large switch
4)
set "message" to text string
*/
void ()
trigger_multiple =
{
	if (self.sounds == 1)
		precache_noise ("misc/secret.wav");
	else if (self.sounds == 2)
		precache_noise ("misc/talk.wav");
	else if (self.sounds == 3)
		precache_noise ("misc/trigger1.wav");

	if (!self.wait)
		self.wait = 0.2;

	self.use = multi_use;

	InitTrigger ();

	if (self.health)
	{
		if (self.spawnflags & SPAWNFLAG_NOTOUCH)
			objerror ("health and notouch don't make sense\n");
		self.max_health	= self.health;
		self.th_die	= multi_killed;
		self.takedamage	= DAMAGE_YES;
		self.solid	= SOLID_BBOX;

		setorigin (self, self.origin); // make sure it links into the world
	}
	else
		if (!(self.spawnflags & SPAWNFLAG_NOTOUCH))
			self.touch = multi_touch;
};

/*QUAKED trigger_once (.5 .5 .5) ? notouch
Variable sized trigger. Triggers once, then removes itself.  You must set the key "target" to the name of another object in the level that has a matching
"targetname".  If "health" is set, the trigger must be killed to activate.
If notouch is set, the trigger is only fired by other entities, not by touching.
if "killtarget" is set, any objects that have a matching "target" will be removed when the trigger is fired.
if "angle" is set, the trigger will only fire when someone is facing the direction of the angle.  Use "360" for an angle of 0.
sounds
1)	secret
2)	beep beep
3)	large switch
4)
set "message" to text string
*/
void ()
trigger_once =
{
	if (mapname == "e1m7")
		remove (self);

	self.wait = -1;

	trigger_multiple ();
};

//=============================================================================

/*QUAKED trigger_relay (.5 .5 .5) (-8 -8 -8) (8 8 8)
This fixed size trigger cannot be touched, it can only be fired by other events.  It can contain killtargets, targets, delays, and messages.
*/
void ()
trigger_relay =
{
	self.use = SUB_UseTargets;
};

//=============================================================================

/*QUAKED trigger_secret (.5 .5 .5) ?
secret counter trigger
sounds
1)	secret
2)	beep beep
3)
4)
set "message" to text string
*/
void ()
trigger_secret =
{
	total_secrets	= total_secrets + 1;
	self.wait	= -1;

	if (!self.message)
		self.message = "You found a secret area!";

	if (!self.sounds)
		self.sounds = 1;

	if (self.sounds == 1)
		precache_noise ("misc/secret.wav");
	else if (self.sounds == 2)
		precache_noise ("misc/talk.wav");

	trigger_multiple ();
};

//=============================================================================

void ()
counter_use =
{
	self.count = self.count - 1;
	if (self.count < 0)
		return;

	if (self.count != 0)
	{
		if (activator.classname == "player" &&
				(self.spawnflags & SPAWNFLAG_NOMESSAGE)	== 0)
		{
			if (self.count >= 4)
				centerprint (activator, "There are more to go...");
			else
			{
				local string s;

				s = ftos (self.count);
				centerprint3 (activator, "Only ", s, " more to go...");
			}
		}
		return;
	}

	if (activator.classname == "player"
			&& (self.spawnflags & SPAWNFLAG_NOMESSAGE) == 0)
		centerprint (activator, "Sequence completed!");

	self.enemy = activator;

	multi_trigger ();
};

/*QUAKED trigger_counter (.5 .5 .5) ? nomessage
Acts as an intermediary for an action that takes multiple inputs.

If nomessage is not set, t will print "1 more.. " etc when triggered and "sequence complete" when finished.

After the counter has been triggered "count" times (default 2), it will fire all of it's targets and remove itself.
*/
void ()
trigger_counter =
{
	self.wait = -1;

	if (!self.count)
		self.count = 2;

	self.use = counter_use;
};

/*
==============================================================================

TELEPORT TRIGGERS

==============================================================================
*/

float PLAYER_ONLY	= 1;
float SILENT 		= 2;

void ()
play_teleport =
{
	local float i;
	local string s;

	i = rint (random () * 5);
	if (i == 1)
		s = "misc/r_tele1.wav";
	else if (i == 2)
		s = "misc/r_tele2.wav";
	else if (i == 3)
		s = "misc/r_tele3.wav";
	else if (i == 4)
		s = "misc/r_tele4.wav";
	else
		s = "misc/r_tele5.wav";

	sound (self, CHAN_VOICE, s, 1, ATTN_NORM);

	remove (self);
};

void (vector org)
spawn_tfog =
{
	s_tfog			= spawn ();
	s_tfog.origin		= org;
	s_tfog.nextthink	= time + 0.2;
	s_tfog.think		= play_teleport;

	create_te_teleport (org);
};

/*
Whenever a player triggers (touches) a teleporter, spawn_tdeath() is called and an entity is created at
the exit (target) of the teleporter.  The entity only thinks for 0.2 seconds and its touch function is,
you guessed it, tdeath_touch().  Normally, if someone triggers the entity's field, also known as teledeath,
he is toast (telefragged)!  However, what happens in the case when someone has pent?

When a player cannot be telefragged, tdeath_touch() continues to be called (looping) until 'teledeath' stops
thinking (0.2 seconds).  Because of this, and if your timing is that of a machine, you can deflect a
telefrag and yet still managed to get telefragged!  This only happens when your pent has less than 0.2
seconds left when you enter a teleporter.  But what if I shorten the length of the think?

If your think() isn't long enough, you don't telefrag the player but rather you are locked into position.  I
was thinking that if I made the think() twice the tick rate, maybe this wouldn't happen.

Another interesting anomaly is that if someone follows you into a teleporter at just the right time,
he'll wind up being telefragged, but you'll be safe.  This happens because you're just outside the
entity's touch, but your spawn_tdeath() is still active.  Again, perhaps if the nextthink() was shorter
than 0.2 this might be avoidable.  I hesitate to say this because lag/ping does seem to play a big factor
on who gets telefragged first, or at least that is the way it appears.

UPDATE: I changed nextthink to sys_ticrate * 2, lets see what happens!
*/
void ()
tdeath_touch =
{
	if (other == self.owner)
		return;

	if (other.health <= 0)
		return;

	if (other.classname == "player")
	{
		// frag anyone who teleports in on top of an invincible player
		if (other.invincible_finished > time)
		{
			T_Damage (self.owner, self, other, 50000, "teledeath2");
			return;
		}

		if (other.runetype == RN_DEFLECT)
		{
			if (self.owner.invincible_finished > time || self.owner.runetype == RN_DEFLECT)
				T_Damage (other, self, self.owner, 50000, "teledeath2");

			if (T_Damage (self.owner, self, other, 50000, "teledeath2") && other.health > 0)
				Rune_Deflect_Telefrag ();
			return;
		}

		// frag monsters who try to telefrag players
		if (self.owner.classname != "player")
		{
			T_Damage (self.owner, self, other, 50000, self.classname);
			return;
		}
	}

	T_Damage (other, self, self.owner, 50000, "teledeath");
};

void (vector org, entity death_owner)
spawn_tdeath =
{
	local entity death;

	death		= spawn ();
	death.classname	= "teledeath";
	death.movetype	= MOVETYPE_NONE;
	death.solid	= SOLID_TRIGGER;
	death.angles	= VEC_ORIGIN;

	setsize (death, death_owner.mins - '1 1 1', death_owner.maxs + '1 1 1');
	setorigin (death, org);

	death.touch	= tdeath_touch;
	// This was 0.2, but that might be too slow for a lower tick rate.
	death.nextthink	= time + (sys_ticrate * 2);
	death.think	= SUB_Remove;
	death.owner	= death_owner;

	force_retouch	= 2;		// make sure even still objects get hit
};

entity ()
find_info_teleport_destination =
{
	local entity spot;

	spot = find (last_teleport, classname, "info_teleport_destination");
	if (!spot)
		spot = find (spot, classname, "info_teleport_destination");

	last_teleport = spot;
	return spot;
};

void ()
teleport_touch =
{
	local entity t;
	local vector org;

	if (self.targetname)
	{
		// not fired yet
		if (self.nextthink < time)
			return;
	}

	if (self.spawnflags & PLAYER_ONLY)
	{
		if (other.classname != "player")
			return;
	}

	// only teleport living creatures
	if (other.health <= 0 || other.solid != SOLID_SLIDEBOX)
		return;

	SUB_UseTargets ();

	// put a tfog where the player was unless cloaked
	if (other.runetype != RN_CLOAK)
		spawn_tfog (other.origin);

	if (self.target)
		t = find (world, targetname, self.target);
	else
		t = find_info_teleport_destination ();

	if (!t)
	{
		// objerror ("couldn't find target");
		dprint ("teleport_touch(): couldn't find target!\n");
		remove (self);
		return;
	}

	// spawn a tfog flash in front of the destination
	makevectors (t.mangle);
	org = t.origin + 32 * v_forward;

	if (other.runetype != RN_CLOAK)
		spawn_tfog (org);

	spawn_tdeath (t.origin, other);

	// fix shambler from constantly teleporting
	if (other.classname == "shambler_slave")
		t.origin = t.origin + 8 * v_forward;

	setorigin (other, t.origin);

	other.angles = t.mangle;

	// move the player and lock him down for a little while
	if (other.classname == "player")
	{
		other.fixangle		= TRUE; // turn this way immediately
		other.teleport_time	= time + 0.7;

		HookOff_e (other);
		HookOff_by_targ_e (other);

		if (other.flags & FL_ONGROUND)
			other.flags = other.flags - other.flags & FL_ONGROUND;

		if (other.runetype == RN_DEFLECT)
			other.velocity = VEC_ORIGIN;
		else
			other.velocity = v_forward * 300;
	}
	else
		other.flags = other.flags - other.flags & FL_ONGROUND;
};

/*QUAKED info_teleport_destination (.5 .5 .5) (-8 -8 -8) (8 8 32)
This is the destination marker for a teleporter.  It should have a "targetname" field with the same value as a teleporter's "target" field.
*/
void ()
info_teleport_destination =
{
	// this does nothing, just serves as a target spot
	self.mangle	= self.angles;
	self.angles	= VEC_ORIGIN;
	self.model	= string_null;
	self.origin	= self.origin + '0 0 27';

	if (!self.targetname)
		objerror ("no targetname");
};

void ()
teleport_use =
{
	self.nextthink	= time + 0.2;
	force_retouch	= 2; // make sure even still objects get hit
	self.think	= SUB_Null;
};

/*QUAKED trigger_teleport (.5 .5 .5) ? PLAYER_ONLY SILENT
Any object touching this will be transported to the corresponding info_teleport_destination entity. You must set the "target" field, and create an object with a "targetname" field that matches.

If the trigger_teleport has a targetname, it will only teleport entities when it has been fired.
*/
void ()
trigger_teleport =
{
	local vector o;

	// Remove bogus teleporters, some of which have no destination.
	if ((mapname == "e4m5" && self.target == "t178")
		|| (mapname == "e4m8" && self.target == "t273")
		|| (mapname == "start" && self.target == "t11")
		|| (mapname == "e1m7" && self.target != "T2") // && self.target == "t15")
		|| (mapname == "e2m6" && self.target == "t88"))
	{
		remove (self);
		return;
	}

	InitTrigger ();
	self.touch = teleport_touch;
	if (!self.target)
		objerror ("no target");
	self.use = teleport_use;

	if (!self.spawnflags & SILENT)
	{
		if (!scratch1 & S1_AMBIENT_SOUND_OFF)
		{
			precache_sound ("ambience/hum1.wav");
			o = (self.mins + self.maxs) * 0.5;
			ambientsound (o, "ambience/hum1.wav", 0.5, ATTN_STATIC);
		}
	}
};

/*
==============================================================================

trigger_setskill

==============================================================================
*/

/* void ()
trigger_skill_touch =
{
	if (other.classname != "player")
		return;

	if (!deathmatch & DM_DM_MASK)
		cvar_set ("skill", self.message);
}; */

/*QUAKED trigger_setskill (.5 .5 .5) ?
sets skill level to the value of "message".
Only used on start map.
*/
void ()
trigger_setskill =
{
	remove (self);
	// InitTrigger ();
	// self.touch = trigger_skill_touch;
};

/*
==============================================================================

ONLY REGISTERED TRIGGERS

==============================================================================
*/

/* void ()
trigger_onlyregistered_touch =
{
	if (other.classname != "player")
		return;

	if (self.attack_finished > time)
		return;

	self.attack_finished = time + 2;
	if (cvar ("registered"))
	{
		self.message = string_null;
		SUB_UseTargets ();
		remove (self);
	}
	else
	{
		if (self.message != string_null)
		{
			centerprint (other, self.message);
			sound (other, CHAN_BODY, "misc/talk.wav", 1, ATTN_NORM);
		}
	}
}; */

/*QUAKED trigger_onlyregistered (.5 .5 .5) ?
Only fires if playing the registered version, otherwise prints the message
*/
void ()
trigger_onlyregistered =
{
	// precache_sound ("misc/talk.wav");
	InitTrigger ();
	self.nextthink = time + 1;
	self.think = DelayThink;
	//self.touch = trigger_onlyregistered_touch;
};

//============================================================================

void ()
hurt_on =
{
	self.solid = SOLID_TRIGGER;
	self.nextthink = -1;
};

void ()
hurt_touch =
{
	if (other.takedamage)
	{
		self.solid = SOLID_NOT;
		T_Damage (other, self, self, self.dmg, string_null);
		self.think = hurt_on;
		self.nextthink = time + 1;
	}

	return;
};

/*QUAKED trigger_hurt (.5 .5 .5) ?
Any object touching this will be hurt
set dmg to damage amount
defalt dmg = 5
*/
void ()
trigger_hurt =
{
	// Prevents you from getting hurt on map END.
	if (world.model == "maps/end.bsp")
		return;
	InitTrigger ();
	self.touch = hurt_touch;
	if (!self.dmg)
		self.dmg = 5;
};

//============================================================================

float PUSH_ONCE = 1;

void ()
trigger_push_touch =
{
	if (other.classname == "grenade")
		other.velocity = self.speed * self.movedir * 10;
	else if (other.health > 0)
	{
		other.velocity = self.speed * self.movedir * 10;
		if (other.classname == "player")
		{
			if (other.fly_sound < time)
			{
				other.fly_sound = time + 1.5;
				sound (other, CHAN_AUTO, "ambience/windfly.wav", 1, ATTN_NORM);
			}
		}
	}
	if (self.spawnflags & PUSH_ONCE)
		remove (self);
};

/*QUAKED trigger_push (.5 .5 .5) ? PUSH_ONCE
Pushes the player
*/
void ()
trigger_push =
{
	InitTrigger ();
	precache_sound ("ambience/windfly.wav");
	self.touch = trigger_push_touch;
	if (!self.speed)
		self.speed = 1000;
};

//============================================================================

void ()
trigger_monsterjump_touch =
{
	if (other.flags & (FL_MONSTER | FL_FLY | FL_SWIM) != FL_MONSTER)
		return;

	// set XY even if not on ground, so the jump will clear lips
	other.velocity_x = self.movedir_x * self.speed;
	other.velocity_y = self.movedir_y * self.speed;

	if (!(other.flags & FL_ONGROUND))
		return;

	other.flags = other.flags - FL_ONGROUND;

	other.velocity_z = self.height;
};

/*QUAKED trigger_monsterjump (.5 .5 .5) ?
Walking monsters that touch this will jump in the direction of the trigger's angle
"speed" default to 200, the speed thrown forward
"height" default to 200, the speed thrown upwards
*/
void ()
trigger_monsterjump =
{
	if (!self.speed)
		self.speed = 200;
	if (!self.height)
		self.height = 200;
	if (self.angles == VEC_ORIGIN)
		self.angles = '0 360 0';
	InitTrigger ();
	self.touch = trigger_monsterjump_touch;
};
