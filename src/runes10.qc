/*  $Id: runes10.qc,v 1.17 2004/11/28 05:33:40 slotzero Exp $

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
Haste_Sound =
{
	if (self.runetime > time)
		return;

	self.runetime = time + 2;
	sound (self, CHAN_AUTO, "boss1/sight1.wav", 1, ATTN_NORM);
};

void ()
Rune_Enviro =
{
	local float amt, dly;
	local string snd;

	if (self.runetime > time)
		return;

	amt = 0;
	if (self.watertype == CONTENT_WATER && self.air_finished < time)
	{
		dly = 1;
		amt = 5;
		snd = "items/r_item1.wav";
	}
	else if (self.watertype == CONTENT_LAVA)
	{
		dly = 0.2;
		amt = 3 * self.waterlevel;
		snd = "player/inlava.wav";
	}
	else if (self.watertype == CONTENT_SLIME)
	{
		dly = 0.8;
		amt = 3 * self.waterlevel;
		snd = "player/slimbrn2.wav";
	}

	if (amt > 0 && self.health < self.max_health)
	{
		self.runetime = time + dly;
		self.health = self.health + amt;
		if (self.health > self.max_health)
			self.health = self.max_health;
		sound (self, CHAN_AUTO, snd, 1, ATTN_NORM);
	}
};

void ()
Enviro_Jump =
{
	local float i;

	makevectors (self.angles);

	if (self.watertype == CONTENT_LAVA)
		i = 700;
	else if (self.watertype == CONTENT_SLIME)
		i = 500;
	else if (self.watertype == CONTENT_WATER)
		i = 500;
	else
		return;

	self.velocity_z = i;
	self.velocity = self.velocity + v_forward*500;
	sound (self, CHAN_AUTO, "doors/airdoor2.wav", 1, ATTN_NORM);
};

void ()
Regen_Activate =
{
	if (scratch1 & S1_BASIC_RUNES)
		return;
	if (self.armorvalue >= MAX_ARMOR_3 && self.health >= self.max_health)
		return;

	self.armortype = ARMOR_TYPE_3;
	if (self.armorvalue < MAX_ARMOR_3)
	{
		self.armorvalue = MAX_ARMOR_3;
		self.items = self.items - (self.items & (IT_ARMOR1
			| IT_ARMOR2 | IT_ARMOR3)) + IT_ARMOR3;
	}

	if (self.health < self.max_health)
		self.health = self.max_health;

	sound (self, CHAN_AUTO, "items/armor1.wav", 1, ATTN_NORM);
	sound (self, CHAN_AUTO, "items/r_item2.wav", 1, ATTN_NORM);

	Rune_Delete (0);
};

void ()
Rune_Regen =
{
	local float any, m;

	if (self.runetype != RN_JACK)
	{
		if (self.runetime > time)
			return;
		if (0) // (!self.runevar)
		{
			self.runevar = 1;
			self.armortype = ARMOR_TYPE_3;
			self.items = self.items - (self.items & (IT_ARMOR1 | IT_ARMOR2 | IT_ARMOR3)) + IT_ARMOR3;
		}
		self.runetime = time + 0.5;
	}

	any = 0;

	m = get_max_armor ();
	if (self.runetype == RN_JACK)
		m = rint (m * RN_JACK_REGEN_ARMOR);
	if (self.armorvalue < m)
	{
		any = 1;
		self.armorvalue = self.armorvalue + 5;
		if (self.armorvalue > m)
			self.armorvalue = m;
	}

	m = self.max_health;
	if (self.runetype == RN_JACK)
		m = rint (m * RN_JACK_REGEN_HEALTH);
	if (self.health < m)
	{
		any = 1;
		self.health = self.health + 5;
		if (self.health > m)
			self.health = m;
	}

	if (any)
		sound (self, CHAN_AUTO, "items/r_item1.wav", 1, ATTN_NORM);
};

void (float riders, entity of_e)
Rune_Fly_sprint =
{
	if (self.runevar)
		rprint (self, riders, "\{141} flight on");
	else
		rprint (self, riders, "\{141} flight off");

	if (FLY_TIMER_ON)
	{
		rprint (self, riders, " (");
		rprint_numdesc (self, riders, of_e.class_cnt, "second");
		rprint (self, riders, " left)");
	}
	rprint (self, riders, "\n");
};

void ()
Rune_Fly_Activate =
{
	if (self.runevar)
	{
		self.movetype = MOVETYPE_WALK;
		self.runevar = 0;
	}
	else
	{
		self.movetype = MOVETYPE_FLY;
		// Flying people can't seem to have a waterlevel other
		// than 3 or 0.  If you pick it up while you have a 2
		// everything seems okay, but it you pick it up while a
		// 1 and you don't go deeper, you keep the 1 even after
		// you leave the liquid.
		if (self.waterlevel == 1)
			self.waterlevel = 0;
		self.runevar = 1;
	}
	Rune_Fly_sprint (1, self);
};

void ()
Rune_Fly =
{
	if (FLY_TIMER_ON)
	{
		if (self.runetime <= time && self.runevar)
		{
			self.class_cnt = self.class_cnt - 1;
			self.runetime = time + 1;
		}

		if (self.class_cnt <= 0)
		{
			sprint (self, "Rune timelimit expired, rune removed.\n");
			Rune_Delete (0);
		}
	}
	if (self.runevar)
		obs_fly ();
};

void ()
GFire_Touch =
{
	if (other == world)
		return;

	if (other.classname != "player" && !is_pet_e (other))
		return;

	if (!other.takedamage || other.health <= 0)
		return;

	if (isfriend2 (self.owner, other))
		return;

	if (environmental (other)
			|| other.runetype == RN_FIREWALK
			|| other.runetype == RN_TORCH)
		return;

	T_Damage (other, self, self.owner, 25, "gfire");
	remove (self);
};

void ()
GFire_Spawn =
{
	if (self.velocity == VEC_ORIGIN)
		return;
	if (!self.flags & FL_ONGROUND)
		return;
	if (self.waterlevel > 0)
		return;

	local entity fire;

	fire = spawn ();

	setorigin (fire, self.origin - '0 0 10');
	setmodel (fire, "progs/flame2.mdl");

	fire.movetype = MOVETYPE_FLY;
	fire.solid = SOLID_TRIGGER;

	setsize (fire, '-17 -17 -10', '17 17 22');

	fire.classname = "gfire";
	fire.owner = self;

	fire.touch = GFire_Touch;
	fire.nextthink = time + 1.5;
	fire.think = SUB_Remove;

	fire.angles_y = crandom ()*360;

	if (random () > 0.5)
	{
		sound (fire, CHAN_AUTO, "hknight/hit.wav", 1, ATTN_NORM);
		fire.frame = 1;
	}
	else
	{
		sound (fire, CHAN_AUTO, "weapons/ax1.wav", 1, ATTN_NORM);
		fire.frame = 0;
	}
};

void ()
Rune_Firewalk =
{
	if (self.runetime > time)
		return;
	self.runetime = time + 0.3;

	GFire_Spawn ();
};

void ()
recall_point_erase =
{
	self.runevar = 0;
	centerprint (self, "Recall point erased.");
};

void (float riders, entity of_e)
Rune_Recall_sprint =
{
	if (of_e.runevar)
		rprint (self, riders, "Recall point is set\n");
	else
		rprint (self, riders, "Recall point is not set\n");
};

void ()
Rune_Recall =
{
	if (!self.runevar)
	{
		self.runevector = self.origin;
		self.pos1 = self.v_angle;
		self.runevar = 1;
		centerprint (self, "Recall point set.");
		return;
	}

	if (self.origin == self.runevector)
	{
		recall_point_erase ();
		return;
	}

	HookOff ();
	HookOff_by_targ ();

	spawn_tfog (self.origin);
	spawn_tdeath (self.runevector, self);
	setorigin (self, self.runevector);
	self.angles = self.pos1;
	self.fixangle = 1;
	spawn_tfog (self.origin);
	self.velocity = VEC_ORIGIN;
};

void ()
Rune_Zap =
{
	local entity head, selected;
	local float dist;

	if (time > self.runevector_x)
	{
		self.runevector_x = time + 5;
		if (self.ammo_cells < MAX_CELLS)
		{
			self.ammo_cells = self.ammo_cells + 1;
			set_current_ammo ();
		}
	}

	if (self.waterlevel > 0)
		return;
	if (self.ammo_cells < 1)
		return;
	if (self.runetime > time)
		return;

	if ((random ()*100) > 60)
		muzzleflash ();

	self.runetime = time + 0.3;
	dist = 200;

	if (pointcontents (self.origin) != CONTENT_EMPTY)
		return;

	selected = world;
	head = findradius (self.origin, dist);
	while (head)
	{
		if ((head.health > 0)
				&& !isfriend (head)
				&& head.takedamage == DAMAGE_AIM
				&& (head.invincible_finished < time
				|| head.armorvalue > 0))
		{
			traceline (self.origin, head.origin, TRUE, self);
			if ((trace_fraction >= 1) && (vlen (head.origin - self.origin) < dist))
			{
				selected = head;
				dist = vlen (head.origin - self.origin);
			}
		}
		head = head.chain;
	}
	if (selected != world
			&& selected.runetype != RN_ENVIRO
			&& !selected.items & IT_SUIT)
	{
		self.ammo_cells = self.ammo_cells - 1;

		if (random ()*100 > 50)
			dist = TE_LIGHTNING1;
		else
			dist = TE_LIGHTNING2;
		create_te_lightning (dist, self, self.origin + '0 0 20',
					selected.origin);
		sound (self, CHAN_WEAPON, "weapons/lhit.wav", 1, ATTN_NORM);

		self.runevar = 10;
		LightningDamage (self.origin, selected.origin, self, 20, "zapped");
		self.runevar = 0;
		muzzleflash ();
	}
};

void ()
Zap_Think =
{
	if (self.owner.runetype != RN_ZAP || intermission_running)
	{
		remove (self);
		return;
	}

	setorigin (self, self.owner.origin + '0 0 20');
	trackvel (self.owner);
	self.nextthink = time + sys_ticrate;

	if (self.owner.ammo_cells < 1 || self.owner.waterlevel > 0)
	{
		self.angles = '90 0 0';
		return;
	}

	self.angles_x = crandom ()*360;
	self.angles_y = crandom ()*360;
	self.angles_z = crandom ()*360;
};

void (float is_new)
Zap_Spawn =
{
	local entity temp;

	self.runevector_x = time + 5;
	if (is_new)
	{
		self.ammo_cells = self.ammo_cells + 10;
		other = self;
		bound_other_ammo ();
	}

	temp = spawn ();
	temp.movetype = MOVETYPE_FLY;
	temp.solid = SOLID_NOT;
	temp.owner = self;
	setorigin (temp, self.origin);
	setsize (temp, VEC_ORIGIN, VEC_ORIGIN);
	setmodel (temp, "progs/bolt2.mdl");
	temp.angles = '-90 0 0';
	temp.think = Zap_Think;
	temp.nextthink = time;
	self.runent = temp;
	self.runevar = 0;
};

void ()
Rune_Cloak =
{
	if (self.runevar < 1 && self.runetime < time)
	{
		stuffcmd (self, CSHIFT_CLOAK);
		cloaked_sound (self, CHAN_AUTO, "items/inv1.wav", 1, ATTN_NORM);
		sprint (self, "\{141} Cloaked.\n");
		self.runevar = 1;
	}
	if (self.runevar > 0 && self.runetime > time)
	{
		stuffcmd (self, CSHIFT_NONE);
		cloaked_sound (self, CHAN_AUTO, "misc/r_tele4.wav", 1, ATTN_NORM);
		if (self.runetime < time + 3)
			sprint (self, "\{141} Uncloaked.\n");
		self.runevar = 0;
	}
};
