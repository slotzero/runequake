/*
    Copyright (C) 1996, 1997  Nick 'SiNGE' Bousman.

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
Strength_Sound =
{
	if (self.runetime > time)
		return;

	self.runetime = time + 1;
	sound (self, CHAN_AUTO, "items/damage3.wav", 1, ATTN_NORM);
};

void ()
Radio_Think =
{
	local entity head;

	if (self.runetime < time)
	{
		if (maybe_update_trap_count (self.owner, RN_RADIO))
			sprint (self.owner, "Your radiation expired\n");

		remove (self);
		return;
	}

	if (self.runevar)
	{
		self.runevar = 0;
		create_te_lavasplash (self.origin);
	}

	head = findradius (self.origin, RADIO_DIST);
	while (head)
	{
		if (head.takedamage == DAMAGE_AIM && head.health > 0)
		{
			if (CanDamage (head, self))
			{
				IN_POQ([-
					particle (head.origin, '0 0 10', PARTICLE_RADIATION, 150);
				-], [-
					create_te_lightningblood (head.origin);
				-])
				// don't harm the owner or anyone with a
				// radiation rune or a rad suit
				if (head == self.owner)
				{
					// heal the owner if she still
					// has radiation
					if (head.runetype == RN_RADIO)
					{
						if (T_Heal (head, RADIO_HEAL, 0))
							sound (head, CHAN_AUTO, "items/r_item1.wav", 1, ATTN_NORM);
					}
				}
				else if (head.runetype == RN_RADIO)
					SUB_Null ();
				else if (head.radsuit_finished > time)
					SUB_Null ();
				else
				{
					if (T_Damage (head, self, self.owner,
							RADIO_DAMAGE,
							"radioactive")
							&& head.classname
								== "player")
						sprint (head, "\{141} This area is radioactive!\n");
				}
			}
		}
		head = head.chain;
	}
	self.nextthink = time + RADIO_INTERVAL;
};

void (float riders, entity of_e)
Rune_Radio_sprint =
{
	rprint_numdesc (self, riders, of_e.runevar, "radiation point");
	rprint (self, riders, " active\n");
};

void ()
Rune_Radio =
{
	local entity radio;
	local entity head;
	local string s, s1;

	if (self.health > 0 && self.runevar >= MAX_RADIO)
	{
		s = ftos (MAX_RADIO);
		if (MAX_RADIO != 1)
			s1 = "s";
		centerprint4 (self, "You can only irradiate ", s, " area", s1);
		return;
	}

	head = findradius (self.origin, RADIO_DIST);
	while (head)
	{
		if (head.classname == "radioactive")
		{
			traceline (self.origin, head.origin, TRUE, self);
			if (trace_fraction == 1)
			{
				if (self.health > 0)
					centerprint (self, "This area is already radioactive");
				return;
			}
		}
		head = head.chain;
	}

	self.runevar = self.runevar + 1;

	if (self.health > 0)
	{
		// This is Matthew's gag.
		if (random () >= 0.9)
			centerprint (self, "5 seconds to Irritation");
		else
			centerprint (self, "5 seconds to Irradiation");
	}

	radio = spawn ();
	radio.movetype = MOVETYPE_NONE;
	// This can't be SOLID_NOT the findradius() won't see it.
	radio.solid = SOLID_TRIGGER;
	radio.owner = self;
	radio.classname = "radioactive";
	setorigin (radio, self.origin);
	setsize (radio, VEC_ORIGIN, VEC_ORIGIN);

	radio.nextthink = time + 5;
	sound (radio, CHAN_WEAPON, "items/damage.wav", 1, ATTN_NORM);

	radio.runetime = time + RADIO_DURATION;
	radio.think = Radio_Think;
	radio.runevar = 1;
};

void ()
Rune_Switch =
{
	local vector tempv, org;
	local float tempf, switch_shealth, self_shealth;
	local float switch_wasbest, self_wasbest;
	local entity switch, tempe;

	local vector f, p1, p2;

	org = self.origin + '0 0 15';
	makevectors (self.v_angle);

	p1 = org;
	p2 = org + v_forward*1000;

	f = p2 - p1;
	normalize (f);
	f_x = 0 - f_y;
	f_y = f_x;
	f_z = 0;
	f = f*16;

	traceline (p1, p2, FALSE, self);
	switch = trace_ent;
	IN_POQ([-
		particle (trace_endpos, VEC_ORIGIN, PARTICLE_SWITCH_1, 100);
		particle (trace_endpos, VEC_ORIGIN, PARTICLE_SWITCH_2, 50);
	-], [-
		create_te_gunshot (trace_endpos, 5);
	-])
	makevectors (self.angles);

	if (isfriend (switch))
		return;

	if (switch.health <= 0)
	    	return;

	if (environmental (switch))
		return;

	if (switch.classname != "player"
			&& switch.classname != "shambler_slave"
			&& switch.classname != "zombie_camper")
		return;

	if (switch.solid == SOLID_BSP)
	    	return;

	spawn_tfog (switch.origin);
	spawn_tfog (self.origin);
	create_te_lightning (TE_LIGHTNING3, world, self.origin, switch.origin);

	self_wasbest = self.weapon == W_BestWeapon ();
	tempe = self;
	self = switch;
	switch_wasbest = self.weapon == W_BestWeapon ();
	self = tempe;

	// Switch places
	tempv = switch.origin;
	setorigin (switch, self.origin);
	setorigin (self, tempv);

	// Switch angles
	// XXX I haven't figured out a way to cure batman villain
	// syndrome here, or to fully swap the angles (the Z
	// doesn't transfer, even when swapping the whole of
	// angles and v_angle, and putting the setorigin() after
	// rather than before).
	tempv_y		= switch.angles_y;
	switch.angles_y	= self.angles_y;
	switch.angles_z	= 0; // fix-angles
	self.angles_y	= tempv_y;
	self.angles_z	= 0; // fix-angles

	self.fixangle	= 1;
	switch.fixangle	= 1;

	// Switch velocity
	tempv = switch.velocity;
	switch.velocity = self.velocity;
	self.velocity = tempv;

	// Switch health
	tempf = switch.health;
	switch.health = self.health;
	self.health = tempf;

	if (switch.classname != "player")
	{
		// Decay her health if she switched with something which
		// has more than she's allowed.  This is a no-op if
		// she's under her maximum.
		decay_health_spawn (self, 1);
		return;
	}

	// Invis vars switch
	if ((switch.items & IT_INVISIBILITY)||(self.items & IT_INVISIBILITY))
	{
		tempf = switch.invisible_finished;
		switch.invisible_finished = self.invisible_finished;
		self.invisible_finished = tempf;

		tempf = switch.invisible_time;
		switch.invisible_time = self.invisible_time;
		self.invisible_time = tempf;
	}

	// Pentagram vars switch
	if ((switch.items & IT_INVULNERABILITY)||(self.items & IT_INVULNERABILITY))
	{
		spawn_protect_off ();
		spawn_protect_off_e (switch);

		tempf = switch.invincible_finished;
		switch.invincible_finished = self.invincible_finished;
		self.invincible_finished = tempf;

		tempf = switch.invincible_time;
		switch.invincible_time = self.invincible_time;
		self.invincible_time = tempf;
	}

	// Quad vars switch
	if ((switch.items & IT_QUAD)||(self.items & IT_QUAD))
	{
		tempf = switch.super_damage_finished;
		switch.super_damage_finished = self.super_damage_finished;
		self.super_damage_finished = tempf;

		tempf = switch.super_time;
		switch.super_time = self.super_time;
		self.super_time = tempf;
	}

	// Biosuit vars switch
	if ((switch.items & IT_SUIT)||(self.items & IT_SUIT))
	{
		tempf = switch.radsuit_finished;
		switch.radsuit_finished = self.radsuit_finished;
		self.radsuit_finished = tempf;

		tempf = switch.rad_time;
		switch.rad_time = self.rad_time;
		self.rad_time = tempf;
	}

	// Switch items.  Don't switch IT_SUPERHEALTH,
	// though, because it really indicates an external
	// health rotter acting on this player.
	self_shealth	= self.items & (IT_SUPERHEALTH | IT_KEY1 | IT_KEY2);
	switch_shealth	= switch.items & (IT_SUPERHEALTH | IT_KEY1 | IT_KEY2);
	tempf		= switch.items;
	switch.items	= self.items;
	self.items	= tempf;
	self.items	= self.items - self.items & (IT_SUPERHEALTH | IT_KEY1 | IT_KEY2) + self_shealth;
	switch.items	= switch.items - switch.items & (IT_SUPERHEALTH | IT_KEY1 | IT_KEY2) + switch_shealth;

	// Start up health rotters.  This is a no-op if
	// she doesn't need one or if she already has
	// one.
	decay_health_spawn (self, 1);
	decay_health_spawn (switch, 1);

	// Switch lithium hook
	tempf = switch.aqflags & AQ_HOOK;
	switch.aqflags = switch.aqflags - switch.aqflags & AQ_HOOK + self.aqflags & AQ_HOOK;
	self.aqflags = self.aqflags - self.aqflags & AQ_HOOK + tempf;

	// Switch ammo
	tempf = switch.ammo_shells;
	switch.ammo_shells = self.ammo_shells;
	self.ammo_shells = tempf;

	tempf = switch.ammo_nails;
	switch.ammo_nails = self.ammo_nails;
	self.ammo_nails = tempf;

	tempf = switch.ammo_rockets;
	switch.ammo_rockets = self.ammo_rockets;
	self.ammo_rockets = tempf;

	tempf = switch.ammo_cells;
	switch.ammo_cells = self.ammo_cells;
	self.ammo_cells = tempf;

	// Switch armor
	tempf = switch.armortype;
	if (switch.runetype != RN_ARMOR)
		switch.armortype = self.armortype;
	self.armortype = tempf;
	set_armor_items_e (self);
	tempf = switch.armorvalue;
	switch.armorvalue = self.armorvalue;
	self.armorvalue = tempf;
	decay_armor_spawn (self, ARMOR_DECAY_RATE);
	decay_armor_spawn (switch, ARMOR_DECAY_RATE);
	set_armor_items_e (self);
	set_armor_items_e (switch);

	// Switch head count
	tempf = switch.num_heads;
	switch.num_heads = self.num_heads;
	self.num_heads = tempf;

	// Switch head entities
	tempe = switch.head_chain;
	switch.head_chain = self.head_chain;
	self.head_chain = tempe;

	// Take dim light from both, if they still have
	// the powerup they'll get it right back from
	// CheckPowerups().
	self.effects = self.effects - self.effects & EF_DIMLIGHT;
	switch.effects = switch.effects	- switch.effects & EF_DIMLIGHT;

	if (self.ammo_shells < 25)
		self.ammo_shells = 25;
	if (switch.ammo_shells < 25)
		switch.ammo_shells = 25;

	centerprint (switch, "You've switched places!");

	if (self_wasbest)
		set_weapon (W_BestWeapon ());
	else
		maybe_set_weapon ();
	CheckPowerups ();

	tempe = self;
	self = switch;

	if (switch_wasbest)
		set_weapon (W_BestWeapon ());
	else
		maybe_set_weapon ();
	CheckPowerups ();

	self = tempe;
};

void ()
Freeze_Think =
{
	self.nextthink = time + 1.0;
	IN_POQ([-
		particle (self.origin, '0 0 -10', PARTICLE_FREEZE_TRAP, 20);

		if (teamplay & (TEAM_TEAM_MASK | TEAM_MODE_MATCH))
		{
			local float particle_team;

			particle_team = team_to_particle (self.owner.team);
			particle (self.origin, '0 0 -10', particle_team, 10);
		}
	-])
	if (self.runetime < time)
	{
		if (maybe_update_trap_count (self.owner, RN_FREEZE))
			sprint (self.owner, "A freeze trap timed out\n");

		remove (self);
	}
};

void (entity wanted)
Unfreeze =
{
	local entity freeze;

	freeze = find (world, classname, "freeze");
	while (freeze)
	{
		if (freeze.runent == wanted)
		{
			freeze.runent.effects		= freeze.runent.effects - freeze.runent.effects & EF_FROZEN;
			freeze.runent.attack_finished	= time + sys_ticrate;

			sound (freeze.runent, CHAN_BODY, "blob/death1.wav", 1, ATTN_NORM);

			remove (freeze);
		}
		freeze = find (freeze, classname, "freeze");
	}
};

void ()
Freeze_Frozen =
{
	if (!self.runent.effects & EF_FROZEN)
		self.runent.effects = self.runent.effects | EF_FROZEN;

	setorigin (self.runent, self.origin);

	self.runent.angles		= self.angles;
	self.runent.fixangle		= 1;
	self.runent.attack_finished	= time + 30;	// magic in W_WeaponFrame()
	self.runent.frame		= self.runevar;
	self.runent.velocity		= VEC_ORIGIN;

	self.nextthink = time + sys_ticrate;

	// frozen particles
	if (self.attack_finished < time)
	{
		self.attack_finished = time + 0.15;
		makevectors (self.angles);
		IN_POQ([-
			particle (self.origin + v_up*random ()*30, '0 0 -10' + v_forward*crandom ()*5 + v_right*crandom ()*5, PARTICLE_FREEZE_TRAP, 20);
		-], [-
			create_te_gunshot (self.origin + v_up*random ()*30, 2);
		-])

		// Speed up the process for people while they are
		// burning.  The original code only tested this as the
		// trap was triggered, but people can start burning
		// after they've been frozen, and stop before they are
		// thawed.
		if (self.runent.runetype == RN_FIREWALK
				|| self.runent.runetype == RN_TORCH
				|| self.runent.aqstate & AQS_BURNING)
			self.runetime = self.runetime - 0.3;
	}

	// remove if time is out or dead
	if (self.runetime < time
			|| self.runent.health <= 0
			|| self.runent.runetype == RN_FREEZE
			|| self.runent.runetype == RN_ENVIRO
			|| (self.runent.runetype == RN_BLIZZARD && self.runent.runevector_x < time)
			|| self.runent.items & IT_SUIT)
	{
		self.runent.effects		= self.runent.effects - self.runent.effects & EF_FROZEN;
		self.runent.attack_finished	= time + sys_ticrate;

		if (self.runent.classname == "player")
		{
			if (self.runent.health > 0)
			{
				if (self.owner.runetype == RN_BLIZZARD)
				{
					if (self.owner == self.runent)
						centerprint (self.runent, "You've broken free!");
					else
						centerprint (self.runent, "The storm has passed");
				}
				else
					centerprint (self.runent, "Released from ice trap");
			}
			stuffcmd (self.runent, CSHIFT_NONE);
		}

		sound (self, CHAN_BODY, "blob/death1.wav", 1, ATTN_NORM);
		remove (self);
	}
};

void ()
Freeze_Touch =
{
	if (other == world)
		return;

	if (other.classname != "player" && other.classname != "shambler_slave")
		return;

	if (!other.takedamage || other.health <= 0)
		return;

	if (isfriend2 (self.owner, other) && self.owner != other)
		return;

	if (environmental (other) || other.runetype == RN_FREEZE)
		return;

	if (other.runetype == RN_BLIZZARD)
	{
		sprint (other, "you deactivated an ice trap\n");
		if (maybe_update_trap_count (self.owner, RN_FREEZE))
		{
			sprint (self.owner, other.netname);
			sprint (self.owner, " deactivated your ice trap\n");
		}
		sound (self, CHAN_BODY, "fish/bite.wav", 1, ATTN_NORM);
		remove (self);
		return;
	}

	if (other.effects & EF_FROZEN)
		return;

	other.effects = other.effects | EF_FROZEN;
	maybe_update_trap_count (self.owner, RN_FREEZE);

	if (other.classname == "player")
	{
		stuffcmd (other, CSHIFT_FREEZE);
		if (self.owner == other)
			centerprint (other, "You froze yourself,\nyou big dummy!\n");
		else
		{
			centerprint3 (other, "You've been frozen\nby ",
						self.owner.netname,
						// fastqcc chokes on "!"
						"! ");
			sprint (self.owner, other.netname);
			sprint (self.owner, " is frozen in your ice trap.\n");
		}
	}
	else if (other.classname == "shambler_slave")
	{
		sprint (other.owner, "Your shambler is frozen in ");
		sprint (other.owner, self.owner.netname);
		sprint (other.owner, "'s ice trap.\n");

		sprint (self.owner, other.owner.netname);
		sprint (self.owner, "'s shambler is frozen in your ice trap.\n");
	}

	sound (self, CHAN_BODY, "shambler/smack.wav", 1, ATTN_NORM);

	self.runent	= other;
	self.runevar	= other.frame;

	// If you use angles here you get batman villain syndrome if you're
	// frozen while in the middle of a roll.
	self.angles	= other.v_angle;
	self.fixangle	= 1;

	setorigin (self, other.origin);

	self.touch	= SUB_Null;
	IN_QW([-
	setmodel (self, string_null);
	-])

	// how long frozen
	self.runetime	= time + 13;
	self.nextthink	= time;
	self.think	= Freeze_Frozen;
};

void ()
Freeze_Arm =
{
	self.nextthink	= time;
	self.runetime	= time + 120;
	self.think	= Freeze_Think;
	self.touch	= Freeze_Touch;
	IN_POQ([-
		setmodel (self, string_null);
	-], [-
		self.effects = self.effects - self.effects & EF_DIMLIGHT;
	-])
	sound (self, CHAN_BODY, "fish/bite.wav", 1, ATTN_NORM);
};

void (float riders, entity of_e)
Rune_Freeze_sprint =
{
	rprint_numdesc (self, riders, of_e.runevar, "ice trap");
	rprint (self, riders, " active\n");
};

void ()
Rune_Freeze =
{
	local entity freeze;
	local string s, s1;

	if (self.runevar >= MAX_FREEZE)
	{
		s = ftos (MAX_FREEZE);
		if (MAX_FREEZE != 1)
			s1 = "s";
		centerprint5 (self, "Only ", s, " ice trap", s1, " allowed");
		return;
	}
	self.runevar = self.runevar + 1;

	freeze			= spawn ();
	freeze.movetype		= MOVETYPE_FLY;
	freeze.solid		= SOLID_TRIGGER;
	freeze.owner		= self;
	freeze.classname	= "freeze";
	freeze.angles		= self.angles;
	freeze.v_angle		= self.v_angle;

	setorigin (freeze, self.origin + '0 0 10');
	setmodel (freeze, "progs/s_bubble.spr");
	setsize (freeze, VEC_ORIGIN, VEC_ORIGIN);
	IN_QW([-
		freeze.effects	= freeze.effects | EF_DIMLIGHT;
	-])

	freeze.think		= Freeze_Arm;
	freeze.nextthink	= time + 3;

	sound (self, CHAN_AUTO, "enforcer/sight2.wav", 1, ATTN_NORM);
	sound (freeze, CHAN_WEAPON, "buttons/switch04.wav", 1, ATTN_NORM);

	centerprint (self, "Ice trap created!");
};

void (entity sucker)
Suck =
{
	local entity suckee;
	local vector suckdir, suckforce;
	local float suckdist, dist;

	dist = 700;

	suckee = findradius (sucker.origin, dist); // find the victims
	while (suckee)
	{
		if (suckee.health || !suckee.flags & FL_ONGROUND)
		{
			if (suckee.solid != SOLID_BSP && !isfriend2 (sucker.owner, suckee) && sucker != suckee)
			{
				if (suckee.classname != "player")
					suckee.flags = suckee.flags - suckee.flags & FL_ONGROUND;
				if (!environmental (suckee))
				{
					suckdir		= sucker.origin - suckee.origin;
					suckdist	= vlen (suckdir);
					suckdir		= normalize (suckdir);
					suckforce	= suckdir * SUCK_FORCE * (dist - suckdist);
					suckee.velocity	= suckee.velocity + suckforce;
				}
			}
		}
		suckee = suckee.chain;
	}
};

void ()
Suck_Think =
{
	if ((self.owner.runevar == 0 && self.owner.runetype == RN_SUCK)
			|| self.runetime < time)
	{
		spawn_tfog (self.origin);
		remove (self);
		if (self.owner.runetype == RN_SUCK)
			self.owner.class_cnt = 0;
		return;
	}

	if (self.owner.runetype == RN_SUCK)
		self.runetime = time + 20;

	// I used to set this to sys_ticrate but every time the rate changes
	// SUCK_FORCE is either too weak or too strong.
	self.nextthink = time + 0.1;

	Suck (self);
};

void ()
Suck_Touch =
{
	if (other == world)
		return;

	if (other.classname != "player" && !is_pet_e (other))
		return;

	if (!other.takedamage)
		return;

	if (isfriend2 (self.owner, other))
		return;

	if (environmental (other))
		return;

	T_Damage (other, self, self.owner, 1, "sucker");
};

void ()
Suck_Spawn =
{
	local entity suck;

	suck = spawn ();
	suck.movetype = MOVETYPE_FLY;
	suck.solid = SOLID_TRIGGER;
	suck.owner = self;
	setorigin (suck, self.origin + '0 0 40');
	setsize (suck, VEC_ORIGIN, VEC_ORIGIN);
	setmodel (suck, "progs/s_light.spr");
	suck.classname = "sucker";

	sound (suck, CHAN_WEAPON, "buttons/switch04.wav", 1, ATTN_NORM);

	suck.nextthink = time;
	suck.think = Suck_Think;
	suck.runetime = time + 1;
	suck.touch = Suck_Touch;

	centerprint (self, "Gravity well dropped");
};

void (float riders, entity of_e)
Rune_Suck_sprint =
{
	if (of_e.runevar)
		rprint (self, riders, "Gravity well is deployed\n");
	else
		rprint (self, riders, "Gravity well is not deployed\n");
};

void ()
Suck_Button =
{
	if (self.runevar == 0 && !self.class_cnt)
	{
		if (sv_gravity != DEFAULT_GRAVITY)
			centerprint (self, "Can't use gravity well on this level");
		else
		{
			self.runevar = 1;
			self.class_cnt = 1;
			Suck_Spawn ();
		}
	}
	else
	{
		self.runevar = 0;
		centerprint (self, "Gravity well recalled");
	}
};

// In QW a player's touch function only triggers if somebody touches the
// player, not the other way around.

IN_POQ([-
void ()
Impact_Touch =
{
	misc_touch ();

	if (other == world)
		return;
	if (other.takedamage != DAMAGE_AIM)
		return;
	if (self.runetime > time)
		return;

	self.runetime = time + 0.5;

	other.flags	= other.flags - (other.flags & FL_ONGROUND);
	other.velocity	= other.velocity + '0 0 200' + self.velocity * 3;
	self.velocity	= VEC_ORIGIN - self.velocity;
	sound (self, CHAN_AUTO, "zombie/z_miss.wav", 1, ATTN_NORM);
	T_Damage (other, self, self, (40 + random () * 10), "bodycheck");
};
-])

IN_QW([-
void ()
Rune_Impact =
{
	local entity head;

	// XXX this causes it not to trip if you run into him while he
	// stands still
	if (self.velocity == VEC_ORIGIN)
		return;

	if (self.runetime > time)
		return;
	self.runetime = time + 0.5;

	// XXX This can trigger as you're walking away from a guy.  Just
	// stand next to him and back up to reproduce.
	head = findradius (self.origin, 60);
	while (head)
	{
		if (head.health > 0 && head != self && head.solid != SOLID_BSP)
		{
			head.flags = head.flags - head.flags & FL_ONGROUND;
			head.velocity = head.velocity
					+ '0 0 200'
					+ 3 * self.velocity;
			self.velocity = self.velocity * -1;
			sound (self, CHAN_AUTO, "zombie/z_miss.wav",
				1, ATTN_NORM);
			self.runevar = 10;
			T_Damage (head, self, self, 45 + 10 * random (),
					"bodycheck");
		}
		head = head.chain;
	}
};
-])

void ()
Rune_Twalk =
{
	local vector org, place, f, p1, p2;
	local entity switch;

	org = self.origin + '0 0 15';
	makevectors (self.v_angle);

	p1 = org;
	p2 = org + v_forward*1500;
	f = p2 - p1;
	normalize (f);
	f_x = 0 - f_y;
	f_y = f_x;
	f_z = 0;
	f = f*16;

	traceline (p1, p2, FALSE, self);
	switch = trace_ent;

	IN_POQ([-
		particle (trace_endpos, VEC_ORIGIN, PARTICLE_TELEPORT_SHUFFLE, 100);
	-], [-
		create_te_gunshot (trace_endpos, 5);
	-])

	makevectors (self.angles);

	HookOff ();
	HookOff_by_targ ();

	if (switch == world)
	{
		create_te_teleport (self.origin);
		setorigin (self, trace_endpos - v_forward*60);
		droptofloor ();
		return;
	}

	if (switch.flags & FL_ITEM)
	{
		setorigin (self, switch.origin);
		return;
	}

	if (switch.health > 0 && switch.solid != SOLID_BSP && switch.movetype != MOVETYPE_NONE)
	{
		spawn_tfog (self.origin);
		spawn_tfog (switch.origin);

		if (random () < 0.3)
			spawn_tdeath (self.origin, self);
		else if (switch.classname == "player")
			centerprint (switch, "Someone tried to telefrag you!");

		place = switch.origin;
		setorigin (switch, self.origin);
		setorigin (self, place);

		return;
	}
};

void ()
VengHead_Think =
{
	local vector a;

	if (self.owner.runetype != RN_VENG || intermission_running)
	{
		remove (self);
		return;
	}

	a = self.owner.angles;
	// Convert from angles to v_angles form that makevectors() uses.
	a_x = 0 - a_x;
	makevectors (a);

	setorigin (self, self.owner.origin + v_up*20 - v_right*1 - v_forward*9);
	trackvel (self.owner);
	self.nextthink = time + sys_ticrate;

	self.angles_x = self.owner.angles_x - 60;
	self.angles_y = self.owner.angles_y - 27;
};

void ()
VengHead_Spawn =
{
	local entity temp;

	temp = spawn ();
	temp.movetype = MOVETYPE_FLY;
	temp.solid = SOLID_NOT;
	temp.owner = self;
	setorigin (temp, self.origin);
	setsize (temp, VEC_ORIGIN, VEC_ORIGIN);
	setmodel (temp, "progs/h_player.mdl");
	temp.think = VengHead_Think;
	temp.nextthink = time;
	temp.angles_z = -30;
	temp.colormap = self.colormap;
	self.runent = temp;
};

void ()
ShubHat_Bye =
{
	self.nextthink = time + sys_ticrate;
	setorigin (self, self.origin + '0 0 15');
	self.angles_y = self.angles_y - 10;

	if (self.runetime > time)
		return;

	remove (self);
};

void ()
ShubHat_Think =
{
	if (intermission_running)
	{
		remove (self);
		return;
	}

	if (self.owner.runetype != RN_SHUB)
	{
		self.nextthink = time;
		self.think = ShubHat_Bye;
		self.flags = self.flags - FL_ONGROUND;
		self.runetime = time + 10;
		return;
	}

	setorigin (self, self.owner.origin);
	trackvel (self.owner);
	self.nextthink = time + sys_ticrate;
};

void ()
ShubHat_Spawn =
{
	local entity temp;

	temp = spawn ();
	temp.movetype = MOVETYPE_FLY;
	temp.solid = SOLID_NOT;
	temp.owner = self;
	setorigin (temp, self.origin);
	setsize (temp, '-160 -128 -24', '160 128 256');
	setmodel (temp, "progs/oldone.mdl");
	temp.think = ShubHat_Think;
	temp.nextthink = time;
	if (random () > 0.5)
		temp.avelocity_y = 100;
	else
		temp.avelocity_y = -100;
	temp.colormap = self.colormap;
	self.runent = temp;
};

void ()
Rune_Repel =
{
	local entity pushee;
	local vector pushdir, pushforce;
	local float pushdist, dist, isplayer;

	if (self.runetime > time)
		return;

	// I used to set this to sys_ticrate but every time the rate changes
	// PUSH_FORCE is either too weak or too strong.
	self.runetime = self.runetime + 0.1;

	dist = 400;

	pushee = findradius (self.origin, dist); // Find the victims.
	while (pushee)
	{
		if (pushee.health > 0 || !pushee.flags & FL_ONGROUND)
		{
			isplayer = is_player_e (pushee);
			if (pushee.solid != SOLID_BSP && (!isplayer || !isfriend (pushee)))
			{
				if (!environmental (pushee))
				{
					if (pushee.classname != "player")
						pushee.flags = pushee.flags - pushee.flags & FL_ONGROUND;

					pushdir		= self.origin - pushee.origin;
					pushdist	= vlen (pushdir);
					pushdir		= normalize (pushdir);
					pushforce	= pushdir * PUSH_FORCE * (dist - pushdist);
					pushee.velocity	= pushee.velocity - pushforce;
				}
			}
		}
		pushee = pushee.chain;
	}
};
