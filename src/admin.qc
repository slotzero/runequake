// $Id: admin.qc,v 1.3 2002/03/03 00:24:56 slotzero Exp $
//
// Copyright (c) 2001, 2002 Rune Quake Development Team.  All rights reserved.
// See the file `Copying' in the distribution for terms.

void ()
admin_Init =
{
	if (is_admin ())
	{
		sprint (self, "Admin mode already active\n");
		return;
	}

	admin_sprint2 (self.netname, " activated admin mode\n");
	self.aqflags = self.aqflags | AQ_ADMIN;
	player_init_impulse_alias ("admin-eyes",	IMP_ADMIN_EYES);
	player_init_impulse_alias ("admin-cycle",	IMP_ADMIN_CYCLE);
	player_init_impulse_alias ("admin-cycle-show",	IMP_ADMIN_CYCLE_SHOW);
	player_init_impulse_alias ("admin-forward",	IMP_ADMIN_FORWARD);
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
	sprint (self, "Admin mode activated\n");
};

void (string msg, float passcode)
admin_Wrong_Passcode =
{
	local float i;

	i = self.aqstate & AQS_ADMIN_ATTEMPTS_MASK;
	if (i == AQS_ADMIN_ATTEMPTS_MASK)
		kick ("for using an incorrect ", msg);
	else
	{
		admin_sprint2 (self.netname, " used the wrong admin passcode\n");
		sprint (self, "Invalid passcode ");
		if (passcode)
			self_sprint_float (self, passcode);
		sprint (self, "\n");
		self.aqstate = self.aqstate + AQS_ADMIN_ATTEMPTS_MULT;
	}
};

void (float tell, float mention_console)
admin_Toggle =
{
	if (is_admin ())
	{
		sprint (self, "Admin mode disabled\n");
		self.aqflags = self.aqflags - AQ_ADMIN;
		return;
	}

	if (self.aqflags & AQ_KICKED)
	{
		kick ("for trying to crack the admin passcode", string_null);
		return;
	}

	if (ADMIN_PASSCODE == 123456)
	{
		if (tell)
			sprint (self, "Admin passcode not configured\n");
		return;
	}

	if (ADMIN_PASSCODE < 100000 || ADMIN_PASSCODE > 888888)
	{
		if (tell)
			sprint (self, "Invalid admin passcode in settings.qc\n");
		return;
	}

	if (tell)
	{
		if (mention_console)
			sprint (self, "Close console and e");
		else
			sprint (self, "E");
		sprint (self, "nter admin passcode now\n");
	}
	self.aqstate = self.aqstate | AQS_IMPOVER_PASSWORD;
	self.state = 0;
};

void ()
admin_Impulse_Password =
{
	local string s;

	if (self.impulse < 1 || self.impulse > 8)
	{
		sprint (self, "Canceled, invalid passcode impulse ");
		sprint_float (self, self.impulse);
		sprint (self, "\n");
		impulse_override_cancel ();
		return;
	}

	s = ftos (self.impulse);
	self_sprint (self, "");
	self_sprint (self, s);
	self_sprint (self, "‘\n");
	self.state = self.state * 10 + self.impulse;
	self.impulse = 0;
	if (self.state > 99999)
	{
		local float passcode;

		passcode = self.state;
		self.state = 0;
		impulse_override_cancel ();
		if (passcode == ADMIN_PASSCODE)
		{
			self.aqstate = self.aqstate
				- self.aqstate & AQS_ADMIN_ATTEMPTS_MASK;
			admin_Init ();
		}
		else
			admin_Wrong_Passcode ("admin passcode", passcode);
	}
};

void ()
admin_Impulse_Qsmack_Password =
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
			admin_Wrong_Passcode ("Qsmack passcode", 0);
		else
			admin_Init ();

	}
};

float ADMIN_PLAYER_TYPE_ANY		= 0;
float ADMIN_PLAYER_TYPE_PLAYER		= 1;
float ADMIN_PLAYER_TYPE_OBSERVER	= 2;

entity (float pt)
admin_Player_Pick =
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
		sprint (self, "This client is an admin\n");
		return world;
	}

	if (pt == ADMIN_PLAYER_TYPE_PLAYER)
	{
		if (!is_player_e (e))
		{
			sprint (self, "This client isn't playing\n");
			return world;
		}
	}
	else if (pt == ADMIN_PLAYER_TYPE_OBSERVER)
	{
		if (!is_observer_e (e))
		{
			sprint (self, "This client isn't observing\n");
			return world;
		}
	}
	else if (pt != ADMIN_PLAYER_TYPE_ANY)
	{
		sprint (self, "Bug, invalid player type ");
		sprint_float (self,  pt);
		sprint (self, "\n");
		return world;
	}

	return e;
};

void ()
admin_Try_Eyes =
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

	sprint (self, s1);
};

void (float cycle_show)
admin_Try_Cycle =
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
		self_sprint5 (self, " #", s, "‘ ", e.netname, " selected\n");
};

void (float configured)
admin_Try_Forward =
{
	local entity e, old_self;

	e = admin_Player_Pick (ADMIN_PLAYER_TYPE_ANY);
	if (!e)
		return;
	if (!configured)
	{
		self_sprint (self, "Admin forward not configured\n");
		return;
	}
	old_self = self;
	self = e;
	sprint3 (old_self, "Attempting to forward ", self.netname, "\n");
	admin_forward_player ();
	self = old_self;
};

void ()
admin_Try_Join =
{
	local entity e, old_self;

	e = admin_Player_Pick (ADMIN_PLAYER_TYPE_OBSERVER);
	if (!e)
		return;
	old_self = self;
	self = e;
	obs_join_game (1);
	self = old_self;
};

void ()
admin_Try_Kick =
{
	local entity e, old_self;

	e = admin_Player_Pick (ADMIN_PLAYER_TYPE_ANY);
	if (!e)
		return;
	old_self = self;
	self = e;
	if (old_self.impulse == IMP_ADMIN_KICK)
		kick ("by ", old_self.netname);
	self = old_self;
};

void ()
admin_Try_Kill =
{
	local entity e, old_self;

	e = admin_Player_Pick (ADMIN_PLAYER_TYPE_PLAYER);
	if (!e)
		return;
	old_self = self;
	self = e;
	sure_kill ("admin-kill");
	self = old_self;
};

void ()
admin_Try_Rename =
{
	local entity e;
	local string newname;

	e = admin_Player_Pick (ADMIN_PLAYER_TYPE_ANY);
	if (!e)
		return;
	admin_sprint2 (e.netname, " was renamed to ");
	self_stuffcmd (e, "name \"");
	newname = random_name ();
	self_stuffcmd (e, newname);
	self_stuffcmd (e, "\"\n");
	admin_sprint2 (newname, " by ");
	admin_sprint2 (self.netname, "\n");
};

void ()
admin_Try_Rune_Delete =
{
	local entity e, old_self;

	e = admin_Player_Pick (ADMIN_PLAYER_TYPE_PLAYER);
	if (!e)
		return;
	if (e.deadflag)
		return;
	old_self = self;
	self = e;
	Rune_Activate (0, 1);
	self = old_self;
};

void ()
admin_Try_Team_Change =
{
	local entity e, old_self;

	e = admin_Player_Pick (ADMIN_PLAYER_TYPE_ANY);
	if (!e)
		return;
	old_self = self;
	self = e;
	team_rotate (old_self);
	self = old_self;
};

void ()
admin_Try_Team_Change_Toggle =
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
admin_Try_Vote_Team_Toggle =
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
admin_Try_Teamplay_Zero =
{
	if (is_admin ())
		change_teamplay (0, 1);
};

void ()
admin_Try_Unbind =
{
	local entity e;

	e = admin_Player_Pick (ADMIN_PLAYER_TYPE_ANY);
	if (!e)
		return;
	self_stuffcmd (e, "unbindall\n");
	self_stuffcmd (e, "sensitivity 0\n");
	admin_sprint2 (e.netname, "'s keys unbound by ");
	admin_sprint2 (self.netname, "\n");
};

void (string m)
admin_Try_Changelevel =
{
	bprint (self.netname);
	if (self.netname != string_null)
		bprint (" exited the level\n");
	forced_nextmap = m;
	NextLevel ();
};

void ()
admin_Try_Impulse_Map =
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
		admin_Try_Changelevel (string_null);
		return;
	}

	impulse_override_cancel ();
	aq_menu_set (0);
	m = impulse_to_map ();
	if (!m)
	{
		sprint (self, "Canceled, invalid map impulse ");
		sprint_float (self, self.impulse);
		sprint (self, "\n");
	}
	else
		admin_Try_Changelevel (m);
};

void ()
admin_Try_Change_Map =
{
	if (!is_admin ())
		return;

	self.state = 0;
	self.aqstate = self.aqstate | AQS_IMPOVER_MAP;
	aq_menu_set (AQS_MENU_EPISODE);
};
