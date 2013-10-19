/*
    Copyright (C) 1996, 1997  Id Software, Inc.

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

float ()
crandom =
{
	return 2 * (random () - 0.5);
};

/*
================
W_FireAxe
================
*/
void ()
W_FireAxe =
{
	local vector org, source;
	local float damage, reach;
	local string dtype;

	if (self.runetype == RN_LUMBER)
	{
		reach	= AXE_REACH_LUMBER;
		damage	= AXE_DAMAGE_LUMBER;
		dtype	= "lumber";
	}
	else
	{
		reach	= AXE_REACH_NORMAL;
		damage	= AXE_DAMAGE_NORMAL;
		dtype	= "axe";
	}

	spawn_protect_off ();
	makevectors (self.v_angle);
	source = self.origin + PLAYER_WEAPON_OFFSET;
	traceline (source, source + v_forward * reach, FALSE, self);
	if (trace_fraction == 1.0)
		return;

	org = trace_endpos - v_forward * 4;

	if (trace_ent.takedamage)
	{
		SpawnBlood (org, VEC_ORIGIN, IN_POQ(20, 1));
		T_Damage (trace_ent, self, self, damage, dtype);
	}
	else
	{
		sound (self, CHAN_BODY, "player/axhit2.wav", 1, ATTN_NORM);
		create_te_gunshot (org, 1);
	}
};

//============================================================================

vector ()
wall_velocity =
{
	local vector vel;

	vel = normalize (self.velocity);
	vel = normalize (vel + v_up * (random () - 0.5) + v_right * (random () - 0.5));
	vel = vel + 2 * trace_plane_normal;
	vel = vel * 200;

	return vel;
};

/*
================
SpawnMeatSpray
================
*/
void (vector org, vector vel)
SpawnMeatSpray =
{
	local	entity missile;

	missile			= spawn ();
	missile.owner		= self;
	missile.movetype	= MOVETYPE_BOUNCE;
	missile.solid		= SOLID_NOT;

	makevectors (self.angles);

	missile.velocity	= vel;
	missile.velocity_z	= missile.velocity_z + 250 + 50 * random ();

	missile.avelocity	= '3000 1000 2000';

	// set missile duration
	missile.nextthink	= time + 1;
	missile.think		= SUB_Remove;

	setmodel (missile, "progs/zom_gib.mdl");
	setsize (missile, VEC_ORIGIN, VEC_ORIGIN);
	setorigin (missile, org);
};

/*
================
SpawnBlood
================
*/
void (vector org, vector vel, float damage)
SpawnBlood =
{
	IN_POQ([-
		particle (org, vel * 0.1, PARTICLE_BLOOD, damage * 2);
	-], [-
		create_te_blood (org, damage);
	-])
};

/*
================
spawn_touchblood
================
*/
void (float damage)
spawn_touchblood =
{
	local vector vel;

	if (0) damage = damage;	// prevent frikqcc compiler warning;

	vel = wall_velocity () * 0.2;
	SpawnBlood (self.origin + vel * 0.01, vel, IN_POQ(damage, 1));
};

/*
==============================================================================

MULTI-DAMAGE

Collects multiple small damages into a single damage

==============================================================================
*/

entity	multi_ent;
float	multi_damage;
string	multi_dtype;
vector	blood_org, blood_vel, puff_org;
float	blood_count, puff_count;

void ()
ClearMultiDamage =
{
	multi_ent	= world;
	multi_damage	= 0;
	blood_count	= 0;
	puff_count	= 0;
};

void ()
ApplyMultiDamage =
{
	if (!multi_ent)
		return;
	T_Damage (multi_ent, self, self, multi_damage, multi_dtype);

	// efficiency
	self.shell_dmg = self.shell_dmg + multi_damage;
};

void (entity hit, float damage, string dtype)
AddMultiDamage =
{
	if (!hit)
		return;
	if (hit != multi_ent || dtype != multi_dtype)
	{
		ApplyMultiDamage ();
		multi_damage = 0;
		multi_ent = hit;
		multi_dtype = dtype;
	}
	multi_damage = multi_damage + damage;
};

void() Multi_Finish =
{
        if (blood_count)
		SpawnBlood (blood_org, blood_vel, blood_count);
        if (puff_count)
		create_te_gunshot (puff_org, puff_count);
};

/*
==============================================================================

BULLETS

==============================================================================
*/

/*
================
TraceAttack
================
*/
void (float damage, vector dir, string dtype)
TraceAttack =
{
	local vector vel, org;

	vel = normalize (dir + v_up * crandom () + v_right * crandom ());
	vel = vel + 2 * trace_plane_normal;
	vel = vel * 200;

	org = trace_endpos - dir * 4;

	if (trace_ent.takedamage)
	{
		blood_count	= blood_count + IN_POQ(damage, 1);
		blood_org	= org;
		blood_vel	= vel * 0.2;
		AddMultiDamage (trace_ent, damage, dtype);
	}
	else
	IN_POQ([-
	{
		WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
		WriteByte (MSG_BROADCAST, TE_GUNSHOT);
		WriteCoord (MSG_BROADCAST, org_x);
		WriteCoord (MSG_BROADCAST, org_y);
		WriteCoord (MSG_BROADCAST, org_z);
	}
	-], [-
		puff_count	= puff_count + 1;
	-])
};

/*
================
FireBullets

Used by shotgun, super shotgun, and enemy soldier firing
Go to the trouble of combining multiple pellets into a single damage call.
================
*/
void (float shotcount, vector dir, vector spread, string dtype)
FireBullets =
{
	local vector direction;
	local vector src;

	makevectors (self.v_angle);

	src	= self.origin + v_forward * 10;
	src_z	= self.absmin_z + self.size_z * 0.7;

	ClearMultiDamage ();

	traceline (src, src + dir * 2048, FALSE, self);
	puff_org = trace_endpos - dir * 4;

	while (shotcount > 0)
	{
		direction = dir + crandom () * spread_x * v_right + crandom () * spread_y * v_up;

		traceline (src, src + direction * 2048, FALSE, self);
		if (trace_fraction != 1.0)
			TraceAttack (4, direction, dtype);

		shotcount = shotcount - 1;
	}
	ApplyMultiDamage ();
	Multi_Finish ();
};

/*
================
W_FireShotgun
================
*/
void ()
W_FireShotgun =
{
	sound (self, CHAN_WEAPON, "weapons/guncock.wav", 1, ATTN_NORM);
	smallkick ();
	FireBullets (6, v_forward, '0.04 0.04 0', "shotgun");

	// efficiency
	self.shell_dmg_max = self.shell_dmg_max + 24;
};

void ()
MagicShotgun_Think =
{
	create_te_explosion (self.origin, 1);
};

/*
================
W_ShotgunBomb
================
*/
void ()
W_MagicShotgun =
{
	local entity bomb;
	local vector o;

	sound (self, CHAN_WEAPON, "hknight/attack1.wav", 1, ATTN_NORM);

	bomb		= spawn ();
	o		= self.origin + '0 0 16';
	bomb.think	= MagicShotgun_Think;
	bomb.nextthink	= time;

	traceline (o, o + v_forward * 1000000, FALSE, self);
	setorigin (bomb, trace_endpos);

	monk_radius_hack = 1;
	T_RadiusDamage (RADIUS_NORMAL, bomb, self, 35, other, "magic-shotgun");
	monk_radius_hack = 0;
};

/*
================
W_FireSuperShotgun
================
*/
void ()
W_FireSuperShotgun =
{
	sound (self, CHAN_WEAPON, "weapons/shotgn2.wav", 1, ATTN_NORM);
	bigkick ();
	FireBullets (14, v_forward, '0.14 0.08 0', "supershotgun");

	// efficiency
	self.shell_dmg_max = self.shell_dmg_max + 56;
};

/*
==============================================================================

ROCKETS

==============================================================================
*/

void ()	s_explode1 = [0, s_explode2] {};
void ()	s_explode2 = [1, s_explode3] {};
void ()	s_explode3 = [2, s_explode4] {};
void ()	s_explode4 = [3, s_explode5] {};
void ()	s_explode5 = [4, s_explode6] {};
void ()	s_explode6 = [5, SUB_Remove] {};

void ()
BecomeExplosion =
{
	self.movetype	= MOVETYPE_NONE;
	self.velocity	= VEC_ORIGIN;
	self.touch	= SUB_Null;
	setmodel (self, "progs/s_explod.spr");
	self.solid	= SOLID_NOT;
	s_explode1 ();
};

// explosion effect with radius damage
void ()
RocketDamageExplosion =
{
	local float damg;

	if (self.classname == "gmissile")
		damg = GUIDED_MISSILE_DAMAGE;
	else if (self.classname == "reflect")
		damg = REFLECT_DAMAGE;
	else
		damg = 120;

	monk_radius_hack = 1;
	T_RadiusDamage (RADIUS_NORMAL, self, self.owner, damg, world, self.classname);
	monk_radius_hack = 0;

	create_te_explosion (self.origin, 1);
};

// reflect rocket
void ()
reflect_projectile =
{
	if (self.velocity == VEC_ORIGIN)
	{
		create_te_explosion (self.origin, 1);
		return;
	}
	else
		self.angles = vectoangles (self.velocity);

	random_sound2 (self, CHAN_WEAPON, "weapons/ric2.wav", "weapons/ric3.wav", 1, ATTN_NORM);
	create_te_explosion (self.origin, 0);

	self.movetype	= MOVETYPE_FLYMISSILE;
	self.nextthink	= time + 1;
	self.think	= RocketDamageExplosion;
};

void ()
T_MissileTouch =
{
	local float damg, gmissile, reflect;
	local entity head;

	// don't explode on owner
	if (other == self.owner)
		return;

	// guided missile
	gmissile = self.classname == "gmissile";

	// reflect rocket
	reflect = self.classname == "reflect";

	if (pointcontents (self.origin) == CONTENT_SKY)
	{
		if (gmissile)
			restore_gmissile_owner (self.owner);

		remove (self);
		return;
	}

	if (other.health)
	{
		damg = 100 + random () * 20;
		if (other.classname == "monster_shambler")
			damg = damg * 0.5;	// mostly immune
		T_Damage (other, self, self.owner, damg, self.classname);

		// efficiency
		if (other.classname == "player")
		{
			self.rocket_dmg = TRUE;
			self.owner.rocket_dmg = self.owner.rocket_dmg + damg;
		}
	}

	// efficiency
	if (!self.rocket_dmg)
	{
		head = findradius (self.origin, 250);
		while (head)
		{
			if (head != self.owner && head.classname == "player")
			{
				self.rocket_dmg = TRUE;
				head = world;
			}
			else
				head = head.chain;
		}
	}

	if (gmissile)
		damg = GUIDED_MISSILE_DAMAGE;
	else if (reflect)
		damg = REFLECT_DAMAGE;
	else
		damg = 120;

	// don't do radius damage to the other, because all the damage
	// was done in the impact
	monk_radius_hack = 1;
	T_RadiusDamage (RADIUS_NORMAL, self, self.owner, damg, other, self.classname);
	monk_radius_hack = 0;

	self.origin = self.origin - 8 * normalize (self.velocity);

	// efficiency
	if (self.rocket_dmg && self.owner.classname == "player")
		self.owner.rocket_dmg_max = self.owner.rocket_dmg_max + 120;

	if (gmissile)
		restore_gmissile_owner (self.owner);

	if (reflect)
	{
		if (self.runevar == 2)
			create_te_explosion (self.origin, 1);
		else
		{
			self.runevar = self.runevar + 1;
			self.movetype = MOVETYPE_BOUNCE;
			self.nextthink = time;
			self.think = reflect_projectile;
			self.velocity = self.velocity * 1.4;
			return;
		}
	}
	else
		create_te_explosion (self.origin, 1);
};

/*
================
W_FireRocket
================
*/
void (string class)
W_FireRocket =
{
	local entity head;

	sound (self, CHAN_WEAPON, "weapons/sgun1.wav", 1, ATTN_NORM);
	smallkick ();

	newmis			= spawn ();
	newmis.owner		= self;
	newmis.movetype		= MOVETYPE_FLYMISSILE;
	newmis.solid		= SOLID_BBOX;
	newmis.classname	= class;

	// I don't want to calculate efficiency every time you fire a rocket,
	// so I check for nearby enemies when the rocket is launched and
	// again when it explodes.
	newmis.rocket_dmg	= FALSE;

	// set missile speed
	makevectors (self.v_angle);
	newmis.velocity		= v_forward * 1000;
	newmis.angles		= vectoangles (newmis.velocity);

	newmis.touch		= T_MissileTouch;

	// set missile duration
	newmis.nextthink	= time + 5;
	newmis.think		= SUB_Remove;

	setmodel (newmis, "progs/missile.mdl");
	setsize (newmis, VEC_ORIGIN, VEC_ORIGIN);
	setorigin (newmis, self.origin + v_forward * 8 + PLAYER_WEAPON_OFFSET);

	// guided missile
	if (newmis.classname == "gmissile")
		W_FireGuidedMissile();

	// efficiency
	head = findradius (self.origin, 250);
	while (head)
	{
		if (head != self && head.classname == "player")
		{
			newmis.rocket_dmg = TRUE;
			head = world;
		}
		else
			head = head.chain;
	}
};

/*
===============================================================================

LIGHTNING

===============================================================================
*/

void (entity from, float damage, string dtype)
LightningHit =
{
	IN_POQ([-
		particle (trace_endpos, '0 0 100', PARTICLE_ENT_DAMAGE, damage * 4);
	-], [-
		create_te_lightningblood (trace_endpos);
	-])

	T_Damage (trace_ent, from, from, damage, dtype);

	// efficiency
	if (dtype == "lightning")
		from.cell_dmg = from.cell_dmg + damage;
};

/*
=================
LightningDamage
=================
*/
void (vector p1, vector p2, entity from, float damage, string dtype)
LightningDamage =
{
	traceline (p1, p2, FALSE, self);
	if (trace_ent.takedamage)
		LightningHit (from, damage, dtype);
};

void ()
W_FireLightning =
{
	local	vector		org;
	local	float		cells;

	if (!W_CheckNoAmmo ())
		return;

	// explode if under water
	if (self.runetype != RN_THOR && self.waterlevel > SAFE_DISCHARGE_WATERLEVEL)
	{
		cells = self.ammo_cells;
		self.ammo_cells = 0;
		set_current_ammo ();
		monk_radius_hack = 1;
		discharge_hack = 1;
		T_RadiusDamage (RADIUS_NORMAL, self, self, 35*cells, world, "discharge");
		discharge_hack = 0;
		monk_radius_hack = 0;
		return;
	}

	use_ammo ();

	if (self.runetype == RN_CLOAK)
		self.runetime = time + RECLOAK_DELAY;
	else if (self.runetype == RN_THOR)
	{
		if (self.runetime < time + 2)
			self.runetime = time + 2;
	}

	if (self.t_width < time)
	{
		sound (self, CHAN_WEAPON, "weapons/lhit.wav", 1, ATTN_NORM);
		self.t_width = time + 0.6;
	}
	smallkick ();

	makevectors (self.v_angle);

	org = self.origin + PLAYER_WEAPON_OFFSET;

	//RUNE SERV: Haste makes lightning fire twices as far
	if (self.runetype == RN_HASTE)
		traceline (org, org + v_forward*1200, TRUE, self);
	else if (self.runetype == RN_JACK)
		traceline (org, org + v_forward*750, TRUE, self);
	else
		traceline (org, org + v_forward*600, TRUE, self);
	create_te_lightning (TE_LIGHTNING2, self, org, trace_endpos);
	LightningDamage (org, trace_endpos + v_forward*4, self, 30, "lightning");

	// efficiency
	self.cell_dmg_max = self.cell_dmg_max + 30;
};

//=============================================================================

void (entity targ)
GrenadeExplode_targ =
{
	if (self.classname == "gasbomb")
		Gas_Cloud ();

	if (targ)
		T_Damage (targ, self, self.owner, 100 + (random () + 0.01) * 20, self.classname);

	monk_radius_hack = 1;
	T_RadiusDamage (RADIUS_NORMAL, self, self.owner, 120, targ, self.classname);
	monk_radius_hack = 0;

	create_te_explosion (self.origin, 1);
};

void ()
GrenadeExplode =
{
	GrenadeExplode_targ (world);
};

void ()
GrenadeTouch =
{
	if (other == self.owner)
		return;		// don't explode on owner
	if (other.takedamage == DAMAGE_AIM)
	{
		GrenadeExplode_targ (other);
		return;
	}
	sound (self, CHAN_WEAPON, "weapons/bounce.wav", 1, ATTN_NORM);	// bounce sound
	if (self.velocity == VEC_ORIGIN)
		self.avelocity = VEC_ORIGIN;
};

/*
================
W_FireGrenade
================
*/
void (string class)
W_FireGrenade =
{
	local float eff, spam_cnt;
	local string snd;

	if (class == "flashgrenade")
	{
		snd	= "demon/dhit2.wav";
		eff	= EF_DIMLIGHT;
	}
	else
	{
		snd	= "weapons/grenade.wav";
		eff	= 0;
	}

	if (gamemode == MODE_PRACTICE || GRENADE_SPAM_OVERRIDE)
	{
		if (self.grenade_spam_time > time)
		{
			spam_cnt = ceil (self.grenade_spam_time - time);

			if (spam_cnt > 4)
			{
				set_weapon (W_BestWeapon ());
				self.items = self.items - self.items & IT_GRENADE_LAUNCHER;
				// self.grenade_spam_time = -1; // spam fix
				sprint (self, "\b\<Grenade Spam Protection Activated\>\b\n");
			}
		}

		// if (self.grenade_spam_time >= 0) // spam fix
			self.grenade_spam_time = time + spam_cnt + 1;
	}

	sound (self, CHAN_WEAPON, snd, 1, ATTN_NORM);
	smallkick ();

	newmis			= spawn ();
	newmis.owner		= self;
	newmis.movetype		= MOVETYPE_BOUNCE;
	newmis.solid		= SOLID_BBOX;
	newmis.classname	= class;
	newmis.effects		= eff;

	// set missile speed

	makevectors (self.v_angle);

	if (self.v_angle_x)
		newmis.velocity = v_forward * 600 + v_up * 200 + crandom () * v_right * 10 + crandom () * v_up * 10;
	else
	{
		newmis.velocity = v_forward * 600;
		newmis.velocity_z = 200;
	}

	newmis.avelocity	= '300 300 300';
	newmis.angles		= vectoangles (newmis.velocity);

	if (class == "betty")
	{
		newmis.touch		= Betty_Touch;
		newmis.nextthink	= time + 1;
		newmis.think		= Launch_Betty_Package;
	}
	else
	{
		newmis.touch		= GrenadeTouch;
		newmis.nextthink	= time + 2.5;
		newmis.think		= GrenadeExplode;
	}

	setmodel (newmis, "progs/grenade.mdl");
	setsize (newmis, VEC_ORIGIN, VEC_ORIGIN);
	setorigin (newmis, self.origin);
};

//=============================================================================

/*
===============
launch_spike

Used for both the player and the ogre
===============
*/
void (vector org, vector dir)
launch_spike =
{
	newmis = spawn ();
	newmis.owner = self;
	newmis.movetype = MOVETYPE_FLYMISSILE;
	newmis.solid = SOLID_BBOX;

	newmis.angles = vectoangles (dir);

	newmis.touch = spike_touch;
	newmis.classname = "spike";
	newmis.think = SUB_Remove;
	newmis.nextthink = time + 6;
	setmodel (newmis, "progs/spike.mdl");
	setsize (newmis, VEC_ORIGIN, VEC_ORIGIN);
	setorigin (newmis, org);

	//RUNE SERV: Haste rune makes them fly faster
	if (self.runetype == RN_HASTE)
		newmis.velocity = dir * 2000;
	else if (self.runetype == RN_JACK)
		newmis.velocity = dir * 1250;
	else
		newmis.velocity = dir * 1000;
};

void ()
W_FireSuperSpikes =
{
	sound (self, CHAN_WEAPON, "weapons/spike2.wav", 1, ATTN_NORM);
	self.attack_finished = time + 0.2;
	makevectors (self.v_angle);
	launch_spike (self.origin + PLAYER_WEAPON_OFFSET, v_forward);
	newmis.touch = superspike_touch;
	setmodel (newmis, "progs/s_spike.mdl");
	setsize (newmis, VEC_ORIGIN, VEC_ORIGIN);
	smallkick ();

	// efficiency
	self.nail_dmg_max = self.nail_dmg_max + 18;
};

void (float ox)
W_FireSpikes =
{
	if (!W_CheckNoAmmo ())
		return;
	use_ammo ();

	if (self.runetype == RN_CLOAK)
		self.runetime = time + RECLOAK_DELAY;

	if (self.weapon == IT_SUPER_NAILGUN)
	{
		W_FireSuperSpikes ();
		return;
	}

	makevectors (self.v_angle);

	if (self.weapon == WEAPON_LAVA)
	{
		W_FireFlameMissile ("lavagun", ox);
		return;
	}

	sound (self, CHAN_WEAPON, "weapons/rocket1i.wav", 1, ATTN_NORM);
	self.attack_finished = time + 0.2;
	launch_spike (self.origin + PLAYER_WEAPON_OFFSET + v_right*ox, v_forward);
	smallkick ();

	// efficiency
	self.nail_dmg_max = self.nail_dmg_max + 9;
};

void ()
spike_touch =
{
	local float type;

	if (other == self.owner)
		return;

	if (other.solid == SOLID_TRIGGER)
		return;	// trigger field, do nothing

	if (pointcontents (self.origin) == CONTENT_SKY)
	{
		remove (self);
		return;
	}

	// hit something that bleeds
	if (other.takedamage)
	{
		spawn_touchblood (9);
		T_Damage (other, self, self.owner, 9, "nail");

		// efficiency
		self.owner.nail_dmg = self.owner.nail_dmg + 9;
	}
	else
	{
		// developing reflect code
		if (0)
		{
			if (self.runevar == 1)
				create_te_spike (type, self.origin);
			else
			{
				self.runevar	= 1;
				self.movetype	= MOVETYPE_BOUNCE;
				self.nextthink	= time;
				self.think	= reflect_projectile;

				return;
			}
		}
		else
		{
			if (self.classname == "wizspike")
				type = TE_WIZSPIKE;
			else if (self.classname == "knightspike")
				type = TE_KNIGHTSPIKE;
			else
				type = TE_SPIKE;

			create_te_spike (type, self.origin);
		}
	}

	remove (self);
};

void ()
superspike_touch =
{
	if (other == self.owner)
		return;

	if (other.solid == SOLID_TRIGGER)
		return;	// trigger field, do nothing

	if (pointcontents (self.origin) == CONTENT_SKY)
	{
		remove (self);
		return;
	}

	// hit something that bleeds
	if (other.takedamage)
	{
		spawn_touchblood (18);
		T_Damage (other, self, self.owner, 18, "supernail");

		// efficiency
		self.owner.nail_dmg = self.owner.nail_dmg + 18;
	}
	else
		create_te_spike (TE_SUPERSPIKE, self.origin);

	remove (self);
};

/*
===============================================================================

PLAYER WEAPON USE

===============================================================================
*/

void (float reset)
W_SetCurrentAmmo =
{
	local string m;
	local float w, ammo_type;

	ammo_type = weapon_it_ammo_type (self.weapon);
	self.currentammo = ammo_type_cur_ammo (ammo_type);

	if (!reset)
		return;

	w = self.weapon & WEAPON_NONALT_MASK;
	if (w == IT_AXE)			m = "progs/v_axe.mdl";
	else if (w == IT_SHOTGUN)		m = "progs/v_shot.mdl";
	else if (w == IT_SUPER_SHOTGUN)		m = "progs/v_shot2.mdl";
	else if (w == IT_NAILGUN)		m = "progs/v_nail.mdl";
	else if (w == IT_SUPER_NAILGUN)		m = "progs/v_nail2.mdl";
	else if (w == IT_GRENADE_LAUNCHER)	m = "progs/v_rock.mdl";
	else if (w == IT_ROCKET_LAUNCHER)	m = "progs/v_rock2.mdl";
	else if (w == IT_LIGHTNING)		m = "progs/v_light.mdl";
	else					m = string_null;

	player_run ();		// get out of any weapon firing states
	self.items = self.items - (self.items & (IT_SHELLS | IT_NAILS | IT_ROCKETS | IT_CELLS));
	self.items = self.items | ammo_type;
	self.weaponmodel = m;
	self.weaponframe = 0;
};

// XXX Allow different criteria.
//
// XXX Clean this up.

float ()
W_BestWeapon =
{
	local	float	it, nw, alt;
	local	entity	e;

	if (self.runetype == RN_LUMBER)
	{
		e = findradius (self.origin, AXE_REACH_LUMBER);
		while (e)
		{
			if (e != self && e.classname == "player")
				return IT_AXE;
			e = e.chain;
		}
	}

	nw = self.waterlevel <= SAFE_DISCHARGE_WATERLEVEL;
	it = self.items;

	if (it & IT_LIGHTNING)
	{
		if (weapon_it_is_alt (IT_LIGHTNING))
		{
			if (weapon_it_have_min_ammo (WEAPON_BFG, 0))
				return WEAPON_BFG;
		}
		else if ((nw || self.runetype == RN_THOR) && weapon_it_have_min_ammo (IT_LIGHTNING, 0))
			return IT_LIGHTNING;
	}

	if (it & IT_SUPER_NAILGUN && weapon_it_have_min_ammo (IT_SUPER_NAILGUN, 0))
		return IT_SUPER_NAILGUN;

	if (it & IT_SUPER_SHOTGUN)
	{
		alt = weapon_it_is_alt (IT_SUPER_SHOTGUN);
		if (nw && weapon_it_have_min_ammo (WEAPON_FLAMETHROWER, 0) && (self.runetype == RN_TORCH || alt))
			return WEAPON_FLAMETHROWER;
		else if (weapon_it_have_min_ammo (IT_SUPER_SHOTGUN, 0))
			return IT_SUPER_SHOTGUN;
	}

	if (it & IT_NAILGUN)
	{
		alt = weapon_it_is_alt (IT_NAILGUN);
		if (nw && weapon_it_have_min_ammo (WEAPON_LAVA, 0) && (self.runetype == RN_TORCH || alt))
			return WEAPON_LAVA;
		else if (weapon_it_have_min_ammo (IT_NAILGUN, 0))
			return IT_NAILGUN;
	}

	if (it & IT_SHOTGUN && weapon_it_have_min_ammo (IT_SHOTGUN, 0))
			return IT_SHOTGUN;

	if (weapon_it_is_alt (IT_AXE))
		return WEAPON_HOOK;
	else
		return IT_AXE;
};

float ()
W_CheckNoAmmo =
{
	if (weapon_it_have_min_ammo (self.weapon, 0))
		return TRUE;

	set_weapon (W_BestWeapon ());

	// drop the weapon down
	return FALSE;
};

/*
============
W_Attack

An attack impulse can be triggered now
============
*/

void ()
W_Attack =
{
	local	float	do_ammo, base_weapon, is_alt, haste_mult, r, t;
	local	string	s;

	// Prevent firing except when match begins and player is waiting for opponent.
	if (gamemode & MODE_ARENA)
	{
		if (arena.state && arena.state != -2)
			return;
	}

	// Cancel guided missile.
	if (self.rqstate & RQS_GUIDED_MISSILE)
	{
		restore_gmissile_owner (self);
		return;
	}

	spawn_protect_off ();

	if (!W_CheckNoAmmo ())
		return;

	// Sometimes self.deadflag doesn't get set fast enough so I check it
	// again here.
 	if (self.deadflag)
		return;

	if (self.weapon == WEAPON_HOOK)
	{
		if (have_hook ())
		{
			if (!self.aqstate & AQS_HOOK)
				HookOn ();
			return;
		}
	}
	else
	{
		// Feature request for PK.
		if (HOOK_CAMP_PROT)
			HookOff ();
	}

	do_ammo = 1;
	base_weapon = self.weapon & WEAPON_NONALT_MASK;

	// This failed as a single expression.
	if (options & NO_ALT_WEAPONS)
		is_alt = 0;
	else
		is_alt = self.weapon & WEAPON_ALT;
	t = 0;
	if (self.runetype == RN_HASTE)
		haste_mult = 0.5;
	else if (self.runetype == RN_JACK)
		haste_mult = 0.875;
	else
		haste_mult = 1;

	//RUNE SERV: So much stuff here.. prevents lag.
	if (self.runetype != 0)
	{
		if (self.runetype == RN_HASTE)
			Haste_Sound ();
		else if (self.runetype == RN_STRENGTH)
			Strength_Sound ();
		else if (self.runetype == RN_BERSERK)
			Strength_Sound ();
		else if (self.runetype == RN_CLOAK)
			self.runetime = time + RECLOAK_DELAY;
	IN_POQ([-
		else if (self.runetype == RN_IMPACT)
			particle (self.origin, '0 0 10', PARTICLE_IMPACT, 250);
	-])
		else if (self.runetype == RN_JACK && self.runevar == 0)
		{
			Strength_Sound ();
			self.runevar = self.runevar + 1;
		}
		else if (self.runetype == RN_JACK && self.runevar == 2)
		{
			Haste_Sound ();
			self.runevar = self.runevar + 1;
		}
	}

	makevectors (self.v_angle);	// calculate forward angle for velocity
	self.show_hostile = time + 1;	// wake monsters up

	if (base_weapon == IT_AXE)
	{
	    	if (self.runetype == RN_LUMBER)
			s = "knight/sword1.wav";
		else
			s = "weapons/ax1.wav";
		sound (self, CHAN_WEAPON, s, 1, ATTN_NORM);
		r = random ();
		if (r < 0.25)
			player_axe1 ();
		else if (r<0.5)
			player_axeb1 ();
		else if (r<0.75)
			player_axec1 ();
		else
			player_axed1 ();
		t = 0.5 * haste_mult;
	}
	else if (base_weapon == IT_SHOTGUN)
	{
		player_shot1 ();
		if (is_alt)
		{
			W_MagicShotgun ();
			t = 0.6 * haste_mult;
		}
		else
		{
			W_FireShotgun ();
			t = 0.5 * haste_mult;
		}
	}
	else if (base_weapon == IT_SUPER_SHOTGUN)
	{
		if (is_alt)
		{
			// This is too fast with haste, but for haste to
			// be over one tick non-haste has to be too
			// slow.  So, haste helps the flames go farther,
			// which is useful anyway.
			t = 0.15;
			self.weaponframe = 8;
			// XXX investigate, regular 3 gun doesn't use it
			player_ssshot1 ();
			W_FireFlameMissile ("flamethrower", 0);
		}
		else
		{
			player_shot1 ();
			W_FireSuperShotgun ();
			t = 0.7 * haste_mult;
		}
	}
	else if (base_weapon == IT_NAILGUN)
	{
		// Lava gun behavior is triggerred in W_FireSpikes().
		player_nail1 ();
		do_ammo = 0;
	}
	else if (base_weapon == IT_SUPER_NAILGUN)
	{
		if (is_alt)
		{
			W_Bomb ();
			// The speed up is in the ticking time.
			t = 0.5;
		}
		else
		{
			player_nail1 ();
			do_ammo = 0;
		}
	}
	else if (base_weapon == IT_GRENADE_LAUNCHER)
	{
		player_rocket1 ();
		if (is_alt)
			W_FireGrenade ("gasbomb");
		else
			W_FireGrenade ("grenade");
		t = 0.6 * haste_mult;
	}
	else if (base_weapon == IT_ROCKET_LAUNCHER)
	{
		player_rocket1 ();
		if (is_alt)
		{
			if (MOD_PROTOCOL) // XXX add a server command option to turn on
			{
				W_FireRocket ("gmissile");
				t = 0.5;
			}
			else
			{
				W_FireRocket ("reflect");
				t = 1.4 * haste_mult;
			}
		}
		else
		{
			W_FireRocket ("missile");
			t = 0.8 * haste_mult;
		}
	}
	else if (base_weapon == IT_LIGHTNING)
	{
		if (is_alt)
		{
			t = 4;
			sound (self, CHAN_AUTO, "weapons/lstart.wav", 1, ATTN_NORM);
			W_BFG ();
		}
		else
		{
			player_light1 ();
			t = 0.1;
			sound (self, CHAN_AUTO, "weapons/lstart.wav", 1, ATTN_NORM);
			do_ammo = 0;
		}
	}

	if (t)
		self.attack_finished = time + t;
	if (do_ammo)
		use_ammo ();
};

/*
============
ImpulseCommands

============
*/
void ()
ImpulseCommands =
{
	if (self.aqstate & AQS_IMPOVER_MASK)
		impulse_override ();

	else if (self.impulse >= 1 && self.impulse <= 8)
		W_ChangeWeapon (1, 1);

	else if (self.impulse == 10)
		CycleWeaponCommand ();

	else if (self.impulse == 12)
		CycleWeaponReverseCommand ();

	else if (self.impulse >= IMP_RUNE_CHEAT_BASE && self.impulse < IMP_RUNE_CHEAT_BASE + RN_MAX_ALL)
	{
		local float wanted;

		wanted = self.impulse - IMP_RUNE_CHEAT_BASE + 1;
		if (wanted == self.runetype)
			wanted = 0;
		//if (wanted && self.runetype == RN_SHIELD && self.runevar == 1)
		//	wanted = 0;
		// Let admins use camo to help spot cheaters.
		if (wanted && deathmatch & DM_DM_MASK && !temp1 & T1_RUNE_CHEAT && (!self.aqflags & AQ_ADMIN || wanted != RN_CAMO))
			wanted = 0;
		if (wanted)
			Rune_Activate (wanted, 1);
	}

	else if (self.impulse == IMP_RUNE_USE)
		Rune_Button ();

	else if (self.impulse == IMP_RUNE_TELL)
		rune_tell_toggle (0, self);

	else if (self.impulse == IMP_RUNE_DELETE)
	{
		if (self.runetype == 0)
		{
			if (!self.aqflags & AQ_QUIET)
				centerprint (self, "No rune");
		}
		else if (self.runetype == RN_RECALL && self.runevar)
			recall_point_erase ();
		else if (self.runetype == RN_PACK_RAT && self.runevar)
			pack_rat_rune_drop (1);
		else if (rune_drop_delay == -1)
		{
			centerprint2 (self, "Rune deletion is disabled,\n", "make the best of what you have!\n");
		}
		else if (self.dropdelay < 0)
		{
			if (!self.aqflags & AQ_QUIET)
				centerprint (self, "Rune removal canceled");
			self.dropdelay = 0 - self.dropdelay;
		}
		else
		{
			if (self.dropdelay > time && !self.aqflags & AQ_QUIET)
			{
				local float i;
				local string s;

				i = self.dropdelay - time;
				s = ftos (ceil (i));

				if (i > 5)
					centerprint3 (self, "Rune will be removed\nin ", s, " seconds");
				else
					centerprint (self, "Rune will be removed");
			}
			self.dropdelay = 0 - self.dropdelay;
		}
		draw_hud (1);
		rune_tell_stop (1);
	}

	else if (self.impulse == IMP_BEST_WEAPON)
		set_weapon (W_BestWeapon ());

	else if (self.impulse == IMP_SWITCHFIRE_OFF)
		switchfire_off ();

	else if (self.impulse >= IMP_SWITCHFIRE_BASE && self.impulse <= IMP_SWITCHFIRE_BASE + IMP_SWITCHFIRE_COUNT - 1)
	{
		self.impulse = self.impulse - IMP_SWITCHFIRE_BASE + 1;
		switchfire ();
	}

	else if (self.impulse == IMP_SWITCHFIRE_BEST)
		switchfire_best ();

	else if (self.impulse == IMP_HOOK_ON || self.impulse == IMP_HOOK_OFF || self.impulse == IMP_HOOK_TOGGLE)
	{
		if (!have_hook ())
		{
			if (self.impulse != IMP_HOOK_OFF)
			{
				sprint (self, "No hook");
				if (options2 & HOOK_MASK == LITHIUM_HOOK)
					sprint (self, ", find one first");
				else if (!vote_hook_disabled (0))
					sprint (self, ", use vote-hook");
 				sprint (self, "\n");
			}
		}
		else if (self.impulse == IMP_HOOK_ON)
			HookOn ();
		else if (self.impulse == IMP_HOOK_OFF)
			HookOff ();
		else if (self.impulse == IMP_HOOK_TOGGLE)
			HookToggle ();
	}

	else if (self.impulse == IMP_WEAPON_MODE)
		weapon_mode ();

	else if (self.impulse >= IMP_WEAPON_BASE && self.impulse <= IMP_WEAPON_BASE + IMP_WEAPON_COUNT - 1)
	{
		self.impulse = self.impulse - IMP_WEAPON_BASE + IMP_WEAPON_START;
		W_ChangeWeapon (0, 1);
	}

	else
		common_impulses ();

	self.impulse = 0;
};

/*
============
W_WeaponFrame

Called every frame so impulse events can be handled as well as possible
============
*/
void ()
W_WeaponFrame =
{
	// prevent accidental discharge when respawning
	if (self.button1)
	{
		if (self.button0)
			return;

		self.button1 = FALSE;
	}

	// Stop switchfiring if she starts using a regular attack.
	if (self.button0 && self.aqstate & AQS_SWITCHFIRING)
		switchfire_off ();

	// The standard progs doesn't let you use any impulse commands
	// before your attack is finished.  This causes more problems
	// than it fixes.  (The only problem it actually fixes, that I've
	// spotted, is that you don't get to see the entire animation for
	// your weapon (or the other players of your model) if you switch
	// while firing.)  The main problem it causes is that of all the
	// impulse commands which come in while your attack is running,
	// only the most recent one is acted upon.  (Additionally, for
	// the 4, 5 and 8 guns it isn't acted upon until you stop firing
	// entirely, rather than when the current cycle finishes.)  With
	// this implementation (not ignoring the impulses) an impulse
	// will only be lost if you send more than one in the same game
	// tick.  I don't know a way to fix that.
	//
	// The freeze rune depended on impulses not working while an
	// attack was going on, though.  My current implementation for
	// this is to have the freeze trap set your attack_finished far
	// in the future, and to key off of that to prevent impulses
	// here.
	if (self.impulse && self.attack_finished <= time + 15)
		ImpulseCommands ();

	if (time < self.attack_finished)
		return;

	// check for attack
	if (self.button0 || self.aqstate & AQS_SWITCHFIRING)
	{
		SuperDamageSound ();
		W_Attack ();
	}
	else if (self.weapon == WEAPON_HOOK && self.aqstate & AQS_HOOK)
		HookOff ();
};

/*
========
SuperDamageSound

Plays sound if needed
========
*/
void ()
SuperDamageSound =
{

	if (self.super_damage_finished > time || self.owner.super_damage_finished > time)
	{
		if (self.super_sound < time)
		{
			self.super_sound = time + 1;
			sound (self, CHAN_AUTO, "items/damage3.wav", 1, ATTN_NORM);
		}
	}
	return;
};
