/*  $Id: bindings.qc,v 1.93 2006/09/05 04:22:00 slotzero Exp $

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
	player_init_impulse_alias ("help-vote",			IMP_HELP_VOTE);
	player_init_impulse_alias ("+hook",			IMP_HOOK_ON);
	player_init_impulse_alias ("-hook",			IMP_HOOK_OFF);
	player_init_impulse_alias ("hook-off",			IMP_HOOK_OFF);
	player_init_impulse_alias ("hook-on",			IMP_HOOK_ON);
	player_init_impulse_alias ("hook-toggle",		IMP_HOOK_TOGGLE);
	player_init_impulse_alias ("hud-toggle",		IMP_HUD_TOGGLE);
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
	player_vote_impulse_alias ("vote-exit",			IMP_VOTE_EXIT);
	player_vote_impulse_alias ("vote-free",			IMP_VOTE_FREE);
	player_vote_impulse_alias ("vote-hook",			IMP_VOTE_HOOK);
	player_vote_impulse_alias ("vote-hook-damage",		IMP_VOTE_HOOK_DAMAGE);
	player_vote_impulse_alias ("vote-lithium",		IMP_VOTE_LITHIUM);
	player_vote_impulse_alias ("vote-match",		IMP_VOTE_MATCH);
	player_vote_impulse_alias ("vote-mega",			IMP_VOTE_MEGA);
	player_vote_impulse_alias ("vote-midair",		IMP_VOTE_MIDAIR);
	player_vote_impulse_alias ("vote-normal",		IMP_VOTE_NORMAL);
	player_vote_impulse_alias ("vote-pent",			IMP_VOTE_PENT);
	player_vote_impulse_alias ("vote-practice",		IMP_VOTE_PRACTICE);
	player_vote_impulse_alias ("vote-quad",			IMP_VOTE_QUAD);
	player_vote_impulse_alias ("vote-ring",			IMP_VOTE_RING);
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
	console_init_cvar_alias ("dropon",		CVAR_C2,	C2_DROPON);
	console_init_cvar_alias ("dropoff",		CVAR_C2,	C2_DROPOFF);
	console_init_cvar_alias ("faststarton",		CVAR_C2,	C2_FASTSTARTON);
	console_init_cvar_alias ("faststartoff",	CVAR_C2,	C2_FASTSTARTOFF);
	console_init_cvar_alias ("backpackson",		CVAR_C2,	C2_BACKPACKSON);
	console_init_cvar_alias ("backpacksoff",	CVAR_C2,	C2_BACKPACKSOFF);
	console_init_cvar_alias ("midair",		CVAR_C2,	C2_MODE_MIDAIR);

	level_aliases ();
	custom_aliases ();
	custom_maps ();

	IN_QW(return;)

	// prepare the hunk
	for (i = 0; i < BAN_LIST_SIZE; i = i + %1)
		Write_Hunk_Vector (HUNK_CONTEXT, HUNK_BAN_OFFSET + (i * 3), VEC_ORIGIN);

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
			commands ();

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
			if (NO_QUAD)
			{
				dprint_force ("Quad enabled\n");
				setquad ();
			}
		}

		else if (i == C2_QUADOFF)
		{
			if (!NO_QUAD)
			{
				dprint_force ("Quad disabled\n");
				setquad ();
			}
		}

		else if (i == C2_PENTON)
		{
			if (NO_PENT)
			{
				dprint_force ("Pentagram enabled\n");
				setpent ();
			}
		}

		else if (i == C2_PENTOFF)
		{
			if (!NO_PENT)
			{
				dprint_force ("Pentagram disabled\n");
				setpent ();
			}
		}

		else if (i == C2_RINGON)
		{
			if (NO_RING)
			{
				dprint_force ("Ring of shadows enabled\n");
				setring ();
			}
		}

		else if (i == C2_RINGOFF)
		{
			if (!NO_RING)
			{
				dprint_force ("Ring of shadows disabled\n");
				setring ();
			}
		}

		else if (i == C2_SUITON)
		{
			if (NO_SUIT)
			{
				dprint_force ("Environmental protection suit enabled\n");
				setsuit ();
			}
		}

		else if (i == C2_SUITOFF)
		{
			if (!NO_SUIT)
			{
				dprint_force ("Environmental protection suit disabled\n");
				setsuit ();
			}
		}

		else if (i == C2_ARMORON)
		{
			if (NO_ARMOR)
			{
				dprint_force ("Armor enabled\n");
				setarmor ();
			}
		}

		else if (i == C2_ARMOROFF)
		{
			if (!NO_ARMOR)
			{
				dprint_force ("Armor disabled\n");
				setarmor ();
			}
		}

		else if (i == C2_ROTATEON)
		{
			if (!ROTATE)
			{
				dprint_force ("Rotating armors enabled\n");
				setrotate ();
			}
		}

		else if (i == C2_ROTATEOFF)
		{
			if (ROTATE)
			{
				dprint_force ("Rotating armors disabled\n");
				setrotate ();
			}
		}

		else if (i == C2_RUNESON)
		{
			if (NO_RUNES)
			{
				dprint_force ("Runes enabled\n");
				setrunes ();
			}
		}

		else if (i == C2_RUNESOFF)
		{
			if (!NO_RUNES)
			{
				dprint_force ("Runes disabled\n");
				setrunes ();
			}
		}

		else if (i == C2_ALTSON)
		{
			if (gamemode == MODE_PRACTICE)
				dprint_force ("Alternate weapons disabled in practice mode\n");
			else if (NO_ALT_WEAPONS)
			{
				dprint_force ("Alternate weapons enabled\n");
				setalts ();
			}
		}

		else if (i == C2_ALTSOFF)
		{
			if (!NO_ALT_WEAPONS)
			{
				dprint_force ("Alternate weapons disabled\n");
				setalts ();
			}
		}

		else if (i == C2_SHIELDSON)
		{
			if (NO_SPAWN_SHIELDS)
			{
				dprint_force ("Spawn shields enabled\n");
				setshields ();
			}
		}

		else if (i == C2_SHIELDSOFF)
		{
			if (!NO_SPAWN_SHIELDS)
			{
				dprint_force ("Spawn shields disabled\n");
				setshields ();
			}
		}

		else if (i == C2_HOOKDAMAGEON)
		{
			if (NO_HOOK_DAMAGE)
			{
				dprint_force ("Hook damage enabled\n");
				sethookdamage ();
			}
		}

		else if (i == C2_HOOKDAMAGEOFF)
		{
			if (!NO_HOOK_DAMAGE)
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
			if (NO_MEGA)
			{
				dprint_force ("Mega-health boxes enabled\n");
				setmega ();
			}
		}

		else if (i == C2_MEGAOFF)
		{
			if (!NO_MEGA)
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
				ban_add (v);
		}

		else if (i == C2_BAN_REMOVE)
		{	IN_QW(return;)
			s = cvar_string ("skill", 1);
			v = ip_to_vec (s);
			if (v == VEC_ORIGIN)
				self_sprint (self, "invalid ip address\n");
			else
				ban_remove (v);
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

		else if (i == C2_DROPON)
		{
			if (deathmatch & DM_NO_DROP_ARMOR)
			{
				dprint_force ("Armor dropping enabled\n");
				toggle_armor_drop ();
			}
		}

		else if (i == C2_DROPOFF)
		{
			if (!deathmatch & DM_NO_DROP_ARMOR)
			{
				dprint_force ("Armor dropping disabled\n");
				toggle_armor_drop ();
			}
		}

		else if (i == C2_FASTSTARTON)
		{
			if (!FASTSTART)
			{
				dprint_force ("Fast match starts enabled\n");
				setfaststart ();
			}
		}

		else if (i == C2_FASTSTARTOFF)
		{
			if (FASTSTART)
			{
				dprint_force ("Fast match starts disabled\n");
				setfaststart ();
			}
		}

		else if (i == C2_BACKPACKSON)
		{
			if (NO_BACKPACKS)
			{
				dprint_force ("Backpack dropping enabled\n");
				setbackpacks ();
			}
		}

		else if (i == C2_BACKPACKSOFF)
		{
			if (!NO_BACKPACKS)
			{
				dprint_force ("Backpack dropping disabled\n");
				setbackpacks ();
			}
		}

		else if (i == C2_MODE_MIDAIR)
			change_mode_to_midair ();

		else
			dprint ("Unknown command\n");

		cvar_set_infokey (CVAR_C2, "0");
	}
};

//-------------------------------------------------------------------
// HELP MENUS
//-------------------------------------------------------------------

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
	self_sprint (self, "\bcustom\b        custom levels on server\n");
	self_sprint (self, "\bvote-exit\b     vote to exit the level\n");
	self_sprint (self, "\bvote-team\b     vote to toggle teams\n");
	self_sprint (self, "\bvote-hook\b     vote to toggle hook\n");
	self_sprint (self, "\bremove-frags\b  reset frags to zero\n");
	self_sprint (self, "\b+hook\b         use hook\n");
	self_sprint (self, "\bquiet-toggle\b  mute many game messages\n");
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
