/*  $Id: bindings.qc,v 1.115 2008/07/09 05:48:13 slotzero Exp $

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

//-------------------------------------------------------------------
// PLAYER BINDINGS
//-------------------------------------------------------------------

void ()
bind_keys =
{
	self_stuffcmd (self, "bind x rune-use\n");
	self_stuffcmd (self, "bind c rune-tell\n");
	self_stuffcmd (self, "bind q rune-delete\n");
	self_stuffcmd (self, "bind 9 weapon-mode\n");
	self_stuffcmd (self, "bind [ show-riders\n");
	self_stuffcmd (self, "bind ] fix-angles\n");
	sprint (self, "Standard keys bound\n");
};

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

void (string cmd, float imp)
player_vote_impulse_alias =
{
	local string s;

	self_stuffcmd (self, "alias ");
	self_stuffcmd (self, cmd);
	self_stuffcmd (self, " \"");
	self_stuffcmd (self, "vc;w5;w5;impulse ");
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

	// trickle the aliases or else client crashes
	if (os.runevar == 1)
	{
		self_sprint (self, "Sending player bindings\n");
		player_aliases ();
		switchfire_aliases ();
   	}
	else if (os.runevar == 2)
	{
		vote_aliases ();
		level_aliases ();
	}
  	else if (os.runevar == 3 && total_customs ())
	{
		custom_aliases ();

		// XXX Move this to settings.qc.
		if (MAP_IS_CUSTOM)
		{
			if (gamemode == MODE_ARENA)
			{
				self_sprint (self, "\nDon't have the arena maps?\n");
				self_sprint (self, "\nDownload from\n\n\b    runequake.com/maps/ramaps.zip\b\n\n");
			}
			else
			{
				self_sprint (self, "\nDon't have the map?\n");
				self_sprint (self, "\nDownload from\n\n\b    ftp.runequake.com/quake/maps/\b\n\nFilename: ");
				self_sprint (self, mapname);
				self_sprint (self, ".zip\n");
			}
		}
	}

	self = os;

	if (self.runevar > 2)
	{
		self_stuffcmd (self.owner, "init\n");
		self.owner.rqflags = self.owner.rqflags | RQ_BINDINGS_RECEIVED;
		remove (self);
	}
	else
	{
		self.runevar = self.runevar + 1;
		self.nextthink = time + 1;
	}
};

void ()
spawn_player_bindings =
{
	local entity e;

	e		= spawn ();
	e.classname	= "spawn_player_bindings";
	e.owner		= self;
	e.runevar	= 1;
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
	player_init_impulse_alias ("bind-keys",			IMP_BIND_DEFAULT_KEYS);
	player_init_impulse_alias ("bind-default-keys",		IMP_BIND_DEFAULT_KEYS);
	player_init_impulse_alias ("autostats",			IMP_AUTOSTATS);
	player_init_impulse_alias ("change-level",		IMP_LEVELS);
	player_init_impulse_alias ("commands",			IMP_COMMANDS);
	player_init_impulse_alias ("custom",			IMP_CUSTOM);
	player_init_impulse_alias ("custom-sounds",		IMP_CUSTOM_SOUNDS);
	player_init_impulse_alias ("cycle-alternates",		IMP_CYCLE_ALTERNATES);
	player_init_impulse_alias ("eff",			IMP_EFFICIENCY);
	player_init_impulse_alias ("efficiency",		IMP_EFFICIENCY);
	player_init_impulse_alias ("fix-angles",		IMP_FIX_BATMAN);
	player_init_impulse_alias ("help-levels",		IMP_HELP_LEVELS);
	player_init_impulse_alias ("help-match",		IMP_HELP_MATCH);
	player_init_impulse_alias ("help-options",		IMP_HELP_OPTIONS);
	player_init_impulse_alias ("help-vote",			IMP_HELP_VOTE);
	player_init_impulse_alias ("+hook",			IMP_HOOK_ON);
	player_init_impulse_alias ("-hook",			IMP_HOOK_OFF);
	player_init_impulse_alias ("hook-off",			IMP_HOOK_OFF);
	player_init_impulse_alias ("hook-on",			IMP_HOOK_ON);
	player_init_impulse_alias ("hook-toggle",		IMP_HOOK_TOGGLE);
	player_init_impulse_alias ("hud-toggle",		IMP_HUD_TOGGLE);
	player_init_impulse_alias ("killstats",			IMP_KILLSTATS);
	player_init_impulse_alias ("last",			IMP_LAST);
	player_init_impulse_alias ("levels",			IMP_LEVELS);
	player_init_impulse_alias ("lag",			IMP_LAG);
	player_init_impulse_alias ("no",			IMP_VOTE_NO);
	player_init_impulse_alias ("notready",			IMP_NOTREADY);
	player_init_impulse_alias ("observer",			IMP_OBSERVER);
	player_init_impulse_alias ("quiet-toggle",		IMP_QUIET_TOGGLE);
	player_init_impulse_alias ("ready",			IMP_READY);
	player_init_impulse_alias ("remove-frags",		IMP_REMOVE_FRAGS);
	player_init_impulse_alias ("rider-hide",		IMP_RIDER_HIDE);
	player_init_impulse_alias ("rune-delete",		IMP_RUNE_DELETE);
	player_init_impulse_alias ("rune-tell",			IMP_RUNE_TELL);
	player_init_impulse_alias ("rune-use",			IMP_RUNE_USE);
	player_init_impulse_alias ("show-players",		IMP_SHOW_PLAYERS);
	player_init_impulse_alias ("show-pos",			IMP_SHOW_POS);
	player_init_impulse_alias ("show-riders",		IMP_SHOW_RIDERS);
	player_init_impulse_alias ("show-settings",		IMP_SHOW_SETTINGS);
	player_init_impulse_alias ("show-votes",		IMP_SHOW_VOTES);
	player_init_impulse_alias ("stats",			IMP_STATS);
	player_init_impulse_alias ("team-change",		IMP_TEAM_ROTATE);
	player_init_impulse_alias ("team-stats",		IMP_TEAM_STATS);
	player_init_impulse_alias ("vote-help",			IMP_HELP_VOTE);
	player_init_impulse_alias ("vote-level",		IMP_LEVELS);
	player_init_impulse_alias ("weapon-mode",		IMP_WEAPON_MODE);
	player_init_impulse_alias ("weapon-toggles",		IMP_WEAPON_TOGGLES);
	player_init_impulse_alias ("weapon-toggles-toggle",	IMP_WEAPON_TOGGLES);
	player_init_impulse_alias ("yes",			IMP_VOTE_YES);

	self_stuffcmd (self, "alias +teamscores \"+showscores; impulse ");
	s = ftos (IMP_TEAMSCORES_ON);
	self_stuffcmd (self, s);
	self_stuffcmd (self, "\"\n");

	self_stuffcmd (self, "alias -teamscores \"-showscores; impulse ");
	s = ftos (IMP_TEAMSCORES_OFF);
	self_stuffcmd (self, s);
	self_stuffcmd (self, "\"\n");
};

void ()
admin_aliases =
{
	local string s;

	self_stuffcmd (self, "alias ac \"impulse ");
	s = ftos (IMP_ADMIN_COMMAND);
	self_stuffcmd (self, s);
	self_stuffcmd (self, "\"\n");

	player_admin_impulse_alias ("admin-banip",		IMP_ADMIN_BANIP);
	player_admin_impulse_alias ("admin-banlist",		IMP_ADMIN_BANLIST);
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
	player_admin_impulse_alias ("admin-unbanip",		IMP_ADMIN_UNBANIP);
	player_admin_impulse_alias ("admin-unbind",		IMP_ADMIN_UNBIND);
	player_admin_impulse_alias ("change-level",		IMP_ADMIN_CHANGE_MAP);
	player_admin_impulse_alias ("disp-info",		IMP_ADMIN_DISP_INFO);
	player_admin_impulse_alias ("disp-info-all",		IMP_ADMIN_DISP_INFO_ALL);
	player_admin_impulse_alias ("exit-level",		IMP_EXIT_LEVEL);
	player_admin_impulse_alias ("qsmack",			IMP_QSMACK_COMMAND);
};

void ()
vote_aliases =
{
	local string s;

	self_stuffcmd (self, "alias vc \"impulse ");
	s = ftos (IMP_VOTE_COMMAND);
	self_stuffcmd (self, s);
	self_stuffcmd (self, "\"\n");

	self_stuffcmd (self, "alias 1 \"impulse 1\"\n");
	self_stuffcmd (self, "alias 2 \"impulse 2\"\n");
	self_stuffcmd (self, "alias 3 \"impulse 3\"\n");
	self_stuffcmd (self, "alias 4 \"impulse 4\"\n");
	self_stuffcmd (self, "alias 5 \"impulse 5\"\n");
	self_stuffcmd (self, "alias 6 \"impulse 6\"\n");

	player_vote_impulse_alias ("arena",			IMP_VOTE_ARENA);	// CRMod (Style)
	player_vote_impulse_alias ("faststart",			IMP_VOTE_FASTSTART);	// CRMod
	player_vote_impulse_alias ("ffa",			IMP_VOTE_NORMAL);	// CRMod
	player_vote_impulse_alias ("lock",			IMP_VOTE_LOCK);		// CRMod
	player_vote_impulse_alias ("match",			IMP_VOTE_MATCH);	// CRMod
	player_vote_impulse_alias ("midair",			IMP_VOTE_MIDAIR);	// CRMod (Style)
	player_vote_impulse_alias ("normal",			IMP_VOTE_NORMAL);	// CRMod
	player_vote_impulse_alias ("practice",			IMP_VOTE_PRACTICE);	// CRMod
	player_vote_impulse_alias ("setpent",			IMP_VOTE_PENT);		// CRMod
	player_vote_impulse_alias ("setquad",			IMP_VOTE_QUAD);		// CRMod
	player_vote_impulse_alias ("setring",			IMP_VOTE_RING);		// CRMod
	player_vote_impulse_alias ("setsuit",			IMP_VOTE_SUIT);		// CRMod
	player_vote_impulse_alias ("timeset",			IMP_VOTE_TIMESET);	// CRMod
	player_vote_impulse_alias ("unlock",			IMP_VOTE_UNLOCK);	// CRMod
	player_vote_impulse_alias ("vote-alts",			IMP_VOTE_ALTS);
	player_vote_impulse_alias ("vote-alt-weapons",		IMP_VOTE_ALTS);
	player_vote_impulse_alias ("vote-arena",		IMP_VOTE_ARENA);
	player_vote_impulse_alias ("vote-armor",		IMP_VOTE_ARMOR);
	player_vote_impulse_alias ("vote-armor-drop",		IMP_VOTE_ARMOR_DROP);
	player_vote_impulse_alias ("vote-backpacks",		IMP_VOTE_BACKPACKS);
	player_vote_impulse_alias ("vote-classic-mega",		IMP_VOTE_CLASSIC_MEGA);
	player_vote_impulse_alias ("vote-exit",			IMP_VOTE_EXIT);
	player_vote_impulse_alias ("vote-free",			IMP_VOTE_FREE);
	player_vote_impulse_alias ("vote-hook",			IMP_VOTE_HOOK);
	player_vote_impulse_alias ("vote-hook-damage",		IMP_VOTE_HOOK_DAMAGE);
	player_vote_impulse_alias ("vote-lithium",		IMP_VOTE_LITHIUM);
	player_vote_impulse_alias ("vote-lg-discharge",		IMP_VOTE_LG_DISCHARGE);
	player_vote_impulse_alias ("vote-match",		IMP_VOTE_MATCH);
	player_vote_impulse_alias ("vote-mega",			IMP_VOTE_MEGA);
	player_vote_impulse_alias ("vote-midair",		IMP_VOTE_MIDAIR);
	player_vote_impulse_alias ("vote-normal",		IMP_VOTE_NORMAL);
	player_vote_impulse_alias ("vote-pent",			IMP_VOTE_PENT);
	player_vote_impulse_alias ("vote-powerup-drop",		IMP_VOTE_POWERUP_DROP);
	player_vote_impulse_alias ("vote-practice",		IMP_VOTE_PRACTICE);
	player_vote_impulse_alias ("vote-quad",			IMP_VOTE_QUAD);
	player_vote_impulse_alias ("vote-ring",			IMP_VOTE_RING);
	player_vote_impulse_alias ("vote-rune-drop",		IMP_VOTE_RUNE_DROP);
	player_vote_impulse_alias ("vote-runes",		IMP_VOTE_RUNES);
	player_vote_impulse_alias ("vote-rotate",		IMP_VOTE_ROTATE);
	player_vote_impulse_alias ("vote-shields",		IMP_VOTE_SHIELDS);
	player_vote_impulse_alias ("vote-suit",			IMP_VOTE_SUIT);
	player_vote_impulse_alias ("vote-team",			IMP_VOTE_TEAM);
	player_vote_impulse_alias ("vote-weapons-stay",		IMP_VOTE_WEAPONS_STAY);
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

//-------------------------------------------------------------------
// CONSOLE BINDINGS
//-------------------------------------------------------------------

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
	local float i;

	dprint_force ("Sending console bindings\n");

	console_init_cvar_alias ("update-bindings",	CVAR_C2,	C2_UPDATE_BINDINGS);
	console_init_cvar_alias ("show-players",	CVAR_C2,	C2_SHOW_PLAYERS);
	console_init_cvar_alias ("players",		CVAR_C2,	C2_SHOW_PLAYERS);
	console_init_cvar_alias ("show-settings",	CVAR_C2,	C2_SHOW_SETTINGS);
	console_init_cvar_alias ("settings",		CVAR_C2,	C2_SHOW_SETTINGS);
	console_init_cvar_alias ("rune-cheat",		CVAR_C2,	C2_TOGGLE_RUNE_CHEAT);
	console_init_cvar_alias ("last",		CVAR_C2,	C2_LAST);
	console_init_cvar_alias ("levels",		CVAR_C2,	C2_LEVELS);
	console_init_cvar_alias ("custom",		CVAR_C2,	C2_CUSTOM);
	console_init_cvar_alias ("commands",		CVAR_C2,	C2_COMMANDS);
	console_init_cvar_alias ("level-time",		CVAR_C2,	C2_LEVEL_TIME);
	console_init_cvar_alias ("practice",		CVAR_C2,	C2_MODE_PRACTICE);
	console_init_cvar_alias ("normal",		CVAR_C2,	C2_MODE_NORMAL);
	console_init_cvar_alias ("quadon",		CVAR_C2,	C2_QUADON);
	console_init_cvar_alias ("quadoff",		CVAR_C2,	C2_QUADOFF);
	console_init_cvar_alias ("penton",		CVAR_C2,	C2_PENTON);
	console_init_cvar_alias ("pentoff",		CVAR_C2,	C2_PENTOFF);
	console_init_cvar_alias ("ringon",		CVAR_C2,	C2_RINGON);
	console_init_cvar_alias ("ringoff",		CVAR_C2,	C2_RINGOFF);
	console_init_cvar_alias ("suiton",		CVAR_C2,	C2_SUITON);
	console_init_cvar_alias ("suitoff",		CVAR_C2,	C2_SUITOFF);
	console_init_cvar_alias ("armoron",		CVAR_C2,	C2_ARMORON);
	console_init_cvar_alias ("armoroff",		CVAR_C2,	C2_ARMOROFF);
	console_init_cvar_alias ("rotateon",		CVAR_C2,	C2_ROTATEON);
	console_init_cvar_alias ("rotateoff",		CVAR_C2,	C2_ROTATEOFF);
	console_init_cvar_alias ("runeson",		CVAR_C2,	C2_RUNESON);
	console_init_cvar_alias ("runesoff",		CVAR_C2,	C2_RUNESOFF);
	console_init_cvar_alias ("altson",		CVAR_C2,	C2_ALTSON);
	console_init_cvar_alias ("altsoff",		CVAR_C2,	C2_ALTSOFF);
	console_init_cvar_alias ("shieldson",		CVAR_C2,	C2_SHIELDSON);
	console_init_cvar_alias ("shieldsoff",		CVAR_C2,	C2_SHIELDSOFF);
	console_init_cvar_alias ("hookdamageon",	CVAR_C2,	C2_HOOKDAMAGEON);
	console_init_cvar_alias ("hookdamageoff",	CVAR_C2,	C2_HOOKDAMAGEOFF);
	console_init_cvar_alias ("arena",		CVAR_C2,	C2_MODE_ARENA);
	console_init_cvar_alias ("sping",		CVAR_C2,	C2_CLIENT_PING_TIMES);
	console_init_cvar_alias ("megaon",		CVAR_C2,	C2_MEGAON);
	console_init_cvar_alias ("megaoff",		CVAR_C2,	C2_MEGAOFF);
	console_init_cvar_alias ("banip",		CVAR_C2,	C2_BAN_ADD);
	console_init_cvar_alias ("unbanip",		CVAR_C2,	C2_BAN_REMOVE);
	console_init_cvar_alias ("banlist",		CVAR_C2,	C2_BAN_LIST);
	console_init_cvar_alias ("conprint",		CVAR_C2,	C2_CONPRINT);
	console_init_cvar_alias ("eff",			CVAR_C2,	C2_EFFICIENCY);
	console_init_cvar_alias ("match",		CVAR_C2,	C2_MODE_MATCH);
	console_init_cvar_alias ("armordropon",		CVAR_C2,	C2_ARMORDROPON);
	console_init_cvar_alias ("armordropoff",	CVAR_C2,	C2_ARMORDROPOFF);
	console_init_cvar_alias ("faststarton",		CVAR_C2,	C2_FASTSTARTON);
	console_init_cvar_alias ("faststartoff",	CVAR_C2,	C2_FASTSTARTOFF);
	console_init_cvar_alias ("backpackson",		CVAR_C2,	C2_BACKPACKSON);
	console_init_cvar_alias ("backpacksoff",	CVAR_C2,	C2_BACKPACKSOFF);
	console_init_cvar_alias ("midair",		CVAR_C2,	C2_MODE_MIDAIR);
	console_init_cvar_alias ("modelock",		CVAR_C2,	C2_MODE_LOCK);
	console_init_cvar_alias ("modeunlock",		CVAR_C2,	C2_MODE_UNLOCK);
	console_init_cvar_alias ("powerdropon",		CVAR_C2,	C2_POWERDROPON);
	console_init_cvar_alias ("powerdropoff",	CVAR_C2,	C2_POWERDROPOFF);
	console_init_cvar_alias ("help-options",	CVAR_C2,	C2_HELP_OPTIONS);
	console_init_cvar_alias ("options",		CVAR_C2,	C2_HELP_OPTIONS);
	console_init_cvar_alias ("killstats",		CVAR_C2,	C2_KILLSTATS);
	console_init_cvar_alias ("stats",		CVAR_C2,	C2_STATS);
	console_init_cvar_alias ("runedropon",		CVAR_C2,	C2_RUNEDROPON);
	console_init_cvar_alias ("runedropoff",		CVAR_C2,	C2_RUNEDROPOFF);
	console_init_cvar_alias ("lgdischargeon",	CVAR_C2,	C2_LGDISCHARGEON);
	console_init_cvar_alias ("lgdischargeoff",	CVAR_C2,	C2_LGDISCHARGEOFF);
	console_init_cvar_alias ("muteip",		CVAR_C2,	C2_MUTE_ADD);
	console_init_cvar_alias ("unmuteip",		CVAR_C2,	C2_MUTE_REMOVE);
	console_init_cvar_alias ("mutelist",		CVAR_C2,	C2_MUTE_LIST);
	console_init_cvar_alias ("classicmegaon",	CVAR_C2,	C2_CLASSICMEGAON);
	console_init_cvar_alias ("classicmegaoff",	CVAR_C2,	C2_CLASSICMEGAOFF);
	console_init_cvar_alias ("mode",		CVAR_C2,	C2_CURRENT_MODE);
	console_init_cvar_alias ("weaponsstayon",	CVAR_C2,	C2_WEAPONSSTAYON);
	console_init_cvar_alias ("weaponsstayoff",	CVAR_C2,	C2_WEAPONSSTAYOFF);

	level_aliases ();
	custom_aliases ();
	custom_maps ();

	if (!HUNK_CONTEXT)
		return;

	// initialize storage for ban
	for (i = 0; i < BAN_LIST_SIZE; i = i + %1)
		Write_Hunk_Float (HUNK_CONTEXT, HUNK_BAN_OFFSET + i, 0);

	// initialize storage for mute
	for (i = 0; i < MUTE_LIST_SIZE; i = i + %1)
		Write_Hunk_Float (HUNK_CONTEXT, HUNK_MUTE_OFFSET + i, 0);

	localcmd ("exec ban.txt\n");
};

void ()
check_console_command =
{
	local vector v;
	local float i;
	local string s;

	i = cvar_infokey (CVAR_C1);
	if (i)
	{
		cvar_set_infokey (CVAR_C1, "0");
		IN_POQ(if (!HUNK_CONTEXT_MAX) i = 0;)

		&%IN_POQ(368,376) = i;
		s = impulse_to_map ();
		if (s)
			admin_changelevel_now (s);
		else
			dprint ("Invalid level impulse\n");
	}

	i = cvar_infokey (CVAR_C2);
	if (i)
	{
		if (i == C2_UPDATE_BINDINGS)
			console_aliases ();

		else if (i == C2_SHOW_PLAYERS)
			show_players ();

		else if (i == C2_SHOW_SETTINGS)
			show_settings ();

		else if (i == C2_TOGGLE_RUNE_CHEAT)
		{
			// XXX Move this to its own function, for in-game use.
			temp1 = cvar_infokey ("temp1");
			if (temp1 & T1_RUNE_CHEAT)
			{
				temp1 = temp1 - temp1 & T1_RUNE_CHEAT;
				dprint_force ("Rune cheat off\n");
			}
			else
			{
				temp1 = temp1 | T1_RUNE_CHEAT;
				dprint_force ("Rune cheat on\n");
			}
			s = ftos (temp1);
			cvar_set_infokey ("temp1", s);
		}

		else if (i == C2_LAST)
			Client_Disconnect_Log ();

		else if (i == C2_LEVELS)
			levels ();

		else if (i == C2_CUSTOM)
			custom ();

		else if (i == C2_COMMANDS)
			console_commands ();

		else if (i == C2_LEVEL_TIME)
		{
			dprint_force (parse_time (time));
			dprint_force ("\n");
		}

		else if (i == C2_MODE_PRACTICE)
			change_mode_to_practice ();

		else if (i == C2_MODE_NORMAL)
			change_mode_to_normal ();

		// removed

		else if (i == C2_QUADON)
		{
			if (options & NO_QUAD)
			{
				dprint_force ("Quad enabled\n");
				setquad ();
			}
		}

		else if (i == C2_QUADOFF)
		{
			if (!options & NO_QUAD)
			{
				dprint_force ("Quad disabled\n");
				setquad ();
			}
		}

		else if (i == C2_PENTON)
		{
			if (options & NO_PENT)
			{
				dprint_force ("Pentagram enabled\n");
				setpent ();
			}
		}

		else if (i == C2_PENTOFF)
		{
			if (!options & NO_PENT)
			{
				dprint_force ("Pentagram disabled\n");
				setpent ();
			}
		}

		else if (i == C2_RINGON)
		{
			if (options & NO_RING)
			{
				dprint_force ("Ring of shadows enabled\n");
				setring ();
			}
		}

		else if (i == C2_RINGOFF)
		{
			if (!options & NO_RING)
			{
				dprint_force ("Ring of shadows disabled\n");
				setring ();
			}
		}

		else if (i == C2_SUITON)
		{
			if (options & NO_SUIT)
			{
				dprint_force ("Environmental protection suit enabled\n");
				setsuit ();
			}
		}

		else if (i == C2_SUITOFF)
		{
			if (!options & NO_SUIT)
			{
				dprint_force ("Environmental protection suit disabled\n");
				setsuit ();
			}
		}

		else if (i == C2_ARMORON)
		{
			if (options & NO_ARMOR)
			{
				dprint_force ("Armor enabled\n");
				setarmor ();
			}
		}

		else if (i == C2_ARMOROFF)
		{
			if (!options & NO_ARMOR)
			{
				dprint_force ("Armor disabled\n");
				setarmor ();
			}
		}

		else if (i == C2_ROTATEON)
		{
			if (!options & ARMOR_ROTATE)
			{
				dprint_force ("Rotating armors enabled\n");
				setrotate ();
			}
		}

		else if (i == C2_ROTATEOFF)
		{
			if (options & ARMOR_ROTATE)
			{
				dprint_force ("Rotating armors disabled\n");
				setrotate ();
			}
		}

		else if (i == C2_RUNESON)
		{
			if (options & NO_RUNES)
			{
				dprint_force ("Runes enabled\n");
				setrunes ();
			}
		}

		else if (i == C2_RUNESOFF)
		{
			if (!options & NO_RUNES)
			{
				dprint_force ("Runes disabled\n");
				setrunes ();
			}
		}

		else if (i == C2_ALTSON)
		{
			if (gamemode == MODE_PRACTICE)
				dprint_force ("Alternate weapons disabled in practice mode\n");
			else if (options & NO_ALT_WEAPONS)
			{
				dprint_force ("Alternate weapons enabled\n");
				setalts ();
			}
		}

		else if (i == C2_ALTSOFF)
		{
			if (!options & NO_ALT_WEAPONS)
			{
				dprint_force ("Alternate weapons disabled\n");
				setalts ();
			}
		}

		else if (i == C2_SHIELDSON)
		{
			if (options & NO_SPAWN_SHIELDS)
			{
				dprint_force ("Spawn shields enabled\n");
				setshields ();
			}
		}

		else if (i == C2_SHIELDSOFF)
		{
			if (!options & NO_SPAWN_SHIELDS)
			{
				dprint_force ("Spawn shields disabled\n");
				setshields ();
			}
		}

		else if (i == C2_HOOKDAMAGEON)
		{
			if (options & NO_HOOK_DAMAGE)
			{
				dprint_force ("Hook damage enabled\n");
				sethookdamage ();
			}
		}

		else if (i == C2_HOOKDAMAGEOFF)
		{
			if (!options & NO_HOOK_DAMAGE)
			{
				dprint_force ("Hook damage disabled\n");
				sethookdamage ();
			}
		}

		else if (i == C2_MODE_ARENA)
			change_mode_to_arena ();

		else if (i == C2_CLIENT_PING_TIMES)
			client_ping_times ();

		else if (i == C2_MEGAON)
		{
			if (options & NO_MEGA)
			{
				dprint_force ("Mega-health boxes enabled\n");
				setmega ();
			}
		}

		else if (i == C2_MEGAOFF)
		{
			if (!options & NO_MEGA)
			{
				dprint_force ("Mega-health boxes disabled\n");
				setmega ();
			}
		}

		else if (i == C2_BAN_ADD)
		{	IN_QW(return;)
			s = cvar_string ("skill", 1);
			v = ip_to_vec (s);
			if (v == VEC_ORIGIN)
				self_sprint (self, "invalid ip address\n");
			else
				ban_add (v_x + (v_y * 256) + (v_z * 65536));
		}

		else if (i == C2_BAN_REMOVE)
		{	IN_QW(return;)
			s = cvar_string ("skill", 1);
			v = ip_to_vec (s);
			if (v == VEC_ORIGIN)
				self_sprint (self, "invalid ip address\n");
			else
				ban_remove (v_x + (v_y * 256) + (v_z * 65536));
		}

		else if (i == C2_BAN_LIST)
		{	IN_QW(return;)
			ban_list ();
		}

		else if (i == C2_CONPRINT)
		{
			scratch1 = cvar_infokey ("scratch1");
			if (scratch1 & S1_BPRINT_TO_CONSOLE)
			{
				dprint ("conprint off\n");
				scratch1 = scratch1 - scratch1 & S1_BPRINT_TO_CONSOLE;
			}
			else
			{
				dprint ("conprint on\n");
				scratch1 = scratch1 | S1_BPRINT_TO_CONSOLE;
			}

			s = ftos (scratch1);
			cvar_set_infokey ("scratch1", s);
		}

		else if (i == C2_EFFICIENCY)
			sprint_efficiency ();

		else if (i == C2_MODE_MATCH)
			change_mode_to_match ();

		else if (i == C2_ARMORDROPON)
		{
			if (options & NO_DROP_ARMOR)
			{
				dprint_force ("Armor dropping enabled\n");
				toggle_armor_drop ();
			}
		}

		else if (i == C2_ARMORDROPOFF)
		{
			if (!options & NO_DROP_ARMOR)
			{
				dprint_force ("Armor dropping disabled\n");
				toggle_armor_drop ();
			}
		}

		else if (i == C2_FASTSTARTON)
		{
			if (!options & FASTSTART)
			{
				dprint_force ("Fast match starts enabled\n");
				setfaststart ();
			}
		}

		else if (i == C2_FASTSTARTOFF)
		{
			if (options & FASTSTART)
			{
				dprint_force ("Fast match starts disabled\n");
				setfaststart ();
			}
		}

		else if (i == C2_BACKPACKSON)
		{
			if (options & NO_BACKPACKS)
			{
				dprint_force ("Backpack dropping enabled\n");
				setbackpacks ();
			}
		}

		else if (i == C2_BACKPACKSOFF)
		{
			if (!options & NO_BACKPACKS)
			{
				dprint_force ("Backpack dropping disabled\n");
				setbackpacks ();
			}
		}

		else if (i == C2_MODE_MIDAIR)
			change_mode_to_midair ();

		else if (i == C2_MODE_LOCK)
		{
			if (!options & MODE_LOCKED)
			{
				dprint_force ("Mode is locked\n");
				toggle_mode_lock ();
			}
		}

		else if (i == C2_MODE_UNLOCK)
		{
			if (options & MODE_LOCKED)
			{
				dprint_force ("Mode is unlocked\n");
				toggle_mode_lock ();
			}
		}

		else if (i == C2_POWERDROPON)
		{
			if (options & NO_DROP_POWERUP)
			{
				dprint_force ("Powerup dropping enabled\n");
				toggle_powerup_drop ();
			}
		}

		else if (i == C2_POWERDROPOFF)
		{
			if (!options & NO_DROP_POWERUP)
			{
				dprint_force ("Powerup dropping disabled\n");
				toggle_powerup_drop ();
			}
		}

		else if (i == C2_HELP_OPTIONS)
			help_options ();

		else if (i == C2_KILLSTATS)
			sprint_killstats ();

		else if (i == C2_STATS)
			sprint_stats ();

		else if (i == C2_RUNEDROPON)
		{
			if (options & NO_DROP_ON_DEATH)
			{
				dprint_force ("Rune dropping enabled\n");
				toggle_rune_drop ();
			}
		}

		else if (i == C2_RUNEDROPOFF)
		{
			if (!options & NO_DROP_ON_DEATH)
			{
				dprint_force ("Rune dropping disabled\n");
				toggle_rune_drop ();
			}
		}

		else if (i == C2_LGDISCHARGEON)
		{
			if (options & NO_DISCHARGE)
			{
				dprint_force ("Lightning discharge enabled\n");
				toggle_lightning_discharge ();
			}
		}

		else if (i == C2_LGDISCHARGEOFF)
		{
			if (!options & NO_DISCHARGE)
			{
				dprint_force ("Lightning discharge disabled\n");
				toggle_lightning_discharge ();
			}
		}

		else if (i == C2_MUTE_ADD)
		{	IN_QW(return;)
			s = cvar_string ("skill", 1);
			v = ip_to_vec (s);
			if (v == VEC_ORIGIN)
				self_sprint (self, "invalid ip address\n");
			else
				mute_add (v_x + (v_y * 256) + (v_z * 65536));
		}

		else if (i == C2_MUTE_REMOVE)
		{	IN_QW(return;)
			s = cvar_string ("skill", 1);
			v = ip_to_vec (s);
			if (v == VEC_ORIGIN)
				self_sprint (self, "invalid ip address\n");
			else
				mute_remove (v_x + (v_y * 256) + (v_z * 65536));
		}

		else if (i == C2_MUTE_LIST)
		{	IN_QW(return;)
			mute_list ();
		}

		else if (i == C2_CLASSICMEGAON)
		{
			if (!options & CLASSIC_MEGA)
			{
				dprint_force ("Classic mega enabled\n");
				setclassicmega ();
			}
		}

		else if (i == C2_CLASSICMEGAOFF)
		{
			if (options & CLASSIC_MEGA)
			{
				dprint_force ("Classic mega disabled\n");
				setclassicmega ();
			}
		}

		else if (i == C2_CURRENT_MODE)
		{
			dprint_force ("Current mode: ");
			s = current_gamemode (gamemode);
			dprint_force (s);
			if (options & MODE_LOCKED)
				dprint_force (" (locked)");
			dprint_force ("\n");
		}

		else if (i == C2_WEAPONSSTAYON)
		{
			if (options & WEAPONS_STAY)
			{
				dprint_force ("Weapons-stay disabled\n");
				toggle_weapons_stay ();
			}
		}

		else if (i == C2_WEAPONSSTAYOFF)
		{
			if (!options & WEAPONS_STAY)
			{
				dprint_force ("Weapons-stay enabled\n");
				toggle_weapons_stay ();
			}
		}

		else
			dprint ("Unknown command\n");

		cvar_set_infokey (CVAR_C2, "0");
	}
};

//-------------------------------------------------------------------
// HELP MENUS
//-------------------------------------------------------------------

void ()
console_commands =
{
	self_sprint (self, "Rune Quake v");
	self_sprint (self, version);
	self_sprint (self, " console commands\n\n");

	self_sprint (self, "commands       settings       options         players       last\n");
	self_sprint (self, "levels         custom         level-time      sping         update-bindings\n");
	self_sprint (self, "banlist        banip          unbanip         conprint      rune-cheat\n");
	self_sprint (self, "mutelist       muteip         unmuteip        mode          \n");
	self_sprint (self, "eff            killstats      stats                         \n");

	self_sprint (self, "\ngame modes:\n\n");
	self_sprint (self, "normal              practice            match               arena\n");
	self_sprint (self, "midair\n");
	self_sprint (self, "\nsettings:\n\n");

	self_sprint (self, "quadon              quadoff             penton              pentoff\n");
	self_sprint (self, "ringon              ringoff             suiton              suitoff\n");
	self_sprint (self, "armoron             armoroff            armordropon         armordropoff\n");
	self_sprint (self, "rotateon            rotateoff           altson              altsoff\n");
	self_sprint (self, "weaponsstayon       weaponsstayoff      modelock            modeunlock\n");
	self_sprint (self, "shieldson           shieldsoff          hookdamageon        hookdamageoff\n");
	self_sprint (self, "megaon              megaoff             classicmegaon       classicmegaoff\n");
	self_sprint (self, "powerupdropon       powerupdropoff      lgdischargeon       lgdischargeoff\n");
	self_sprint (self, "runeson             runesoff            runedropon          runedropoff\n");
	self_sprint (self, "backpackson         backpacksoff        faststarton         faststartoff\n");
};

void ()
commands =
{
	//                      1234567890123456789012345678901234567\n
	self_sprint (self, "\n        \b\.important commands\.\b\n\n");
	self_sprint (self, "\brune-delete\b   delete your rune\n");
	self_sprint (self, "\brune-tell\b     rune description\n");
	self_sprint (self, "\brune-use\b      activate rune\n");
	self_sprint (self, "\bweapon-mode\b   switch weapon to alt\n");
	self_sprint (self, "\bshow-riders\b   show players riding you\n");
	self_sprint (self, "\bfix-angles\b    fix frozen screen tilt\n");
	self_sprint (self, "\bshow-players\b  status of all players\n");
	self_sprint (self, "\bshow-settings\b show mod settings\n");
	self_sprint (self, "\blevels\b        list standard levels\n");
	self_sprint (self, "\bhelp-levels\b   levels with full name\n");
	self_sprint (self, "\bhelp-vote\b     vote descriptions\n");
	self_sprint (self, "\bhelp-match\b    match mode help\n");
	self_sprint (self, "\bhelp-options\b  current server options\n");
	self_sprint (self, "\bcustom\b        custom levels on server\n");
	self_sprint (self, "\bvote-exit\b     vote to exit the level\n");
	self_sprint (self, "\bvote-team\b     vote to toggle teams\n");
	self_sprint (self, "\bvote-hook\b     vote to toggle hook\n");
	self_sprint (self, "\bremove-frags\b  reset frags to zero\n");
	self_sprint (self, "\b+hook\b         use hook\n");
	self_sprint (self, "\bquiet-toggle\b  mute many game messages\n");
	self_sprint (self, "\bbind-keys\b     bind default keys\n");
	// self_sprint (self, "\n");

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

void ()
help_vote =
{
	//                      1234567890123456789012345678901234567\n
	self_sprint (self, "\n          \b\.vote commands\.\b\n\n");
	self_sprint (self, "\bvote-exit       <mapname>\b (ex: start)\n");
	self_sprint (self, "\bvote-hook       vote-hook-damage\n");
	self_sprint (self, "\bvote-free       vote-lithium\n");
	self_sprint (self, "\bvote-team       vote-arena\n");
	self_sprint (self, "\bvote-practice   vote-normal\n");
	self_sprint (self, "\bvote-quad       vote-pent\n");
	self_sprint (self, "\bvote-ring       vote-suit\n");
	self_sprint (self, "\bvote-armor      vote-rotate\n");
	self_sprint (self, "\bvote-runes      vote-alt-weapons\n");
	self_sprint (self, "\bvote-shields    vote-weapons-stay\n");
	self_sprint (self, "\bvote-mega       vote-match\n");
	self_sprint (self, "\bvote-backpacks  vote-armor-drop\n");
	self_sprint (self, "\bvote-rune-drop  vote-powerup-drop\n");
	self_sprint (self, "\b                vote-lg_discharge\n");
	self_sprint (self, "\b                vote-classic-mega\n");
	// self_sprint (self, "\n");
};

void ()
help_match =
{
	//                      1234567890123456789012345678901234567\n
	self_sprint (self, "\n\b             \.help-match\.\n");
	self_sprint (self, "\b        (match mode commands)\n\n");
	self_sprint (self, "\bvote-match\b    enable match mode\n");
	self_sprint (self, "\bready\b         commit to a team\n");
	self_sprint (self, "\bnotready\b      uncommit yourself\n");
	self_sprint (self, "\btimeset\b       change timelimit\n");
	self_sprint (self, "\block\b          prevent new players\n");
	self_sprint (self, "\bunlock\b        allow new teams\n");
	self_sprint (self, "\bobserver\b      leave match/go observer\n");
};

void ()
help_options =
{
	local string s;

	self_sprint (self, "\n\b             \.help-options\.\n");
	self_sprint (self, "\b       (current state of options)\n");

	s = current_gamemode (gamemode);
	self_sprint (self, "\b\ngamemode      ");
	self_sprint (self, s);
	if (options & MODE_LOCKED)
		self_sprint (self, "\b (locked)");

	self_sprint (self, "\n\bhook          ");	self_sprint_boolean (self, temp1 & T1_HOOK_MASK);
	self_sprint (self, "\b  hook-damage   ");	self_sprint_boolean (self, !options & NO_HOOK_DAMAGE);
	self_sprint (self, "\n\bquad          ");	self_sprint_boolean (self, !options & NO_QUAD);
	self_sprint (self, "\b  pent          ");	self_sprint_boolean (self, !options & NO_PENT);
	self_sprint (self, "\n\bring          ");	self_sprint_boolean (self, !options & NO_RING);
	self_sprint (self, "\b  suit          ");	self_sprint_boolean (self, !options & NO_SUIT);
	self_sprint (self, "\n\barmor         ");	self_sprint_boolean (self, !options & NO_ARMOR);
	self_sprint (self, "\b  armor rotate  ");	self_sprint_boolean (self, options & ARMOR_ROTATE);
	self_sprint (self, "\n\brunes         ");	self_sprint_boolean (self, !options & NO_RUNES);
	self_sprint (self, "\b  rune drop     ");	self_sprint_boolean (self, !options & NO_DROP_ON_DEATH);
	self_sprint (self, "\n\balt weapons   ");	self_sprint_boolean (self, !options & NO_ALT_WEAPONS);
	self_sprint (self, "\b  weapons stay  ");	self_sprint_boolean (self, options & WEAPONS_STAY);
	self_sprint (self, "\n\bmega          ");	self_sprint_boolean (self, !options & NO_MEGA);
	self_sprint (self, "\b  classic mega  ");	self_sprint_boolean (self, options & CLASSIC_MEGA);
	self_sprint (self, "\n\barmor drop    ");	self_sprint_boolean (self, !options & NO_DROP_ARMOR);
	self_sprint (self, "\b  powerup drop  ");	self_sprint_boolean (self, !options & NO_DROP_POWERUP);
	self_sprint (self, "\n\bshields       ");	self_sprint_boolean (self, !options & NO_SPAWN_SHIELDS);
	self_sprint (self, "\b  lg discharge  ");	self_sprint_boolean (self, !options & NO_DISCHARGE);
	self_sprint (self, "\n\bbackpacks     ");	self_sprint_boolean (self, !options & NO_BACKPACKS);
	self_sprint (self, "\n");
};
