/*
    Copyright (C) 2004-2013  David 'Slot Zero' Roberts.

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

// types
//
// "item_artifact_super_damage"
// "item_artifact_invulnerability"
// "item_artifact_invisibility"
// "item_artifact_envirosuit"

void (string type, float mode)
toggle_powerup =
{
	local entity e;

	e = find (world, classname, type);
	while (e)
	{
		if (mode)
		{
			e.nextthink	= time;
			e.think		= SUB_regen;
		}
		else
		{
			e.model		= string_null;
			e.solid		= SOLID_NOT;
			e.nextthink	= -2;
		}
		e = find (e, classname, type);
	}
};

void ()
setquad =
{
	local string s;

	toggle_powerup ("item_artifact_super_damage", options & NO_QUAD);

	if (maybe_bprint_option (options & NO_QUAD, 0, "quad"))
		options = options - options & NO_QUAD;
	else
		options = options | NO_QUAD;

	s = ftos (options);
	cvar_set_infokey (CVAR_C4, s);
};

void ()
setpent =
{
	local string s;

	toggle_powerup ("item_artifact_invulnerability", options & NO_PENT);

	if (maybe_bprint_option (options & NO_PENT, 0, "pent"))
		options = options - options & NO_PENT;
	else
		options = options | NO_PENT;

	s = ftos (options);
	cvar_set_infokey (CVAR_C4, s);
};

void ()
setring =
{
	local string s;

	toggle_powerup ("item_artifact_invisibility", options & NO_RING);

	if (maybe_bprint_option (options & NO_RING, 0, "ring"))
		options = options - options & NO_RING;
	else
		options = options | NO_RING;

	s = ftos (options);
	cvar_set_infokey (CVAR_C4, s);
};

void ()
setsuit =
{
	local string s;

	toggle_powerup ("item_artifact_envirosuit", options & NO_SUIT);

	if (maybe_bprint_option (options & NO_SUIT, 0, "suit"))
		options = options - options & NO_SUIT;
	else
		options = options | NO_SUIT;

	s = ftos (options);
	cvar_set_infokey (CVAR_C4, s);
};

void (float mode)
toggle_armor =
{
	local entity e;

	e = find (world, netname, "item_armor_all");
	while (e)
	{
		if (mode)
		{
			e.skin		= e.impulse;
			e.runetype	= time;
			e.think		= SUB_regen;
			e.nextthink	= time;
		}
		else
		{
			e.solid		= SOLID_NOT;
			e.model		= string_null;
			e.nextthink	= -2;
		}
		e = find (e, netname, "item_armor_all");
	}
};

void ()
setarmor =
{
	local string s;

	toggle_armor (options & NO_ARMOR);

	if (maybe_bprint_option (options & NO_ARMOR, 0, "armor"))
		options = options - options & NO_ARMOR;
	else
		options = options | NO_ARMOR;

	s = ftos (options);
	cvar_set_infokey (CVAR_C4, s);
};

void ()
setrotate =
{
	local string s;

	if (options & NO_ARMOR)
		return;

	toggle_armor (1);

	if (maybe_bprint_option (options & ARMOR_ROTATE, 1, "rotating armor"))
		options = options - options & ARMOR_ROTATE;
	else
		options = options | ARMOR_ROTATE;

	s = ftos (options);
	cvar_set_infokey (CVAR_C4, s);
};

void ()
setrunes =
{
	local entity e, os;
	local string s;

	if (maybe_bprint_option (options & NO_RUNES, 0, "runes"))
		options = options - options & NO_RUNES;
	else
		options = options | NO_RUNES;

	s = ftos (options);
	cvar_set_infokey (CVAR_C4, s);

	if (options & NO_RUNES)
	{
		runemax		= 0;
		runecurrent	= 0;
		remove_classname ("rune");

		e = find (world, classname, "player");
		while (e)
		{
			if (e.runetype)
			{
				os	= self;
				self	= e;

				Rune_Delete (0);

				self	= os;
			}
			e = find (e, classname, "player");
		}
	}
	else
	{
		set_runemax ();
		runespawntime	= time;
	}
};

void ()
setalts =
{
	local entity e, os;
	local string s;

	if (maybe_bprint_option (options & NO_ALT_WEAPONS, 0, "alternate weapons"))
		options = options - options & NO_ALT_WEAPONS;
	else
		options = options | NO_ALT_WEAPONS;

	s = ftos (options);
	cvar_set_infokey (CVAR_C4, s);

	if (options & NO_ALT_WEAPONS)
	{
		e = find (world, classname, "player");
		while (e)
		{
			os = self;
			self = e;
			if (self.weapon & WEAPON_ALT)
				set_weapon (W_BestWeapon ());
			self = os;
			e = find (e, classname, "player");
		}
	}
};

void ()
setshields =
{
	local string s;

	if (maybe_bprint_option (options & NO_SPAWN_SHIELDS, 0, "spawn shields"))
		options = options - options & NO_SPAWN_SHIELDS;
	else
		options = options | NO_SPAWN_SHIELDS;

	s = ftos (options);
	cvar_set_infokey (CVAR_C4, s);
};

void ()
sethookdamage =
{
	local string s;

	if (maybe_bprint_option (options & NO_HOOK_DAMAGE, 0, "hook damage"))
		options = options - options & NO_HOOK_DAMAGE;
	else
		options = options | NO_HOOK_DAMAGE;

	s = ftos (options);
	cvar_set_infokey (CVAR_C4, s);
};

// -1 all
// 0 large health box
// 1 small health box
// 2 mega health box

void (string type, float bit, float mode)
toggle_health =
{
	local entity e;
	local float force;

	if (bit < 0)
		force = 1;

	e = find (world, classname, type);
	while (e)
	{
		if (e.spawnflags & bit || (!bit && !e.spawnflags) || force)
		{
			if (mode)
			{
				e.nextthink	= time;
				e.think		= SUB_regen;
			}
			else
			{
				e.model		= string_null;
				e.solid		= SOLID_NOT;
				e.nextthink	= -2;
			}
		}
		e = find (e, classname, type);
	}
};

void ()
setmega =
{
	local string s;

	toggle_health ("item_health", 2, options & NO_MEGA);

	if (maybe_bprint_option (options & NO_MEGA, 0, "mega-health boxes"))
		options = options - options & NO_MEGA;
	else
		options = options | NO_MEGA;

	s = ftos (options);
	cvar_set_infokey (CVAR_C4, s);
};

void ()
toggle_weapons_stay =
{
	local entity e;
	local string s;

	// XXX slow?  maybe assign second classname and use find?
	e = nextent (world);
	while (e)
	{
		if (e.touch == weapon_touch)
		{
			e.runetime	= time;
			e.think		= SUB_regen;
			e.nextthink	= time;

			if (options & WEAPONS_STAY)
				setorigin (e, e.oldorigin);
			else
				setorigin (e, e.oldorigin + WEAPON_CHARGED_OFFSET);
		}
		e = nextent (e);
	}

	if (maybe_bprint_option (options & WEAPONS_STAY, 1, "weapons stay"))
		options = options - options & WEAPONS_STAY;
	else
		options = options | WEAPONS_STAY;

	s = ftos (options);
	cvar_set_infokey (CVAR_C4, s);
};

void ()
toggle_armor_drop =
{
	local string s;

	if (maybe_bprint_option (options & NO_DROP_ARMOR, 0, "armor drop"))
		options = options - options & NO_DROP_ARMOR;
	else
	{
		options = options | NO_DROP_ARMOR;
		remove_classname ("dropped_armor");
	}

	s = ftos (options);
	cvar_set_infokey (CVAR_C4, s);
};

void ()
setfaststart =
{
	local string s;

	if (maybe_bprint_option (options & FASTSTART, 1, "fast match starts"))
		options = options - options & FASTSTART;
	else
		options = options | FASTSTART;

	s = ftos (options);
	cvar_set_infokey (CVAR_C4, s);
};

void ()
setmatchlock =
{
	MATCHLOCK = !MATCHLOCK;
	if (MATCHLOCK)
		bprint_teamsize (2);
};

void ()
setbackpacks =
{
	local string s;

	if (maybe_bprint_option (options & NO_BACKPACKS, 0, "backpacks"))
		options = options - options & NO_BACKPACKS;
	else
		options = options | NO_BACKPACKS;

	if (options & NO_BACKPACKS)
		remove_classname ("backpack");

	s = ftos (options);
	cvar_set_infokey (CVAR_C4, s);
};

void ()
toggle_powerup_drop =
{
	local string s;

	if (maybe_bprint_option (options & NO_DROP_POWERUP, 0, "powerup drop"))
		options = options - options & NO_DROP_POWERUP;
	else
	{
		options = options | NO_DROP_POWERUP;
		remove_classname ("dropped_powerup");
	}

	s = ftos (options);
	cvar_set_infokey (CVAR_C4, s);
};

void ()
toggle_rune_drop =
{
	local entity e;
	local string s;

	if (maybe_bprint_option (options & NO_DROP_ON_DEATH, 0, "rune dropping"))
		options = options - options & NO_DROP_ON_DEATH;
	else
	{
		options = options | NO_DROP_ON_DEATH;

		e = find (world, classname, "rune");
		while (e)
		{
			e.owner = world;
			e.enemy = world;
			e = find (e, classname, "rune");
		}
	}

	s = ftos (options);
	cvar_set_infokey (CVAR_C4, s);
};

void ()
toggle_lightning_discharge =
{
	local string s;

	if (maybe_bprint_option (options & NO_DISCHARGE, 0, "lightning discharge"))
		options = options - options & NO_DISCHARGE;
	else
		options = options | NO_DISCHARGE;

	s = ftos (options);
	cvar_set_infokey (CVAR_C4, s);
};

void ()
setclassicmega =
{
	local entity e;
	local string s;

	e = find (world, classname, "item_health");
	while (e)
	{
		if (e.spawnflags & H_MEGA)
		{
			if (e.owner)
				e.owner = world;

			if (e.nextthink > -2 && e.solid == SOLID_NOT)
			{
				e.nextthink = time;
				e.think = SUB_regen;
			}
		}
		e = find (e, classname, "item_health");
	}

	e = find (world, classname, "decay_health");
	while (e)
	{
		if (e.runevar > 1)
			e.runevar = 1;
		e = find (e, classname, "decay_health");
	}

	if (maybe_bprint_option (options & CLASSIC_MEGA, 1, "classic mega"))
		options = options - options & CLASSIC_MEGA;
	else
		options = options | CLASSIC_MEGA;

	s = ftos (options);
	cvar_set_infokey (CVAR_C4, s);
};

void ()
toggle_mode_lock =
{
	local string s;

	if (options & MODE_LOCKED)
		options = options - options & MODE_LOCKED;
	else
		options = options | MODE_LOCKED;

	s = ftos (options);
	cvar_set_infokey (CVAR_C4, s);
};

void ()
toggle_random_spawn =
{
	local string s;

	if (maybe_bprint_option (options & RANDOM_SPAWN, 1, "random spawn"))
		options = options - options & RANDOM_SPAWN;
	else
		options = options | RANDOM_SPAWN;

	lastspawn = world;

	s = ftos (options);
	cvar_set_infokey (CVAR_C4, s);
};

void ()
toggle_shoot_buttons =
{
	local entity e;
	local string s;

	e = find (world, netname, "func_button_shootable");
	while (e)
	{
		if (options & SHOOT_BUTTONS)
		{
			e.takedamage = DAMAGE_NO;
			e.health = 0;
		}
		else
		{
			e.health	= 1;
			e.max_health	= e.health;
			e.th_die	= button_killed;
			e.takedamage	= DAMAGE_YES;
		}
		e = find (e, netname, "func_button_shootable");
	}

	if (maybe_bprint_option (options & SHOOT_BUTTONS, 1, "shootable buttons"))
		options = options - options & SHOOT_BUTTONS;
	else
		options = options | SHOOT_BUTTONS;

	s = ftos (options);
	cvar_set_infokey (CVAR_C4, s);
};

void ()
toggle_powerup_hats =
{
	local entity e;
	local string s;

	if (maybe_bprint_option (options & NO_POWERUP_HATS, 0, "powerup hats"))
	{
		options = options - options & NO_POWERUP_HATS;

		// put hats back on players
		e = find (world, classname, "player");
		while (e)
		{
			if (e.invincible_finished > time)
				Hat_Spawn (e, "progs/invulner.mdl", '0 0 35', VEC_ORIGIN, ITEM_PENT);

			if (e.super_damage_finished > time)
				Hat_Spawn (e, "progs/quaddama.mdl", '0 0 30', VEC_ORIGIN, ITEM_QUAD);

			e = find (e, classname, "player");
		}
	}
	else
		options = options | NO_POWERUP_HATS;



	s = ftos (options);
	cvar_set_infokey (CVAR_C4, s);
};

void ()
toggle_vote_hook =
{
	local string s;

	if (options2 & VOTE_HOOK_DISABLED)
		options2 = options2 - options2 & VOTE_HOOK_DISABLED;
	else
		options2 = options2 | VOTE_HOOK_DISABLED;

	s = ftos (options2);
	cvar_set_infokey (CVAR_C5, s);
};

void ()
set_gamemode_default =
{
	if (scratch1 & S1_NO_DEFAULT)
		return;

	maybe_bprint_option_hack = 1;
	gamemode_default (gamemode);
	maybe_bprint_option_hack = 0;
};

float (float type, float neg, string desc)
maybe_bprint_option =
{
	local string s;

	if (!maybe_bprint_option_hack)
		return type;

	// parens needed
	if (!(!type) - !(!neg))
		s = " enabled\n";
	else
		s = " disabled\n";

	bprint (desc);
	bprint (s);

	return type;
};
