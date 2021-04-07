/*  $Id: arena.qc,v 1.34 2010/10/24 07:16:47 slotzero Exp $

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
// arena.goalentity	= first person to die, if both death
// arena.movetarget	= winner
// arena.dmg_inflictor	= current streaker
// arena.dmg_take	= streak amount
// arena.last_thought	= length match in progress
// arena.delay		= timelimit override

void (entity e)
arena_game_pos_announce =
{
	local float my_pos, total;
	local string s;

	if (e == arena.owner || e == arena.runent)
		return self_sprint (e, "you are in the game\n");

	my_pos = game_queue_pos_e (e);
	total = game_queue_len ();

	if (my_pos == 1)
		self_sprint (e, "you are next in line\n");
	else if (my_pos == total)
		self_sprint (e, "you are last in line\n");
 	else
	{
		self_sprint (e, "there are ");
		s = ftos (my_pos);
		self_sprint (e, s);
		self_sprint (e, " (of ");
		s = ftos (total);
		self_sprint (e, s);
		self_sprint (e, ") players ahead of you\n");
	}
};

void ()
arena_game_queue_announce =
{
	local float next_in_line;
	local entity e, e_next;

	e = find (world, classname, "player");
	while (e)
	{
		if (is_observer_e (e) && e.runevar)
		{
			if (!next_in_line || next_in_line > e.runevar)
			{
				next_in_line = e.runevar;
				e_next = e;
			}
		}
		e = find (e, classname, "player");
	}

	if (e_next.classname == "player")
		bprint2 (e_next.netname, " is next in line\n");
};

void (entity e)
set_arena_parms_e =
{
	local entity os;

	os = self;
	self = e;
	self.takedamage = DAMAGE_NO;
	if (gamemode == MODE_MIDAIR)
		SetMidairParms ();
	else
		SetArenaParms ();
	self = os;
};

void ()
arena_fight =
{
	if (self.runevar)
	{
		self_custom_sound (arena.owner, string_null, "misc/medkey.wav");
		self_custom_sound (arena.runent, string_null, "misc/medkey.wav");
		remove (self);
	}
	else
	{
		self_custom_sound (arena.owner, "ra/fight.wav", string_null);
		self_custom_sound (arena.runent, "ra/fight.wav", string_null);
	}

	self.runevar = 1;
	self.nextthink = time + 0.30;
};

void ()
arena_countdown =
{
	local float a, b;
	local string s;
	local entity e;

	if (intermission_running)
		return;

	a = is_player_e (self.owner);
	b = is_player_e (self.runent);

	if (self.state < 0)
	{
		if (self.owner.deadflag || self.runent.deadflag)
		{
				arena.deadflag = 1;
				self.nextthink = time + 1;
				return;
		}

		if (a && b)
		{
			bprint (self.runent.netname);
			bprint (" is the new challenger\n");

			// set parms
			set_arena_parms_e (self.owner);

			self.state = 6;
		}
   		else
		{
			if (b)
			{
				self.owner = self.runent;
				self.runent = world;
			}

			if (a || b)
			{
				self_sprint (self.owner, "waiting for opponent\n");
				centerprint (self.owner, string_null);

				// set parms
				set_arena_parms_e (self.owner);

				// allow waiting player to rocket jump
				self.owner.takedamage = DAMAGE_AIM;
				self.state = -2;
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
			// reset match time
			self.last_thought = time;

			// prevent timelimit during match
			self.delay = 1;

			bprint (self.owner.netname);
			if (self.owner == self.dmg_inflictor && self.dmg_take > 1)
			{
				bprint (" \[");
				bprint_float (self.dmg_take);
				bprint ("\]");
			}
			bprint (" vs ");
			bprint (self.runent.netname);
			bprint ("\n");

			arena_game_queue_announce ();

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

			// custom sounds
			if (self.state < 4)
			{
				if (self.state == 3)
					s = "ra/3.wav";
				else if (self.state == 2)
					s = "ra/2.wav";
			       	else
					s = "ra/1.wav";

				self_custom_sound (self.owner, s, "buttons/switch04.wav");
				self_custom_sound (self.runent, s, "buttons/switch04.wav");

				// hack
				if (self.state == 1)
				{
					e		= spawn ();
					e.think		= arena_fight;
					e.nextthink	= time + 0.65;
				}
			}
		}
	}
	else
	{
		// prevent match from taking too long
		a = game_queue_len();
		if (a)
		{
			b = ceil (time - self.last_thought);
			if ((a > 3 && b == 50) || b == 80)
				bprint ("\{1}match ends in 10 seconds\n");
			if ((a > 3 && b > 60) || (b > 90))
			{
				bprint ("\{1}match timelimit reached\n");
				if ((self.owner.health + self.owner.armorvalue) > (self.runent.health + self.runent.armorvalue))
					sure_kill_e (self.runent, string_null);
				else
					sure_kill_e (self.owner, string_null);
			}
		}
	}

	arena.nextthink = time + 1;
};

void ()
arena_results =
{
	local entity winner, os;
	local float draw;
	local string x;

	// This is done here so that any damage done after the first death
	// can be acted out upon.
	if (self.owner)
		self.owner.takedamage = DAMAGE_NO;
	if (self.runent)
		self.runent.takedamage = DAMAGE_NO;

	if (!self.owner || !self.runent)
	{
		arena.think = arena_countdown;
		arena.nextthink = time;
		return;
	}

	winner = world;

	// draw (dual suicides)
	if (self.oldenemy != world && self.enemy == self.aiment && self.oldenemy == self.goalentity)
		draw = 1;
	// suicider always loses
	else if (self.enemy == self.oldenemy || self.enemy == self.aiment)
	{
		if (self.owner == self.enemy)
			winner = self.runent;
		else
			winner = self.owner;
	}
	// draw
	else if (self.oldenemy)
		draw = 1;
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

		if (self.dmg_inflictor == winner)
			self.dmg_take = self.dmg_take + 1;
		else
		{
			self.dmg_inflictor = winner;
			self.dmg_take = 1;
		}

		add_frag (winner, 1);
		IN_QW([-
			if (winner == self.enemy)
				logfrag (self.enemy, self.runent);
			else
				logfrag (self.runent, self.enemy);
		-])
		bprint (winner.netname);
		bprint (" won the round");

		if (winner == self.enemy || winner == self.oldenemy)
		{
			bprint ("\n");

			if (winner.health >= 100 && winner.armorvalue >= 200)
			{
				self_custom_sound (world, "ra/flawless.wav", string_null);
				bprint ("\bFLAWLESS VICTORY!\n");
			}
			else
			{
				if (winner.health >= 75 && winner.armorvalue >= 100)
					self_custom_sound (world, "ra/excelent.wav\n", string_null);

				x = ftos (winner.health);
				bprint (winner.netname);
				bprint (" had ");
				bprint (x);
				bprint (" health and ");

				if (winner.armorvalue)
				{
					x = ftos (winner.armorvalue);
					bprint (x);
					bprint (" armor\n");
				}
				else
					bprint ("no armor\n");
			}
		}
		else
			bprint (" by default\n");
	}
	else
	{
		// draw clears streak
		self.dmg_inflictor = world;
		self.dmg_take = 0;

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

void (entity targ, entity attacker, string dtype)
arena_death =
{
	if (targ.classname != "player")
		return;

	arena.state = -1;

	if (attacker.classname != "player")
		attacker = targ;

	if (arena.enemy)
	{
		arena.oldenemy   = arena.enemy;
		arena.goalentity = arena.aiment;
	}

	// prevent anything other than the current players from being the winner
	if (arena.owner != attacker && arena.runent != attacker)
		attacker = targ;

	arena.enemy	= attacker;
	arena.aiment	= targ;

	arena.think	= arena_results;

	// kill command
	if (dtype == "suicide")
		arena.nextthink = time + 4;
	else
		arena.nextthink	= time + 1;
};

void ()
arena_init =
{
	arena.state		= -1;
	arena.deadflag		= 0;
	arena.delay		= 0;
	arena.enemy		= world;
	arena.oldenemy		= world;
	arena.aiment		= world;
	arena.goalentity	= world;

	arena.think		= arena_countdown;
	arena.nextthink		= time + 1;
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

	if (is_player_e (arena.owner) && !arena.owner.deadflag)
		set_arena_parms_e (arena.owner);

	arena.think = arena_countdown;
	arena.nextthink = time;

	return TRUE;
};
