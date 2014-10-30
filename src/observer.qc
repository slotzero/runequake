/*
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

float (entity e)
is_admin_e =
{
	return e.aqflags & AQ_ADMIN;
};

float ()
is_admin =
{
	return is_admin_e (self);
};

float (entity e)
is_qsmack_e =
{
	return e.aqflags & AQ_QSMACK;
};

float ()
is_qsmack =
{
	return is_qsmack_e (self);
};

float (entity e)
is_player_e =
{
	return is_valid_player_e (e) && !e.aqflags & AQ_OBSERVER;
};

float ()
is_player =
{
	return is_player_e (self);
};

float (entity e)
is_observer_e =
{
	return is_valid_player_e (e) && e.aqflags & AQ_OBSERVER;
};

float ()
is_observer =
{
	return is_observer_e (self);
};

float ()
is_rider =
{
	return is_observer () && self.owner != world;
};

entity (entity e)
ridee_e =
{
	if (is_observer_e (e))
		return e.owner;
	else
		return world;
};

entity ()
ridee =
{
	return ridee_e (self);
};

float (float tell_type)
corpse_to_observer =
{
	CopyToBodyQue (self);
	obs_become (tell_type);
	obs_process_game_queue ();

	if (self.items | IT_KEY2)
		self.items = self.items - self.items & IT_KEY2;

	return 1;
};

void ()
dead_impulses =
{
	if (self.aqstate & AQS_IMPOVER_MASK)
		impulse_override ();

	else if (self.impulse == 4)
	{
		if (self.aqflags & AQ_NO_WEAPON_TOGGLE || gamemode == MODE_MATCH)
			self_sprint (self, "Menu observer disabled, type \bobserver\b in console instead.\n");
		else
			corpse_to_observer (1);
	}

	// Allow dead people to remove a phoenix rune, to avoid somebody
	// waiting for them to spawn.
	else if (self.impulse == IMP_RUNE_DELETE && self.runetype == RN_PHOENIX)
	{
		self.runetype = 0;
		centerprint (self, "Rune Removed");
	}

	else
		common_impulses ();

	self.impulse = 0;
};

void ()
obs_impulses =
{
	local float m;

	m = aq_menu_get ();

	if (self.aqstate & AQS_IMPOVER_MASK)
		impulse_override ();

	// help impulses
	else if (m >= AQS_MENU_HELP_FIRST && m <= AQS_MENU_HELP_LAST)
	{
		if (self.impulse == 1)
			aq_menu_set (AQS_MENU_MAIN);
		else if (self.impulse == 2)
			aq_menu_next (1);
		else if (self.impulse == 3)
			aq_menu_next (-1);
		else
			common_impulses ();
	}

	else if (m == AQS_MENU_ADMIN)
	{
		if (self.impulse == 1)
		{
			aq_menu_set (AQS_MENU_MAIN);
			self.impulse = 0;
		}
		else if (self.impulse == 2)
			aq_menu_set (AQS_MENU_ADMIN_ACTION);
		else if (self.impulse == 3)
			aq_menu_set (AQS_MENU_ADMIN_TEAMPLAY);
		else if (self.impulse == 4)
			self.impulse = IMP_ADMIN_CHANGE_MAP;
		else if (self.impulse == 5)
			self.impulse = IMP_ADMIN_EYES;

		if (self.impulse >= 4)
			admin_impulse_commands ();
		else
			common_impulses ();
	}

	else if (m == AQS_MENU_ADMIN_ACTION)
	{
		if (self.impulse == 1)
		{
			aq_menu_set (AQS_MENU_ADMIN);
			self.impulse = 0;
		}
		else if (self.impulse == 2)
			self.impulse = IMP_ADMIN_KILL;
		else if (self.impulse == 3)
			self.impulse = IMP_ADMIN_KICK;
		else if (self.impulse == 4)
			self.impulse = IMP_ADMIN_RUNE_DELETE;
		else if (self.impulse == 5)
			self.impulse = IMP_ADMIN_UNBIND;
		else if (self.impulse == 6)
			self.impulse = IMP_ADMIN_RENAME;
		else if (self.impulse == 7)
			self.impulse = IMP_ADMIN_JOIN;

		if (self.impulse)
			admin_impulse_commands ();
	}

	else if (m == AQS_MENU_ADMIN_TEAMPLAY)
	{
		if (self.impulse == 1)
		{
			aq_menu_set (AQS_MENU_ADMIN);
			self.impulse = 0;
		}
		else if (self.impulse == 2)
			self.impulse = IMP_ADMIN_VOTE_TEAM_TOGGLE;
		else if (self.impulse == 3)
			self.impulse = IMP_ADMIN_TEAM_CHANGE_TOGGLE;
		else if (self.impulse == 4)
			self.impulse = IMP_ADMIN_TEAMPLAY_ZERO;
		else if (self.impulse == 5)
			self.impulse = IMP_ADMIN_TEAM_CHANGE;

		if (self.impulse)
			admin_impulse_commands ();
	}

	// observer/rider impulses
	else
	{
		if (self.impulse == 1)
		{
			// If the menu is up, go to instructions,
			if (m == AQS_MENU_MAIN)
				aq_menu_set (AQS_MENU_HELP_FIRST);
			// else put the menu up.
			else
				aq_menu_set (AQS_MENU_MAIN);
		}

		// This command, which would more naturally come after the
		// credits, is purposefully left on key 2.  This is to cater
		// to people who have weapons sensing commands bound to the
		// standard weapon selection impulse keys.  This way the last
		// weapon impulse typed before entering the game is 2, which
		// selects the shotgun.
		else if (self.impulse == 2)
			obs_join_game (self.aqflags & AQ_ADMIN);

		else if (self.impulse == 3)
			aq_menu_set (AQS_MENU_CREDITS);

		else if (self.impulse == 4)
		{
			aq_menu_set (0);
			obs_rider_off (1);
		}

		else if (self.impulse == 5)
		{
			aq_menu_set (0);
			// Don't switch ridees if the menu was up and you were
			// already riding.
			if (!m || self.owner == world)
				obs_rider_next ();
		}

		else if (self.impulse == 6)
		{
			if (self.aqflags & AQ_ADMIN)
				aq_menu_set (AQS_MENU_ADMIN);
			else
				admin_toggle (1, 0);
		}

		else if (self.impulse == 7)
		{
			self.impulse = IMP_WEAPON_TOGGLES;
			common_impulses ();
		}

		else if (self.impulse == IMP_RUNE_TELL && self.owner != world)
			rune_tell_toggle (0, self.owner);

		else
			common_impulses ();
	}

	self.impulse = 0;
};

void ()
obs_fly =
{
	local float invcos, nvp, nvpmax, sp, svz;
	local vector f, vp, vs;

	if (self.velocity == VEC_ORIGIN)
		return;

	if (pointcontents (self.origin) != CONTENT_EMPTY)
	{
		if (pointcontents (self.origin) != CONTENT_SOLID)
		{
			self.waterlevel = 3;
			self.watertype = pointcontents (self.origin);
			self.flags = self.flags | FL_INWATER;
		}
	}
	else
	{
		if (self.waterlevel == 3)
		{
			if (pointcontents (self.origin) == CONTENT_EMPTY)
			{
				self.waterlevel = 0;
				self.flags = self.flags - FL_INWATER;
			}
		}
	}

	self.flags = self.flags | FL_ONGROUND;

	svz = self.velocity_z * 0.75;
	self.velocity_z = 0;

	// v_forward is already normalized
	makevectors (self.v_angle);
	f_x = v_forward_x;
	f_y = v_forward_y;
	f_z = 0;
	invcos = vlen (f);
	if (invcos)
		invcos = 1 / invcos;
	else
		invcos = 0;
	f = f * invcos; // normalize f

	sp = f * self.velocity;
	vp = sp*f;
	nvp = vlen (vp);
	if (sp<0)
		nvp = 0 - nvp;
	vs = self.velocity - vp;

	vp = v_forward * (nvp * invcos);
	vp_z = vp_z + svz;
	nvp = vlen (vp);
	nvpmax = (320 - 100*(v_forward * '0 0 1'));
	if (nvp > nvpmax)
		vp = vp * (nvpmax/nvp);

	self.velocity = vp + vs;
};

void ()
obs_pre_think =
{
	local entity e;

	// XXX server-modules does this, I don't know why
	self.flags = self.flags | FL_ONGROUND;

	if (!self.owner)
	{
		if (self.button2)
			self.velocity_z = self.velocity_z + 270;
		obs_fly ();
		IN_POQ([-
			if (self.button0)
				self.velocity = self.velocity * 2;
		-])

		// Activate teleporters.
		e = findradius (self.origin, 75);
		while (e)
		{
			if (e.classname == "trigger_teleport"
					|| (e.touch == teleport_touch && e.classname == "trigger_changelevel"))
			{
				observer_teleport (e);
				e = world;
			}
			else
				e = e.chain;
		}

		// Identify players as observer.
		if (!self.aqflags & AQ_QUIET)
			obs_player_detect ();
	}
};

void ()
obs_post_think =
{
	self.frame = 0;

	if (self.impulse)
		obs_impulses ();

	if (self.owner)
	{
		local vector newpos;

		IN_POQ([-
			if (MOD_PROTOCOL)
			{
				if (self.owner.viewentity)
				{
					if (self.viewentity != self.owner.viewentity)
						set_viewport (self.owner.viewentity);
				}
				else if (self.viewentity != self.owner)
					set_viewport (self.owner);

				if (self.view_ofs != self.owner.view_ofs)
					self.view_ofs = self.owner.view_ofs;
			}
			// Place the eyes a little below the ridee.
			// Originally I placed them a little behind, but
			// then they were sometimes visible when the
			// ridee ran backwards.  They're still sometimes
			// visible, but less often.
			//
			// '0 0 30' is the better general settings (the
			// eyes are visible less often), but in waist
			// deep water the rider can be in a different
			// vis area than the ridee (eg, looking at the
			// grenade launcher in e2m4), so I need to put
			// the eyes a little higher.
			if (self.owner.waterlevel > 0 && self.owner.waterlevel < 3)
				newpos = self.owner.origin - '0 0 20';
			else
				newpos = self.owner.origin - '0 0 30';
		-], [-
			newpos = self.owner.origin + '0 0 15';
		-])
		if (self.origin != newpos)
		{
			setorigin (self, newpos);
			trackvel (self.owner);
		}

		if (!self.button0)
		{
			local vector angle;

			// Support for pq_smoothcam.
			angle_x = 360.0 / 256.0 * rint(self.owner.v_angle_x * 256.0 / 360.0);
			angle_y = 360.0 / 256.0 * rint(self.owner.v_angle_y * 256.0 / 360.0);
			angle_z = 0;

			self.angles = angle - '0.1 0.1 0.1';
			self.angles_z = 0;
			self.fixangle = TRUE;

			// This worked on all of my local linux and windows dedicated
			// servers but didn't on Shmack.
			/* msg_entity = self;
			WriteByte (MSG_ONE, SVC_SETANGLE);
			WriteAngle (MSG_ONE, self.owner.v_angle_x);
			WriteAngle (MSG_ONE, self.owner.v_angle_y);
			WriteAngle (MSG_ONE, 0); */
		}

		/* if (self.angles != self.owner.v_angle)
		{
			self.angles = self.owner.v_angle;
			self.fixangle = 1;
		} */

		// What controls when these are sent to the client?  Is
		// it useless to avoid setting them in this way?

		IN_POQ([-
			if (self.punchangle != self.owner.punchangle)
				self.punchangle = self.owner.punchangle;
		-])
		if (self.weapon != self.owner.weapon)
			self.weapon = self.owner.weapon;
		if (self.weaponmodel != self.owner.weaponmodel)
			self.weaponmodel = self.owner.weaponmodel;
		if (self.weaponframe != self.owner.weaponframe)
			self.weaponframe = self.owner.weaponframe;

		if (!self.owner.aqflags & AQ_RIDER_HIDE || !ALLOW_RIDER_HIDE)
		{
			if (deathmatch & DM_DM_MASK)
			{
				if (self.items | IT_KEY2 != self.owner.items | IT_KEY2)
				{
					self.items = self.owner.items
						- (self.owner.items & IT_KEY2)
						+ (self.items & IT_KEY2);
				}
			}
			else
			{
				if (self.items != self.owner.items)
					self.items = self.owner.items;
			}
			if (self.health != self.owner.health)
				self.health = self.owner.health;
			if (self.currentammo != self.owner.currentammo)
				self.currentammo = self.owner.currentammo;
			if (self.ammo_shells != self.owner.ammo_shells)
				self.ammo_shells = self.owner.ammo_shells;
			if (self.ammo_nails != self.owner.ammo_nails)
				self.ammo_nails = self.owner.ammo_nails;
			if (self.ammo_rockets != self.owner.ammo_rockets)
				self.ammo_rockets = self.owner.ammo_rockets;
			if (self.ammo_cells != self.owner.ammo_cells)
				self.ammo_cells = self.owner.ammo_cells;
			if (self.armortype != self.owner.armortype)
				self.armortype = self.owner.armortype;
			if (self.armorvalue != self.owner.armorvalue)
				self.armorvalue = self.owner.armorvalue;
		}

		if ((self.runetime > 0 && time > self.runetime) || self.runetime == -2)
		{
			if (deathmatch & DM_DM_MASK)
			{
				// Don't key admin observers (only admin obs can ride obs).
				if (!is_observer_e (self.owner))
					self.owner.items = self.owner.items | IT_KEY2;
			}

			self_sprint (self.owner, "Rider ");
			self_sprint (self.owner, self.netname);
			self_sprint (self.owner, " acquired\n");
			if (self.runetime != -2)
			{
				sprint (self, "Notified ");
				sprint (self, self.owner.netname);
				sprint (self, " of new rider\n");
			}
			self.runetime = -1;
		}
	}
};

void ()
obs_init_hidables =
{
	if (deathmatch & DM_DM_MASK)
		self.items	= self.items & IT_KEY2;
	else
		self.items	= 0;

	self.health		= 999;
	self.currentammo	= 0;
	self.ammo_shells	= 0;
	self.ammo_nails		= 0;
	self.ammo_rockets	= 0;
	self.ammo_cells		= 0;
	self.armortype		= 0;
	self.armorvalue		= 0;
};

void (float tell_type)
obs_become =
{
	if (tell_type == 1)
	{
		bprint (self.netname);
		bprint (" became an observer\n");

		// Reset arena entity when arena player goes observer.
		if (gamemode & MODE_ARENA)
		{
			if (arena.owner == self || arena.runent == self)
			{
				if (arena.owner == self)
					arena.owner = world;
				else if (arena.runent == self)
					arena.runent = world;

				if (arena.runent)
				{
					arena.owner = arena.runent;
					arena.runent = world;
				}
			}
		}
	}
	else if (tell_type == 2)
	{
		bprint (self.netname);
		bprint (" became an observer for idling as a corpse\n");
	}

	// Reset cshift for when you drop off riding someone who is
	// cshifted.
	stuffcmd (self, CSHIFT_NONE);

	// observer resets negative frags automatically
	if (self.frags < 0)
		self.frags = 0;

	if (!is_observer ())
	{
		if (gamemode & MODE_ARENA && tell_type == 3)
			self.runevar = time;
		else
			self.runevar = 0;
	}
	self.aqflags		= self.aqflags | AQ_OBSERVER;
	self.flags		= self.flags | FL_OBSERVER;
	// Look for classname tests if you try changing this.
	//self.classname	= "observer";
	self.owner		= world;
	self.runetype		= 0;

	// if 0 not a rider or rider but admin, if positive, time to
	// notify ridee, if -1 ridee already notified, if -2 notify
	// ridee immediately but don't tell rider about it
	self.runetime		= 0;

	self.takedamage		= DAMAGE_NO;
	self.solid		= SOLID_NOT;
	self.movetype		= MOVETYPE_NOCLIP;
	self.deadflag		= DEAD_NO;
	self.view_ofs		= PLAYER_VIEW_OFFSET;
	self.weapon		= 0;
	self.weaponmodel	= string_null;
	self.weaponframe	= 0;
	self.flags		= self.flags | FL_ONGROUND;	// XXX why?
	IN_POQ([-
		self.punchangle	= VEC_ORIGIN;
	-])
	obs_init_hidables ();

	// In POQ, if you just set your model to "" you can't move
	// around for some reason.  If you set your model to "" but set
	// your modelindex to a real model only your client draws you
	// as the other model (other clients don't see you at all) and
	// movement works normally.
	//
	// This is only a problem for rider mode, because in rider mode
	// I alter your viewport to be the player you're chasing, so you
	// are able to see yourself (and your client draws you with the
	// model in your modelindex).  I mostly work around this by
	// placing you a little bit below the player you are chasing.
	// (It's necessary to update your position anyway, because your
	// viewport entity has to be in the same vis area as yourself.)
	setmodel (self, string_null);
	IN_POQ([-
		self.modelindex = modelindex_eyes;
	-])

	// Reset the viewport, for when I'm switching from rider to
	// observer mode.
	set_viewport (self);

	if (gamemode == MODE_MATCH)
		match_obs_become (tell_type);
	else if (enforced_teams ())
		assign_teams (self);

	lose_riders ();
};

// The ideas in this function were largely stolen from Server Modules.

void (entity tele)
observer_teleport =
{
	local vector v1, v2;
	local entity targ;

	v1 = ((tele.absmax + tele.absmin) * 0.5) - self.origin;
	v2 = self.velocity;
	normalize (v1);
	normalize (v2);
	if (v1 * v2 <= 0.1)
		return;

	if (!tele.target)
	{
		if (last_teleport)
			targ = last_teleport;
		else
			targ = find_info_teleport_destination ();
	}
	else
		targ = find (world, targetname, tele.target);

	if (!targ)
	{
		dprint ("teleport_touch(): couldn't find target!\n");
		return;
	}

	setorigin (self, targ.origin);
	self.angles		= targ.mangle;
	self.fixangle		= 1;
	makevectors (targ.mangle);
	self.velocity		= v_forward * 300;
	self.teleport_time	= time + 0.7;
};

void ()
obs_player_detect =
{
	local entity wanted, tempe;
	local float area, tempf;
	local vector vec;
	local string s, s1, s2, s3;

	if (self.model != string_null)
		s3 = "\nvisible eyes";
	else
		s3 = string_null;

	wanted = findradius (self.origin, 600);
	while (wanted)
	{
		if (wanted != self && (wanted.classname == "player"
				|| wanted.classname == "shambler_slave"
				|| wanted.classname == "zombie_camper"))
		{
			traceline (self.origin, wanted.origin, TRUE, self);
			if (trace_fraction >= 1)
			{
				// Since obs_fly() calls makevectors() every frame when you're
				// moving, I only call it when you're not moving.
				if (self.velocity == VEC_ORIGIN)
					makevectors (self.v_angle);
				vec = normalize (wanted.origin - self.origin);
				area = vec * v_forward;

				if ( area > 0.85 )
				{
					if (area > tempf)
					{
						tempf = area;
						tempe = wanted;
					}
				}
			}
		}
		wanted = wanted.chain;
	}
	wanted = tempe;

	if (wanted)
	{
		if (wanted.classname == "player")
		{
			s = string_null;
			s1 = wanted.netname;
			s2 = Rune_Tell_real (0, wanted.runetype, 0, 2);
			if (s2 == "No Rune")
				s2 = string_null;
		}
		else if (wanted.classname == "shambler_slave")
		{
			s = wanted.owner.netname;
			s1 = "'s Shambler";
			s2 = string_null;
		}
		else if (wanted.classname == "zombie_camper")
		{
			s = wanted.owner.netname;
			s1 = "'s Zombie";
			s2 = string_null;
		}

		if (!self.aqstate & AQS_MENU_MASK && (self.class_cnt < time || wanted != self.aiment))
		{
			if (!s2)
				s2 = " ";
			centerprint5 (self, s, s1, "\n\n", s2[%1], s3);
			self.class_cnt = time + CENTERPRINT_REFRESH;
			self.aiment = wanted;
		}

		if (!wanted.aqflags & AQ_RIDER_HIDE || !ALLOW_RIDER_HIDE)
		{
			if (self.items != wanted.items)
				self.items = wanted.items;
			if (self.health != wanted.health)
				self.health = wanted.health;
			if (self.currentammo != wanted.currentammo)
				self.currentammo = wanted.currentammo;
			if (self.ammo_shells != wanted.ammo_shells)
				self.ammo_shells = wanted.ammo_shells;
			if (self.ammo_nails != wanted.ammo_nails)
				self.ammo_nails = wanted.ammo_nails;
			if (self.ammo_rockets != wanted.ammo_rockets)
				self.ammo_rockets = wanted.ammo_rockets;
			if (self.ammo_cells != wanted.ammo_cells)
				self.ammo_cells = wanted.ammo_cells;
			if (self.armortype != wanted.armortype)
				self.armortype = wanted.armortype;
			if (self.armorvalue != wanted.armorvalue)
				self.armorvalue = wanted.armorvalue;
		}
	}
	else
	{
		if (self.class_cnt < 0 || self.class_cnt > time)
			return;

		if (self.health != 999)
		{
			self.aiment = world;
			self.items = 0;
			obs_init_hidables ();
			if (s3)
				self.items = self.items | IT_KEY1;
		}

		if (!self.aqstate & AQS_MENU_MASK)
		{
			centerprint (self, string_null);
			self.class_cnt = -1;
		}
	}
};

float (entity e)
game_queue_pos_e =
{
	local float epos;
	local entity ie;

	epos = 1;
	ie = find (world, classname, "player");
	while (ie)
	{
		if (is_observer_e (ie) && ie.runevar && ie.runevar < e.runevar)
			epos = epos + 1;
		ie = find (ie, classname, "player");
	}
	return epos;
};

float ()
game_queue_len =
{
	local float qlen;
	local entity e;

	qlen = 0;
	e = find (world, classname, "player");
	while (e)
	{
		if (is_observer_e (e) && e.runevar)
			qlen = qlen + 1;
		e = find (e, classname, "player");
	}
	return qlen;
};

void (float force)
obs_join_game =
{
	local float maxp, i, ra, mm;
	local string s1, s2, sx;

	ra = gamemode & MODE_ARENA;

	mm = gamemode == MODE_MATCH;
	if (mm)
	{
		if (match_obs_join_game ())
			force = 1;
		else
			return;
	}

	if (!force && self.runevar)
	{
		if (self.runevar > time)
		{
			bprint ("bug: runevar for ");
			bprint (self.netname);
			bprint (" is in the future (");
			bprint_float (self.runevar);
			bprint (")\n");
		}

		if (ra)
		{
			self.runevar = 0;
			self_sprint (self, "you are \bout\b of line\n");
			return;
		}
		else
		{
			self_sprint (self, "Current game queue position ");
			i = game_queue_pos_e (self);
			self_sprint_float (self, i);
			self_sprint (self, " of ");
			i = game_queue_len ();
			self_sprint_float (self, i);
			self_sprint (self, "\n");
		}

		if (time <= LEVEL_RECONNECT_ALLOWANCE)
		{
			self_sprint (self, "Game will open in ");
			i = LEVEL_RECONNECT_ALLOWANCE - time;
			i = floor (i);
			self_sprint_float (self, i);
			self_sprint (self, " second");
			if (i != 1)
				self_sprint (self, "s");
			self_sprint (self, "\n");
		}
		return;
	}

	// Just queue if this is the very start of a level, so that you
	// can't join what is really a full game before the players
	// arrive.
	if (!force && time <= LEVEL_RECONNECT_ALLOWANCE && !temp1 & T1_RUNE_CHEAT)
	{
		self.runevar = time;

		if (ra)
			arena_game_pos_announce (self);
		else
		{
			bprint (self.netname);
			bprint (" queued for game at start of level\n");
		}
		return;
	}

	// Make sure not to cut in line.
	if (!force)
		obs_process_game_queue ();

	maxp = max_players ();
	if (!force && maxp && count_players (0) >= maxp)
	{
		self.runevar = time;

		if (ra)
			arena_game_pos_announce (self);
		else
		{
			bprint (self.netname);
			bprint (" queued for game, position ");
			i = game_queue_pos_e (self);
			bprint_float (i);
			bprint ("\n");
		}
		return;
	}

	aq_menu_set (0);
	obs_rider_off (2);
	self.aqflags = self.aqflags - AQ_OBSERVER;
	self.flags = self.flags - self.flags & FL_OBSERVER;
	set_viewport (self);
	SetParms ();
	PutClientInServer ();

	if (!ra && !mm)
	{
		bprint (self.netname);
		bprint (" joined the game\n");
	}

	if (self.items & IT_KEY2)
		self.items = self.items - self.items & IT_KEY2;
	if (teamplay & TEAM_TEAM_MASK)
	{
		describe_team_mode ();
		s1 = "\bteam";
	}
	if (enforced_teams ())
		assign_teams (self);
	if (gamemode == MODE_PRACTICE)
		s2 = "\bpractice";

	if (s1 != string_null || s2 != string_null)
	{
		if (s1 != string_null && s2 != string_null)
			sx = " ";
		centerprint5 (self, "\b\<", s1, sx, s2, "\b mode\>");
	}
};

void ()
obs_process_game_queue =
{
	local float maxp, curp, any;
	local entity e, ehead;

	if (time <= LEVEL_RECONNECT_ALLOWANCE)
		return;

	maxp = max_players ();
	curp = count_players (0);

	while (maxp == 0 || curp < maxp)
	{
		any = 0;
		ehead = world;
		e = find (world, classname, "player");
		while (e)
		{
			if (is_observer_e (e) && e.runevar)
			{
				any = 1;
				if (ehead == world || e.runevar < ehead.runevar)
					ehead = e;
			}
			e = find (e, classname, "player");
		}
		if (!any)
			return;

		e = self;
		self = ehead;
		if (intermission_running)
		{
			self.aqflags = self.aqflags - AQ_OBSERVER;
			self.flags = self.flags - self.flags & FL_OBSERVER;
		}
		else
		{
			obs_join_game (1);
			self_sound (self, "boss2/pop2.wav");
		}
		self = e;
		curp = curp + 1;
	}
};

void (float tell)
obs_rider_drop =
{
	local entity old;

	Weird_AllOff ();
	old = self.owner;
	if (old)
	{
		self.owner = world;
		if (self.runetime == -1 && tell)
		{
			self_sprint (old, "Rider ");
			self_sprint (old, self.netname);
			self_sprint (old, " dropped\n");
		}
		self.runetime = 0;
		set_has_riders_e (old);
		if (!old.aqstate & AQS_HAS_RIDERS && deathmatch & DM_DM_MASK)
			old.items = old.items - (old.items & IT_KEY2);
	}
};

void (float tell)
obs_rider_off =
{
	if (self.owner)
	{
		setorigin (self, self.owner.origin);
		self.aqstate = self.aqstate - self.aqstate & AQS_RIDE_MASK;
		obs_rider_drop (tell);
		if (tell == 1)
			sprint (self, "Rider mode canceled\n");

		// Check to make sure you're not joining the game before calling
		// obs_become().  This would cause frags to be -99 when joining
		// the game in match mode.
		if (tell != 2)
			obs_become (0);
	}
};

void (entity e, float tell)
obs_rider_set =
{
	obs_rider_drop (tell);
	self.owner = e;
	self.owner.aqstate = self.owner.aqstate | AQS_HAS_RIDERS;
	sprint (self, "Now riding ");
	show_ridee ();
	sprint (self, "\n");
	if (self.owner.aqflags & AQ_NO_HUD)
		Rune_Tell (1, self.owner, self.owner.runetype, self.owner.aqflags & AQ_HOOK);
	else
		draw_hud_e (self.owner, 1);
	if (!self.aqflags & AQ_ADMIN || self.owner.aqflags & AQ_ADMIN)
	{
		// Tell about ridees acquired via tracking right away.
		if (tell == 2)
			self.runetime = -2;
		else
			self.runetime = time + 5;
	}

	// prevent ridee notification
	if (self.aqflags & AQ_RIDER_HIDE)
		self.runetime = 0;

	// This prevents you from moving around and seeing
	// yourself, and from bobbing your display as you try
	// to move.
	self.movetype = MOVETYPE_NONE;
	setorigin (self, self.owner.origin);
	self.angles = self.owner.v_angle;
	self.fixangle = 1;
	set_viewport (self.owner);
	obs_init_hidables ();
};

entity ()
ridee_pick =
{
	local entity e, best_e;
	local float is_fast, this_f, best_f;

	is_fast = self.aqstate & AQS_RIDE_MASK == AQS_RIDE_FAST;
	best_e = world;
	best_f = -9999;

	// If she already has a ridee, prefer that one in case of ties.
	//
	// Note this failed when these two calls were in the same
	// expression.
	if (is_player_e (self.owner))
	{
		best_e = self.owner;
		if (is_fast)
			best_f = self.owner.frag_rate;
		else
			best_f = self.owner.frags;
	}

	e = find (world, classname, "player");
	while (e)
	{
		if (is_fast)
			this_f = e.frag_rate;
		else
			this_f = e.frags;
		if (e != self && this_f > best_f && is_player_e (e))
		{
			best_e = e;
			best_f = this_f;
		}
		e = find (e, classname, "player");
	}

	return best_e;
};

void ()
high_track_recalc =
{
	local entity old_self, topdog;

	// Don't do the recalc at the start of a level, otherwise you
	// end up bouncing around several times for the first few frags.
	if (time < 90)
		return;

	topdog = world;
	old_self = self;
	self = find (world, classname, "player");
	while (self)
	{
		if (is_observer ()
			&& self.aqstate & AQS_RIDE_MASK == AQS_RIDE_HIGH)
		{
			if (!topdog)
				topdog = ridee_pick ();
			if (topdog != self.owner)
				obs_rider_set (topdog, 2);
		}
		self = find (self, classname, "player");
	}

	self = old_self;
};

void ()
update_frag_rates =
{
	local entity e, best_e, old_self;

	self.nextthink = update_frag_rates_time = time + 60;

	best_e = world;
	e = find (world, classname, "player");
	while (e)
	{
		if (is_player_e (e))
		{
			e.frag_rate = e.frag_rate
				+ 0.25 * (e.recent_frags - e.frag_rate);
			e.recent_frags = 0;
			if (!best_e || e.frag_rate > best_e.frag_rate)
				best_e = e;
		}
		e = find (e, classname, "player");
	}

	old_self = self;
	self = find (world, classname, "player");
	while (self)
	{
		if (is_observer ()
			&& self.aqstate & AQS_RIDE_MASK == AQS_RIDE_FAST)
		{
			if (self.owner.frag_rate < best_e.frag_rate)
				obs_rider_set (best_e, 2);
		}
		self = find (self, classname, "player");
	}
	self = old_self;
};

void ()
obs_rider_next =
{
	local float orig_ride_type;
	local entity new;

	orig_ride_type = self.aqstate & AQS_RIDE_MASK;
	self.aqstate = self.aqstate - orig_ride_type;
	new = world;

	// If she wasn't riding anybody, go into fast track mode.
	if (self.owner == world)
	{
		self.aqstate = self.aqstate | AQS_RIDE_FAST;
		new = ridee_pick ();
		if (!new)
			self.aqstate = self.aqstate - AQS_RIDE_FAST;

		// If admin observer has eyes visible, turn them off
		// when she rides.
		if (self.model != string_null)
		{
			setmodel (self, string_null);
			self.modelindex = modelindex_eyes;
		}
	}

	// else if she was in fast track mode, switch to high track.
	else if (orig_ride_type == AQS_RIDE_FAST)
	{
		self.aqstate = self.aqstate | AQS_RIDE_HIGH;
		new = ridee_pick ();
		if (!new)
			self.aqstate = self.aqstate - AQS_RIDE_HIGH;
	}

	if (!new)
	{
		new = find (self.owner, classname, "player");
		while (new != self.owner
			&& (!is_valid_player_e (new)
				|| new == self
				// XXX I'd like this to be possible, but
				// it doesn't work as-is.  It's allowed
				// for admins anyway so they can kick
				// observers and such.
				|| (is_observer_e (new) && !self.aqflags & AQ_ADMIN)))
			new = find (new, classname, "player");
	}

	if (new == self.owner)
	{
		if (self.owner == world)
			sprint (self, "Nobody to ride\n");
		else if (orig_ride_type)
		{
			sprint (self, "Still riding ");
			show_ridee ();
			sprint (self, "\n");
		}
		else
			sprint (self, "Nobody else to ride\n");
	}
	else
		obs_rider_set (new, 1);
};

// When you enter a level and you'd been riding somebody on the previous
// level, you might arrive before your ridee does.  If I just blindly
// set you to riding the entity that player is going to get when she
// connects the set_viewport() won't actually work.  So, I set up an
// entity to watch for your ridee to show up and then sets you to riding
// her.

void ()
rider_wait_think =
{
	local entity old_self;

	// Give up waiting after a while.
	if (time > self.runetime)
	{
		remove (self);
		return;
	}

	// Make sure the rider is still an observer.
	if (is_player_e (self.owner))
	{
		remove (self);
		return;
	}

	if (!is_valid_player_e (self.enemy))
	{
		// If rider is in fast/high track mode, give up after a bit
		// and try to find a new ridee.
		if (self.runetime - time < 9)
		{
			if (self.owner.aqstate & AQS_RIDE_MASK)
				self.enemy = ridee_pick ();
		}

		self.nextthink = time + 1;
		return;
	}

	old_self = self;
	self = old_self.owner;

	// If you're riding somebody already you might have done that
	// manually or tracking might have done it for you.  In either
	// case don't switch again.
	if (!self.owner)
		obs_rider_set (old_self.enemy, 0);

	remove (old_self);
};

void (entity e)
set_has_riders_e =
{
	local entity o;
	local float any;

	any = 0;
	o = find (world, classname, "player");
	while (o != world && !any)
	{
		if (ridee_e (o) == e)
			any = 1;
		else
			o = find (o, classname, "player");
	}

	if (any)
		e.aqstate = e.aqstate | AQS_HAS_RIDERS;
	else
		e.aqstate = e.aqstate - e.aqstate & AQS_HAS_RIDERS;
};

void ()
show_ridee =
{
	local float n;
	local string s;

	self_sprint (self, self.owner.netname);

	// add status # to ridee
	n = player_ent_to_num (self.owner);
	s = ftos (n);
	sprint (self, " \[#");
	sprint (self, s);
	sprint (self, "\]");

	sprint (self, " (rate ");
	sprint_float_f (self, self.owner.frag_rate, 0, 2);
	if (self.aqstate & AQS_RIDE_MASK == AQS_RIDE_FAST)
		self_sprint (self, ", fast track");
	else if (self.aqstate & AQS_RIDE_MASK == AQS_RIDE_HIGH)
		self_sprint (self, ", high track");
	sprint (self, ")");
};

void ()
show_riders =
{
	local float any;
	local entity e, targ;

	if (is_rider ())
	{
		self_sprint (self, "You are riding ");
		show_ridee ();
		self_sprint (self, "\n");
		targ = self.owner;
	}
	else
	{
		if (DEVELOPER_MODE)
		{
			Test_Button ();
			return;
		}

		// Display rate and head info with show-riders.
		if (!is_observer ())
		{
			if (gamemode == MODE_HEADS)
				heads_tell ();

			self_sprint (self, "Your rate is ");
			self_sprint_float_f (self, self.frag_rate, 0, 2);
			self_sprint (self, "\n");
		}
		self_sprint (self, "Current riders:");
		targ = self;
	}

	e = find (world, classname, "player");
	while (e)
	{
		if (ridee_e (e) == targ
			&& (!e.aqflags & AQ_ADMIN || self.aqflags & AQ_ADMIN)
			&& e != self)
		{
			if (!any && targ != self)
				self_sprint (self, "Along with:");
			self_sprint (self, " ");
			self_sprint (self, e.netname);
			any = 1;
		}
		e = find (e, classname, "player");
	}
	if (!any && targ == self)
	{
		self_sprint (self, " none");
		self.items = self.items - self.items & IT_KEY2;
	}
	if (any || targ == self)
		self_sprint (self, "\n");
};

// This is called when a player leaves the game or becomes an observer.
// It causes her riders to become observers or (if in tracking mode)
// switch to somebody else.

void ()
lose_riders =
{
	local entity old_self, new;

	old_self = self;
	self = find (world, classname, "player");
	while (self)
	{
		if (ridee () == old_self)
		{
			if (self.aqstate & AQS_RIDE_MASK)
			{
				new = ridee_pick ();
				if (!new)
					obs_rider_off (0);
				else if (new != self.owner)
					obs_rider_set (new, 2);
			}
			else if (!self.aqflags & AQ_ADMIN)
				obs_rider_off (0);
		}
		self = find (self, classname, "player");
	}
	self = old_self;
};

void (entity e, string s)
stuffcmd =
{
	local entity o;

	self_stuffcmd (e, s);
	if (!e.aqstate & AQS_HAS_RIDERS)
		return;
	o = find (world, classname, "player");
	while (o)
	{
		if (ridee_e (o) == e)
			self_stuffcmd (o, s);
		o = find (o, classname, "player");
	}
};
