// $Id: runeserv.qc,v 1.2 2002/02/22 05:05:42 slotzero Exp $
//
// Copyright (c) 2001, 2002 Rune Quake Development Team.  All rights reserved.
// See the file `Copying' in the distribution for terms.

void ()
Rune_Think =
{
	if (self.runetype == RN_REGEN)		Rune_Regen (); else
	if (self.runetype == RN_FIREWALK)	Rune_Firewalk (); else
	if (self.runetype == RN_ZAP)		Rune_Zap (); else
	if (self.runetype == RN_BOMB)		Rune_Bomb (); else
	if (self.runetype == RN_CLOAK)		Rune_Cloak (); else
	if (self.runetype == RN_CAMO)		Rune_Camo (); else
	if (self.runetype == RN_JUMP)		Rune_Jump (); else
	if (self.runetype == RN_AMMO)		Rune_Ammo (); else
	if (self.runetype == RN_SHIELD)		Shield_On (); else
	if (self.runetype == RN_REPEL)		Rune_Repel (); else
	if (self.runetype == RN_FLY)		Rune_Fly (); else
	if (self.runetype == RN_WEIRD)		Rune_Weird (); else
	IN_QW([-
		if (self.runetype == RN_IMPACT)		Rune_Impact (); else
	-])
	if (self.runetype == RN_BERSERK)	Berserk_Bleed (); else
	if (self.runetype == RN_QUAD)		quad_think (); else
	if (self.runetype == RN_JACK)		jack_think (); else
	return;
};

void ()
Rune_PostThink =
{
	if (self.runetype == RN_MONK)		monk_think (); else
	return;
};

void ()
Rune_Button =
{
	spawn_protect_off ();
	rune_tell_stop (0);
	if (!self.runetype) return;
	else if (self.runetype == RN_REGEN)	Regen_Activate ();
	else if (self.runetype == RN_FLY)	Rune_Fly_Activate ();
	else if (self.runetype == RN_RECALL)	Rune_Recall ();
	else if (self.runetype == RN_BOMB)	Bomb_Arm ();
	else if (self.runetype == RN_DSPOTS)	Rune_DSpots ();
	else if (self.runetype == RN_HOLO)	Rune_Holo ();
	else if (self.runetype == RN_BLINK)	Rune_Blink (0);
	else if (self.runetype == RN_SHIELD)	Rune_Shield ();
	else if (self.runetype == RN_RADIO)	Rune_Radio ();
	else if (self.runetype == RN_SWITCH)	Rune_Switch ();
	else if (self.runetype == RN_FREEZE)	Rune_Freeze ();
	else if (self.runetype == RN_SUCK)	Suck_Button ();
	else if (self.runetype == RN_ENVIRO)	Enviro_Jump ();
	else if (self.runetype == RN_TWALK)	Rune_Twalk ();
	else if (self.runetype == RN_PHASE)	Wall_Check ();
	else if (self.runetype == RN_SHAMB)	Rune_ShamblerReloc (1);
	else if (self.runetype == RN_DUAL)	Rune_Dual ();
	else if (self.runetype == RN_WEIRD)	Weird_Throw ();
	else if (self.runetype == RN_HOOK)	HookToggle ();
	else if (self.runetype == RN_ATHLETE)	Athlete_Jump ();
	else if (self.runetype == RN_ZOMBIE)	Rune_Zombie ();
	else if (self.runetype == RN_TORCH)	Rune_Torch ();
	else if (self.runetype == RN_QUAD)	quad_activate ();
};

// This doesn't always tell the riders because it can be triggered both
// automatically and on request (impulse 99).  The riders are only told
// when it's done automatically.

string (float riders, float type, float also_hook, float return_string)
Rune_Tell_real =
{
	local string s, s1, s2, s3, s4, d1, d2, d3, r;

	d2 = string_null;
	d3 = string_null;

	if (riders && self.aqflags & AQ_QUIET)
		return;

	if (type == 0)
	{
		s = "No Rune";
		r = "       ";
		d1 = string_null;
	}
	else if (type == RN_HEALTH)
	{
		s = "Rune of Good Health";
		r = " Health";
		d1 = "Maximum health now set to ";
		d2 = ftos (MAX_HEALTH_GOOD_HEALTH);
	}
	else if (type == RN_REGEN)
	{
		s = "Rune of Regeneration";
		r = " Regen ";
		d1 = "Health and armor regenerate";
		d2 = "\nActivate to instantly\nincrease health and armor";
		d3 = "\nRune is removed when activated";
	}
	else if (type == RN_RESIST)
	{
		s = "Rune of Resistance";
		r = " Resist";
		d1 = "You take half damage";
	}
	else if (type == RN_HASTE)
	{
		s = "Rune of Haste";
		r = " Haste ";
		d1 = "Shoot weapons faster";
	}
	else if (type == RN_ENVIRO)
	{
		s = "Rune of Environmental Protection";
		r = " Enviro";
		d1 = "Protection from some runes\nSlime and lava give health";
	}
	else if (type == RN_FLY)
	{
		s = "Rune of Flight";
		r = " Flight";
		if (FLY_TIMER_ON)
		{
			d1 = "Gravity does not affect you\nfor ";
			d2 = ftos (FLY_TIMER_DURATION);
			if (FLY_TIMER_DURATION == 1)
				d3 = " second";
			else
				d3 = " seconds";
		}
		else
			d1 = "Gravity does not affect you";
	}
	else if (type == RN_FIREWALK)
	{
		s = "Rune of Fire Walking";
		r = " FrWalk";
		d1 = "Fire left when you walk burns foes";
	}
	else if (type == RN_RECALL)
	{
		s = "Rune of Recall";
		r = " Recall";
		d1 = "Use once to set your recall point";
		d2 = "\nUse again to go back to that point";
	}
	else if (type == RN_ZAP)
	{
		s = "Electric Rune";
		r = " Elec  ";
		d1 = "Enemies attacked with electricity\nwhen they get too close";
		d2 = "\nAvoid water!";
	}
	else if (type == RN_CLOAK)
	{
		s = "Rune of Cloaking";
		r = " Cloak ";
		d1 = "You are always silent\nYou are invisible unless you fire";
	}
	else if (type == RN_BOMB)
	{
		s = "Rune of Divine Wind";
		r = " Divine";
		d1 = "Kamikaze attack kills\neveryone in view";
	}
	else if (type == RN_DSPOTS)
	{
		s = "Death Spots";
		r = " DSpots";
		d1 = "Leave multicolored traps\nwhich kill when touched\n";
		d2 = ftos (MAX_DSPOTS);
		d3 = " maximum";
	}
	else if (type == RN_HOLO)
	{
		s = "Holorune";
		r = " Holo  ";
		d1 = "Duke Nukem-style holograms\n";
		d2 = ftos (MAX_HOLO);
		d3 = " maximum";
	}
	else if (type == RN_ORB)
	{
		s = "Orb of Death";
		r = " Orb   ";
		d1 = "Sphere of death circles you and\ndamages enemies upon contact";
	}
	else if (type == RN_BLINK)
	{
		s = "Blink Rune";
		r = " Blink ";
		d1 = "\"Random\" teleportation";
	}
	else if (type == RN_CAMO)
	{
		s = "Rune of Camouflage";
		r = " Camo  ";
		d1 = "Full invisibility when still";
	}
	else if (type == RN_JUMP)
	{
		s = "Rune of Uncontrollable Jumping";
		r = " Jumpng";
		d1 = "Enemies jump uncontrollably\nwhen in sight";
	}
	else if (type == RN_AMMO)
	{
		s = "Action Movie Arsenal";
		r = " Arsenl";
		d1 = "Gives ammo and weapons";
	}
	else if (type == RN_VAMP)
	{
		s = "Vampiric Rune";
		r = " Vamp  ";
		d1 = "Damage other players to\nget their health";
	}
	else if (type == RN_SHIELD)
	{
		s = "Rune of Shielding";
		r = " Shield";
		d1 = "Invulnerability for ";
		d2 = ftos (RN_SHIELD_DURATION);
		d3 = "\nseconds when activated";
	}
	else if (type == RN_STRENGTH)
	{
		s = "Rune of Strength";
		r = " Strgth";
		d1 = "Your attacks do double damage";
	}
	else if (type == RN_RADIO)
	{
		s = "Rune of Radioactivity";
		r = " Radio ";
		d1 = "Irradiate areas, opponents die\nslowly but you are healed\n";
		d2 = ftos (MAX_RADIO);
		if (MAX_RADIO == 1)
			d3 = " area maximum";
		else
			d3 = " areas maximum";
	}
	else if (type == RN_SWITCH)
	{
		s = "Switch Rune";
		r = " Switch";
		d1 = "Switch place, items, ammo\nand powerups with enemy";
	}
	else if (type == RN_FREEZE)
	{
		s = "Ice Traps";
		r = " Ice   ";
		d1 = "Leave icy traps which\nimmobilize when touched\n";
		d2 = ftos (MAX_FREEZE);
		d3 = " maximum";
	}
	else if (type == RN_SUCK)
	{
		s = "Gravity Rune";
		r = " Grav  ";
		d1 = "Sphere of gravity sucks\nin enemies and items";
	}
	else if (type == RN_TWALK)
	{
		s = "The Teleport Shuffle";
		r = " Telprt";
		d1 = "Teleport anywhere you can see\nTelefrag your enemies";
	}
	else if (type == RN_IMPACT)
	{
		s = "Impact Rune";
		r = " Impact";
		d1 = "Attacks move foes around and\nhurt more, hockey-style checking";
		d2 = "\ndoes serious damage";
	}
	else if (type == RN_VENG)
	{
		s = "Rune of Vengeance";
		r = " Vengnc";
		d1 = "Damage done to you\nalso done to attacker";
	}
	else if (type == RN_SHUB)
	{
		s = "Shub Hat";
		r = " Shub  ";
		d1 = "A hologram of Shub-Niggurath\nsurrounds you, most people";
		d2 = "\nshould delete this rune";
	}
	else if (type == RN_REPEL)
	{
		s = "Rune of Repulsion";
		r = " Repuls";
		d1 = "Push rockets, death spots,\nand people back from you";
		d2 = "\nTry your grenade launcher";
	}
	else if (type == RN_CLOUD)
	{
		s = "Rune of Floating Spiky Death Cloud";
		r = " Spikey";
		d1 = "Cloud above you spews balls\nwhich damage foes";
	}
	else if (type == RN_SHAMB)
	{
		s = "Shambler Helper";
		r = " Shmblr";
		d1 = "Your own personal shambler\nto attack your foes";
	}
	else if (type == RN_DUAL)
	{
		s = "Rune of Dual Recall";
		r = " DualRl";
		d1 = "Activate to teleport to last\nplace where you activated it";
		d2 = "\nTelefrag your enemies";
	}
	else if (type == RN_WEIRD)
	{
		s = "Rune of Weirdness";
		r = " Weird ";
		d1 = "Small blue balls induce\ndrug-like effects in foes";
	}
	else if (type == RN_PHOENIX)
	{
		s = "Phoenix Rune";
		r = " Phenix";
		d1 = "Respawn with quad and items\n3 respawns maximum";
	}
	else if (type == RN_BERSERK)
	{
		s = "Berserker Rune";
		r = " Beserk";
		d1 = "Deal 6x damage\nTake 3x damage";
	}
	else if (type == RN_PHASE)
	{
		s = "Phasing Rune";
		r = " Phase ";
		d1 = "Walk through walls";
	}
	else if (type == RN_HOOK)
	{
		s = "Grappling Hook";
		r = " Grappl";
		d1 = "Activate to throw hook and\nattach to what you hit";
		d2 = "\nActivate again to release";
	}
	else if (type == RN_ATHLETE)
	{
		s = "Rune of Athletics";
		r = " Athlet";
		d1 = "Jump Higher\nSwim Farther";
	}
	else if (type == RN_LUMBER)
	{
		s = "Lumberjack Rune";
		r = " Lumber";
		d1 = "More health\nBetter axe\nMore damage";
	}
	else if (type == RN_ZOMBIE)
	{
		s = "Houngan Rune";
		r = " Houngn";
		d1 = "Activate to place camping zombies";
	}
	else if (type == RN_PIERCING)
	{
		s = "Rune of Armor Piercing";
		r = " Pierce";
		d1 = "Your attacks ignore\nyour opponent's armor";
	}
	else if (type == RN_SELFPRES)
	{
		s = "Rune of Self Preservation";
		r = " SelfPr";
		d1 = "Your attacks can't hurt you";
	}
	else if (type == RN_MONK)
	{
		s = "Zen Monk";
		r = " Monk  ";
		d1 = "Mostly invulnerable when\nnot moving or shooting";
	}
	else if (type == RN_TORCH)
	{
		s = "Human Torch";
		r = " Torch ";
		d1 = "Better flame weapons\n";
		d2 = ftos (MAX_TORCH);
		if (MAX_TORCH == 1)
			d3 = " flaming trap maximum\nBeware of water!";
		else
			d3 = " flaming traps maximum\nBeware of water!";
	}
	else if (type == RN_PACK_RAT)
	{
		s = "Pack Rat";
		r = " PckRat";
		d1 = "Collect runes to score\nbonus frags with each kill";
	}
	else if (type == RN_ARMOR)
	{
		s = "Rune of Good Armor";
		r = " Armor ";
		d1 = "All armor is red armor\nCollect lots\nArmor color shows amount left";
	}
	else if (type == RN_QUAD)
	{
		s = "Rune of Quad Damage";
		r = " Quad  ";
		d1 = "Quad damage for ";
		d2 = ftos (RN_QUAD_DURATION);
		if (RN_QUAD_DURATION == 1)
			d3 = " second\nwhen activated";
		else
			d3 = " seconds\nwhen activated";
	}
	else if (type == RN_JACK)
	{
		s = "Jack of All Runes";
		r = " Jack  ";
		d1 = "A smattering of other\nrunes' abilities\nin less potent form";
	}
	else if (type == RN_LITHIUM_HOOK)
	{
		s = "Grappling Hook";
		r = "       ";
		d1 = "Non-rune grappling hook,\nuse with axe toggle or +hook";
		d2 = "\nor hook-on or hook-toggle";
	}
	else
	{
		s = "Invalid Rune";
		r = "       ";
		d1 = string_null;
	}

	s1 = "\n\n\n\n\n\n";
	if (also_hook)
		s2 = "Grappling hook, plus";
	else
		s2 = string_null;
	s3 = "\nùûûûûûûûûûûûûûûûûûûûûü\nè ";
	s4 = " è\nùûûûûûûûûûûûûûûûûûûûûü\n";

	if (return_string)
	{
		if (return_string == 2)
			return s;
		else
			return r;
	}
	else
	{
		if (riders)
			centerprint7 (self, s2, s3, s, s4, d1, d2, d3);
		else
			self_centerprint (self, s2, s3, s, s4, d1, d2, d3);
	}
};

void (float r, entity of_e)
Rune_Tell_sprint =
{
	local float i;
	local string s;

	// No need for extra info when you first pick up the rune, but
	// do show it for riders who just got on.
	if (r && of_e == self)
		return;

	if (of_e.dropdelay < 0 && fabs (of_e.dropdelay) > time)
	{
		i = fabs (of_e.dropdelay) - time;
		i = ceil (i);
		s = ftos (i);

		if (i > 5)
			rprint3 (self, r, "Rune will be removed in ", s, " seconds\n");
		else
			rprint (self, r, "Rune will be removed\n");
	}

	if	(of_e.runetype == RN_FLY)	Rune_Fly_sprint (r, of_e);
	else if (of_e.runetype == RN_RECALL)	Rune_Recall_sprint (r, of_e);
	else if (of_e.runetype == RN_DSPOTS)	Rune_DSpots_sprint (r, of_e);
	else if (of_e.runetype == RN_HOLO)	Rune_Holo_sprint (r, of_e);
	else if (of_e.runetype == RN_RADIO)	Rune_Radio_sprint (r, of_e);
	else if (of_e.runetype == RN_FREEZE)	Rune_Freeze_sprint (r, of_e);
	else if (of_e.runetype == RN_SUCK)	Rune_Suck_sprint (r, of_e);
	else if (of_e.runetype == RN_SHAMB)	Rune_Shambler_sprint (r, of_e);
	else if (of_e.runetype == RN_PHOENIX)	Rune_Phoenix_sprint (r, of_e);
	else if (of_e.runetype == RN_ZOMBIE)	Rune_Zombie_sprint (r, of_e);
	else if (of_e.runetype == RN_TORCH)	Rune_Torch_sprint (r, of_e);
	else if (of_e.runetype == RN_PACK_RAT)	pack_rat_sprint (r, of_e);
};

void (float type, float tell)
Rune_Activate =
{
	local float best, old_rune;

	spawn_protect_off ();

	if (type == RN_LITHIUM_HOOK)
	{
		self.aqflags = self.aqflags | AQ_HOOK;
		if (tell)
		{
			cloaked_sound (self, CHAN_BODY, SOUND_RUNE_PICKUP,
					1, ATTN_NORM);
			muzzleflash ();
			Rune_Tell (1, self, type, 0);
		}
		draw_hud (1);
		return;
	}

	best = W_BestWeapon ();

	// Clean up rune being removed.
	if (self.runetype == RN_PACK_RAT)
		pack_rat_rune_drop (0);
	else if (self.runetype == RN_HOOK)
		HookOff ();
	else if (self.runetype == RN_MONK)
		monk_trance_off ();

	self.max_health	= MAX_HEALTH_NORMAL;
	self.movetype	= MOVETYPE_WALK;
	self.runent	= world;
	self.runetime	= time;
	self.runevar	= 0;
	self.class_cnt	= 0;
	self.runevector	= VEC_ORIGIN;
	self.touch	= SUB_Null;
	stuffcmd (self, CSHIFT_NONE);

	old_rune = self.runetype;
	self.runetype = 0;

	// This has to run after max_health is reset else no rotting
	// will take place.
	if (old_rune == RN_HEALTH
			|| old_rune == RN_LUMBER
			|| old_rune == RN_JACK)
		decay_health_spawn (self, 1);
	else if (old_rune == RN_ARMOR)
	{
		decay_armor_spawn (self, ARMOR_DECAY_RATE);
		set_armor_items_e (self);
	}

	self.runetype	= type;

	// If tell is set this is a new pick up, so enforce the delay before
	// allowing a drop.  Otherwise, this is the rune she had last level.
	if (tell)
	{
		if (self.runetype)
		{
			if (rune_drop_delay == -1)
				self.dropdelay = time + 5;		// in case it changes
			else if (DROP_INTERVAL)
			{
				self.last_drop_delay = self.last_drop_delay + 5;
				self.dropdelay = time + self.last_drop_delay;
				if (self.last_drop_delay > rune_drop_delay)
					self.dropdelay = time + rune_drop_delay;
			}
			else
				self.dropdelay = time + rune_drop_delay;
			muzzleflash ();
			cloaked_sound (self, CHAN_BODY, SOUND_RUNE_PICKUP, 1, ATTN_NORM);
			Rune_Tell (1, self, self.runetype, 0);
		}
		else
		{
			if (!self.aqflags & AQ_QUIET)
			{
				centerprint (self, "Rune Removed");
				rune_tell_stop (1);
			}
			else
				rune_tell_stop (0);
		}
	}
	else
		self.dropdelay = time;

	if (self.runetype == RN_HEALTH)
	{
		self.max_health = MAX_HEALTH_GOOD_HEALTH;
		if (tell && self.health < self.max_health)
		{
			self.health = self.health + HEALTH_BONUS_GOOD_HEALTH;
			if (self.health > self.max_health)
				self.health = self.max_health;
		}
	}
	else if (self.runetype == RN_FLY)
	{
		self.class_cnt = FLY_TIMER_DURATION;
		Rune_Fly_Activate ();
	}

	else if (self.runetype == RN_ZAP)
		Zap_Spawn (tell);

	else if (self.runetype == RN_BOMB)
		Bomb_Spawn ();

	else if (self.runetype == RN_DSPOTS)
		self.class_cnt = count_class_own (self, "dspot");

	else if (self.runetype == RN_ORB)
		Orb_Spawn ();

	else if (self.runetype == RN_BLINK)
		Hat_Spawn ("progs/s_bubble.spr", '-4 2 31', VEC_ORIGIN);

	else if (self.runetype == RN_RADIO)
		self.class_cnt = count_class_own (self, "radioative");

	else if (self.runetype == RN_FREEZE)
		self.class_cnt = count_class_own (self, "freeze");

	else if (self.runetype == RN_VENG)
		VengHead_Spawn ();

	else if (self.runetype == RN_SHUB)
		ShubHat_Spawn ();

	else if (self.runetype == RN_CLOUD)
		Cloud_Spawn ();

	else if (self.runetype == RN_SHAMB)
	{
		if (!tell)
			delayed_shambler_spawn ();
		else
			Rune_ShamblerSpawn ();
	}

	//else if (self.runetype == RN_FIREWALK)
	//	GFire_Spawn ();

	else if (self.runetype == RN_PHOENIX)
	{
		// XXX Don't give these at start of level, but that requires
		// saving this value between levels.
		self.runevar = 3;
	}

	else if (self.runetype == RN_CLOAK) Rune_Cloak ();

	else if (self.runetype == RN_VAMP) Vamp_Spawn ();

	else if (self.runetype == RN_DUAL)
	{
		self.runevector = self.origin;
		Hat_Spawn ("progs/s_spike.mdl", '-4 1 23', '90 0 0');
	}

	else if (self.runetype == RN_IMPACT)
	{
		IN_POQ([-
		self.touch = Impact_Touch;
		-])
		Hat_Spawn ("progs/s_spike.mdl", '-8 1 30', VEC_ORIGIN);
	}

	else if (self.runetype == RN_LUMBER)
	{
		self.max_health = MAX_HEALTH_LUMBER;
		if (tell && self.health < self.max_health)
		{
			self.health = self.health + HEALTH_BONUS_GOOD_LUMBER;
			if (self.health > self.max_health)
				self.health = self.max_health;
		}
	}

	// XXX This isn't ready yet.
	else if (self.runetype == RN_MONK)
		self.touch = monk_touch;

	else if (self.runetype == RN_TORCH)
	{
		self.touch = Torch_Touch;
		self.class_cnt = count_class_own (self, "torchtrap");
		Hat_Spawn ("progs/flame2.mdl", '-4 1 35', VEC_ORIGIN);
	}

	else if (self.runetype == RN_ARMOR)
	{
		local float max;

		// Stop burning
		self.aqstate = self.aqstate - self.aqstate & AQS_BURNING;

		max = get_max_armor ();
		if (tell && self.armorvalue < max)
		{
			sound (self, CHAN_ITEM, "items/armor1.wav", 1,
				ATTN_NORM);
			self.armorvalue = self.armorvalue
						+ ARMOR_BONUS_GOOD_ARMOR;
			if (self.armorvalue > max)
				self.armorvalue = max;
		}
		if (self.armorvalue)
		{
			self.armortype = ARMOR_TYPE_3;
			good_armor_set_armor_items_e (self);
		}
	}

	else if (self.runetype == RN_JACK)
	{
		self.max_health = MAX_HEALTH_JACK;
		if (tell && self.health < self.max_health)
		{
			self.health = self.health + HEALTH_BONUS_JACK;
			if (self.health > self.max_health)
				self.health = self.max_health;
		}
	}

	if (self.weapon == best)
		set_weapon (W_BestWeapon ());
	draw_hud (1);
};

void (float tell)
Rune_Delete =
{
	if (self.runetype && !(self.runetype == RN_SHIELD && self.runevar == 1))
		Rune_Activate (0, tell);
};

entity ()
SelectRuneSpawnPoint =
{
	local float runec, iters;

	// runec is to keep them from clustering
	iters = random ()*100+10;
	runec = 0;
	while (runec < iters)
	{
		runespawn = nextent (runespawn);
		runec = runec + 1;
	}

	runec = 0;
	// Now runec checks for HUGE HUGE loops to prevent crashing

	while (runec < 1500 &&
			(runespawn.classname == "player"
				|| runespawn.classname == "rune"
				|| runespawn.classname == "hook"
				|| runespawn.origin == VEC_ORIGIN))
	{
		runespawn = nextent (runespawn);
		runec = runec + 1;
	}

	return runespawn;
};

float ()
Rune_Must_Move =
{
	local float i;

	i = pointcontents (self.origin);
	return (i == CONTENT_SOLID
		|| i == CONTENT_LAVA
		|| i == CONTENT_SLIME
		|| (i == CONTENT_WATER
			&& (self.runetype == RN_ZAP
				|| self.runetype == RN_FIREWALK
				|| self.runetype == RN_TORCH)));
};

void ()
Rune_Move =
{
	local float must_move;
	local entity temp;

	must_move = Rune_Must_Move ();

	if (time < self.runetime - 3 && !must_move)
	{
		if (self.runetype == RN_JACK)
		{
			self.cnt = self.cnt + 1;
			if (self.cnt > 3)
				self.cnt = 0;
			self.mdl = Rune_Model (self.cnt);
			setmodel (self, self.mdl);
		}
		self.nextthink = time + 2;
		if (self.nextthink > self.runetime - 3)
			self.nextthink = self.runetime - 3;
		return;
	}

	// Blink for a few seconds before moving.
	if (time < self.runetime && !must_move)
	{
		local float i;

		i = self.runetime - time;
		if (0)
		{
			local string s;

			bprint ("blink ");
			s = ftos (i);
			bprint (s);
			bprint (" ");
			s = vtos (self.origin);
			bprint (s);
			bprint ("\n");
		}
		if ((i - floor (i)) >= 0.5)
			setmodel (self, self.mdl);
		else
		{
			setmodel (self, string_null);
			//setmodel (self, "progs/s_bubble.spr");
		}
		self.nextthink = time + 0.5;

		return;
	}
	setmodel (self, self.mdl);

	// There can be too many runes by people dropping them when they die.
	// I don't want to remove runes at that point because it would cause
	// them to be removed without blinking.  So, remove this one if there
	// are too many.
	if (runecurrent > runemax)
	{
		// XXX Sometimes, for no reason I can discern, this
		// remove() doesn't actually remove the entity.
		// That causes runecurrent to get out of whack.
		// So, I periodically re-count runecurrent from
		// StartFrame().  I hate that.
		runecurrent = runecurrent - 1;
		remove (self);
		return;
	}

	// Reset dropper fields so you can pick up your own rune after it
	// moves.
	self.owner = world;
	self.enemy = world;
	self.runevar = 0;

	temp = SelectRuneSpawnPoint ();
	setorigin (self, temp.origin);

	self.runetime = time + 60 + random ()*60;
	self.nextthink = self.runetime - 3;

	self.flags = self.flags-(self.flags & FL_ONGROUND);

	self.velocity_x = crandom ()*500;
	self.velocity_y = crandom ()*500;
	self.velocity_z = random ()*500;
};

void ()
Rune_Touch =
{
	local entity temp;
	local string s;

	if (Rune_Must_Move ())
	{
		self.nextthink = time;
		return;
	}

	if (other == world)
		sound (self, CHAN_WEAPON, "weapons/tink1.wav", 1.0, ATTN_NORM);

	if (other.classname != "player")
		return;
	if (other.health <= 0)
		return;
	if (other == self.runent && time < self.lip)
		return;

	if (self.runetype == RN_LITHIUM_HOOK)
	{
		if (other.aqflags & AQ_HOOK)
			return;
	}
	else if (other.runetype == RN_PACK_RAT && self.enemy == other)
	{
		if (!self.runevar & 2)
		{
			centerprint (other,
					"You killed the owner of this rune");
			self.runevar = self.runevar | 2;
		}
		return;
	}
	else if (other.runetype == RN_PACK_RAT)
	{
		pack_rat_rune_touch ();
		return;
	}
	else if (other.runetype != 0)
		return;

	if (other == self.owner && !temp1 & T1_CAN_GET_OWN_RUNE)
	{
		if (!self.runevar & 1)
		{
			if (self.runetype == RN_LITHIUM_HOOK)
				s = "hook";
			else
				s = "rune";
			centerprint2 (other, "This was your ", s);
			self.runevar = self.runevar | 1;
		}
		return;
	}

	temp = self;
	self = other;
	Rune_Activate (temp.runetype, 1);
	self = temp;

	if (self.runetype != RN_LITHIUM_HOOK)
		runecurrent = runecurrent - 1;
	remove (self);
};

string (float ix)
Rune_Model =
{
	     if (ix == -1)	return "progs/v_spike.mdl";
	else if (ix == 0)	return "progs/end1.mdl";
	else if (ix == 1)	return "progs/end2.mdl";
	else if (ix == 2)	return "progs/end3.mdl";
	else			return "progs/end4.mdl";
};

void (vector sorigin, float xmax, float ymax, float zmax, float type, entity spawnee, entity killer)
Rune_Spawn =
{
	local entity rune;
	local float ix;

	rune = spawn ();
	if (type == RN_LITHIUM_HOOK)
		current_hooks = current_hooks + 1;
	else
		runecurrent = runecurrent + 1;
	setorigin (rune, sorigin);

	setsize (rune, '-16 -16 IN_QW(-15, 0)', '16 16 IN_QW(35, 50)');
	rune.movetype = MOVETYPE_BOUNCE;
	rune.solid = SOLID_TRIGGER;
	rune.flags = FL_ITEM;
	rune.velocity_x = crandom ()*xmax;
	rune.velocity_y = crandom ()*ymax;
	rune.velocity_z = random ()*zmax;
	if (type == RN_LITHIUM_HOOK)
		rune.classname = "hook";
	else
		rune.classname = "rune";
	rune.runetype = type;
	rune.owner = spawnee;		// dropper
	rune.enemy = killer;		// killer
	rune.runevar = 0;		// |1 = dropper told, |2 = killer told
	rune.runent = world;		// link for pack rat chain
	rune.lip = 0;			// pack rat pickup time

	if (type == RN_LITHIUM_HOOK)
		ix = -1;
	else if (temp1 & T1_RANDOM_RUNE_MODELS)
		ix = floor (random () * 4);
	else
	{
		// Set the model based on the type, so a rune of type X
		// always has the same model.
		ix = type;
		while (ix > 3)
			ix = ix - 4;
	}
	rune.cnt = ix;
	rune.mdl = Rune_Model (rune.cnt);
	setmodel (rune, rune.mdl);

	rune.touch = Rune_Touch;
	rune.think = Rune_Move;
	rune.runetime = time + 60 + random ()*60;
	// Set RN_JACK up to change models.
	if (rune.runetype == RN_JACK && !temp1 & T1_RANDOM_RUNE_MODELS)
		rune.nextthink = time + 2;
	else
		rune.nextthink = rune.runetime - 3;
};

float (float type)
Rune_Type_Allowed =
{
	if (type == RN_SHUB)					return 0;
	if (type == RN_HOLO)					return 0;
	if (type == RN_HOOK	&& temp1 & T1_HOOK_MASK)	return 0;
	if (type == RN_SUCK	&& sv_gravity != DEFAULT_GRAVITY) return 0;
	if (type == RN_CLOUD	&& !deathmatch & DM_LAN_MODE)	return 0;
	if (type == RN_FIREWALK	&& !deathmatch & DM_LAN_MODE)	return 0;
	if (type == RN_SELFPRES && teamplay & TEAM_SELF_HEALTH_PROT
			&& teamplay & TEAM_SELF_ARMOR_PROT)
								return 0;
	IN_QW([-
		if (type == RN_FLY)				return 0;
		if (type == RN_TWALK)				return 0;
		if (type == RN_PHASE)				return 0;
	-])
	return 1;
};

void (float numspawn)
Rune_SpawnAll =
{
	local float counter, type;
	local entity temp;

	counter = 0;
	while (counter < numspawn)
	{
		temp = SelectRuneSpawnPoint ();
		do
		{
			type = random ()*RN_MAX;
			type = ceil (type);
		} while (!Rune_Type_Allowed (type));
		Rune_Spawn (temp.origin, 500, 500, 500, type, world, world);
		counter = counter + 1;
	}
};

void ()
spawn_lithium_hook =
{
	local entity e;

	e = SelectRuneSpawnPoint ();
	Rune_Spawn (e.origin, 500, 500, 500, RN_LITHIUM_HOOK, world, world);
};
