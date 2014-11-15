/*  $Id: runes60.qc,v 1.69 2011/03/29 07:50:26 slotzero Exp $

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

void (float riders, entity of_e)
Rune_Glue_sprint =
{
	rprint_numdesc (self, riders, of_e.runevar, "glue trap");
	rprint (self, riders, " placed\n");
};

void()
Glue_Think =
{
	if (self.runevar)
	{
		if (maybe_update_trap_count (self.owner, RN_GLUE))
			sprint (self.owner, "A glue trap evaporated\n");

		create_te_tarexplosion (self.origin);
		remove (self);
		return;
	}

	if (self.velocity != VEC_ORIGIN)
		self.nextthink	= time + sys_ticrate;
	else
	{
		self.runevar	= 1;
		self.solid	= SOLID_TRIGGER;
		self.nextthink	= time + 45;

		setsize (self, self.mins, self.maxs);
		sound (self, CHAN_WEAPON, "blob/land1.wav", 1, ATTN_NORM);
	}
};

void ()
Glue_Stuck =
{
	local float release;

	if (self.runetime < time)
	{
		centerprint (self.runent, "Released from glue trap");
		sound (self, CHAN_WEAPON, "blob/death1.wav", 1, ATTN_NORM);
		release = 1;
	}
	else if (self.runent.health <= 0)
		release = 1;
	else if (environmental (self.runent))
		release = 1;

	if (release)
	{
		self.runent.effects = self.runent.effects - self.runent.effects & EF_FROZEN;
		remove (self);
		return;
	}

	self.runent.effects	= self.runent.effects | EF_FROZEN;
	setorigin (self.runent, self.origin);

	self.runent.velocity	= VEC_ORIGIN;
	self.nextthink		= time + sys_ticrate;
};

void()
Glue_Touch =
{
	if (other.classname != "player" && !is_pet_e (other))
		return;

	if (other.health <= 0)
		return;

	if (environmental (other))
		return;

	if (isfriend2 (self.owner, other) && self.owner != other)
		return;

	if (other.effects & EF_FROZEN)
		return;

	if (!self.runevar)
		return;

	other.effects = other.effects | EF_FROZEN;
	maybe_update_trap_count (self.owner, RN_GLUE);

	self.solid	= SOLID_NOT;
	self.movetype	= MOVETYPE_NONE;
	self.touch	= SUB_Null;
	self.think	= Glue_Stuck;
	self.nextthink	= time;
	self.runent	= other;
	self.runetime	= time + 5;

	setorigin(self, other.origin);
	self.frame	= 60;

	setmodel (self, "progs/tarbaby.mdl");
	sound (self, CHAN_WEAPON, "blob/hit1.wav", 1, ATTN_NORM);

	centerprint(other, "You are stuck!");

	if (other == self.owner)
		sprint (self.owner, "You glued yourself\n");
	else
	{
		if (is_pet_e (other))
		{
			sprint (self.owner, other.owner.netname);
			sprint (self.owner, "'s pet is caught in your glue.\n");
		}
		else
		{
			sprint (other, "You stepped in ");
			sprint (other, self.owner.netname);
			sprint (other, "'s glue.\n");

			sprint (self.owner, other.netname);
			sprint (self.owner, " is caught in your glue.\n");
  		}
	}
};

void()
Rune_Glue =
{
	local entity glue;
	local string s, s1;

	if (self.runevar >= MAX_GLUE)
	{
		s = ftos (MAX_GLUE);
		if (MAX_GLUE != 1)
			s1 = "s";
		centerprint5 (self, "Only ", s, " glue trap", s1, " allowed");
		return;
	}
	self.runevar		= self.runevar + 1;

	sound (self, CHAN_WEAPON, "blob/sight1.wav", 1, ATTN_NORM);

	glue			= spawn();
	glue.owner		= self;
	glue.movetype		= MOVETYPE_BOUNCE;
	glue.solid		= SOLID_TRIGGER;
	glue.classname		= "glue";

	makevectors (self.v_angle);

	glue.velocity		= v_forward * (600 + random() * 100) + v_up * 200 + v_right * (random() * 100 - random() * 100);
	glue.avelocity		= '0 600 0';

	setmodel (glue, "progs/tarbaby.mdl");
	setsize (glue, '-16 -16 -24', '16 16 24');
	setorigin (glue, self.origin + '0 0 24');

	glue.touch		= Glue_Touch;
	glue.think		= Glue_Think;
	glue.nextthink		= time;
};

void (float riders)
Rune_Blizzard_sprint =
{
	if (self.runevar)
		rprint (self, riders, "Recharging...\n");
	else
		rprint (self, riders, "Charged\n");
};

void ()
Rune_Blizzard =
{
	local entity e;
	local float i;

	i = 0;
	if (self.runetime > time)
	{
		centerprint (self, "Blizzard recharging");
		return;
	}

	e = findradius (self.origin, 1500);
	while (e)
	{
		if (e.classname == "player" || is_pet_e (e))
		{
			if (!environmental (e) && e.runetype != RN_BLIZZARD)
			{
				if (e.runetype != RN_FREEZE && !(isfriend2 (self, e) && self != e) && !e.effects & EF_FROZEN)
				{
					if (e.health > 0 && e != self && e.owner != self)
					{
						if (CanDamage (e, self))
						{
							Blizzard_Freeze (e, 1.2);
							i = i + 1;
						}
					}
				}
			}
		}
		e = e.chain;
	}

	if (i)
	{
		sprint (self, "You froze ");
		sprint_float (self, i);
		sprint (self, " player");
		if (i > 1)
			sprint (self, "s");
		sprint (self, "\n");

		self.runetime = time + (BLIZZARD_RECHARGE * i);
	}
	else
		self.runetime = time + 3;

	self.runevar = 1;
	sound (self, CHAN_AUTO, "enforcer/sight2.wav", 1, ATTN_NORM);
};

void (entity tofreeze, float freeze_time)
Blizzard_Freeze =
{
	local entity freeze;

	if (tofreeze.classname == "player")
	{
		if (tofreeze == self)
			sprint (tofreeze, "Ice crystals are forming around you!\n");
		else
			sprint (tofreeze, "You're caught in a blizzard!\n");
	}

	freeze			= spawn ();
	freeze.movetype		= MOVETYPE_FLY;
	freeze.solid		= SOLID_TRIGGER;
	freeze.owner		= self;
	freeze.classname	= "freeze";
	freeze.angles		= tofreeze.angles;
	freeze.v_angle		= tofreeze.v_angle;

	setorigin (freeze, tofreeze.origin + '0 0 10');
	setmodel (freeze, string_null);
	setsize (freeze, VEC_ORIGIN, VEC_ORIGIN);

	sound (freeze, CHAN_BODY, "shambler/smack.wav", 1, ATTN_NORM);

	freeze.runent		= tofreeze;
	freeze.runevar		= tofreeze.frame;
	freeze.angles		= tofreeze.v_angle;
	freeze.fixangle		= 1;

	setorigin (freeze, tofreeze.origin);

	freeze.touch		= SUB_Null;

	// how long frozen
	freeze.runetime		= time + freeze_time;
	freeze.nextthink	= time;
	freeze.think		= Freeze_Frozen;
};

void ()
Blizzard_Think =
{
	if (self.runevar && self.runetime < time)
	{
		self.runevar = 0;
		centerprint (self, string_null);
		sprint (self, "\{141} Blizzard recharged\n");
	}

	if (self.watertype == CONTENT_WATER && self.runevector_x < time && !environmental (self))
	{
		self.runevector_x = time + 3;
		Blizzard_Freeze (self, 1);
	}

	IN_POQ([-
		particle (self.origin + '0 0 23', '0 0 -0.05', PARTICLE_FREEZE_TRAP, 1);
		particle (self.origin + '0 0 10', '0 0 -0.05', PARTICLE_FREEZE_TRAP, 1);
	-])
};

void ()
Blizzard_Touch =
{
	if (self.runetime > time)
		return;
 	if (other.health <= 0)
		return;
	if (other.classname != "player" && !is_pet_e (other))
		return;
	if (environmental (other) || other.runetype == RN_BLIZZARD || other.runetype == RN_FREEZE)
		return;
	if (isfriend (other) && self != other)
		return;
	if (other.effects & EF_FROZEN)
		return;

	other.effects = other.effects | EF_FROZEN;
	self.runetime = time + 3;
	Blizzard_Freeze (other, 1);
};

void ()
Rune_Thor =
{
	if (!self.items & IT_LIGHTNING)
		self.items = self.items | IT_LIGHTNING;

	if (self.ammo_cells >= MAX_CELLS)
		return;

	if (self.runetime > time)
		return;

	self.runetime = time + 0.6;

	if (self.ammo_cells < MAX_CELLS)
		self.ammo_cells = self.ammo_cells + 1;

	if (self.ammo_cells < 50)
		self.ammo_cells = 50;

	set_current_ammo ();
};

void ()
Sniper_Touch =
{
	if (other.solid == SOLID_TRIGGER)
		return;

	if (other.takedamage)
	{
		T_Damage (other, self, self.owner, SURE_KILL_DAMAGE, "sniped");

		if (other.classname == "player")
			self.owner.runevar = self.owner.runevar + 25;
	}
	else
		create_te_spike (TE_SUPERSPIKE, self.origin);

	remove (self);
};

void ()
Rune_Sniper =
{
	if (self.runetime > time)
		return;

	if (!W_CheckNoAmmo ())
		return;

	T_Damage (self, self, self, (25 + (random () * self.runevar)), "sniped");
	sound (self, CHAN_WEAPON, "weapons/ric3.wav", 1, ATTN_NORM);

	makevectors (self.v_angle);
	launch_spike (self.origin + PLAYER_WEAPON_OFFSET, v_forward);

	newmis.touch = Sniper_Touch;

	//setmodel (newmis, "progs/s_spike.mdl");
	setmodel (newmis, "progs/laser.mdl");
	setsize (newmis, VEC_ORIGIN, VEC_ORIGIN);

	smallkick ();
	self.runetime = time + 0.1;
};

void (entity e, float dist, float is_next)
sonar_sprint =
{
	local string s;

	if (is_next)
		self_sprint (self, "\n");

	self_sprintf_len (self, e.netname, -16);

	self_sprint (self, "\bD");
	s = ftos (rint (dist));
	self_sprintf_len (self, s, -4);

	self_sprint (self, " ");
	if	(e.items & IT_ARMOR3 || e.armorvalue > MAX_ARMOR_3)	self_sprint (self, "\bR");
	else if (e.items & IT_ARMOR2)					self_sprint (self, "\bY");
	else if	(e.items & IT_ARMOR1)					self_sprint (self, "\bG");
	else								self_sprint (self, " ");

	self_sprint (self, "\bA");
	s = ftos (e.armorvalue);
	self_sprintf_len (self, s, -3);
	self_sprint (self, " \bH");
	s = ftos (e.health);
	self_sprintf_len (self, s, -3);

	self_sprint (self, " ");
	if	(e.items & IT_INVULNERABILITY)				self_sprint (self, "\bP");
	if	(e.items & IT_QUAD)					self_sprint (self, "\bQ");
};

void ()
Rune_Sonar =
{
	local entity head, e1, e2, e3, e4;
	local float d1, d2, d3, d4, dist;

	if (self.runetime > time)
		return;

	self.runetime = time + 4;
	// self.runevar = 0;

	head = findradius (self.origin, 1600);
	while (head)
	{
		if (head.classname == "player")
		{
			if (head.health > 0 && head != self)
			{
				if (!environmental (head))
				{
					// XXX Only sonar holder should hear this.
					cloaked_sound (head, CHAN_WEAPON, "enforcer/sight3.wav", 1, ATTN_NORM);

					// Pingee has cloak, make him visible.
					if (head.runetype == RN_CLOAK)
						head.runetime = time + 1;

					dist = vlen (head.origin - self.origin);
					dist = floor (dist / 32);

					if (!d1 || dist < d1)
					{
						if (!d1)
						{
							d1 = dist;
							e1 = head;
						}
						else
						{
							d4 = d3;
							e4 = e3;

							d3 = d2;
							e3 = e2;

							d2 = d1;
							e2 = e1;

							d1 = dist;
							e1 = head;
						}
					}
					else if (!d2 || dist < d2)
					{
						if (!d2)
						{
							d2 = dist;
							e2 = head;
						}
						else
						{
							d4 = d3;
							e4 = e3;

							d3 = d2;
							e3 = e2;

							d2 = dist;
							e2 = head;
						}
					}
					else if (!d3 || dist < d3)
					{
						if (!d3)
						{
							d3 = dist;
							e3 = head;
						}
						else
						{
							d4 = d3;
							e4 = e3;

							d3 = dist;
							e3 = head;
						}
					}
					else if (!d4 || dist < d4)
					{
						d4 = dist;
						e4 = head;
					}
				}
			}
		}
		head = head.chain;
	}

	if (e1)
	{
		sonar_sprint (e1, d1, FALSE);
		if (e2)
		{
			sonar_sprint (e2, d2, TRUE);
			if (e3)
			{
				sonar_sprint (e3, d3, TRUE);
				if (e4)
					sonar_sprint (e4, d4, TRUE);
			}
		}
		self_sprint (self, "\n");
	}
	else
		sprint (self, "\{141} Uncloaked.\n");
};

void (float riders, entity of_e)
Rune_AntiPack_sprint =
{
	rprint_numdesc (self, riders, of_e.runevar, "anti-pack");
	rprint (self, riders, " placed\n");
};

void ()
AntiPack_Think =
{
	self.nextthink = time + 1;
	IN_POQ([-


		if (teamplay & (TEAM_TEAM_MASK | TEAM_MODE_MATCH))
		{
			local float particle_team;

			particle_team = team_to_particle (self.owner.team);
			particle (self.origin, '0 0 10', particle_team, 20);
		}
		else
			particle (self.origin, '0 0 10', 73, 20);
	-], [-
		create_te_blood (self.origin + '0 0 10', 2);
	-])

	if (self.runetime < time)
	{
		if (maybe_update_trap_count (self.owner, RN_ANTIPACK))
			self_sprint (self.owner, "An anti-pack expired\n");

		remove (self);
	}
};

void (.float ammo_type)
antipack_maybe_remove_ammo =
{
	local float n;

	n = floor (random () * (other.ammo_type / 2));
	if (n <= other.ammo_type)
		other.ammo_type = other.ammo_type - n;
	else
		other.ammo_type = 0;
};

void ()
AntiPack_Touch =
{
	local entity os;
	local float i, it;

	if (other == world)
		return;

	if (other.classname != "player")
		return;

	if (other.health <= 0)
		return;

	if (isfriend2 (self.owner, other))
		return;

	if (environmental (other))
		return;

	maybe_update_trap_count (self.owner, RN_ANTIPACK);

	centerprint (other, "You picked up an anti-pack!");
	bprint (other.netname);
	bprint (" picked up ");
	bprint (self.owner.netname);
	bprint ("'s anti-pack!\n");

	sound (other, CHAN_ITEM, "weapons/lock4.wav", 1, ATTN_NORM);
	sound (other, CHAN_BODY, "demon/ddeath.wav", 1, ATTN_NORM);

	stuffcmd (other, "bf\n");

	antipack_maybe_remove_ammo (ammo_shells);
	antipack_maybe_remove_ammo (ammo_nails);
	antipack_maybe_remove_ammo (ammo_rockets);
	antipack_maybe_remove_ammo (ammo_cells);

	for (i = 8; i > 2; i = i - 1)
	{
		it = weapon_num_to_it (i);
		if (other.items & it)
		{
			other.items = other.items - other.items & it;
			i = -1;
		}
	}

	if (other.weapon & it)
	{
		os = self;
		self = other;
		set_weapon (W_BestWeapon ());
		self = os;
	}

	remove (self);
};

void ()
AntiPack_Arm =
{
	self.nextthink	= time;
	self.runetime	= time + DROP_BACKPACK_DURATION;
	self.think	= AntiPack_Think;
	self.touch	= AntiPack_Touch;
};

void ()
Rune_AntiPack =
{
	local entity antipack;
	local string s, s1;

	if (gamemode == MODE_PRACTICE)
		return centerprint (self, "Rune disabled in practice mode\n");

	if (self.runevar >= MAX_ANTIPACK)
	{
		s = ftos (MAX_ANTIPACK);
		if (MAX_ANTIPACK != 1)
			s1 = "s";
		centerprint5 (self, "Only ", s, " anti-pack", s1, " allowed");
		return;
	}
	self.runevar		= self.runevar + 1;

	antipack		= spawn ();
	antipack.flags		= FL_ITEM;
	antipack.solid		= SOLID_TRIGGER;
	antipack.movetype	= MOVETYPE_TOSS;
	antipack.owner		= self;
	antipack.classname	= "antipack";

	setorigin (antipack, self.origin - '0 0 24');
	setmodel (antipack, "progs/backpack.mdl");
	setsize (antipack,'-16 -16 0', '16 16 56');

	antipack.think		= AntiPack_Arm;
	antipack.nextthink	= time + 3;

	sound (self, CHAN_WEAPON, "demon/dhit2.wav", 1, ATTN_NORM);
	centerprint (self, "Anti-pack dropped!");
};

void ()
Rune_Deflect_Telefrag =
{
	if (other.health <= 0)
		return;

	centerprint (other, "You deflected a telefrag!");
};

void ()
Launch_Betty =
{
	newmis			= spawn ();

	if (!self.owner)
		newmis.owner	= self;
	else
		newmis.owner	= self.owner;

	newmis.movetype		= MOVETYPE_BOUNCE;
	newmis.solid		= SOLID_BBOX;

	newmis.touch		= GrenadeTouch;
	newmis.classname	= "betty";
	newmis.think		= GrenadeExplode;

	newmis.nextthink	= time + 0.75 + random ();

	// Assign a random direction for the shrapnel to fly in
	newmis.velocity_x	= 5 * (110 * random () - 55);
	newmis.velocity_y	= 5 * (110 * random () - 55);
	newmis.velocity_z	= 10 * (50 * random () - 25);

	newmis.avelocity_x	= 250 + (random () * 150);
	newmis.avelocity_y	= 250 + (random () * 150);
	newmis.avelocity_z	= 250 + (random () * 150);

	setmodel (newmis, "progs/grenade.mdl");
	setsize (newmis, VEC_ORIGIN, VEC_ORIGIN);
	setorigin (newmis, self.origin + '0 0 -1');
};

// This code segment detonates the 'second stage' of the grenade
// (After it has popped up)
void ()
Betty_Package_Explode =
{
	local float i;

        monk_radius_hack = 1;
        T_RadiusDamage (RADIUS_NORMAL, self, self.owner, 200, world, "betty");
	monk_radius_hack = 0;

	for (i = MAX_LAUNCH_BETTY; i >= 0; i = i - 1)
		Launch_Betty ();

	create_te_explosion (self.origin, 1);
};

void ()
Betty_Touch =
{
	if (self.velocity == VEC_ORIGIN)
		self.avelocity = VEC_ORIGIN;

	sound (self, CHAN_AUTO, "weapons/bounce.wav", 1, ATTN_NORM);
};

void ()
Launch_Betty_Package =
{
	local entity missile;

	sound (self, CHAN_WEAPON, "weapons/grenade.wav", 1, ATTN_NORM);

	// Spawn and animate the 'second stage'
	missile			= spawn ();
	missile.owner		= self.owner;
	missile.movetype	= MOVETYPE_BOUNCE;
	missile.solid		= SOLID_BBOX;
	missile.classname	= "betty-package";

	// Set speed
	missile.velocity	= '0 0 650';
	missile.angles		= vectoangles (missile.velocity);
	missile.touch		= Betty_Touch;

	// Set Duration
	missile.nextthink	= time + 0.5;
	missile.think		= Betty_Package_Explode;

	setmodel (missile, "progs/missile.mdl");
	setsize (missile, VEC_ORIGIN, VEC_ORIGIN);
	setorigin (missile, self.origin);

	BecomeExplosion ();
};

void ()
Rune_Betty =
{
	local float nospam;

	if (self.runevector_x > time)
		return;

	nospam = 0;
	if (gamemode == MODE_PRACTICE)
		nospam = 3;
	else if (self.ammo_rockets >= AMMO_BETTY)
	{
		self.ammo_rockets = self.ammo_rockets - AMMO_BETTY;
		set_current_ammo ();
	}
	else
	{
		sprint (self, "Not enough ammo\n");
		return;
	}

	self.runevector_x = time + 3 + nospam;

	W_FireGrenade ("betty");
};

void ()
tornado_move =
{
	local float rspeed;

	rspeed = 4 - (self.attack_finished - time);
	rspeed = rspeed * rspeed;

	self.runent.angles_y = self.runent.angles_y + (300 * sys_ticrate);

	if (self.runent.angles_y > 360)
		self.runent.angles_y = self.runent.angles_y - 360;

	makevectors (self.runent.angles);

	traceline (self.runent.origin, self.runent.origin + (v_forward * 7 * rspeed), 1, self.runent);
	self.origin = trace_endpos - v_forward + ('0 0 6' * rspeed);
};

void ()
tornado_pull =
{
	local entity e;
	local float d, dist, percent;

	dist = 960;

	if (self.runevar >= 512 && time < self.attack_finished + 0.5)
		self.runevar = 512;
	else
		self.runevar = self.runevar * 2;

	if (time > self.attack_finished)
	{
		if (self.effects & EF_BRIGHTLIGHT)
			self.effects = self.effects - EF_BRIGHTLIGHT;

		T_RadiusDamage (RADIUS_NORMAL, self, self.owner, 40, world, "tornado");
		remove (self.runent);
		create_te_explosion (self.origin, 1);
		return;
	}

	tornado_move ();

	e = findradius (self.origin, dist);
	while (e)
	{
		if (visible (e))
		{
			if (!environmental (e))
			{
				if (!isfriend2 (self.owner, e) || self.owner == e)
				{
					if (e.movetype != MOVETYPE_NONE && e.movetype != MOVETYPE_PUSH && e.movetype != MOVETYPE_NOCLIP && e.health > 0)
					{
						d = vlen (e.origin - self.origin);
						percent = 1 - (d / dist);

						e.velocity = e.velocity + '0 0 11' + normalize (self.origin - e.origin) * self.runevar * percent;
						e.flags = e.flags - e.flags & FL_ONGROUND;

						IN_POQ([-
							// Fire those particles toward the tornado
							if (teamplay & (TEAM_TEAM_MASK | TEAM_MODE_MATCH))
							{
								local float particle_team;

								particle_team = team_to_particle (self.owner.team);
								particle (e.origin + v_up * random () * 30, e.velocity, particle_team, 3);
							}
							else
								particle (e.origin + v_up * random () * 30, e.velocity, 96, 3);
						-])
					}
				}
			}
		}
		e = e.chain;
	}
	self.nextthink = time + sys_ticrate;
};

void ()
tornado_touch =
{
	if (other.health <= 0 || other == world)
		return;

	if (environmental (other))
		return;

	if (isfriend2 (self.owner, other) && self.owner != other)
		return;

	T_Damage (other, self, self.owner, self.runevar / 2, "tornado");
};

void ()
tornado_spawn =
{
	local entity e;

	e		= spawn ();
	e.classname	= "tornado_center";
	self.runent	= e;

	setorigin (e, self.origin + '0 0 1');

	self.attack_finished = time + 3 + random ();
	self.touch	= tornado_touch;
	self.effects	= self.effects | EF_BRIGHTLIGHT;
	self.think	= tornado_pull;
	self.nextthink	= time + 0.1;

	sound (self, CHAN_BODY, "boss1/out1.wav", 1, ATTN_NORM);
};

void ()
Rune_Tornado =
{
	local entity tornado;
	local float nospam;

	if (self.runevector_x > time)
		return;

	if (gamemode == MODE_PRACTICE)
		nospam = 13.5;
	else if (self.ammo_cells >= AMMO_TORNADO)
	{
		self.ammo_cells = self.ammo_cells - AMMO_TORNADO;
		set_current_ammo ();
	}
	else
	{
		sprint (self, "Not enough ammo\n");
		return;
	}

 	self.runevector_x	= time + 1.5 + nospam;

	tornado 		= spawn();
	tornado.classname	= "tornado";
	tornado.owner		= self;
	tornado.solid		= SOLID_TRIGGER;
	tornado.movetype	= MOVETYPE_TOSS;
	tornado.angles		= '90 0 0';
	tornado.runevar		= 1;

	setorigin (tornado, self.origin + self.view_ofs);
	setmodel(tornado, "progs/w_spike.mdl");

	tornado.think		= tornado_spawn;
	tornado.nextthink	= time + 2;

	sound (self, CHAN_BODY, "doors/meduse.wav", 1, ATTN_NORM);

	makevectors (self.angles);
	tornado.velocity	= (v_forward * 250) + (v_up * 250);
};
