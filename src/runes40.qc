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

// For the normal balls
void ()
Ball_Touch =
{
	if (other == self.owner.runent)
		return;
	if (other.classname == "spikeball")
		return;

	if ((other.health > 0) && !isfriend2 (other, self.owner) && other.solid != SOLID_BSP)
	{
		T_Damage (other, self, self.owner, 40, "spikeball");
		other.flags = other.flags-(other.flags & FL_ONGROUND);
		other.velocity_z = other.velocity_z + 270;
		sound (other, CHAN_AUTO, "zombie/z_miss.wav", 1, ATTN_NORM);

		self.touch = SUB_Null;
		setmodel (self, string_null);
	}
};

// For the final balls
void ()
Ball_Touch2 =
{
	if (pointcontents (self.origin) == CONTENT_LAVA || pointcontents (self.origin) == CONTENT_SOLID)
	{
		remove (self);
		return;
	}

	if (other == self.owner.runent)
		return;
	if (other.classname == "spikeball")
		return;

	if ((other.health > 0) && !isfriend2 (other, self.owner) && other.solid != SOLID_BSP)
	{
		T_Damage (other, self, self.owner, 40, "spikeball");
		other.flags = other.flags-(other.flags & FL_ONGROUND);
		other.velocity_z = other.velocity_z + 270;
		sound (other, CHAN_AUTO, "zombie/z_miss.wav", 1, ATTN_NORM);
		remove (self);
	}
};

void ()
Ball_Move =
{
	if (self.owner.runetype != RN_CLOUD || intermission_running)
	{
		remove (self);
		return;
	}

	self.nextthink = time + 3 + crandom ()*0.3;

	setmodel (self, string_null);
	setorigin (self, self.owner.runent.origin);
	setmodel (self, "progs/v_spike.mdl");

	self.touch = Ball_Touch;
	self.velocity_x = crandom ()*200;
	self.velocity_y = crandom ()*200;

	self.avelocity_x = crandom ()*360;
	self.avelocity_y = crandom ()*360;
	self.avelocity_z = crandom ()*360;

	self.flags = self.flags-(self.flags & FL_ONGROUND);
};

// For the final balls
void (entity master)
Ball_Spawn =
{
	local entity temp;

	temp = spawn ();
	temp.movetype = MOVETYPE_BOUNCE;
	temp.solid = SOLID_TRIGGER;
	temp.owner = master;
	setorigin (temp, self.origin);
	setsize (temp, '-15 -15 -15', '15 15 15');
	setmodel (temp, "progs/v_spike.mdl");
	temp.avelocity_x = crandom ()*360;
	temp.avelocity_y = crandom ()*360;
	temp.avelocity_z = crandom ()*360;
	temp.velocity_x = crandom ()*200;
	temp.velocity_y = crandom ()*200;
	temp.classname = "spikeball";
	temp.touch = Ball_Touch2;
	temp.think = SUB_Remove;
	temp.nextthink = time + 1 + random ()*2;
	if (master.health < 1)
	{
		temp.velocity_z = crandom ()*700;
		temp.nextthink = temp.nextthink + 8;
	}
};

// For the normal balls
void ()
Balls_Spawn =
{
	local entity temp;
	local float n;

	n = 0;
	while (n <= 3)
	{
		n = n + 1;

		temp = spawn ();
		temp.movetype = MOVETYPE_BOUNCE;
		temp.solid = SOLID_TRIGGER;
		temp.owner = self;
		setorigin (temp, self.runent.origin);
		setsize (temp, '-15 -15 -15', '15 15 15');
		setmodel (temp, "progs/v_spike.mdl");

		temp.flags = temp.flags-(temp.flags & FL_ONGROUND);

		temp.avelocity_x = crandom ()*360;
		temp.avelocity_y = crandom ()*360;
		temp.avelocity_z = crandom ()*360;
		temp.velocity_x = crandom ()*200;
		temp.velocity_y = crandom ()*200;
		temp.classname = "spikeball";
		temp.touch = Ball_Touch;
		temp.think = Ball_Move;
		temp.nextthink = time + n;
	}
};

void ()
Cloud_Bye =
{
	local float n;

	n = 0;
	while (n < 15)
	{
		Ball_Spawn (self.owner);
		n = n + 1;
	}

	create_te_tarexplosion (self.origin);
	remove (self);
};

void ()
Cloud_Think =
{
	if (intermission_running)
	{
		remove (self);
		return;
	}

	if (self.owner.health < 1)
	{
		self.think = Cloud_Bye;
		self.nextthink = time + 2;
		self.avelocity = VEC_ORIGIN;
		return;
	}

	if (self.owner.runetype != RN_CLOUD)
	{
		remove (self);
		return;
	}

	setorigin (self, self.owner.origin + '0 0 60');
	// XXX Can't set velocity here because it overrides avelocity.
	self.nextthink = time + sys_ticrate;
};

void ()
Cloud_Spawn =
{
	local entity temp;

	temp = spawn ();
	temp.movetype = MOVETYPE_FLY;
	temp.solid = SOLID_NOT;
	temp.owner = self;
	setorigin (temp, self.origin);
	setsize (temp, '-50 -50 -50', '-50 -50 -50');
	setmodel (temp, "progs/teleport.mdl");
	temp.avelocity_x = crandom ()*360;
	temp.avelocity_y = crandom ()*360;
	temp.avelocity_z = crandom ()*360;
	temp.think = Cloud_Think;
	temp.nextthink = time;
	self.runent = temp;

	Balls_Spawn ();
};

float ()
is_shambler =
{
	return self.classname == "monster_shambler"
		|| self.classname == "shambler_slave";
};

void (entity sham, float tell)
shambler_slave_respawn =
{
	// If this is a vengeful shambler, he doesn't respawn.
	if (sham.trigger_field.runevar)
	{
		Killed (sham, sham.owner, string_null);
		remove (sham.trigger_field);
		remove (sham);
		return;
	}

	if (sham.effects & EF_FROZEN)
		Unfreeze (sham);

	// stop burning
	if (sham.aqstate & AQS_BURNING)
		sham.aqstate = sham.aqstate - sham.aqstate & AQS_BURNING;

	HookOff_by_targ_e (sham);

	sham.health = sham.max_health;
	spawn_tfog (sham.origin);
	setorigin (sham, sham.owner.origin);
	spawn_tfog (sham.origin);

	if (tell && sham.owner.classname == "player")
		sprint (sham.owner, "Shambler ran back to master!\n");
};

void (entity sham, entity attacker)
shambler_slave_retribution =
{
	local entity old_self;

	shambler_slave_respawn (sham, 0);
	sham.trigger_field.runevar = 1;
	sham.super_damage_finished = time + 15;
	Hat_Spawn (sham, "progs/quaddama.mdl", '0 0 60', VEC_ORIGIN, ITEM_QUAD);
	sham.effects = sham.effects | EF_DIMLIGHT;
	sprint (sham.owner, "Shambler seeks retribution!\n");

	old_self = self;
	self = sham;
	self.enemy = attacker;
	FoundTarget ();
	self = old_self;
};

void (float riders, entity of_e)
Rune_Shambler_sprint =
{
	rprint (self, riders, "Shambler health: ");
	rprint_float (self, riders, of_e.runent.health);
	if (of_e.runent.enemy)
	{
		rprint (self, riders, ", enemy: ");
		rprint_entity (self, riders, of_e.runent.enemy);
	}
	rprint (self, riders, "\n");
};

void (float by_player)
Rune_ShamblerReloc =
{
	local entity old_self;

	if (self.runent.effects & EF_FROZEN)
	{
		sprint (self, "Your shambler is frozen!\n");
		return;
	}

	// Stop burning when recalled in water or acid.
	if (self.runent.owner.waterlevel > 1 && self.runent.owner.watertype != CONTENT_LAVA)
		self.runent.aqstate = self.runent.aqstate - self.runent.aqstate & AQS_BURNING;

	old_self = self;
	self = self.runent;

	spawn_tfog (self.origin);
	setorigin (self, self.owner.origin);
	spawn_tfog (self.origin);
	self.angles = self.pos1 = self.owner.angles;
	self.fixangle = 1;

	self.runevar = by_player;
	self.pausetime = 0;
	self.goalentity = self.movetarget;
	self.enemy = world;
	self.th_walk ();

	self = old_self;
};

void ()
Rune_ShamblerThink =
{
	// Angry shambler for dead player.
	if (self.runevar)
	{
		if (time > self.runent.super_damage_finished)
		{
			self.runent.health = 0;
			Killed (self.runent, self.owner, string_null);
			remove (self.runent);
			remove (self);
			return;
		}

		// Otherwise do nothing.  I can't easily respawn the
		// shambler to get it unstuck because I have nowhere to
		// respawn it to.  XXX Fix this.  When you do be careful
		// that you can't use the owner's runent &c anymore
		// because she could have respawned already.

		self.nextthink = time + 1;
		return;
	}

	if (self.owner.runetype != RN_SHAMB
			|| self.owner.runent != self.runent)
	{
		self.runent.health = 0;
		spawn_tfog (self.runent.origin);
		remove (self.runent);
		remove (self);
		return;
	}

	// Check to see that the shambler isn't stuck, but only if the
	// shambler wasn't placed in a stuck place by the player.
	if (!self.runent.runevar)
	{
		local entity old_self;

		old_self = self;
		self = self.runent;
		if (walkmove (0, 0))
			self.runevar = 1;
		else
		{
			// Stuck, and not placed here.  Move to the
			// owner again.
			self = self.owner;
			Rune_ShamblerReloc (0);
		}
		self = old_self;
	}

	self.nextthink = time + 1;
};

void ()
delayed_shambler_spawn_think =
{
	// Removing this here really screws you up, I don't know why.
	self.think = SUB_Remove;
	self.nextthink = time + 1;

	self = self.owner;
	if (self.runetype == RN_SHAMB && self.runent == world)
		Rune_ShamblerSpawn ();
};

// Spawning the shambler at the start of a level fails for some reason,
// so i do it after a think.

void ()
delayed_shambler_spawn =
{
	local entity e;

	e = spawn ();
	e.owner = self;
	e.think = delayed_shambler_spawn_think;
	e.nextthink = time + sys_ticrate;
};

void ()
Rune_ShamblerSpawn =
{
	local entity sham;
	local entity temp;
	local entity shamctrl;

	sham			= spawn ();
	self.runent		= sham;

	sham.classname		= "shambler_slave";
	sham.owner		= self;
	sham.runevar		= 0;
	sham.flags		= sham.flags | FL_MONSTER;
	sham.movetarget		= self;
	sham.angles		= self.pos1 = self.angles;
	sham.fixangle		= 1;

	setorigin (sham, self.origin);
	spawn_tfog (sham.origin);

	temp			= self;
	self			= sham;
	monster_shambler_1 (0);
	self			= temp;

	shamctrl		= spawn ();
	shamctrl.solid		= SOLID_NOT;
	shamctrl.movetype	= MOVETYPE_FLY;

	setorigin (shamctrl, self.origin);
	setsize (shamctrl, VEC_ORIGIN, VEC_ORIGIN);

	shamctrl.classname	= "shambler_control";
	shamctrl.owner		= self;
	shamctrl.runent		= sham;
	shamctrl.runevar	= 0;
	shamctrl.nextthink	= time + 1;
	shamctrl.think		= Rune_ShamblerThink;

	sham.trigger_field	= shamctrl;
};

void ()
Rune_Dual =
{
	local vector i_origin, i_angles;

	if (self.runetime > time)
		return;
	self.runetime = time + sys_ticrate;

	HookOff ();
	HookOff_by_targ ();

	spawn_tfog (self.origin);
	i_origin = self.origin;
	i_angles = self.v_angle;
	spawn_tdeath (self.runevector, self);
	setorigin (self, self.runevector);
	self.angles = self.pos1;
	self.fixangle = 1;
	self.runevector = i_origin;
	self.pos1 = i_angles;
	spawn_tfog (self.origin);
	self.velocity = VEC_ORIGIN;
};

float WEIRD_JUMPING	= 1;
float WEIRD_SHROOMS	= 2;
float WEIRD_DRUNK	= 3;
float WEIRD_TWITCHING	= 4;
float WEIRD_COFFEE	= 5;
float WEIRD_STICKY	= 6;
float WEIRD_SHOOTPHOB	= 7;
float WEIRD_TWIRLY	= 8;
float WEIRD_VERTIGO	= 9;
float WEIRD_BLIND	= 10;

// I've disabled blindness entirely.  What I don't like about it is that
// if you're hit with multiple weirdnesses and one of them is blindness,
// you can't really appreciate how weird you are.
//
// Twirly head is disabled in QW because punchangle does not exist.

float WEIRD_MAX_POQ	= 8;
float WEIRD_MAX_QW	= 7;

void ()
Weird_WanderThink =
{
	if (self.runetime < time)
	{
		remove (self);
		return;
	}

	self.velocity_x = self.velocity_x + crandom ()*30;
	self.velocity_y = self.velocity_y + crandom ()*30;
	self.velocity_z = self.velocity_z + crandom ()*30;

	self.flags = self.flags-(self.flags & FL_ONGROUND);

	self.nextthink = time + 0.5;
};

void ()
Weird_AllOff =
{
	stuffcmd (self, "v_idlescale 0\n");
	// stuffcmd (self, "fov 90\n");
	stuffcmd (self, CSHIFT_NONE);
	stuffcmd (self, "bf\n");
	IN_POQ([-
		self.punchangle = VEC_ORIGIN;
	-])
};

void ()
Weird_Think =
{
	IN_QW([-
		local float r;
		local vector o;
	-])

	// Stop EP suit and rune from burning.
	if (environmental (self.runent))
		self.runetime = time - 1;

	// Remove the weirder
	if (self.runent.health < 1 || self.runetime < time || intermission_running)
	{
		self.runent.effects = self.runent.effects - self.runent.effects & EF_WEIRD;
		if (self.runevar == WEIRD_SHROOMS) stuffcmd (self.runent, "v_idlescale 0\n"); else
		if (self.runevar == WEIRD_VERTIGO) stuffcmd (self.runent, "fov 90\n"); else
		if (self.runevar == WEIRD_BLIND) stuffcmd (self.runent, CSHIFT_NONE); else
		IN_POQ([-
			if (self.runevar == WEIRD_TWIRLY)
				self.runent.punchangle = VEC_ORIGIN;
		-])
		remove (self);
		return;
	}

	self.nextthink = time + sys_ticrate;

	IN_POQ([-
		particle (self.runent.origin + '0 0 25', '0 0 1'*crandom ()*500 + '0 1 0'*crandom ()*500 + '1 0 0'*crandom ()*500, random ()*255, 30);
	-], [-
		r = random ();
		o = self.runent.origin
			+ '0 0 10'
			+ '1 0 0' * crandom () * 15
			+ '0 1 0' * crandom () * 15
			+ '0 0 1' * crandom () * 15;
		if (r < 0.5)
			create_te_gunshot (o, 1);
		else if (r < 0.75)
			create_te_blood (o, 1);
		else
			create_te_lightningblood (o);
	-])

	// The weirdness factors
	if (self.runevar == WEIRD_SHROOMS)
	{
		if (self.attack_finished > time)
			return;
		self.attack_finished = time + 0.5;
		stuffcmd (self.runent, "v_idlescale 120\n");
	}
	else if (self.runevar == WEIRD_DRUNK)
	{
		if (self.attack_finished > time)
			return;
		self.attack_finished = time + 0.5;
		self.runent.angles_y = self.runent.angles_y + crandom ()*40;
		self.runent.fixangle = 1;
	}
	else if (self.runevar == WEIRD_TWIRLY)
	{
		IN_POQ([-
			self.runent.punchangle_z = self.runent.punchangle_z - 5;
		-])
		return;
	}
	else if (self.runevar == WEIRD_TWITCHING)
	{
		if (random () > 0.3)
		{
			self.runent.velocity_x = self.runent.velocity_x + crandom ()*200;
			self.runent.velocity_y = self.runent.velocity_y + crandom ()*200;
			self.runent.velocity_z = self.runent.velocity_z + crandom ()*200;

			self.runent.flags = self.runent.flags-(self.runent.flags & FL_ONGROUND);
		}
	}
	else if (self.runevar == WEIRD_COFFEE)
	{
		self.runent.velocity = self.runent.velocity * 2;
	}
	else if (self.runevar == WEIRD_STICKY)
	{
		self.runent.velocity = self.runent.velocity * -1;
	}
	else if (self.runevar == WEIRD_SHOOTPHOB)
	{
		self.runent.effects = self.runent.effects | EF_WEIRD;
		self.runent.attack_finished = time + 0.5;
	}
	else if (self.runevar == WEIRD_VERTIGO)
	{
		if (self.attack_finished > time)
			return;
		self.attack_finished = time + 0.5;
		stuffcmd (self.runent, "fov 160\n");
	}
	else if (self.runevar == WEIRD_BLIND)
	{
		if (self.attack_finished > time)
			return;
		self.attack_finished = time + 0.5;
		stuffcmd (self.runent, CSHIFT_BLIND);
	}
	else
	{
		if (self.attack_finished > time)
			return;
		if (self.runent.flags & FL_ONGROUND)
		{
			self.runent.flags = self.runent.flags - FL_ONGROUND;
			sound (self.runent, CHAN_JUMP, "player/plyrjmp8.wav", 1, ATTN_NORM);
			self.runent.velocity_z = self.runent.velocity_z + 270;
			self.attack_finished = time + sys_ticrate;
		}
	}
};

void ()
Weird_Touch =
{
	local string self_desc, other_desc;

	if (other == world || other.solid == SOLID_BSP)
	{
		self.velocity = self.velocity * -1;
		return;
	}

	if (other.classname != "player" && !is_pet_e (other))
		return;

	if (other.health <= 0)
		return;

	if (isfriend2 (other, self.owner))
		return;

	if (environmental (other))
		return;

	self.runent	= other;
	self.runetime	= time + 15;
	self.touch	= SUB_Null;
	self.think	= Weird_Think;
	self.nextthink	= time;
	self.runevar	= ceil (random ()* IN_POQ(WEIRD_MAX_POQ, WEIRD_MAX_QW));

	setmodel (self, string_null);

	// shambler/zombie
	if (other.classname != "player")
	{
		if (self.runevar == WEIRD_SHROOMS
				|| self.runevar == WEIRD_TWIRLY
				|| self.runevar == WEIRD_VERTIGO
				|| self.runevar == WEIRD_BLIND
				|| self.runevar == WEIRD_DRUNK)
		self.runevar = WEIRD_JUMPING;
	}

	sound (self, CHAN_BODY, "boss2/idle.wav", 1, ATTN_NORM);
	if (self.runevar == WEIRD_SHROOMS)
	{
		 self_desc = "shrooms";
		other_desc = "SHROOM MODE!";
	}
	else if (self.runevar == WEIRD_DRUNK)
	{
		 self_desc = "drunken walk";
		other_desc = "DRUNKEN WALK!";
	}
	else if (self.runevar == WEIRD_TWIRLY)
	{
		 self_desc = "twirly head";
		other_desc = "TWIRLY HEAD!";
	}
	else if (self.runevar == WEIRD_TWITCHING)
	{
		 self_desc = "twitching";
		other_desc = "RANDOM TWITCHING!";
	}
	else if (self.runevar == WEIRD_COFFEE)
	{
		 self_desc = "too much coffee";
		other_desc = "TOO MUCH COFFEE!";
	}
	else if (self.runevar == WEIRD_STICKY)
	{
		 self_desc = "sticky feet";
		other_desc = "STICKY FEET!";
	}
	else if (self.runevar == WEIRD_SHOOTPHOB)
	{
		 self_desc = "shootphobia";
		other_desc = "HOW DO I SHOOT?!";
	}
	else if (self.runevar == WEIRD_VERTIGO)
	{
		 self_desc = "vertigo";
		other_desc = "VERTIGO!";
	}
	else if (self.runevar == WEIRD_BLIND)
	{
		 self_desc = "blindness";
		other_desc = "I'M BLIND! I'M BLIND!";
	}
	else
	{
		 self_desc = "jumping";
		other_desc = "UNCONTROLLABLE JUMPING!";
	}

	centerprint3 (other, "\b\.\b Hit by weirdness! \b\.\b\n",
		"\<\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\>\n",
		other_desc);

	sprint (self.owner, "You weirded out ");
	if (other.classname != "player")
	{
		sprint (self.owner, other.owner.netname);
		if (other.classname == "shambler_slave")
			sprint (self.owner, "'s shambler");
		else if (other.classname == "zombie_camper")
			sprint (self.owner, "'s zombie");
	}
	else
		sprint (self.owner, other.netname);
	sprint (self.owner, " with ");
	sprint (self.owner, self_desc);
	sprint (self.owner, ".\n");
};

void ()
Spawn_Weird =
{
	local entity temp;

	temp = spawn ();
	temp.movetype = MOVETYPE_FLY;
	temp.solid = SOLID_TRIGGER;
	temp.owner = self;
	setorigin (temp, self.origin + '0 0 15');
	setmodel (temp, "progs/s_bubble.spr");
	temp.think = Weird_WanderThink;
	temp.touch = Weird_Touch;
	temp.nextthink = time;
	temp.runetime = time + 4 + random ()*3;
	self.runent = temp;
};

void ()
Rune_Weird =
{
	if (self.runetime > time)
		return;
	self.runetime = time + 2.5;

	Spawn_Weird ();

	self.runent.flags = self.runent.flags-(self.runent.flags & FL_ONGROUND);
};

void ()
Weird_Throw =
{
	if (self.runevar > time)
		return;
	self.runevar = time + 1;
	self.runetime = time + 2;

	Spawn_Weird ();

	makevectors (self.v_angle);
	self.runent.velocity = 750 * normalize (v_forward);
	// Explicitly thrown weird bubbles go further before their velocity
	// is manipulated.
	self.runent.nextthink = time + 2.5;
};

void (float riders, entity of_e)
Rune_Phoenix_sprint =
{
	rprint_numdesc (self, riders, of_e.runevar, "resurrection");
	rprint (self, riders, " left\n");
};

void (float is_phoenix)
Resurrect =
{
	local float w;

	if (gamemode & MODE_ARENA)
	{
		SetParms ();
		PutClientInServer ();
		return;
	}

	self.classname = "player";
	self.takedamage = DAMAGE_AIM;
	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_WALK;
	self.show_hostile = 0;
	self.flags = FL_CLIENT;
	self.air_finished = time + 12;
	self.dmg = 2;         // initial water damage
	self.super_damage_finished = 0;
	self.radsuit_finished = 0;
	self.invisible_finished = 0;
	self.invincible_finished = 0;
	self.effects = 0;
	self.invincible_time = 0;

	if (self.rqflags & RQ_LOW_BANDWIDTH_CLIENT)
		self.flags = self.flags | FL_LOW_BANDWIDTH_CLIENT;

	if (is_phoenix)
	{
		self.runevar = self.runevar - 1;
		self.max_health = MAX_HEALTH_NORMAL;
		self.health = self.max_health;
		self.super_time = -2;

		if (self.super_damage_finished < time)
			Hat_Spawn (self, "progs/quaddama.mdl", '0 0 30', VEC_ORIGIN, ITEM_QUAD);

		self.super_damage_finished = time + 15;
		self.items = self.items | IT_QUAD;
		self.effects = EF_DIMLIGHT;
	}

	// Set the weapon.  This is required because right now it isn't
	// being drawn.
	if (self.aqstate & AQS_SWITCHFIRING)
	{
		self.aqstate = self.aqstate - self.aqstate & AQS_SWITCHFIRING;
		w = switchfire_weapon ();
	}
	else
		w = self.weapon;
	if (!self.items & w || !weapon_it_have_min_ammo (w, 0))
		w = W_BestWeapon ();
	// Forcing the weapon to be 0 first is required because
	// set_weapon() vets unnecessary calls.
	self.weapon = 0;
	set_weapon (w);

	if ((pointcontents (self.origin) == CONTENT_LAVA
			|| pointcontents (self.origin) == CONTENT_SOLID)
			&& is_phoenix)
	{
		local entity startent;
		startent = SelectSpawnPoint ();
		setorigin (self, startent.origin);
	}
	else
		setorigin (self, self.origin + '0 0 40');

	self.attack_finished = time;
	self.th_pain = player_pain;
	self.th_die = PlayerDie;

	self.deadflag = DEAD_NO;
	self.aflag = 0;

	self.modelindex = modelindex_player;

	setsize (self, VEC_HULL_MIN, VEC_HULL_MAX);

	self.view_ofs = PLAYER_VIEW_OFFSET;
	self.state = 0;

	player_stand ();

	spawn_tdeath (self.origin, self);

	if (is_phoenix)
	{
		self.ammo_shells = self.ammo_shells + 25;
		if (self.ammo_shells > MAX_SHELLS)
			self.ammo_shells = MAX_SHELLS;
		centerprint (self, "You've risen again!");

		sound (self, CHAN_AUTO, "misc/power.wav", 1, ATTN_NORM);

		ThrowGib ("progs/gib1.mdl", (0 - self.health));
		ThrowGib ("progs/gib2.mdl", (0 - self.health));
		ThrowGib ("progs/gib3.mdl", (0 - self.health));

		sprint (self, "You got the Quad Damage\n");
		if (self.runevar == 0)
		{
			sprint (self, "No resurrections left, rune deleted.\n");
			Rune_Delete (0);
		}
		else
		{
			sprint_float (self, self.runevar);
			sprint (self, " resurrection");
			if (self.runevar != 1)
				sprint (self, "s");
			sprint (self, " left.\n");
		}
	}
};

void ()
Berserk_Bleed =
{
	if (self.runevar > time)
		return;
	self.runevar = time + 0.2;

	IN_POQ([-
		local float r1, r2;

		r1 = crandom ()*50;
		r2 = crandom ()*50;
		makevectors (self.angles);
		SpawnBlood (self.origin IN_POQ(+ '0 0 15'),
				v_right*r1 + v_forward*r2 - '0 0 15',
				30);
	-], [-
		local float r1, r2;
		local vector o;

		r1 = crandom () * 20;
		r2 = crandom () * 20;
		o = self.origin + '1 0 0' * r1 + '0 1 0' * r2;
		if (random () < 0.25)
			create_te_lightningblood (o);
		else
			create_te_blood (o, 1);
	-])

	IN_POQ([-
		self.punchangle_x = crandom ()*2;
		self.punchangle_y = crandom ()*2;
		self.punchangle_z = crandom ()*2;
	-], [-
		self.velocity_x = self.velocity_x + crandom() * 75;
		self.velocity_y = self.velocity_y + crandom() * 75;
	-])
};

void ()
Wall_Check =
{
	// Allow phased holder in lava to blink.
	if (pointcontents (self.origin) == CONTENT_LAVA)
		Rune_Blink (1);

	makevectors (self.v_angle);
	traceline (self.origin, self.origin + v_forward*210, TRUE, self);  // 35

	if (trace_fraction == 1)
		return;

	local float n;
	local vector neworg, oldorg;

	n = 105; // 36
	while (n < 420 && (pointcontents (self.origin + v_forward*n) != CONTENT_EMPTY))
		n = n + 75; // 60

	if (n >= 420)
		return;

	neworg = self.origin + v_forward* (n + 45);
	oldorg = self.origin;

	if (pointcontents (neworg) != CONTENT_EMPTY)
		return;

	HookOff ();
	HookOff_by_targ ();

	setorigin (self, neworg);
};
