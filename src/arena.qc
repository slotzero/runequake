/*  $Id: arena.qc,v 1.6 2005/01/08 04:53:26 slotzero Exp $

    Copyright (C) 2003  David 'Slot Zero' Roberts.

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

// ARENA TODO (DEV)
/*
	// fix takedamage bug
	* shields set takedamage to DAMAGE_AIM when they expire
*/

// arena entity
//
// arena.state		= neg (waiting for players) | pos (counting down) | zero (game in progress)
// arena.owner		= opponent 1
// arena.runent		= opponent 2
// arena.enemy		= last person to kill
// arena.oldenemy	= first person to kill, if both dead
// arena.aiment		= last person to die
// arena.movetarget	= winner

float ()
mode_arena =
{
	if (!arena)
		return FALSE;

	if (!deathmatch & DM_MODE_ROCKET_ARENA)
		return FALSE;

	return TRUE;
};

void ()
arena_countdown =
{
	local float a, b;
	local string s;

	a = is_player_e (self.owner);
	b = is_player_e (self.runent);

	if (self.state < 0)
	{
		if (a && b)
		{
			if (self.owner.deadflag || self.runent.deadflag)
			{
				arena.deadflag = 1;
				self.nextthink = time + 1;
				return;
			}

			bprint (self.runent.netname);
			bprint (" is the new challenger\n");

			self.state = 4;
		}
   		else
		{
			if (a)
			{
				self.runent = world;
				self_sprint (self.owner, "waiting for opponent\n");
				centerprint (self.owner, string_null);
			}
			else if (b)
			{
				self.owner = world;
				self_sprint (self.runent, "waiting for opponent\n");
				centerprint (self.runent, string_null);
			}
			else
				bprint ("waiting for players\n");

			return;
		}
	}
	else if (self.state > 0)
	{
		self.state = self.state - 1;

		if (self.state == 0)
		{
			bprint (self.owner.netname);
			bprint (" vs ");
			bprint (self.runent.netname);
			bprint ("\n");

			self_centerprint (self.owner, "\n\bFIGHT!\n");
			self_centerprint (self.runent, "\n\bFIGHT!\n");

			self.owner.takedamage = DAMAGE_AIM;
			self.runent.takedamage = DAMAGE_AIM;
		}
		else if (self.state <= 10)
		{
			s = ftos (self.state);
			self_centerprint (self.owner, self.runent.netname, "\n\n", s);
			self_centerprint (self.runent, self.owner.netname, "\n\n", s);
		}
	}
	else
		return;

	arena.nextthink = time + 1;
};

void ()
arena_results =
{
	local entity winner, os;
	local float draw;

	// This is done here so that any damage done after the first death
	// can be acted out upon.
	if (self.owner)
		self.owner.takedamage = DAMAGE_NO;
	if (self.runent)
		self.runent.takedamage = DAMAGE_NO;

	// suicider always loses
	if (self.enemy == self.oldenemy || self.enemy == self.aiment)
	{
		if (self.owner == self.enemy)
			winner = self.runent;
		else
			winner = self.owner;
	}
	// draw
	else if (self.oldenemy)
	{
		draw = 1;
		winner = world;
	}
	// last man standing
	else
		winner = self.enemy;

	self.movetarget = winner;
	self.deadflag = 1;
	if (winner)
	{
		// check for new challenger
		if (winner != self.owner)
		{
			os = self.owner;
			self.owner = winner;
			self.runent = os;
		}

		// if winner isn't dead, set her parms
		if (!self.oldenemy)
		{
			os = self;
			self = winner;
			SetArenaParms ();
			self = os;
		}

		add_frag (winner, 1);
		bprint (winner.netname);
		bprint (" won the round\n");
	}
	else
	{
		if (draw)
			bprint ("round was a draw\n");
	}
};

void ()
arena_death_think =
{
	if (self.deadflag != DEAD_DEAD)
		return;

	if (!arena.deadflag)
		return;

	if (arena.movetarget == self || !arena.movetarget)
	{
		respawn ();
		return;
	}

	if (game_queue_len ())
		corpse_to_observer (3);
	else
		respawn ();
};

void (entity targ, entity attacker)
arena_death =
{
	arena.state	= -1;

	if (attacker.classname != "player")
		attacker = targ;

	if (arena.enemy)
		arena.oldenemy = arena.enemy;

	arena.enemy	= attacker;
	arena.aiment	= targ;

	arena.think	= arena_results;
	arena.nextthink	= time + 1;
};

void ()
arena_init =
{
	arena.state	= -1;
	arena.deadflag	= 0;
	arena.enemy	= world;
	arena.oldenemy	= world;
	arena.aiment	= world;

	arena.think	= arena_countdown;
	arena.nextthink	= time + 1;
};

float ()
put_client_in_arena =
{
	if (self == arena.owner || self == arena.runent)
		return TRUE;

	if (!is_player_e (arena.owner))
		arena.owner = self;
	else if (!is_player_e (arena.runent))
		arena.runent = self;
	else
		return FALSE;

	arena.think = arena_init;
	arena.nextthink = time;

	return TRUE;
};

float ()
arena_client_disconnect =
{
	if (self != arena.owner && self != arena.runent)
		return FALSE;

  	arena.state = -1;

	if (arena.owner == self)
	{
		arena.owner = arena.runent;
		arena.runent = world;
	}
	else
		arena.runent = world;

	arena.think = arena_countdown;
	arena.nextthink = time;

	return TRUE;
};
