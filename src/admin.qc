/*  $Id: admin.qc,v 1.15 2002/10/11 22:05:43 slotzero Exp $

    Copyright (C) 1998-2001  Roderick Schertler.

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

void ()
admin_init =
{
	if (is_admin ())
	{
		self_sprint (self, "Admin mode already active\n");
		return;
	}

	sprint_admin2 (self.netname, " activated admin mode\n");
	self.aqflags = self.aqflags | AQ_ADMIN;
	player_init_impulse_alias ("admin-eyes",	IMP_ADMIN_EYES);
	player_init_impulse_alias ("admin-cycle",	IMP_ADMIN_CYCLE);
	player_init_impulse_alias ("admin-cycle-show",	IMP_ADMIN_CYCLE_SHOW);
	player_init_impulse_alias ("admin-join",	IMP_ADMIN_JOIN);
	player_init_impulse_alias ("admin-kick",	IMP_ADMIN_KICK);
	player_init_impulse_alias ("admin-kill",	IMP_ADMIN_KILL);
	player_init_impulse_alias ("admin-rename",	IMP_ADMIN_RENAME);
	player_init_impulse_alias ("admin-rune-delete",	IMP_ADMIN_RUNE_DELETE);
	player_init_impulse_alias ("admin-team-change",	IMP_ADMIN_TEAM_CHANGE);
	player_init_impulse_alias ("admin-team-change-toggle",
							IMP_ADMIN_TEAM_CHANGE_TOGGLE);
	player_init_impulse_alias ("admin-vote-team-toggle",
							IMP_ADMIN_VOTE_TEAM_TOGGLE);
	player_init_impulse_alias ("admin-teamplay-zero",
							IMP_ADMIN_TEAMPLAY_ZERO);
	player_init_impulse_alias ("admin-unbind",	IMP_ADMIN_UNBIND);
	player_init_impulse_alias ("change-level",	IMP_ADMIN_CHANGE_MAP);
	player_init_impulse_alias ("exit-level",	IMP_EXIT_LEVEL);
	player_init_impulse_alias ("qsmack",		IMP_QSMACK_COMMAND);
	self_stuffcmd (self, "bind 9 \"impulse 9\"\n");
	self_sprint (self, "Admin mode activated\n");
	admin_sound ("misc/medkey.wav");
};

void (string msg, float passcode)
admin_wrong_passcode =
{
	local float i;

	i = self.aqstate & AQS_ADMIN_ATTEMPTS_MASK;
	if (i == AQS_ADMIN_ATTEMPTS_MASK)
		kick ("for using an incorrect ", msg);
	else
	{
		sprint_admin2 (self.netname, " used the wrong admin passcode\n");
		self_sprint (self, "Invalid passcode ");
		if (passcode)
			self_sprint_float (self, passcode);
		self_sprint (self, "\n");
		self.aqstate = self.aqstate + AQS_ADMIN_ATTEMPTS_MULT;
	}
};

void (float tell, float mention_console)
admin_toggle =
{
	local float admin_passcode_cvar;

	if (is_admin ())
	{
		self_sprint (self, "Admin mode disabled\n");
		self.aqflags = self.aqflags - AQ_ADMIN;
		return;
	}

	if (self.aqflags & AQ_KICKED)
	{
		kick ("for trying to crack the admin passcode", string_null);
		return;
	}

	ADMIN_PASSCODE_REAL = 0;
	admin_passcode_cvar = cvar_infokey ("gamecfg");

	if (admin_passcode_cvar < 0)
		ADMIN_PASSCODE_REAL = 123456;
	else if (admin_passcode_cvar > 0)
	{
		IN_POQ([-
			ADMIN_PASSCODE_REAL = admin_passcode_cvar;
	    	-], [-
			self_sprint (self, "Admin passcode can not be set in gamecfg\n");
			return;
		-])
	}
	else
		ADMIN_PASSCODE_REAL = ADMIN_PASSCODE;

	if (ADMIN_PASSCODE_REAL == 123456)
	{
		if (tell)
			self_sprint (self, "Admin passcode not configured\n");
		return;
	}

	if (ADMIN_PASSCODE_REAL < 100000 || ADMIN_PASSCODE_REAL > 888888)
	{
		if (tell)
		{
			self_sprint (self, "Invalid admin passcode in");
			if (admin_passcode_cvar > 0)
				self_sprint (self, " gamecfg\n");
			else
				self_sprint (self, " settings.qc\n");
		}
		return;
	}

	if (tell)
	{
		if (mention_console)
			self_sprint (self, "Close console and e");
		else
			self_sprint (self, "E");
		self_sprint (self, "nter admin passcode now\n");
	}
	self.aqstate = self.aqstate | AQS_IMPOVER_PASSWORD;
	self.state = 0;
};

void ()
admin_impulse_password =
{
	if (self.impulse < 1 || self.impulse > 8)
	{
		self_sprint (self, "Canceled, invalid passcode impulse ");
		self_sprint_float (self, self.impulse);
		self_sprint (self, "\n");
		impulse_override_cancel ();
		return;
	}

	self_sprint (self, "");
	self_sprint_float (self, self.impulse);
	self_sprint (self, "‘\n");
	self.state = self.state * 10 + self.impulse;
	self.impulse = 0;
	if (self.state > 99999)
	{
		local float passcode;

		passcode = self.state;
		self.state = 0;
		impulse_override_cancel ();
		if (passcode == ADMIN_PASSCODE_REAL)
		{
			self.aqstate = self.aqstate
				- self.aqstate & AQS_ADMIN_ATTEMPTS_MASK;
			admin_init ();
		}
		else
			admin_wrong_passcode ("admin passcode", passcode);
	}
};

void ()
admin_impulse_qsmack_password =
{
	local float i, failing;
	local string s;

	// Save off the failure flag, leaving just the sequence
	// number in self.state.
	failing = self.state & 8;
	self.state = self.state - failing;

	if 	(self.state == 1)	i = QSMACK_IMPULSE_2;
	else if (self.state == 2)	i = QSMACK_IMPULSE_3;
	else if (self.state == 3)	i = QSMACK_IMPULSE_4;
	else				i = QSMACK_IMPULSE_5;

	if (self.impulse != i)
		failing = 8;
	self.state = self.state + 1;

	if (self.state < 5)
	{
		// She still has impulses left to send.  Stuff
		// the next init alias and put the failure flag
		// back in self.state.
		s = ftos (self.state);
		self_stuffcmd (self, "init0");
		self_stuffcmd (self, s);
		self_stuffcmd (self, "\n");
		self.state = self.state + failing;
	}
	else
	{
		impulse_override_cancel ();
		// She's sent 5 impulses, they might have been
		// right or wrong.
		if (failing)
			admin_wrong_passcode ("Qsmack passcode", 0);
		else
			admin_init ();

	}
};

float ADMIN_PLAYER_TYPE_ANY		= 0;
float ADMIN_PLAYER_TYPE_PLAYER		= 1;
float ADMIN_PLAYER_TYPE_OBSERVER	= 2;

entity (float pt)
admin_player_pick =
{
	local entity e;

	if (!is_admin ())
		return world;

	if (is_player () && self.admin_victim_num)
		e = player_num_to_ent (self.admin_victim_num);
	else
		e = ridee ();

	if (!e)
		return world;

	if (is_admin_e (e))
	{
		self_sprint (self, "This client is an admin\n");
		return world;
	}

	if (pt == ADMIN_PLAYER_TYPE_PLAYER)
	{
		if (!is_player_e (e))
		{
			self_sprint (self, "This client isn't playing\n");
			return world;
		}
	}
	else if (pt == ADMIN_PLAYER_TYPE_OBSERVER)
	{
		if (!is_observer_e (e))
		{
			self_sprint (self, "This client isn't observing\n");
			return world;
		}
	}
	else if (pt != ADMIN_PLAYER_TYPE_ANY)
	{
		self_sprint (self, "Bug, invalid player type ");
		self_sprint_float (self,  pt);
		self_sprint (self, "\n");
		return world;
	}

	return e;
};

void ()
admin_eyes =
{
	local float n;
	local string s, s1;

	if (!is_admin ())
		return;
	if (!is_observer ())
		return;
	if (is_rider ())
		return;

	if (self.model == string_null)
	{
		s = "progs/eyes.mdl";
		s1 = " Visible eyes.\n";
		n = modelindex_eyes;
		self.items = self.items | IT_KEY1;
	}
	else
	{
		s = string_null;
		s1 = " Normal.\n";
		n = 0;
		self.items = self.items - self.items & IT_KEY1;
	}
	setmodel (self, s);

	IN_POQ([-
		self.modelindex = modelindex_eyes;
	-], [-
		self.modelindex = n;
	-])

	self_sprint (self, s1);
};

void (float cycle_show)
admin_cycle =
{
	local entity e;
	local string s;
	local float n;

	if (!is_admin ())
		return;
	if (!is_player ())
		return;

	n = self.admin_victim_num;
	if (cycle_show)
	{
		e = player_num_to_ent (n);
		if (e.classname != "player")
			e = world;
	}
	else
		e = admin_cycle_num_to_ent (n);

	n = player_ent_to_num (e);
	s = ftos (n);
	self.admin_victim_num = n;

	if (!e)
	{
		if (cycle_show)
			self_sprint (self, " Nobody selected\n");
		else
			self_sprint (self, " Nobody to select\n");
	}
	else
	{
		self_sprint (self, " #");
		self_sprint (self, s);
		self_sprint (self, "‘ ");
		self_sprint (self, e.netname);
		self_sprint (self, " selected\n");
	}
};

void ()
admin_join =
{
	local entity e, old_self;

	e = admin_player_pick (ADMIN_PLAYER_TYPE_OBSERVER);
	if (!e)
		return;

	old_self	= self;
	self		= e;

	obs_join_game (1);

	self		= old_self;
};

void ()
admin_kick =
{
	local entity e, old_self;

	e = admin_player_pick (ADMIN_PLAYER_TYPE_ANY);
	if (!e)
		return;

	old_self	= self;
	self		= e;

	if (old_self.impulse == IMP_ADMIN_KICK)
		kick ("by ", old_self.netname);

	self		= old_self;
};

void ()
admin_kill =
{
	local entity e, old_self;

	e = admin_player_pick (ADMIN_PLAYER_TYPE_PLAYER);
	if (!e)
		return;

	old_self	= self;
	self		= e;

	sure_kill ("admin-kill");

	self		= old_self;
};

void ()
admin_rename =
{
	local entity e;
	local string newname;

	e = admin_player_pick (ADMIN_PLAYER_TYPE_ANY);
	if (!e)
		return;

	sprint_admin2 (e.netname, " was renamed to ");
	self_stuffcmd (e, "name \"");
	newname = random_name ();
	self_stuffcmd (e, newname);
	self_stuffcmd (e, "\"\n");
	sprint_admin2 (newname, " by ");
	sprint_admin2 (self.netname, "\n");
};

void ()
admin_rune_delete =
{
	local entity e, old_self;

	e = admin_player_pick (ADMIN_PLAYER_TYPE_PLAYER);
	if (!e)
		return;

	if (e.deadflag)
		return;

	old_self	= self;
	self		= e;

	Rune_Activate (0, 1);

	self		= old_self;
};

void ()
admin_team_change =
{
	local entity e, old_self;

	e = admin_player_pick (ADMIN_PLAYER_TYPE_ANY);
	if (!e)
		return;

	old_self	= self;
	self		= e;

	team_rotate (old_self);

	self		= old_self;
};

void ()
admin_team_change_toggle =
{
	local string s;
	local float old, new;

	if (!is_admin ())
		return;

	old = teamplay & TEAM_CHANGE_MASK;
	teamplay = teamplay - old;
	if (old == TEAM_CHANGE_NONE)
	{
		new = TEAM_CHANGE_ANY;
		s = "Team changing enabled\n";
	}
	else if (old == TEAM_CHANGE_ANY)
	{
		new = TEAM_CHANGE_TOPDOG;
		s = "Team changing allowed for top dog only\n";
	}
	else
	{
		new = TEAM_CHANGE_NONE;
		s = "Team changing disabled\n";
	}
	teamplay = teamplay + new;
	change_teamplay (teamplay, 1);
	bprint (s);
};

void ()
admin_vote_team_toggle =
{
	if (!is_admin ())
		return;

	if (teamplay & TEAM_NO_VOTE)
		teamplay = teamplay - teamplay & TEAM_NO_VOTE;
	else
		teamplay = teamplay | TEAM_NO_VOTE;

	change_teamplay (teamplay, 1);
};

void ()
admin_teamplay_zero =
{
	if (is_admin ())
		change_teamplay (0, 1);
};

void ()
admin_unbind =
{
	local entity e;

	e = admin_player_pick (ADMIN_PLAYER_TYPE_ANY);
	if (!e)
		return;

	self_stuffcmd (e, "unbindall\n");
	self_stuffcmd (e, "sensitivity 0\n");
	sprint_admin2 (e.netname, "'s keys unbound by ");
	sprint_admin2 (self.netname, "\n");
};

void (string m)
admin_changelevel =
{
	bprint (self.netname);

	if (self.netname != string_null)
		bprint (" exited the level\n");

	forced_nextmap = m;
	NextLevel ();
};

void ()
admin_impulse_map =
{
	local string m;

	if (self.state)
	{
		self.impulse = self.impulse + 10 * self.state;
		self.state = 0;
	}
	else if (self.impulse >= 1 && self.impulse <= 5)
	{
		self.state = self.impulse;
		aq_menu_set (AQS_MENU_EPISODE + self.state);
		return;
	}
	else if (self.impulse == 6)
	{
		impulse_override_cancel ();
		aq_menu_set (0);
		admin_changelevel (string_null);
		return;
	}

	impulse_override_cancel ();
	aq_menu_set (0);
	m = impulse_to_map ();
	if (!m)
	{
		self_sprint (self, "Canceled, invalid map impulse ");
		self_sprint_float (self, self.impulse);
		self_sprint (self, "\n");
	}
	else
		admin_changelevel (m);
};

void ()
admin_change_map =
{
	if (!is_admin ())
		return;

	self.state	= 0;
	self.aqstate	= self.aqstate | AQS_IMPOVER_MAP;

	aq_menu_set (AQS_MENU_EPISODE);
};
