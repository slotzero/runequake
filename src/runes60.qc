/*  $Id: runes60.qc,v 1.39 2004/05/03 10:38:29 slotzero Exp $

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
	if (self.runetime < time)
	{
		centerprint (self.runent, "Released from glue trap");
		sound (self, CHAN_WEAPON, "blob/death1.wav", 1, ATTN_NORM);
		remove (self);
		return;
	}

	if (self.runent.health <= 0)
	{
		remove (self);
		return;
	}

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

	if (!self.runevar)
		return;

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

	IN_POQ([-
		self.punchangle_x = -2;
	-])

	glue			= spawn();
	glue.owner		= self;
	glue.movetype		= MOVETYPE_BOUNCE;
	glue.solid		= SOLID_TRIGGER;
	glue.classname		= "glue";

	makevectors (self.v_angle);

	glue.velocity		= v_forward * 600 + v_up * 200;
	glue.avelocity		= '0 600 0';

	setmodel (glue, "progs/tarbaby.mdl");
	setsize (glue, '-16 -16 -24', '16 16 24');
	setorigin (glue, self.origin + '0 0 24');

	glue.touch		= Glue_Touch;
	glue.think		= Glue_Think;
	glue.nextthink		= time;
};

void (float riders, entity of_e)
Rune_Blizzard_sprint =
{
	if (self.runevar)
		rprint (self, riders, "Recharging...\n");
	else if (self.runevector_z)
		rprint (self, riders, "Super charged\n");
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
			if (!environmental (e) && e.runetype != RN_BLIZZARD && e.runetype != RN_FREEZE)
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

	if (self.runevector_z)
	{
		freeze_time = freeze_time + (self.runevector_z * 0.5);
		self.runevector_z = 0;
	}

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
	local vector dir;
	local float n;

	if (self.runetime > time)
		return;

	if (!W_CheckNoAmmo ())
		return;

	//use_ammo ();

	T_Damage (self, self, self, (25 + (random () * self.runevar)), "sniped");
	sound (self, CHAN_WEAPON, "weapons/ric3.wav", 1, ATTN_NORM);

	dir = aim (self, 1000) * 2;
	launch_spike (self.origin + PLAYER_WEAPON_OFFSET, dir);

	newmis.touch = Sniper_Touch;

	setmodel (newmis, "progs/s_spike.mdl");
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
	else
	{
		s = ftos (self.runevar);
		self_sprint (self, "\{141} ");
		self_sprint (self, s);
		self_sprint (self, " player");
		if (self.runevar > 1)
			self_sprint (self, "s");
		self_sprint (self, " detected\n\n");
  	}

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


	if (self.runetime > time)
		return;

	self.runetime = time + 3;

	local entity head, e1, e2, e3, e4;
	local float d1, d2, d3, d4, dist;

	self.runevar = 0;

	head = findradius (self.origin, 1600);
	while (head)
	{
		if (head.classname == "player")
		{
			if (head.health > 0 && head != self)
			{
				if (!environmental (head) || head.runetype != RN_CLOAK)
				{
					// XXX Only sonar holder should hear this.
					sound (head, CHAN_WEAPON, "enforcer/sight3.wav", 1, ATTN_NORM);

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

					self.runevar = self.runevar + 1;
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

	if (self.waterlevel > 1)
		sound (self, CHAN_WEAPON, "fish/idle.wav", 1.0, ATTN_NORM);
	else
		sound (self, CHAN_WEAPON, "wizard/widle1.wav", 0.8, ATTN_NORM);
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
		particle (self.origin, '0 0 10', 73, 20);
	-], [-
		create_te_blood (self.origin + '0 0 10', 2);
	-])

	if (self.runetime < time)
	{
		maybe_update_trap_count (self.owner, RN_ANTIPACK);
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

	if (other.health <= 0 || other == world)
		return;

	if (environmental (other))
		return;

	if (other == self.owner)
		return;

	maybe_update_trap_count (self.owner, RN_ANTIPACK);

	if (other.classname == "player")
	{
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

		if (other.weapon == it)
		{
			os = self;
			self = other;
			set_weapon (W_BestWeapon ());
			self = os;
		}

		remove (self);
	}
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

void (float riders, entity of_e)
Rune_Deflect_Telefrag_sprint =
{
	rprint_numdesc (self, riders, of_e.runevar, "telefrag deflect");
	rprint (self, riders, " left\n");
};

// Deflect telefrag can't be dropped directly after a deflect because tdeath_touch()
// is still looping and will telefrag you as soon as it detects your rune is gone.
// This function drops the rune at the same time tdeath_expires.
void ()
deflect_rune_removal =
{
	local entity os;

	if (self.owner.runetype == RN_DEFLECT)
	{
		sprint (self.owner, "Max telefrags deflected, rune removed.\n");

		os = self;
		self = self.owner;
		Rune_Delete (0);
		self = os;
	}
	remove (self);
};

void ()
Rune_Deflect_Telefrag =
{
	local entity rune_delete;

	if (other.health <= 0)
		return;

	if (other.runevar > 0)
	{
		other.runevar		= other.runevar - 1;
		centerprint (other, "You deflected a telefrag!");
	}

	if (other.runevar <= 0)
	{
		rune_delete		= spawn ();
		rune_delete.owner	= other;
		rune_delete.nextthink	= time + sys_ticrate * 2;
		rune_delete.think	= deflect_rune_removal;
	}
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
	// XXX Why?
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

void (float riders, entity of_e)
Rune_Betty_sprint =
{
	rprint_numdesc (self, riders, of_e.runevar, "betty");
	rprint (self, riders, " left\n");
};

void ()
Rune_Betty =
{
	if (self.runevector_x > time)
		return;

	self.runevar	= self.runevar - 1;
	self.runevector	= time + 3;

	W_FireGrenade ("betty");

	if (self.runevar == 1)
		sprint (self, "\{141} \b[warning]\b 1 betty left\n");

	if (!self.runevar)
	{
		sprint (self, "Max bouncing bettys launched, rune deleted\n");
		Rune_Delete (0);
	}
};

void ()
tornado_random_move =
{
	local float n;
	local vector v;

	self.velocity	= self.velocity * 0.2;
	n		= ceil (100 + (random () * 300));

	v_x = rint (random () * 2) - 1;
	v_y = rint (random () * 2) - 1;

	self.velocity = self.velocity + (v * n);
};

void ()
tornado_pull =
{
	local entity e;
	local vector org;
	local float d, gDist, gPower, gPercent;

	gDist = 960;

	//This makes the wind build up speed from 1 to 512 very rapidly
	gPower = self.runevar;

	if (gPower >= 512 && time < self.attack_finished + 0.5)
		gPower = 512;
	else
		self.runevar = self.runevar * 2;

	setorigin (self, self.origin + '0 0 2');

	self.movetype = MOVETYPE_FLYMISSILE;
	self.flags = self.flags - FL_ONGROUND;

	tornado_random_move ();

	if (time > self.attack_finished)
	{
		if (self.effects & EF_BRIGHTLIGHT)
			self.effects = self.effects - EF_BRIGHTLIGHT;

		T_RadiusDamage (RADIUS_NORMAL, self, self.owner, 40, world, "tornado");
		create_te_explosion (self.origin, 1);
		return;
	}

	org = (self.absmin + self.absmax) * 0.5;
	e = findradius (self.origin, gDist);
	while (e)
	{
		if (visible(e) && e.classname != "tornado"
				&& e.movetype != MOVETYPE_NONE
				&& e.movetype != MOVETYPE_PUSH
				&& e.movetype != MOVETYPE_NOCLIP
				&& !environmental (e)
				&& e.health)
		{
			d = vlen (e.origin - org);
			if (e.flags & FL_ONGROUND)
			{
				// raise the object a bit
				setorigin (e, e.origin + '0 0 1');
				e.flags = e.flags - FL_ONGROUND;
			}
			// dprint(e.classname);
			gPercent = 1 - (d / gDist);

			// modify the velocity
			// I added '0 0 10' to give it more lift (x y z, z being up and down)
			e.velocity = e.velocity + '0 0 10' + normalize (self.origin - e.origin) * gPower * gPercent;

			IN_POQ([-
				// Fire those particles toward the tornado
				particle (e.origin + v_up * random () * 30, e.velocity, 96, 3);
			-])
		}
			e = e.chain;
	}
	self.nextthink = time + sys_ticrate;
};

void ()
tornado_touch =
{
	if (other.health <= 0)
		return;

	if (environmental (other))
		return;

	T_Damage (other, self, self.owner, self.runevar / 2, "tornado");
};

void ()
tornado_explode =
{
	setmodel (self, "progs/w_spike.mdl");
	self.attack_finished = time + 3 + random ();      // duration of tornado well
	self.touch	= tornado_touch;
	self.effects	= self.effects | EF_BRIGHTLIGHT;
	self.think	= tornado_pull;
	self.nextthink	= time + 0.1;
	sound (self, CHAN_BODY, "boss1/out1.wav", 1, ATTN_NORM);
};

void (float riders, entity of_e)
Rune_Tornado_sprint =
{
	rprint_numdesc (self, riders, of_e.runevar, "tornado");
	rprint (self, riders, " left\n");
};

void ()
Rune_Tornado =
{
	local entity tornado;

	if (self.runevector_x > time)
		return;
 	self.runevector_x = time + 1.5;

	self.runevar		= self.runevar - 1;
	if (self.runevar <= 0)
	{
		sprint (self, "Max tornados spawned, rune deleted\n");
		Rune_Delete (0);
	}

	// create a tornado object
	tornado			= spawn();
	tornado.classname	= "tornado";

	tornado.owner		= self;
	tornado.solid		= SOLID_TRIGGER;
	tornado.movetype	= MOVETYPE_TOSS;

	// set it's placement and velocity

	setorigin (tornado, self.origin + self.view_ofs);

	tornado.velocity	= self.velocity * 0.5;

	setmodel(tornado, "progs/w_spike.mdl");

	// XXX get accurate sizing
	setsize (tornado, VEC_ORIGIN, '32 32 32');

	tornado.angles		= '90 0 0';
	tornado.runevar		= 1;
	tornado.think		= tornado_explode;
	tornado.nextthink	= time + 2;

	sound (self, CHAN_BODY, "doors/meduse.wav", 1, ATTN_NORM);

	// Throw away from you
	makevectors (self.angles);
	tornado.velocity = (v_forward * (200 + random() * 100)) + (v_up * (200 + random() * 100));
};
