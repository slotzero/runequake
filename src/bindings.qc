/*  $Id: bindings.qc,v 1.1 2003/10/10 22:30:30 slotzero Exp $

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

void ()
player_aliases =
{
	local string s;

	self_sprint (self, "Sending player bindings\n");

	self_stuffcmd (self, "alias w5 \"wait;wait;wait;wait;wait\"\n");
	self_stuffcmd (self, "alias cl \"impulse ");
	s = ftos (IMP_ADMIN_CHANGE_MAP);
	self_stuffcmd (self, s);
	self_stuffcmd (self, "\"\n");

	player_init_impulse_alias ("admin-toggle",		IMP_ADMIN_TOGGLE);
	player_init_impulse_alias ("best-weapon",		IMP_BEST_WEAPON);
	player_init_impulse_alias ("disp-info",			IMP_DISP_INFO);
	player_init_impulse_alias ("disp-info-all",		IMP_DISP_INFO_ALL);
	player_init_impulse_alias ("fix-angles",		IMP_FIX_BATMAN);
	player_init_impulse_alias ("+hook",			IMP_HOOK_ON);
	player_init_impulse_alias ("-hook",			IMP_HOOK_OFF);
	player_init_impulse_alias ("hook-off",			IMP_HOOK_OFF);
	player_init_impulse_alias ("hook-on",			IMP_HOOK_ON);
	player_init_impulse_alias ("hook-toggle",		IMP_HOOK_TOGGLE);
	player_init_impulse_alias ("hud-toggle",		IMP_HUD_TOGGLE);
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
	player_init_impulse_alias ("vote-team",			IMP_VOTE_TEAM);
	player_init_impulse_alias ("vote-hook",			IMP_VOTE_HOOK);
	player_init_impulse_alias ("weapon-mode",		IMP_WEAPON_MODE);
	player_init_impulse_alias ("weapon-toggles",		IMP_WEAPON_TOGGLES);
	player_init_impulse_alias ("weapon-toggles-toggle",	IMP_WEAPON_TOGGLES);
	player_init_impulse_alias ("cycle-alternates",		IMP_CYCLE_ALTERNATES);
	player_init_impulse_alias ("last",			IMP_LAST);
	player_init_impulse_alias ("levels",			IMP_LEVELS);
	player_init_impulse_alias ("change-level",		IMP_LEVELS);
	player_init_impulse_alias ("vote-level",		IMP_LEVELS);

	switchfire_aliases ();
	level_aliases ();
};

void ()
admin_aliases =
{
	player_init_impulse_alias ("admin-eyes",		IMP_ADMIN_EYES);
	player_init_impulse_alias ("admin-cycle",		IMP_ADMIN_CYCLE);
	player_init_impulse_alias ("admin-cycle-show",		IMP_ADMIN_CYCLE_SHOW);
	player_init_impulse_alias ("admin-join",		IMP_ADMIN_JOIN);
	player_init_impulse_alias ("admin-kick",		IMP_ADMIN_KICK);
	player_init_impulse_alias ("admin-kill",		IMP_ADMIN_KILL);
	player_init_impulse_alias ("admin-rename",		IMP_ADMIN_RENAME);
	player_init_impulse_alias ("admin-rune-delete",		IMP_ADMIN_RUNE_DELETE);
	player_init_impulse_alias ("admin-team-change",		IMP_ADMIN_TEAM_CHANGE);
	player_init_impulse_alias ("admin-team-change-toggle",	IMP_ADMIN_TEAM_CHANGE_TOGGLE);
	player_init_impulse_alias ("admin-vote-team-toggle",	IMP_ADMIN_VOTE_TEAM_TOGGLE);
	player_init_impulse_alias ("admin-teamplay-zero",	IMP_ADMIN_TEAMPLAY_ZERO);
	player_init_impulse_alias ("admin-unbind",		IMP_ADMIN_UNBIND);
	player_init_impulse_alias ("exit-level",		IMP_EXIT_LEVEL);
	player_init_impulse_alias ("qsmack",			IMP_QSMACK_COMMAND);
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
		localcmd (" \"skill ");
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
		self_stuffcmd (self, "\"\n");
	}
};

void (string cmd, string cvr, float imp)
console_init_cvar_alias =
{
	local string s;

	s = ftos (imp);
	localcmd ("alias ");
	localcmd (cmd);
	localcmd (" \"");
	localcmd (cvr);
	localcmd (" ");
	localcmd (s);
	localcmd ("\"\n");
};

void ()
console_aliases =
{
	dprint_force ("Sending console bindings\n");

	console_init_cvar_alias ("last",		"skill",	SKILL_LAST);
	console_init_cvar_alias ("show-players",	"skill",	SKILL_SHOW_PLAYERS);
	console_init_cvar_alias ("show-settings",	"skill",	SKILL_SHOW_SETTINGS);
	console_init_cvar_alias ("rune-cheat",		"skill",	SKILL_TOGGLE_RUNE_CHEAT);
	console_init_cvar_alias ("update-bindings",	"skill",	SKILL_UPDATE_BINDINGS);
	console_init_cvar_alias ("levels",		"skill",	SKILL_LEVELS);

	level_aliases ();
};
