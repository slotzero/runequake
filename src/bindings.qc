/*
    Copyright (C) 2003-2015  David 'Slot Zero' Roberts.

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

	if (MOD_PROTOCOL)
	{
		imp = imp + IMP_ADMIN_MIN;

		self_stuffcmd (self, "alias ");
		self_stuffcmd (self, cmd);
		self_stuffcmd (self, " \"");
		self_stuffcmd (self, "cmd impulse ");
		s = ftos (imp);
		self_stuffcmd (self, s);
		self_stuffcmd (self, "\"\n");
	}
	else
	{
		self_stuffcmd (self, "alias ");
		self_stuffcmd (self, cmd);
		self_stuffcmd (self, " \"");
		self_stuffcmd (self, "ac;w5;w5;impulse ");
		s = ftos (imp);
		self_stuffcmd (self, s);
		self_stuffcmd (self, ";w5\"\n");
	}
};

void (string cmd, float imp)
player_vote_impulse_alias =
{
	local string s;

	if (MOD_PROTOCOL)
	{
		imp = imp + IMP_VOTE_MIN;

		self_stuffcmd (self, "alias ");
		self_stuffcmd (self, cmd);
		self_stuffcmd (self, " \"");
		self_stuffcmd (self, "cmd impulse ");
		s = ftos (imp);
		self_stuffcmd (self, s);
		self_stuffcmd (self, "\"\n");
	}
	else
	{
		self_stuffcmd (self, "alias ");
		self_stuffcmd (self, cmd);
		self_stuffcmd (self, " \"");
		self_stuffcmd (self, "vc;w5;w5;impulse ");
		s = ftos (imp);
		self_stuffcmd (self, s);
		self_stuffcmd (self, ";w5\"\n");
	}
};

void ()
player_bindings_think =
{
	local entity os;

	os = self;
	self = self.owner;
	if (os.count == 1)
	{
		self_sprint (self, "Sending player bindings\n");
		player_aliases ();
		switchfire_aliases ();
   	}
	else if (os.count == 2)
	{
		vote_aliases ();
		level_aliases ();
	}
	else if (os.count == 3)
		custom_aliases_small ();

	else if (os.count == 4)
		custom_aliases_medium ();

  	else if (os.count == 5)
	{
		custom_aliases_large ();

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

	if (self.count >= self.cnt)
	{
		self_stuffcmd (self.owner, "init\n");
		self.owner.rqflags = self.owner.rqflags | RQ_BINDINGS_RECEIVED;
		remove (self);
		return;
	}

	self.count = self.count + 1;
	self.nextthink = time + 1;
};

void ()
spawn_player_bindings =
{
	local entity e;

	e		= spawn ();
	e.classname	= "spawn_player_bindings";
	e.owner		= self;
	e.count		= 1;

	if (total_customs ())
		e.cnt	= 5;
	else
		e.cnt	= 2;

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

	self_stuffcmd (self, "alias cl2 \"impulse ");
	s = ftos (IMP_CHANGE_MAP2);
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
	player_init_impulse_alias ("ignore-mute-client",	IMP_IGNORE_MUTE_CLIENT);
	player_init_impulse_alias ("killstats",			IMP_KILLSTATS);
	player_init_impulse_alias ("last",			IMP_LAST);
	player_init_impulse_alias ("levels",			IMP_LEVELS);
	player_init_impulse_alias ("lag",			IMP_LAG);
	player_init_impulse_alias ("never",			IMP_VOTE_NEVER);
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
	player_admin_impulse_alias ("admin-muteip",		IMP_ADMIN_MUTEIP);
	player_admin_impulse_alias ("admin-mutelist",		IMP_ADMIN_MUTELIST);
	player_admin_impulse_alias ("admin-rename",		IMP_ADMIN_RENAME);
	player_admin_impulse_alias ("admin-rune-delete",	IMP_ADMIN_RUNE_DELETE);
	player_admin_impulse_alias ("admin-team-change",	IMP_ADMIN_TEAM_CHANGE);
	player_admin_impulse_alias ("admin-team-change-toggle",	IMP_ADMIN_TEAM_CHANGE_TOGGLE);
	player_admin_impulse_alias ("admin-vote-team-toggle",	IMP_ADMIN_VOTE_TEAM_TOGGLE);
	player_admin_impulse_alias ("admin-teamplay-zero",	IMP_ADMIN_TEAMPLAY_ZERO);
	player_admin_impulse_alias ("admin-unbanip",		IMP_ADMIN_UNBANIP);
	player_admin_impulse_alias ("admin-unbind",		IMP_ADMIN_UNBIND);
	player_admin_impulse_alias ("admin-unmuteip",		IMP_ADMIN_UNMUTEIP);
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
	player_vote_impulse_alias ("heads",			IMP_VOTE_HEADS);	// CRMod (Style)
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
	player_vote_impulse_alias ("vote-default",		IMP_VOTE_DEFAULT);
	player_vote_impulse_alias ("vote-exit",			IMP_VOTE_EXIT);
	player_vote_impulse_alias ("vote-free",			IMP_VOTE_FREE);
	player_vote_impulse_alias ("vote-heads",		IMP_VOTE_HEADS);
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
	player_vote_impulse_alias ("vote-powerup-hats",		IMP_VOTE_POWERUP_HATS);
	player_vote_impulse_alias ("vote-practice",		IMP_VOTE_PRACTICE);
	player_vote_impulse_alias ("vote-quad",			IMP_VOTE_QUAD);
	player_vote_impulse_alias ("vote-random-spawn",		IMP_VOTE_RANDOM_SPAWN);
	player_vote_impulse_alias ("vote-ring",			IMP_VOTE_RING);
	player_vote_impulse_alias ("vote-rune-drop",		IMP_VOTE_RUNE_DROP);
	player_vote_impulse_alias ("vote-runes",		IMP_VOTE_RUNES);
	player_vote_impulse_alias ("vote-rotate",		IMP_VOTE_ROTATE);
	player_vote_impulse_alias ("vote-shields",		IMP_VOTE_SHIELDS);
	player_vote_impulse_alias ("vote-shoot-buttons",	IMP_VOTE_SHOOT_BUTTONS);
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
		if (MOD_PROTOCOL)
		{
			imp = imp + IMP_LEVEL_MIN;

			self_stuffcmd (self, "alias ");
			self_stuffcmd (self, level);
			self_stuffcmd (self, " \"cmd impulse ");
			s = ftos (imp);
			self_stuffcmd (self, s);
			self_stuffcmd (self, "\"\n");
		}
		else
		{
			self_stuffcmd (self, "alias ");
			self_stuffcmd (self, level);

			// hack to allow more than 255 map impulses
			if (imp > 255)
			{
				imp = imp - 255;
				self_stuffcmd (self, " \"cl2;w5;w5;impulse ");
			}
			else
				self_stuffcmd (self, " \"cl;w5;w5;impulse ");

			s = ftos (imp);
			self_stuffcmd (self, s);
			self_stuffcmd (self, ";w5\"\n");
		}
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
custom_aliases_think =
{
	local entity os;
	local string s;

	if (!total_customs ())
		self.count = 4;

	os = self;
	self = world;
	if (os.count == 1)
		custom_aliases_small ();
	else if (os.count == 2)
		custom_aliases_medium ();
	else if (os.count == 3)
		custom_aliases_large ();
	self = os;

	if (self.count > 2)
	{
		storage = storage | CONSOLE_ALIASES;
		s = ftos (storage);
		cvar_set_infokey (CVAR_C6, s);
		remove (self);
		return;
	}

	self.count = self.count + 1;
	self.nextthink = time + 1;
};

void ()
spawn_custom_aliases =
{
	local entity e;

	e		= spawn ();
	e.count		= 1;
	e.think		= custom_aliases_think;
	e.nextthink	= time + 1;
};

void ()
console_aliases =
{
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
	console_init_cvar_alias ("update-hunkinit",	CVAR_C2,	C2_UPDATE_HUNKINIT);
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
	console_init_cvar_alias ("powerupdropon",	CVAR_C2,	C2_POWERDROPON);
	console_init_cvar_alias ("powerupdropoff",	CVAR_C2,	C2_POWERDROPOFF);
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
	console_init_cvar_alias ("heads",		CVAR_C2,	C2_MODE_HEADS);
	console_init_cvar_alias ("randomspawnon",	CVAR_C2,	C2_RANDOMSPAWNON);
	console_init_cvar_alias ("randomspawnoff",	CVAR_C2,	C2_RANDOMSPAWNOFF);
	console_init_cvar_alias ("freehookon",		CVAR_C2,	C2_FREEHOOKON);
	console_init_cvar_alias ("hookon",		CVAR_C2,	C2_FREEHOOKON);
	console_init_cvar_alias ("lithhookon",		CVAR_C2,	C2_LITHHOOKON);
	console_init_cvar_alias ("hookoff",		CVAR_C2,	C2_HOOKOFF);
	console_init_cvar_alias ("help-deathmatch",	CVAR_C2,	C2_HELP_DEATHMATCH);
	console_init_cvar_alias ("help-teamplay",	CVAR_C2,	C2_HELP_TEAMPLAY);
	console_init_cvar_alias ("help-noexit",		CVAR_C2,	C2_HELP_NOEXIT);
	console_init_cvar_alias ("help-temp1",		CVAR_C2,	C2_HELP_TEMP1);
	console_init_cvar_alias ("help-scratch1",	CVAR_C2,	C2_HELP_SCRATCH1);
	console_init_cvar_alias ("shootbuttonson",	CVAR_C2,	C2_SHOOTBUTTONSON);
	console_init_cvar_alias ("shootbuttonsoff",	CVAR_C2,	C2_SHOOTBUTTONSOFF);
	console_init_cvar_alias ("maxrunes",		CVAR_C2,	C2_MAXRUNES);
	console_init_cvar_alias ("setafk",		CVAR_C2,	C2_SETAFK);
	console_init_cvar_alias ("poweruphatson",	CVAR_C2,	C2_POWERUPHATSON);
	console_init_cvar_alias ("poweruphatsoff",	CVAR_C2,	C2_POWERUPHATSOFF);
	console_init_cvar_alias ("votehookon",		CVAR_C2,	C2_VOTEHOOKON);
	console_init_cvar_alias ("votehookoff",		CVAR_C2,	C2_VOTEHOOKOFF);
	console_init_cvar_alias ("setdefault",		CVAR_C2,	C2_SETDEFAULT);
	console_init_cvar_alias ("create_altar",	CVAR_C2,	C2_CREATE_ALTAR);
	console_init_cvar_alias ("remove_altar",	CVAR_C2,	C2_REMOVE_ALTAR);

	level_aliases ();
	spawn_custom_aliases ();
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

		s = impulse_to_map (i);
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
			if (MOD_PROTOCOL)
			{
				s = cvar_string ("skill", 1);
				v = ip_to_vec (s);
			}
			else
			{
				v_x = cvar ("scr_ofsx");
				v_y = cvar ("scr_ofsy");
				v_z = cvar ("scr_ofsz");

				if (v_x < 0 || v_y < 0 || v_z < 0 || v_x > 255 || v_y > 255 || v_z > 255)
					v = VEC_ORIGIN;
			}
			if (v == VEC_ORIGIN)
				self_sprint (self, "invalid ip address\n");
			else
				ban_add (v_x + (v_y * 256) + (v_z * 65536));
		}

		else if (i == C2_BAN_REMOVE)
		{	IN_QW(return;)
			if (MOD_PROTOCOL)
			{
				s = cvar_string ("skill", 1);
				v = ip_to_vec (s);
			}
			else
			{
				v_x = cvar ("scr_ofsx");
				v_y = cvar ("scr_ofsy");
				v_z = cvar ("scr_ofsz");

				if (v_x < 0 || v_y < 0 || v_z < 0 || v_x > 255 || v_y > 255 || v_z > 255)
					v = VEC_ORIGIN;
			}
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
			if (MOD_PROTOCOL)
			{
				s = cvar_string ("skill", 1);
				v = ip_to_vec (s);
			}
			else
			{
				v_x = cvar ("scr_ofsx");
				v_y = cvar ("scr_ofsy");
				v_z = cvar ("scr_ofsz");

				if (v_x < 0 || v_y < 0 || v_z < 0 || v_x > 255 || v_y > 255 || v_z > 255)
					v = VEC_ORIGIN;
			}
			if (v == VEC_ORIGIN)
				self_sprint (self, "invalid ip address\n");
			else
				mute_add (v_x + (v_y * 256) + (v_z * 65536));
		}

		else if (i == C2_MUTE_REMOVE)
		{	IN_QW(return;)
			if (MOD_PROTOCOL)
			{
				s = cvar_string ("skill", 1);
				v = ip_to_vec (s);
			}
			else
			{
				v_x = cvar ("scr_ofsx");
				v_y = cvar ("scr_ofsy");
				v_z = cvar ("scr_ofsz");

				if (v_x < 0 || v_y < 0 || v_z < 0 || v_x > 255 || v_y > 255 || v_z > 255)
					v = VEC_ORIGIN;
			}
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
			if (!options & WEAPONS_STAY)
			{
				dprint_force ("Weapons-stay enabled\n");
				toggle_weapons_stay ();
			}
		}

		else if (i == C2_WEAPONSSTAYOFF)
		{
			if (options & WEAPONS_STAY)
			{
				dprint_force ("Weapons-stay disabled\n");
				toggle_weapons_stay ();
			}
		}

		else if (i == C2_MODE_HEADS)
			change_mode_to_heads ();

		else if (i == C2_RANDOMSPAWNON)
		{
			if (!options & RANDOM_SPAWN)
			{
				dprint_force ("Random spawn enabled\n");
				toggle_random_spawn ();
			}
		}

		else if (i == C2_RANDOMSPAWNOFF)
		{
			if (options & RANDOM_SPAWN)
			{
				dprint_force ("Random spawn disabled\n");
				toggle_random_spawn ();
			}
		}

		else if (i == C2_FREEHOOKON)
		{
			if (hook_type (options2) != 1)
			{
				dprint_force ("Free hook enabled\n");
				free_hook ();
			}
		}

		else if (i == C2_LITHHOOKON)
		{
			if (hook_type (options2) != 2)
			{
				dprint_force ("Lithium hook enabled\n");
				lithium_hook ();
			}
		}

		else if (i == C2_HOOKOFF)
		{
			if (hook_type (options2))
			{
				dprint_force ("Hook disabled\n");
				toggle_free_hook ();
			}
		}

		else if (i == C2_HELP_DEATHMATCH)
			help_deathmatch ();

		else if (i == C2_HELP_TEAMPLAY)
			help_teamplay ();

		else if (i == C2_HELP_NOEXIT)
			help_noexit ();

		else if (i == C2_HELP_TEMP1)
			help_temp1 ();

		else if (i == C2_HELP_SCRATCH1)
			help_scratch1 ();

		else if (i == C2_UPDATE_HUNKINIT)
		{
			if (HUNK_CONTEXT_MAX)
				hunk_storage_init ();
			else
				dprint_force ("Command not supported on this server\n");
		}

		else if (i == C2_SHOOTBUTTONSON)
		{
			if (!options & SHOOT_BUTTONS)
			{
				dprint_force ("Shootable buttons on\n");
				toggle_shoot_buttons ();
			}
		}

		else if (i == C2_SHOOTBUTTONSOFF)
		{
			if (options & SHOOT_BUTTONS)
			{
				dprint_force ("Shootable buttons off\n");
				toggle_shoot_buttons ();
			}
		}

		else if (i == C2_MAXRUNES)
		{
			skill = cvar ("skill");

			if (!skill)
				dprint_force ("You cannot set maxrunes to 0, use 'runesoff' instead\n");
			else if (skill < 1 || skill > 63)
				dprint_force ("Set 'skill' to a value between 1-63, then type maxrunes\n");
			else
			{
				temp1 = cvar_infokey ("temp1");
				if (temp1 & T1_NRUNES_MASK != skill)
				{
					temp1 = temp1 - temp1 & T1_NRUNES_MASK;
					temp1 = temp1 | skill;
					s = ftos (temp1);
					cvar_set_infokey ("temp1", s);
				}
				dprint_force ("Maxrunes set to ");
				s = ftos (skill);
				dprint_force (s);
				dprint_force ("\n");
			}
		}

		else if (i == C2_SETAFK)
		{
			skill = cvar ("skill");
			if (skill < 0 || skill > 30)
				dprint_force ("Set 'skill' to a value between 0-30, then type setafk\n");
			else
			{
				if (skill == 0) skill = 31; // zero bit hack
				if (storage & SETAFK_MASK != skill)
				{
					storage = storage - storage & SETAFK_MASK;
					storage = storage | (skill * SETAFK_MULTIPLIER);
					s = ftos (storage);
					cvar_set_infokey (CVAR_C6, s);
				}
				dprint_force ("Setafk set to ");
				if (skill == 31) skill = 0; // zero bit hack
				AFK_TIME = skill;
				s = ftos (skill);
				dprint_force (s);
				dprint_force ("\n");
			}
		}

		else if (i == C2_POWERUPHATSON)
		{
			if (options & NO_POWERUP_HATS)
			{
				dprint_force ("Powerup hats on\n");
				toggle_powerup_hats ();
			}
		}

		else if (i == C2_POWERUPHATSOFF)
		{
			if (!options & NO_POWERUP_HATS)
			{
				dprint_force ("Powerup hats off\n");
				toggle_powerup_hats ();
			}
		}

		else if (i == C2_VOTEHOOKON)
		{
			if (options2 & VOTE_HOOK_DISABLED)
			{
				dprint_force ("Vote-hook enabled\n");
				toggle_vote_hook ();
			}
		}

		else if (i == C2_VOTEHOOKOFF)
		{
			if (!options2 & VOTE_HOOK_DISABLED)
			{
				dprint_force ("Vote-hook disabled\n");
				toggle_vote_hook ();
			}
		}

		else if (i == C2_SETDEFAULT)
		{
			if (scratch1 & S1_NO_DEFAULT)
				dprint_force ("Remove 'S1_NO_DEFAULT' from 'scratch1' to use this feature\n");
			else
			{
				gamemode_default (gamemode);
				dprint_force ("Gamemode defaults have been set\n");
			}
		}
		else if (i == C2_CREATE_ALTAR)
		{
			v_x = cvar ("scr_ofsx");
			v_y = cvar ("scr_ofsy");
			v_z = cvar ("scr_ofsz");
			altar_create (v);
		}
		else if (i == C2_REMOVE_ALTAR)
		{
			v_x = cvar ("scr_ofsx");
			v_y = cvar ("scr_ofsy");
			v_z = cvar ("scr_ofsz");
			remove_classname_origin_dist ("altar", v, 32);
		}
		else
			dprint_force ("Unknown command\n");

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

	self_sprint (self, "commands            settings            options             players\n");
	self_sprint (self, "levels              custom              level-time          sping\n");
	self_sprint (self, "last                update-bindings     update-hunkinit     rune-cheat\n");
	self_sprint (self, "banlist             banip               unbanip             mode\n");
	self_sprint (self, "mutelist            muteip              unmuteip            conprint\n");
	self_sprint (self, "eff                 killstats           stats               help-deathmatch\n");
	self_sprint (self, "help-teamplay       help-noexit         help-temp1          help-scratch1\n");
	self_sprint (self, "maxrunes            setafk              setdefault\n");

	self_sprint (self, "\n");
	self_sprint (self, "normal              practice            match               arena\n");
	self_sprint (self, "midair              heads\n");

	self_sprint (self, "\n");
	self_sprint (self, "hookon              lithhookon          hookoff             \n");
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
	self_sprint (self, "randomspawnon       randomspawnoff      shootbuttonson      shootbuttonsoff\n");
	self_sprint (self, "poweruphatson       poweruphatsoff      votehookon          votehookoff\n");
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
	self_sprint (self, "\bvote-team       vote-match\n");
	self_sprint (self, "\bvote-normal     vote-practice\n");
	self_sprint (self, "\bvote-arena      vote-heads\n");
	self_sprint (self, "\bvote-midair     vote-random-spawn\n");
	self_sprint (self, "\bvote-quad       vote-pent\n");
	self_sprint (self, "\bvote-ring       vote-suit\n");
	self_sprint (self, "\bvote-armor      vote-rotate\n");
	self_sprint (self, "\bvote-alts       vote-weapons-stay\n");
	self_sprint (self, "\bvote-runes      vote-rune-drop\n");
	self_sprint (self, "\bvote-shields    vote-lg-discharge\n");
	self_sprint (self, "\bvote-mega       vote-classic-mega\n");
	self_sprint (self, "\bvote-backpacks  vote-armor-drop\n");
	self_sprint (self, "\bvote-default    vote-powerup-drop\n");
	self_sprint (self, "\b                vote-shoot-buttons\n");
	self_sprint (self, "\b                vote-powerup-hats\n");
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

	self_sprint (self, "\n\bhook          ");	self_sprint_boolean (self, options2 & HOOK_MASK);
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
	self_sprint (self, "\b  random spawn  ");       self_sprint_boolean (self, options & RANDOM_SPAWN);
	self_sprint (self, "\n\bshoot buttons ");	self_sprint_boolean (self, options & SHOOT_BUTTONS);
	self_sprint (self, "\b  powerup hats  ");	self_sprint_boolean (self, !options & NO_POWERUP_HATS);
	self_sprint (self, "\n");
};

void ()
help_deathmatch =
{
	local float dm;

	dm = cvar ("deathmatch");

	self_sprint (self, "deathmatch = "); self_sprint_float (self, (dm));
	self_sprint (self, "\n");
	self_sprint (self, "\n    1 items respawn                     "); self_sprint_boolean (self, dm & DM_RESPAWN);
	self_sprint (self, "\n    2 long quad respawn                 "); self_sprint_boolean (self, dm & DM_LONG_QUAD_RESPAWN);
	self_sprint (self, "\n    4 quad replacement                  "); self_sprint_boolean (self, dm & DM_QUAD_REPLACEMENT);
	self_sprint (self, "\n    8 pentagram replacement             "); self_sprint_boolean (self, dm & DM_PENT_REPLACEMENT);
	self_sprint (self, "\n   16 exit attempt doesn't kill you     "); self_sprint_boolean (self, dm & DM_EXIT_NON_FATAL);
	self_sprint (self, "\n   32 random powerup respawn            "); self_sprint_boolean (self, dm & DM_RANDOM_POWERUP_RESPAWN);
	self_sprint (self, "\n   64 damage-based frag scoring         "); self_sprint_boolean (self, dm & DM_DAMAGE_MATCH);
	self_sprint (self, "\n");
};

void ()
help_teamplay =
{
	local float tm;

	tm = cvar ("teamplay");

	self_sprint (self, "teamplay = "); self_sprint_float (self, (tm));
	self_sprint (self, "\n");
	self_sprint (self, "\n    1 health protect                    "); self_sprint_boolean (self, tm & TEAM_HEALTH_PROT);
	self_sprint (self, "\n    2 frag penalty                      "); self_sprint_boolean (self, tm & TEAM_FRAG_PENALTY);
	self_sprint (self, "\n    4 armor protect                     "); self_sprint_boolean (self, tm & TEAM_ARMOR_PROT);
	self_sprint (self, "\n    8 enforce two teams                 "); self_sprint_boolean (self, tm & TEAM_2_TEAMS);
	self_sprint (self, "\n   16 enforce three teams               "); self_sprint_boolean (self, tm & TEAM_3_TEAMS);
	self_sprint (self, "\n   24 enforce four teams                "); self_sprint_boolean (self, tm & TEAM_4_TEAMS);
	self_sprint (self, "\n   64 team change any                   "); self_sprint_boolean (self, tm & TEAM_CHANGE_ANY);
	self_sprint (self, "\n  128 team change top dog               "); self_sprint_boolean (self, tm & TEAM_CHANGE_TOPDOG);
	self_sprint (self, "\n  256 no team voting                    "); self_sprint_boolean (self, tm & TEAM_NO_VOTE);
	self_sprint (self, "\n  512 self health protect               "); self_sprint_boolean (self, tm & TEAM_SELF_HEALTH_PROT);
	self_sprint (self, "\n 1024 self armor protect                "); self_sprint_boolean (self, tm & TEAM_SELF_ARMOR_PROT);
	self_sprint (self, "\n");
};

void ()
help_noexit =
{
	local float i, ne;

	ne = cvar_infokey ("noexit");

	self_sprint (self, "noexit = "); self_sprint_float (self, (ne));
	self_sprint (self, "\n");
	self_sprint (self, "\n    1 no exiting                        "); self_sprint_boolean (self, ne & NOEXIT_NO_EXITING);
	self_sprint (self, "\n    2 allow exiting start level         "); self_sprint_boolean (self, ne & NOEXIT_ALLOW_EXITING_START);
	self_sprint (self, "\n    4 randomize                         "); self_sprint_boolean (self, ne & NOEXIT_RANDOMIZE);
	self_sprint (self, "\n    8 select level by number of players "); self_sprint_boolean (self, ne & NOEXIT_CHOOSE_BY_NPLAYERS);
	self_sprint (self, "\n   16 use Marlinspike levels            "); self_sprint_boolean (self, ne & NOEXIT_MARLINSPIKE_LEVELS);
	self_sprint (self, "\n   32 don't loop back to dm1 after dm6  "); self_sprint_boolean (self, ne & NOEXIT_DM_NO_LOOP);
	self_sprint (self, "\n   64 * max players before forwarding   "); i = ne & NOEXIT_FORWARD_MASK;
	if (i) self_sprint_float (self, i / NOEXIT_FORWARD_MULT); else self_sprint (self, "0");
	self_sprint (self, "\n 1024 don't use custom levels           "); self_sprint_boolean (self, ne & NOEXIT_NO_CUSTOM_LEVELS);
	self_sprint (self, "\n 2048 don't use standard maps           "); self_sprint_boolean (self, ne & NOEXIT_CUSTOM_LEVELS_ONLY);
	self_sprint (self, "\n 4096 allow voting non-rotatable maps   "); self_sprint_boolean (self, ne & NOEXIT_VOTE_ALL_MAPS);
	self_sprint (self, "\n");
};

void ()
help_temp1 =
{
	local float i, t1;

	t1 = cvar_infokey ("temp1");

	self_sprint (self, "temp1 = "); self_sprint_float (self, (t1));
	self_sprint (self, "\n");

	self_sprint (self, "\n     1-63 number of runes               "); self_sprint_float (self, t1 & T1_NRUNES_MASK);
	self_sprint (self, "\n       64 rune selection by impulse     "); self_sprint_boolean (self, t1 & T1_RUNE_CHEAT);
	self_sprint (self, "\n      256 can pick up own rune          "); self_sprint_boolean (self, t1 & T1_CAN_GET_OWN_RUNE);
	self_sprint (self, "\n     1024 random rune models            "); self_sprint_boolean (self, t1 & T1_RANDOM_RUNE_MODELS);
	self_sprint (self, "\n     2048 fast rune spawn               "); self_sprint_boolean (self, t1 & T1_FAST_RUNE_SPAWN);
	self_sprint (self, "\n     4096 * max players                 "); i = max_players ();
	if (!i) self_sprint (self, "off"); else self_sprint_float (self, i);
	self_sprint (self, "\n");
	//self_sprint (self, "\n   262144 free hook                     "); self_sprint_boolean (self, t1 & T1_FREE_HOOK);
	//self_sprint (self, "\n   524288 Lithium hook                  "); self_sprint_boolean (self, t1 & T1_LITHIUM_HOOK);
	//self_sprint (self, "\n  1048576 no hook voting                "); self_sprint_boolean (self, t1 & T1_HOOK_NO_VOTE);
	//self_sprint (self, "\n");
	i = t1 & T1_RUNE_DROP_DELAY_MASK;
	self_sprint (self, "\n    65536 no rune drop delay            "); self_sprint_boolean (self, i == T1_RUNE_DROP_DELAY_0);
	self_sprint (self, "\n    66048  15 second rune drop delay    "); self_sprint_boolean (self, i == T1_RUNE_DROP_DELAY_15);
	self_sprint (self, "\n   131072  30 second rune drop delay    "); self_sprint_boolean (self, i == T1_RUNE_DROP_DELAY_30);
	self_sprint (self, "\n      512  60 second rune drop delay    "); self_sprint_boolean (self, i == T1_RUNE_DROP_DELAY_60);
	self_sprint (self, "\n   131584 120 second rune drop delay    "); self_sprint_boolean (self, i == T1_RUNE_DROP_DELAY_120);
	self_sprint (self, "\n   196608 240 second rune drop delay    "); self_sprint_boolean (self, i == T1_RUNE_DROP_DELAY_240);
	self_sprint (self, "\n   197120 rune dropping disabled        "); self_sprint_boolean (self, i == T1_RUNE_DROP_DELAY_INF);
	self_sprint (self, "\n");
};

void ()
help_scratch1 =
{
	local float s1;

	s1 = cvar_infokey ("scratch1");

	self_sprint (self, "         [YOU MUST RESTART THE LEVEL FOR THESE CHANGES TO TAKE EFFECT!]\n");
	self_sprint (self, "scratch1 = "); self_sprint_float (self, (s1));
	self_sprint (self, "\n");

	self_sprint (self, "\n     1 equalize all lightstyles         "); self_sprint_boolean (self, s1 & S1_EQUALIZE_LIGHTSTYLE);
	self_sprint (self, "\n     2 disable all ambient sounds       "); self_sprint_boolean (self, s1 & S1_AMBIENT_SOUND_OFF);
	self_sprint (self, "\n     4 don't spawn any static lights    "); self_sprint_boolean (self, s1 & S1_LIGHT_MAKESTATIC_OFF);
	self_sprint (self, "\n     8 bprint prints to server console  "); self_sprint_boolean (self, s1 & S1_BPRINT_TO_CONSOLE);
	self_sprint (self, "\n    16 keep original level items        "); self_sprint_boolean (self, s1 & S1_ORIGINAL_LEVELS);
	self_sprint (self, "\n    32 limit maximum traps per rune     "); self_sprint_boolean (self, s1 & S1_MAX_TRAPS_FOR_LEVEL);
	self_sprint (self, "\n    64 basic/lite runes                 "); self_sprint_boolean (self, s1 & S1_BASIC_RUNES);
	self_sprint (self, "\n   128 custom exits                     "); self_sprint_boolean (self, s1 & S1_CUSTOM_EXITS);
	self_sprint (self, "\n   256 no default mode                  "); self_sprint_boolean (self, s1 & S1_NO_DEFAULT);
	self_sprint (self, "\n   512 default uses config files        "); self_sprint_boolean (self, s1 & S1_DEFAULT_USES_CONFIGS);
	self_sprint (self, "\n  1024 default mode normal              "); self_sprint_boolean (self, s1 & S1_NORMAL_DEFAULT);
	self_sprint (self, "\n  2048 default mode practice            "); self_sprint_boolean (self, s1 & S1_PRACTICE_DEFAULT);
	self_sprint (self, "\n  4096 default mode arena               "); self_sprint_boolean (self, s1 & S1_ARENA_DEFAULT);
	self_sprint (self, "\n  8192 default mode match               "); self_sprint_boolean (self, s1 & S1_MATCH_DEFAULT);
	self_sprint (self, "\n 16384 default mode midair              "); self_sprint_boolean (self, s1 & S1_MIDAIR_DEFAULT);
	self_sprint (self, "\n 32768 default mode heads               "); self_sprint_boolean (self, s1 & S1_HEADS_DEFAULT);
	self_sprint (self, "\n");
};
