/*  $Id: bindings.qc,v 1.34 2004/07/08 09:57:56 slotzero Exp $

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

// I have to pass the name_num separately because I have to re-ftos()
// it, because ftos() has a single string which it always returns.
// Quake C is so awful.

void (string name, float name_num, float imp)
player_init_switchfire_alias =
{
	local string s;

	self_stuffcmd (self, "alias +sattack");
	if (name_num)
		name = ftos (name_num);
	self_stuffcmd (self, name);
	self_stuffcmd (self, " \"impulse ");
	s = ftos (imp); self_stuffcmd (self, s);
	self_stuffcmd (self, "\"; alias -sattack");
	if (name_num)
		name = ftos (name_num);
	self_stuffcmd (self, name);
	self_stuffcmd (self, " \"impulse ");
	s = ftos (IMP_SWITCHFIRE_OFF); self_stuffcmd (self, s);
	self_stuffcmd (self, "\"\n");
};

void ()
switchfire_aliases =
{
	local float i;
	local string s;

	i = 1;
	while (i <= IMP_SWITCHFIRE_COUNT)
	{
		i = i + 1;
		s = ftos (i);
		player_init_switchfire_alias (string_null, i, i + IMP_SWITCHFIRE_BASE - 1);
	}

	player_init_switchfire_alias ("-best", 0, IMP_SWITCHFIRE_BEST);

	i = 0;
	while (i < IMP_WEAPON_COUNT)
	{
		self_stuffcmd (self, "alias weapon");
		s = ftos (IMP_WEAPON_START + i); self_stuffcmd (self, s);
		self_stuffcmd (self, " \"impulse ");
		s = ftos (IMP_WEAPON_BASE + i); self_stuffcmd (self, s);
		self_stuffcmd (self, "\"\n");
		i = i + 1;
	}
};

void (string cmd, float imp)
player_init_impulse_alias =
{
	local string s;

	s = ftos (imp);
	self_stuffcmd (self, "alias ");
	self_stuffcmd (self, cmd);
	self_stuffcmd (self, " \"impulse ");
	self_stuffcmd (self, s);
	self_stuffcmd (self, "\"\n");
};

void (string cmd, float imp)
player_admin_impulse_alias =
{
	local string s;

	self_stuffcmd (self, "alias ");
	self_stuffcmd (self, cmd);
	self_stuffcmd (self, " \"");
	self_stuffcmd (self, "ac;w5;w5;impulse ");
	s = ftos (imp);
	self_stuffcmd (self, s);
	self_stuffcmd (self, ";w5\"\n");
};

void ()
player_bindings_think =
{
	local entity os;

	os = self;
	self = self.owner;
	if (os.runevar)
	{
		custom_aliases ();

		// XXX I want to put this in settings.qc, but I'm thinking this can be done
		// more effeciently with internal.qc or just modified the engine.
		if (MAP_IS_CUSTOM)
		{
			self_sprint (self, "\nDon't have the map?\n");
			self_sprint (self, "\nDownload from \bwww.runequake.com\b\n");
		}
	}
	else
	{
		self_sprint (self, "Sending player bindings\n");
		player_aliases ();
	}
	self = os;

	if (self.runevar || !total_customs ())
		remove (self);
	else
	{
		self.runevar = 1;
		self.nextthink = time + 2;
	}
};

void ()
spawn_player_bindings =
{
	local entity e;

	e		= spawn ();
	e.owner		= self;
	e.runevar	= 0;
	e.think		= player_bindings_think;
	e.nextthink	= time + 2;
};

void ()
player_aliases =
{
	local string s;

	// A fix for CRMod users...
	self_stuffcmd (self, "alias ignorethis \"echo Welcome Rune Quake player!\"\n");

	// Prevent honest people from using cam.cfg.
	self_stuffcmd (self, "alias chase_active \"echo chase_active has been disabled on this server.\"\n");

	self_stuffcmd (self, "alias w5 \"wait;wait;wait;wait;wait;\"\n");
	self_stuffcmd (self, "alias cl \"impulse ");
	s = ftos (IMP_CHANGE_MAP);
	self_stuffcmd (self, s);
	self_stuffcmd (self, "\"\n");

	player_init_impulse_alias ("admin-toggle",		IMP_ADMIN_TOGGLE);
	player_init_impulse_alias ("best-weapon",		IMP_BEST_WEAPON);
	player_init_impulse_alias ("change-level",		IMP_LEVELS);
	player_init_impulse_alias ("commands",			IMP_COMMANDS);
	player_init_impulse_alias ("custom",			IMP_CUSTOM);
	player_init_impulse_alias ("custom-sounds",		IMP_CUSTOM_SOUNDS);
	player_init_impulse_alias ("cycle-alternates",		IMP_CYCLE_ALTERNATES);
	player_init_impulse_alias ("disp-info",			IMP_DISP_INFO);
	player_init_impulse_alias ("disp-info-all",		IMP_DISP_INFO_ALL);
	player_init_impulse_alias ("fix-angles",		IMP_FIX_BATMAN);
	player_init_impulse_alias ("help-levels",		IMP_HELP_LEVELS);
	player_init_impulse_alias ("+hook",			IMP_HOOK_ON);
	player_init_impulse_alias ("-hook",			IMP_HOOK_OFF);
	player_init_impulse_alias ("hook-off",			IMP_HOOK_OFF);
	player_init_impulse_alias ("hook-on",			IMP_HOOK_ON);
	player_init_impulse_alias ("hook-toggle",		IMP_HOOK_TOGGLE);
	player_init_impulse_alias ("hud-toggle",		IMP_HUD_TOGGLE);
	player_init_impulse_alias ("last",			IMP_LAST);
	player_init_impulse_alias ("levels",			IMP_LEVELS);
	player_init_impulse_alias ("quiet-toggle",		IMP_QUIET_TOGGLE);
	player_init_impulse_alias ("remove-frags",		IMP_REMOVE_FRAGS);
	player_init_impulse_alias ("rider-hide",		IMP_RIDER_HIDE);
	player_init_impulse_alias ("rune-delete",		IMP_RUNE_DELETE);
	player_init_impulse_alias ("rune-tell",			IMP_RUNE_TELL);
	player_init_impulse_alias ("rune-use",			IMP_RUNE_USE);
	player_init_impulse_alias ("show-players",		IMP_SHOW_PLAYERS);
	player_init_impulse_alias ("show-pos",			IMP_SHOW_POS);
	player_init_impulse_alias ("show-riders",		IMP_SHOW_RIDERS);
	player_init_impulse_alias ("show-settings",		IMP_SHOW_SETTINGS);
	player_init_impulse_alias ("team-change",		IMP_TEAM_ROTATE);
	player_init_impulse_alias ("team-stats",		IMP_TEAM_STATS);
	player_init_impulse_alias ("vote-exit",			IMP_VOTE_EXIT);
	player_init_impulse_alias ("vote-free",			IMP_VOTE_FREE);
	player_init_impulse_alias ("vote-level",		IMP_LEVELS);
	player_init_impulse_alias ("vote-lithium",		IMP_VOTE_LITHIUM);
	player_init_impulse_alias ("vote-team",			IMP_VOTE_TEAM);
	player_init_impulse_alias ("vote-hook",			IMP_VOTE_HOOK);
	player_init_impulse_alias ("weapon-mode",		IMP_WEAPON_MODE);
	player_init_impulse_alias ("weapon-toggles",		IMP_WEAPON_TOGGLES);
	player_init_impulse_alias ("weapon-toggles-toggle",	IMP_WEAPON_TOGGLES);
	player_init_impulse_alias ("yes",			IMP_VOTE_YES);

	// not ready yet
	// player_inti_impulse_alias ("no", 			IMP_VOTE_NO);
	self_stuffcmd (self, "alias no \"echo Command still in development\"\n");

	switchfire_aliases ();
	level_aliases ();
};

void ()
admin_aliases =
{
	local string s;

	self_stuffcmd (self, "alias ac \"impulse ");
	s = ftos (IMP_ADMIN_COMMAND);
	self_stuffcmd (self, s);
	self_stuffcmd (self, "\"\n");

	player_admin_impulse_alias ("admin-cycle",		IMP_ADMIN_CYCLE);
	player_admin_impulse_alias ("admin-cycle-show",		IMP_ADMIN_CYCLE_SHOW);
	player_admin_impulse_alias ("admin-eyes",		IMP_ADMIN_EYES);
	player_admin_impulse_alias ("admin-join",		IMP_ADMIN_JOIN);
	player_admin_impulse_alias ("admin-kick",		IMP_ADMIN_KICK);
	player_admin_impulse_alias ("admin-kill",		IMP_ADMIN_KILL);
	player_admin_impulse_alias ("admin-rename",		IMP_ADMIN_RENAME);
	player_admin_impulse_alias ("admin-rune-delete",	IMP_ADMIN_RUNE_DELETE);
	player_admin_impulse_alias ("admin-team-change",	IMP_ADMIN_TEAM_CHANGE);
	player_admin_impulse_alias ("admin-team-change-toggle",	IMP_ADMIN_TEAM_CHANGE_TOGGLE);
	player_admin_impulse_alias ("admin-vote-team-toggle",	IMP_ADMIN_VOTE_TEAM_TOGGLE);
	player_admin_impulse_alias ("admin-teamplay-zero",	IMP_ADMIN_TEAMPLAY_ZERO);
	player_admin_impulse_alias ("admin-unbind",		IMP_ADMIN_UNBIND);
	player_admin_impulse_alias ("change-level",		IMP_ADMIN_CHANGE_MAP);
	player_admin_impulse_alias ("exit-level",		IMP_EXIT_LEVEL);
	player_admin_impulse_alias ("qsmack",			IMP_QSMACK_COMMAND);
};

void (string level, float imp)
player_console_init_level_alias =
{
	local string s;

	// Console
	if (self == world)
	{
		localcmd ("alias ");
		localcmd (level);
		localcmd (" \"IN_QW(serverinfo )");
		localcmd (CVAR_C1);
		localcmd (" ");
		s = ftos (imp);
		localcmd (s);
		localcmd ("\"\n");
	}
	// Player
	else
	{
		self_stuffcmd (self, "alias ");
		self_stuffcmd (self, level);
		self_stuffcmd (self, " \"cl;w5;w5;impulse ");
		s = ftos (imp);
		self_stuffcmd (self, s);
		self_stuffcmd (self, ";w5\"\n");
	}
};

void (string cmd, string cvr, float imp)
console_init_cvar_alias =
{
	local string s;

	s = ftos (imp);
	localcmd ("alias ");
	localcmd (cmd);
	localcmd (" \"IN_QW(serverinfo )");
	localcmd (cvr);
	localcmd (" ");
	localcmd (s);
	localcmd (";wait;\"\n");
};

void ()
console_aliases =
{
	dprint_force ("Sending console bindings\n");

	console_init_cvar_alias ("update-bindings",	CVAR_C2,	C2_UPDATE_BINDINGS);
	console_init_cvar_alias ("show-players",	CVAR_C2,	C2_SHOW_PLAYERS);
	console_init_cvar_alias ("show-settings",	CVAR_C2,	C2_SHOW_SETTINGS);
	console_init_cvar_alias ("rune-cheat",		CVAR_C2,	C2_TOGGLE_RUNE_CHEAT);
	console_init_cvar_alias ("last",		CVAR_C2,	C2_LAST);
	console_init_cvar_alias ("levels",		CVAR_C2,	C2_LEVELS);
	console_init_cvar_alias ("custom",		CVAR_C2,	C2_CUSTOM);
	console_init_cvar_alias ("commands",		CVAR_C2,	C2_COMMANDS);
	console_init_cvar_alias ("level-time",		CVAR_C2,	C2_LEVEL_TIME);
	console_init_cvar_alias ("practice",		CVAR_C2,	C2_MODE_PRACTICE);
	console_init_cvar_alias ("normal",		CVAR_C2,	C2_MODE_NORMAL);
	console_init_cvar_alias ("noalts",		CVAR_C2,	C2_TOGGLE_NOALTS);

	level_aliases ();
	custom_aliases ();
	custom_maps ();
};

// XXX I would like to expand this.  help-server, help-weapons, help-vote, and so on.
void ()
commands =
{
       local float i;

	i = -14;

	//                                                              12345678901234567890123456789012345\n
	self_sprint (self, "\ncommands\n\n");
	self_sprintf_len (self, "\brune-delete", i);		self_sprint (self, "delete your rune\n");
	self_sprintf_len (self, "\brune-tell", i);		self_sprint (self, "rune description\n");
	self_sprintf_len (self, "\brune-use", i);		self_sprint (self, "activate rune\n");
	self_sprintf_len (self, "\bweapon-mode", i);		self_sprint (self, "switch weapon to alt\n");
	self_sprintf_len (self, "\bshow-riders", i);		self_sprint (self, "show players riding you\n");
	self_sprintf_len (self, "\bfix-angles", i);		self_sprint (self, "fix frozen screen tilt\n");
	self_sprintf_len (self, "\bshow-players", i);		self_sprint (self, "status of all players\n");
	self_sprintf_len (self, "\bshow-settings", i);		self_sprint (self, "show mod settings\n");
	self_sprintf_len (self, "\blevels", i);			self_sprint (self, "list standard levels\n");
	self_sprintf_len (self, "\bhelp-levels", i);		self_sprint (self, "levels with full name\n");
	self_sprintf_len (self, "\bcustom", i);			self_sprint (self, "custom levels on server\n");
	self_sprintf_len (self, "\bvote-exit", i);		self_sprint (self, "vote to exit the level\n");
	self_sprintf_len (self, "\bvote-team", i);		self_sprint (self, "vote to toggle teams\n");
	self_sprintf_len (self, "\bvote-hook", i);		self_sprint (self, "vote to toggle hook\n");
	self_sprintf_len (self, "\bremove-frags", i);		self_sprint (self, "zero out positive frags\n");
	self_sprintf_len (self, "\bhud-toggle", i);		self_sprint (self, "toggle hud display\n");
	self_sprintf_len (self, "\b+hook", i);			self_sprint (self, "use hook\n");
	self_sprintf_len (self, "\bquiet-toggle", i);		self_sprint (self, "mute many game messages\n");
	self_sprint (self, "\n");

/*
       self_sprint ("disp-info",
       self_sprint ("disp-info-all",
       self_sprint ("-hook",
       self_sprint ("hook-off",
       self_sprint ("hook-on",
       self_sprint ("hook-toggle",
       self_sprint ("rider-hide",
       self_sprint ("show-pos",
       self_sprint ("weapon-mode",
       self_sprint ("weapon-toggles"
       self_sprint ("weapon-toggles-toggle"
       self_sprint ("cycle-alternates
       self_sprint ("change-level"
*/
};

void ()
help_levels =
{
	self_sprint (self,
		"\bThe Beginning\b\n\n"
		"start - Welcome To Quake\n\n"
		"\bDimension of the Doomed (shareware)\b\n\n"
		"e1m1  - Slipgate Complex\n"
		"e1m2  - Castle of the Damned\n"
		"e1m3  - The Necropolis\n"
		"e1m4  - The Grisly Grotto\n"
		"e1m5  - Gloom Keep\n"
		"e1m6  - The Door To Chthon\n"
		"e1m7  - The House of Chthon\n"
		"e1m8  - Ziggurat Vertigo\n\n"
	);
	self_sprint (self,
		"\bRealm of Black Magic\b\n\n"
		"e2m1  - The Installation\n"
		"e2m2  - The Ogre Citadel\n"
		"e2m3  - The Crypt of Decay\n"
		"e2m4  - The Ebon Fortress\n"
		"e2m5  - The Wizard's Manse\n"
		"e2m6  - The Dismal Oubliette\n"
		"e2m7  - Underearth\n\n"
	);
	self_sprint (self,
		"\bNetherworld\b\n\n"
		"e3m1  - Termination Central\n"
		"e3m2  - Vaults of Zin\n"
		"e3m3  - The Tomb of Terror\n"
		"e3m4  - Satan's Dark Delight\n"
		"e3m5  - Wind Tunnels\n"
		"e3m6  - Chambers of Torment\n"
		"e3m7  - The Haunted Halls\n\n"
	);
	self_sprint (self,
		"\bThe Elder World\b\n\n"
		"e4m1  - The Sewage System\n"
		"e4m2  - The Tower of Despair\n"
		"e4m3  - The Elder God Shrine\n"
		"e4m4  - The Palace of Hate\n"
		"e4m5  - Hell's Atrium\n"
		"e4m6  - The Pain Maze\n"
		"e4m7  - Azure Agony\n"
		"e4m8  - The Nameless City\n\n"
	);
	self_sprint (self,
		"\bThe End\n\n"
		"end   - Shub-Niggurath's Pit\n\n"
	);
	self_sprint (self,
		"\bThe Deathmatch Arenas\b\n\n"
		"dm1   - Place of Two Deaths\n"
		"dm2   - Claustrophobopolis\n"
		"dm3   - The Abandoned Base\n"
		"dm4   - The Bad Place\n"
		"dm5   - The Cistern\n"
		"dm6   - The Dark Zone\n\n"
	);
};
