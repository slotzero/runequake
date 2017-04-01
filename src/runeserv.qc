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
Rune_Think =
{
	if	(self.runetype == RN_REGEN)		Rune_Regen ();
	else if (self.runetype == RN_FIREWALK)		Rune_Firewalk ();
	else if (self.runetype == RN_ZAP)		Rune_Zap ();
	else if (self.runetype == RN_BOMB)		Rune_Bomb ();
	else if (self.runetype == RN_CLOAK)		Rune_Cloak ();
	else if (self.runetype == RN_CAMO)		Rune_Camo ();
	else if (self.runetype == RN_JUMP)		Rune_Jump ();
	else if (self.runetype == RN_AMMO)		Rune_Ammo ();
	else if (self.runetype == RN_SHIELD)		Shield_On ();
	else if (self.runetype == RN_REPEL)		Rune_Repel ();
	else if (self.runetype == RN_FLY)		Rune_Fly ();
	else if (self.runetype == RN_WEIRD)		Rune_Weird ();
	IN_QW([-
	else if (self.runetype == RN_IMPACT)		Rune_Impact ();
	-])
	else if (self.runetype == RN_BERSERK)		Berserk_Bleed ();
	else if (self.runetype == RN_ATHLETE)		Athlete_Run ();
	else if (self.runetype == RN_QUAD)		quad_think ();
	else if (self.runetype == RN_JACK)		jack_think ();
	else if (self.runetype == RN_BLIZZARD)		Blizzard_Think ();
	else if (self.runetype == RN_THOR)		Rune_Thor ();
};

void ()
Rune_PostThink =
{
	if	(self.runetype == RN_MONK)		monk_think ();
};

void ()
Rune_Button =
{
	rune_tell_stop (0);

	if (!self.runetype)
		return;

	if (self.effects & EF_FROZEN)
		return;

	spawn_protect_off ();

	if 	(self.runetype == RN_REGEN)		Regen_Activate ();
	else if (self.runetype == RN_FLY)		Rune_Fly_Activate ();
	else if (self.runetype == RN_RECALL)		Rune_Recall ();
	else if (self.runetype == RN_BOMB)		Bomb_Arm ();
	else if (self.runetype == RN_DSPOTS)		Rune_DSpots ();
	else if (self.runetype == RN_HOLO)		Rune_Holo ();
	else if (self.runetype == RN_BLINK)		Rune_Blink (0);
	else if (self.runetype == RN_SHIELD)		Rune_Shield ();
	else if (self.runetype == RN_RADIO)		Rune_Radio ();
	else if (self.runetype == RN_SWITCH)		Rune_Switch ();
	else if (self.runetype == RN_FREEZE)		Rune_Freeze ();
	else if (self.runetype == RN_SUCK)		Suck_Button ();
	else if (self.runetype == RN_ENVIRO)		Enviro_Jump ();
	else if (self.runetype == RN_TWALK)		Rune_Twalk ();
	else if (self.runetype == RN_PHASE)		Wall_Check ();
	else if (self.runetype == RN_SHAMB)		Rune_ShamblerReloc (1);
	else if (self.runetype == RN_DUAL)		Rune_Dual ();
	else if (self.runetype == RN_WEIRD)		Weird_Throw ();
	else if (self.runetype == RN_HOOK)		HookToggle ();
	else if (self.runetype == RN_ATHLETE)		Athlete_Jump ();
	else if (self.runetype == RN_ZOMBIE)		Rune_Zombie ();
	else if (self.runetype == RN_TORCH)		Rune_Torch ();
	else if (self.runetype == RN_QUAD)		quad_activate ();
	else if (self.runetype == RN_GLUE)		Rune_Glue ();
	else if (self.runetype == RN_BLIZZARD)		Rune_Blizzard ();
	else if (self.runetype == RN_SNIPER)		Rune_Sniper ();
	else if (self.runetype == RN_CLOAK)		Rune_Sonar ();
	else if (self.runetype == RN_ANTIPACK)		Rune_AntiPack ();
	else if (self.runetype == RN_BETTY)		Rune_Betty ();
	else if (self.runetype == RN_TORNADO)		Rune_Tornado ();
};

// This doesn't always tell the riders because it can be triggered both
// automatically and on request (impulse 99).  The riders are only told
// when it's done automatically.

string (float riders, float type, float also_hook, float return_desc)
Rune_Tell_real =
{
	local string s1, s2, s3, s4, desc_l, desc_s, d1, d2, d3;

	if (riders && self.aqflags & AQ_QUIET)
		return string_null;

	if (type == 0)
	{
		desc_l = "No Rune";
		desc_s = "       ";

		d1 = string_null;
  	}
	else if (type == RN_HEALTH)
	{
		desc_l = "Rune of Good Health";
		desc_s = " Health";

		d1 = "Maximum health now set to ";
		d2 = ftos (MAX_HEALTH_GOOD_HEALTH);
	}
	else if (type == RN_REGEN)
	{
		desc_l = "Rune of Regeneration";
		desc_s = " Regen";

		d1 = "Health and armor regenerate\n"
			"Activate to instantly\n"
			"increase health and armor\n"
			"Rune is removed when activated";
	}
	else if (type == RN_RESIST)
	{
		desc_l = "Rune of Resistance";
		desc_s = " Resist";

		d1 = "You take half damage";
	}
	else if (type == RN_HASTE)
	{
		desc_l = "Rune of Haste";
		desc_s = " Haste";

		d1 = "Shoot weapons faster";
	}
	else if (type == RN_ENVIRO)
	{
		desc_l = "Rune of Environmental Protection";
		desc_s = " Enviro";

		d1 = "Protection from some runes\n"
			"Slime and lava give health";
	}
	else if (type == RN_FLY)
	{
		desc_l = "Rune of Flight";
		desc_s = " Flight";

		if (FLY_TIMER_ON) // XXX Add to bit settings.
		{
			d1 = "Gravity does not affect you\n"
				"for ";
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
		desc_l = "Rune of Fire Walking";
		desc_s = " FrWalk";

		d1 = "Fire left when you walk burns foes";
	}
	else if (type == RN_RECALL)
	{
		desc_l = "Rune of Recall";
		desc_s = " Recall";

		d1 = "Use once to set your recall point\n"
			"Use again to go back to that point";
	}
	else if (type == RN_ZAP)
	{
		desc_l = "Electric Rune";
		desc_s = " Elec";

		d1 = "Enemies attacked with electricity\n"
			"when they get too close\n"
			"Avoid water!";
	}
	else if (type == RN_CLOAK)
	{
		desc_l = "Rune of Cloaking";
		desc_s = " Cloak";

		d1 = "You are always silent\n"
			"You are invisible unless you fire\n"
			"Activate to detect nearby enemies";
   	}
	else if (type == RN_BOMB)
	{
		desc_l = "Rune of Divine Wind";
		desc_s = " Divine";

		d1 = "Kamikaze attack kills\n"
			"everyone in view";
	}
	else if (type == RN_DSPOTS)
	{
		desc_l = "Death Spots";
		desc_s = " DSpots";

		d1 = "Leave multicolored traps\n"
			"which kill when touched\n";
		d2 = ftos (MAX_DSPOTS);
		d3 = " maximum";
	}
	else if (type == RN_HOLO)
	{
		desc_l = "Holorune";
		desc_s = " Holo";

		d1 = "Duke Nukem-style holograms\n";
		d2 = ftos (MAX_HOLO);
		d3 = " maximum";
	}
	else if (type == RN_ORB)
	{
		desc_l = "Orb of Death";
		desc_s = " Orb";

		d1 = "Sphere of death circles you and\n"
			"damages enemies upon contact";
	}
	else if (type == RN_BLINK)
	{
		desc_l = "Blink Rune";
		desc_s = " Blink";

		d1 = "\"Random\" teleportation";
	}
	else if (type == RN_CAMO)
	{
		desc_l = "Rune of Camouflage";
		desc_s = " Camo";

		d1 = "Full invisibility when still";
	}
	else if (type == RN_JUMP)
	{
		desc_l = "Rune of Uncontrollable Jumping";
		desc_s = " Jumpng";

		d1 = "Enemies jump uncontrollably\n"
			"when in sight";
	}
	else if (type == RN_AMMO)
	{
		desc_l = "Action Movie Arsenal";
		desc_s = " Arsenl";

		d1 = "Gives ammo and weapons";
	}
	else if (type == RN_VAMP)
	{
		desc_l = "Vampiric Rune";
		desc_s = " Vamp";

		d1 = "Damage other players to\n"
			"get their health";
	}
	else if (type == RN_SHIELD)
	{
		desc_l = "Rune of Shielding";
		desc_s = " Shield";

		d1 = "Invulnerability for ";
		d2 = ftos (RN_SHIELD_DURATION);
		d3 = "\nseconds when activated";
	}
	else if (type == RN_STRENGTH)
	{
		desc_l = "Rune of Strength";
		desc_s = " Strgth";

		d1 = "Your attacks do double damage";
	}
	else if (type == RN_RADIO)
	{
		desc_l = "Rune of Radioactivity";
		desc_s = " Radio";

		d1 = "Irradiate areas, opponents die\n"
			"slowly but you are healed\n";
		d2 = ftos (MAX_RADIO);
		d3 = " maximum";
	}
	else if (type == RN_SWITCH)
	{
		desc_l = "Switch Rune";
		desc_s = " Switch";

		d1 = "Switch place, items, ammo\n"
			"and powerups with enemy";
	}
	else if (type == RN_FREEZE)
	{
		desc_l = "Ice Traps";
		desc_s = " Ice";

		d1 = "Leave icy traps which\n"
			"immobilize when touched\n";
		d2 = ftos (MAX_FREEZE);
		d3 = " maximum";
	}
	else if (type == RN_SUCK)
	{
		desc_l = "Gravity Rune";
		desc_s = " Grav";

		d1 = "Sphere of gravity sucks\n"
			"in enemies and items";
  	}
	else if (type == RN_TWALK)
	{
		desc_l = "The Teleport Shuffle";
		desc_s = " Telprt";

		d1 = "Teleport anywhere you can see\n"
			"Telefrag your enemies";
	}
	else if (type == RN_IMPACT)
	{
		desc_l = "Impact Rune";
		desc_s = " Impact";

		d1 = "Attacks move foes around and\n"
			"hurt more, hockey-style checking\n"
			"does serious damage";
	}
	else if (type == RN_VENG)
	{
		desc_l = "Rune of Vengeance";
		desc_s = " Vengnc";

		d1 = "Damage done to you\n"
			"also done to attacker";
  	}
	else if (type == RN_SHUB)
	{
		desc_l = "Shub Hat";
		desc_s = " Shub";

		d1 = "A hologram of Shub-Niggurath\n"
			"surrounds you, most people\n"
			"should delete this rune";
	}
	else if (type == RN_REPEL)
	{
		desc_l = "Rune of Repulsion";
		desc_s = " Repuls";

		d1 = "Push rockets, death spots,\n"
			"and people back from you\n"
			"Try your grenade launcher";
	}
	else if (type == RN_CLOUD)
	{
		desc_l = "Rune of Floating Spiky Death Cloud";
		desc_s = " Spikey";

		d1 = "Cloud above you spews balls\n"
			"which damage foes";
	}
	else if (type == RN_SHAMB)
	{
		desc_l = "Shambler Helper";
		desc_s = " Shmblr";

		d1 = "Your own personal shambler\n"
			"to attack your foes";
	}
	else if (type == RN_DUAL)
	{
		desc_l = "Rune of Dual Recall";
		desc_s = " DualRl";

		d1 = "Activate to teleport to last\n"
			"place where you activated it\n"
			"Telefrag your enemies";
	}
	else if (type == RN_WEIRD)
	{
		desc_l = "Rune of Weirdness";
		desc_s = " Weird";

		d1 = "Small blue balls induce\n"
			"drug-like effects in foes";
	}
	else if (type == RN_PHOENIX)
	{
		desc_l = "Phoenix Rune";
		desc_s = " Phenix";

		d1 = "Respawn with quad and items\n"
			"3 respawns maximum";
	}
	else if (type == RN_BERSERK)
	{
		desc_l = "Berserker Rune";
		desc_s = " Beserk";

		d1 = "Deal 6x damage\n"
			"Take 3x damage";
	}
	else if (type == RN_PHASE)
	{
		desc_l = "Phasing Rune";
		desc_s = " Phase";

		d1 = "Activate to walk through walls";
	}
	else if (type == RN_HOOK)
	{
		desc_l = "Grappling Hook";
		desc_s = " Grappl";

		d1 = "Activate to throw hook and\n"
			"attach to what you hit\n"
			"Activate again to release";
	}
	else if (type == RN_ATHLETE)
	{
		desc_l = "Rune of Athletics";
		desc_s = " Athlet";

		d1 = "Jump Higher\n"
			"Swim Farther\n"
			"Run Faster\n"
			"Live Longer";
	}
	else if (type == RN_LUMBER)
	{
		desc_l = "Lumberjack Rune";
		desc_s = " Lumber";

		d1 = "More health\n"
			"Better axe\n"
			"More damage";
	}
	else if (type == RN_ZOMBIE)
	{
		desc_l = "Houngan Rune";
		desc_s = " Houngn";

		d1 = "Activate to place camping zombies";
	}
	else if (type == RN_PIERCING)
	{
		desc_l = "Rune of Armor Piercing";
		desc_s = " Pierce";

		d1 = "Your attacks ignore\n"
			"your opponent's armor";
	}
	else if (type == RN_SELFPRES)
	{
		desc_l = "Rune of Self Preservation";
		desc_s = " SelfPr";

		d1 = "Your attacks can't hurt you";
	}
	else if (type == RN_MONK)
	{
		desc_l = "Zen Monk";
		desc_s = " Monk";

		d1 = "Mostly invulnerable when\n"
			"not moving or shooting";
	}
	else if (type == RN_TORCH)
	{
		desc_l = "Human Torch";
		desc_s = " Torch";

		d1 = "Better flame weapons\n";
		d2 = ftos (MAX_TORCH);
		d3 = " maximum\n"
			"Beware of water!";
	}
	else if (type == RN_PACK_RAT)
	{
		desc_l = "Pack Rat";
		desc_s = " PckRat";

		d1 = "Collect runes to score\n"
			"bonus frags with each kill";
	}
	else if (type == RN_ARMOR)
	{
		desc_l = "Rune of Good Armor";
		desc_s = " Armor";

		d1 = "All armor is red armor\n"
			"Collect lots\n"
			"Armor color shows amount left";
	}
	else if (type == RN_QUAD)
	{
		desc_l = "Rune of Quad Damage";
		desc_s = " Quad";

		d1 = "Quad damage for ";
		d2 = ftos (RN_QUAD_DURATION);
		if (RN_QUAD_DURATION == 1)
			d3 = " second\nwhen activated";
		else
			d3 = " seconds\nwhen activated";
	}
	else if (type == RN_JACK)
	{
		desc_l = "Jack of All Runes";
		desc_s = " Jack";

		d1 = "A smattering of other\n"
			"runes' abilities\n"
			"in less potent form";
	}
	else if (type == RN_GLUE)
	{
                desc_l = "Super Blue Stuff";
                desc_s = " BluStf";

                d1 = "Launch sticky traps which\n"
			"prevent your opponent from\n"
			"moving for a few seconds\n";
		d2 = ftos (MAX_GLUE);
		d3 = " maximum";
	}
	else if (type == RN_BLIZZARD)
	{
		desc_l = "Blizzard Rune";
		desc_s = " Blizrd";

		d1 = "Activate to freeze everyone in sight\n"
			"Walk over ice traps to deactivate them";
	}
	else if (type == RN_THOR)
	{
		desc_l = "Rune of Thor";
		desc_s = " Thor";

		d1 = "Lightning gun and constant\n"
			"supply of ammo\n"
			"Shaft works under water!";
	}
	else if (type == RN_SNIPER)
	{
		desc_l = "Sniper Rifle Rune";
		desc_s = " Sniper";

		d1 = "Activate to fire rifle\n"
			"Single shot kills anything\n"
			"Damage to self increases\n"
			"with each kill";
	}
	/*else if (type == RN_SONAR)
	{
		desc_l = "Sonar Rune";
		desc_s = " Sonar";

		d1 = "Emits a sonic wave which\n"
			"detects nearby players";
	}*/
	else if (type == RN_ANTIPACK)
	{
		desc_l = "Anti-Pack Rune";
		desc_s = " AntiPk";

		d1 = "Drop backpacks that\n"
			"take away weapons and ammo";
	}
	else if (type == RN_DEFLECT)
	{
		desc_l = "Telefrag Deflect Rune";
		desc_s = " TelDef";

		d1 = "Deflects most telefrags";
	}
	else if (type == RN_BETTY)
	{
		desc_l = "Bouncing Betty";
		desc_s = " Betty";

		d1 = "Launch a cluster of grenades\n"
			"(requires rockets)";
	}
	else if (type == RN_TORNADO)
	{
		desc_l = "Tornado Rune";
		desc_s = " Trnado";

		d1 = "Lets you toss tornados\n"
			"with super destructive winds\n"
			"(requires cells)";
	}
	else if (type == RN_REQUIEM)
	{
		desc_l = "Requiem Rune";
		desc_s = " Requim";

		d1 = "Items continously recharge\n"
			"when you touch them";
	}
	else if (type == RN_LITHIUM_HOOK)
	{
		desc_l = "Grappling Hook";
		desc_s = "       ";

		d1 = "Non-rune grappling hook,\n"
			"use with axe toggle or +hook\n"
			"or hook-on or hook-toggle";
	}
	else
	{
		desc_l = "Invalid Rune";
		desc_s = "       ";

		d1 = string_null;
	}

	if (return_desc)
	{
		if (return_desc == 1)
			return desc_l;
		else
			return desc_s;
	}

	s1 = "\n\n\n\n\n\n";
	if (also_hook)
		s2 = "Grappling hook, plus";
	else
		s2 = string_null;
	s3 = "\n\<\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\>\n\b\.\b ";
	s4 = " \b\.\b\n\<\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\>\n";

	if (riders)
		centerprint7 (self, s2, s3, desc_l, s4, d1, d2, d3);
	else
		self_centerprint (self, s2, s3, desc_l, s4, d1, d2, d3);

	return string_null;
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
	else if (of_e.runetype == RN_GLUE)	Rune_Glue_sprint (r, of_e);
	else if (of_e.runetype == RN_BLIZZARD)	Rune_Blizzard_sprint (r);
	else if (of_e.runetype == RN_ANTIPACK)	Rune_AntiPack_sprint (r, of_e);
};

void (float type, float tell)
Rune_Activate =
{
	local float best, old_rune;

	// spawn_protect_off ();

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
	self.touch	= misc_touch;
	stuffcmd (self, CSHIFT_NONE);

	old_rune = self.runetype;
	self.runetype = 0;

	// This has to run after max_health is reset else no rotting
	// will take place.
	if (old_rune == RN_HEALTH
			|| old_rune == RN_LUMBER
			|| old_rune == RN_JACK
			|| old_rune == RN_ATHLETE)
		decay_health_spawn (self, 1);
	else if (old_rune == RN_ARMOR)
	{
		decay_armor_spawn (self, ARMOR_DECAY_RATE);
		set_armor_items_e (self);
	}
	else if (old_rune == RN_SHIELD)
	{
		if (self.effects & EF_BRIGHTFIELD)
			self.effects = self.effects - self.effects & EF_BRIGHTFIELD;
		if (!self.takedamage)
			self.takedamage = DAMAGE_AIM;
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
	{
		if (scratch1 & S1_MAX_TRAPS_FOR_LEVEL)
			self.runevar = count_classname_owner (self, "dspot");
		else
			self.class_cnt = count_classname_owner (self, "dspot");
	}

	else if (self.runetype == RN_HOLO)
	{
		if (scratch1 & S1_MAX_TRAPS_FOR_LEVEL)
			self.runevar = count_classname_owner (self, "hologram");
		else
			self.class_cnt = count_classname_owner (self, "hologram");
	}

	else if (self.runetype == RN_ORB)
		Orb_Spawn ();

	else if (self.runetype == RN_BLINK)
		Hat_Spawn (self, "progs/s_bubble.spr", '-4 2 31', VEC_ORIGIN, 0);

	else if (self.runetype == RN_RADIO)
	{
		if (scratch1 & S1_MAX_TRAPS_FOR_LEVEL)
			self.runevar = count_classname_owner (self, "radioactive");
		else
			self.class_cnt = count_classname_owner (self, "radioactive");
	}

	else if (self.runetype == RN_FREEZE)
	{
		if (scratch1 & S1_MAX_TRAPS_FOR_LEVEL)
			self.runevar = count_classname_owner (self, "freeze");
		else
			self.class_cnt = count_classname_owner (self, "freeze");
	}

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
		Hat_Spawn (self, "progs/s_spike.mdl", '-4 1 23', '90 0 0', 0);
	}

	else if (self.runetype == RN_IMPACT)
	{
		IN_POQ([-
			self.touch = Impact_Touch;
		-])
		Hat_Spawn (self, "progs/s_spike.mdl", '-8 1 30', VEC_ORIGIN, 0);
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
		if (scratch1 & S1_MAX_TRAPS_FOR_LEVEL)
			self.runevar = count_classname_owner (self, "torchtrap");
		else
			self.class_cnt = count_classname_owner (self, "torchtrap");
		Hat_Spawn (self, "progs/flame2.mdl", '-4 1 35', VEC_ORIGIN, 0);
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

	else if (self.runetype == RN_ATHLETE)
	{
		self.max_health = MAX_HEALTH_ATHLETE;
		if (tell && self.health < self.max_health)
		{
			self.health = self.health + HEALTH_BONUS_ATHLETE;
			if (self.health > self.max_health)
				self.health = self.max_health;
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

	else if (self.runetype == RN_GLUE)
	{
		if (scratch1 & S1_MAX_TRAPS_FOR_LEVEL)
			self.runevar = count_classname_owner (self, "glue");
		else
			self.class_cnt = count_classname_owner (self, "glue");
	}

	else if (self.runetype == RN_BLIZZARD)
		self.touch = Blizzard_Touch;

	else if (self.runetype == RN_ANTIPACK)
	{
		if (scratch1 & S1_MAX_TRAPS_FOR_LEVEL)
			self.runevar = count_classname_owner (self, "antipack");
		else
			self.class_cnt = count_classname_owner (self, "antipack");
	}

	else if (self.runetype == RN_DEFLECT)
		self.runevar = MAX_DEFLECT;

	else if (self.runetype == RN_BETTY)
	{
		if (self.ammo_rockets < 50)
			self.ammo_rockets = 50;
		if (self.ammo_rockets >= MAX_ROCKETS)
			self.ammo_rockets = MAX_ROCKETS;
		set_current_ammo ();
	}

	else if (self.runetype == RN_TORNADO)
	{
		Hat_Spawn (self, "progs/w_spike.mdl", '0 0 35', VEC_ORIGIN, 0);
		if (self.ammo_cells < 60)
			self.ammo_cells = 60;
		if (self.ammo_cells >= MAX_CELLS)
			self.ammo_cells = MAX_CELLS;
		set_current_ammo ();
 	}

	if (self.weapon == best)
		set_weapon (W_BestWeapon ());
	draw_hud (1);
};

void (float tell)
Rune_Delete =
{
	if (self.runetype) // && !(self.runetype == RN_SHIELD && self.runevar == 1))
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
				|| runespawn.classname == "thrown_head"
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

	if (gamemode == MODE_MATCH)
	{
		if (!match.state)
			return;
	}

	if (Rune_Must_Move ())
	{
		self.nextthink = time;
		return;
	}

	if (other == world && self.last_thought < time)
		sound (self, CHAN_WEAPON, "weapons/tink1.wav", 1.0, ATTN_NORM);
	self.last_thought = time + sys_ticrate;

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
	rune.last_thought = 0;		// don't tink so much

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
	if (type == RN_HOOK && options2 & HOOK_MASK)		return 0;
	if (type == RN_SUCK && sv_gravity != DEFAULT_GRAVITY)	return 0;
	if (type == RN_SELFPRES && teamplay & TEAM_SELF_HEALTH_PROT
			&& teamplay & TEAM_SELF_ARMOR_PROT)	return 0;
	IN_QW([-
		// On some servers, this rune doesn't work right.  I use zquake
		// version 0.15-dev, which seems to correct the problem.
		// if (type == RN_FLY)				return 0;

		if (type == RN_TWALK)				return 0;
		if (type == RN_PHASE)				return 0;
	-])

	// don't spawn these in practice mode
	if (gamemode == MODE_PRACTICE)
	{
		if (type == RN_ANTIPACK)			return 0;
		if (type == RN_AMMO)				return 0;
	}

	// don't spawn these in arena mode
	if (gamemode & MODE_ARENA)
	{
		if (type == RN_BLINK)				return 0;
	}

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
			if (scratch1 & S1_BASIC_RUNES)
				type = random () * 4;
			else
				type = random () * RN_MAX;
			type = ceil (type);
		} while (!Rune_Type_Allowed (type));
		Rune_Spawn (temp.origin, 500, 500, 500, type, world, world);
		counter = counter + 1;
	}
};

void ()
spawn_runes =
{
	local float i;

	//RUNE SERV: Adding some more runes till too much.
	if (runespawntime < time)
	{
		runespawntime = time + 1 + random ()*15;

		if (runecurrent < runemax)
		{
			if (temp1 & T1_FAST_RUNE_SPAWN)
				Rune_SpawnAll (runemax - runecurrent);
			else
				Rune_SpawnAll (1);
		}

		if (options2 & HOOK_MASK == LITHIUM_HOOK)
		{
			i = count_players (0);
			i = ceil (i / 3);
			if (current_hooks < i)
			{
				if (!temp1 & T1_FAST_RUNE_SPAWN)
					i = current_hooks + 1;
				while (current_hooks < i)
					spawn_lithium_hook ();
			}
		}

		// See the comment in Rune_Move() for why this is done.
		i = count_classname ("rune");
		if (i != runecurrent)
		{
			dprint ("runecurrent bug, ");
			dprint_float (runecurrent);
			dprint (" -> ");
			dprint_float (i);
			dprint ("\n");
			runecurrent = i;
		}
	}
};

void ()
spawn_lithium_hook =
{
	local entity e;

	e = SelectRuneSpawnPoint ();
	Rune_Spawn (e.origin, 500, 500, 500, RN_LITHIUM_HOOK, world, world);
};
