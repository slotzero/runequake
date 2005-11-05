/*  $Id: precache.qc,v 1.3 2005/11/05 23:03:19 slotzero Exp $

    Copyright (C) 2005  David 'Slot Zero' Roberts.

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

// The area based ambient sounds MUST be the first precache_sounds.

void ()
precaches =
{
	///////////////////////////////////////////////////////////////////
	// sounds from c code client side temporary entities - cl_tent.c //
	///////////////////////////////////////////////////////////////////

	precache_sound ("wizard/hit.wav");		// TE_WIZSPIKE
	precache_sound ("hknight/hit.wav");		// TE_KNIGHTSPIKE
	precache_sound ("weapons/tink1.wav");		// TE_SPIKE/TE_SUPERSPIKE
	precache_sound ("weapons/ric1.wav");		// TE_SPIKE/TE_SUPERSPIKE
	precache_sound ("weapons/ric2.wav");		// TE_SPIKE/TE_SUPERSPIKE
	precache_sound ("weapons/ric3.wav");		// TE_SPIKE/TE_SUPERSPIKE
	precache_sound ("weapons/r_exp3.wav");		// TE_EXPLOSION/TE_TAREXPLOSION

	////////////////////////////////////////////
	// sounds from c physics code - sv_phys.c //
	////////////////////////////////////////////

	precache_sound ("demon/dland2.wav");		// SV_Physics_Step()
	precache_sound ("misc/h2ohit1.wav");		// SV_CheckWaterTransition()

	/////////////////////////////////////////////////
	// sounds for player standard weapon precaches //
	/////////////////////////////////////////////////

	// #1 axe
	precache_sound ("weapons/ax1.wav");		// axe swoosh
	precache_sound ("player/axhit1.wav");		// axe hits meat
	precache_sound ("player/axhit2.wav");		// axe hits world

	// #2 shotgun
	precache_sound ("weapons/guncock.wav");		// fire shotgun

	// #3 super shotgun
	precache_sound ("weapons/shotgn2.wav");		// fire super shotgun

	// #4 nailgun
	precache_sound ("weapons/rocket1i.wav");	// launch spike
	//precache_sound ("weapons/tink1.wav");		// spike hits wall
	//precache_sound ("weapons/ric1.wav");		// random reflect 1
	//precache_sound ("weapons/ric2.wav");		// random reflect 2
	//precache_sound ("weapons/ric3.wav");		// random reflect 3

	// #5 super nailgun
	precache_sound ("weapons/spike2.wav");		// launch super spike
	//precache_sound ("weapons/tink1.wav");		// super spike hits wall
	//precache_sound ("weapons/ric1.wav");		// random reflect 1
	//precache_sound ("weapons/ric2.wav");		// random reflect 2
	//precache_sound ("weapons/ric3.wav");		// random reflect 3

	// #6 grenade launcher
	precache_sound ("weapons/grenade.wav");		// launch grenade
	precache_sound ("weapons/bounce.wav");		// grenade bounce
	//precache_sound ("weapons/r_exp3.wav");	// grenade explodes

	// #7 rocket launcher
	precache_sound ("weapons/sgun1.wav");		// launch rocket
	//precache_sound ("weapons/r_exp3.wav");	// rocket explodes

	// #8 lightning gun
	precache_sound ("weapons/lstart.wav");		// lightning start
	precache_sound ("weapons/lhit.wav");		// lightning continue

	//////////////////////////////////////////////////
	// sounds for player alternate weapon precaches //
	//////////////////////////////////////////////////

	// #1 hook
	precache_sound ("shambler/smack.wav");		// hook first contact
	precache_sound ("blob/land1.wav");		// hook tears flesh
	//precache_sound ("player/axhit2.wav");		// hook hits world

	// #2 magic shotgun
	precache_sound ("hknight/attack1.wav");		// fire magic shotgun
	//precache_sound ("weapons/r_exp3.wav");	// magic explodes

	// #3 flame thrower
	precache_sound ("knight/sword2.wav");		// fire flame thrower
	precache_sound ("hknight/hit.wav");		// hits world

	// #4 lava gun
	precache_sound ("shambler/sboom.wav");		// launch lava
	//precache_sound ("hknight/hit.wav");		// hits world

	// #5 bomb
	precache_sound ("doors/runetry.wav");		// bomb tick
	//precache_sound ("weapons/r_exp3.wav");	// bomb explodes

	// #6 gas grenade
	//precache_sound ("weapons/grenade.wav");	// launch grenade
	//precache_sound ("weapons/bounce.wav");	// grenade bounce
	//precache_sound ("weapons/r_exp3.wav");	// grenade explodes

	// #7 reflective rockets
	//precache_sound ("weapons/ric2.wav");		// random reflect 1
	//precache_sound ("weapons/ric3.wav");		// random reflect 2
	//precache_sound ("weapons/r_exp3.wav");	// rocket explodes

	// #8 bfg
	//precache_sound ("weapons/lstart.wav");	// bfg countdown
	//precache_sound ("weapons/sgun1.wav");		// bfg launch
	//precache_sound ("weapons/r_exp3.wav");	// bfg explodes

	////////////////////////////
	// player teleport sounds //
	////////////////////////////

	precache_sound ("misc/r_tele1.wav");		// teleport
	precache_sound ("misc/r_tele2.wav");		// teleport
	precache_sound ("misc/r_tele3.wav");		// teleport
	precache_sound ("misc/r_tele4.wav");		// teleport
	precache_sound ("misc/r_tele5.wav");		// teleport

	////////////////////////
	// player pain sounds //
	////////////////////////

	// normal
	precache_sound ("player/pain1.wav");		// normal pain
	precache_sound ("player/pain2.wav");		// normal pain
	precache_sound ("player/pain3.wav");		// normal pain
	precache_sound ("player/pain4.wav");		// normal pain
	precache_sound ("player/pain5.wav");		// normal pain
	precache_sound ("player/pain6.wav");		// normal pain
	precache_sound ("player/land2.wav");		// hurt landing
	precache_sound ("player/drown1.wav");		// drowning
	precache_sound ("player/drown2.wav");		// drowning
	precache_sound ("player/lburn1.wav");		// slime/lava burn
	precache_sound ("player/lburn2.wav");		// slime/lava burn

	/////////////////////////
	// player death sounds //
	/////////////////////////

	precache_sound ("player/death1.wav");		// normal death
	precache_sound ("player/death2.wav");		// normal death
	precache_sound ("player/death3.wav");		// normal death
	precache_sound ("player/death4.wav");		// normal death
	precache_sound ("player/death5.wav");		// normal death
	precache_sound ("player/gib.wav");		// gibbed
	precache_sound ("player/udeath.wav");		// gibbed
	precache_sound ("player/h2odeath.wav");		// drowned
	precache_sound ("player/teledth1.wav");		// telefragged

	/////////////////////////
	// player items sounds //
	/////////////////////////

	precache_sound ("items/itembk2.wav");		// item respawn sound
	precache_sound ("weapons/lock4.wav");		// ammo pick up
	precache_sound ("weapons/pkup.wav");		// weapon pick up
	precache_sound ("items/armor1.wav");		// armor pick up

	////////////////////////
	// player misc sounds //
	////////////////////////

	precache_sound ("player/plyrjmp8.wav");		// player jump
	precache_sound ("player/h2ojump.wav");		// player jumping into water
	precache_sound ("player/land.wav");		// player landing
	precache_sound ("player/slimbrn2.wav");		// player enter slime
	precache_sound ("player/inh2o.wav");		// player enter water
	precache_sound ("player/inlava.wav");		// player enter lava
	precache_sound ("misc/water1.wav");		// swimming
	precache_sound ("misc/water2.wav");		// swimming
	precache_sound ("player/gasp1.wav");		// soft gasping
	precache_sound ("player/gasp2.wav");		// hard gasping
	precache_sound ("misc/outwater.wav");		// leaving water sound
	precache_sound ("misc/talk.wav");		// talk
	precache_sound ("shalrath/sight.wav");		// player connect
	precache_sound ("player/tornoff2.wav");		// player disconnect

	///////////////////////////////////////////////////////////////////
	// models from c code client side temporary entities - cl_tent.c //
	///////////////////////////////////////////////////////////////////

	precache_model ("progs/bolt.mdl");		// TE_LIGHTNING1
	precache_model ("progs/bolt2.mdl");		// TE_LIGHTNING2
	precache_model ("progs/bolt3.mdl");		// TE_LIGHTNING3

	//////////////////
	// player model //
	//////////////////

	precache_model ("progs/player.mdl");		// player model
	precache_model ("progs/eyes.mdl");		// eyes
	precache_model ("progs/h_player.mdl");		// head
	precache_model ("progs/gib1.mdl");		// gibs
	precache_model ("progs/gib2.mdl");		// gibs
	precache_model ("progs/gib3.mdl");		// gibs

	//////////////////////////
	// player weapon models //
	//////////////////////////

	precache_model ("progs/v_axe.mdl");		// axe
	precache_model ("progs/v_shot.mdl");		// shotgun
	precache_model ("progs/v_shot2.mdl");		// super shotgun
	precache_model ("progs/v_nail.mdl");		// nailgun
	precache_model ("progs/v_nail2.mdl");		// super nailgun
	precache_model ("progs/v_rock.mdl");		// grenade launcher
	precache_model ("progs/v_rock2.mdl");		// rocket launcher
	precache_model ("progs/v_light.mdl");		// lightning gun

	/////////////////////////////////////
	// player weapon projectile models //
	/////////////////////////////////////

	precache_model ("progs/spike.mdl");		// spike
	precache_model ("progs/s_spike.mdl");		// super spike
	precache_model ("progs/grenade.mdl");		// grenade
	precache_model ("progs/missile.mdl");		// rocket
	//precache_model ("progs/bolt2.mdl");		// lightning

	////////////////////////
	// player misc models //
	////////////////////////

	precache_model ("progs/backpack.mdl");		// backpack
	precache_model ("progs/zom_gib.mdl");		// zombie gib (why here?)
	precache_model ("progs/lavaball.mdl");		// for testing (not really)

	// this is for world stuff too, no?
	precache_model ("progs/s_bubble.spr");		// drowning bubbles
	precache_model ("progs/s_explod.spr");		// sprite explosion

	////////////////////
	// NOT YET SORTED //
	////////////////////

	precache_model ("progs/armor.mdl");		// armor dropping on e1m7 &c

	precache_sound ("weapons/tink1.wav");		// runes bounce
	precache_sound ("items/damage2.wav");		// phoenix
	precache_sound ("items/damage3.wav");		// berserk, strength, phoenix
	precache_sound ("misc/power.wav");		// lightning for boss/poenix
	precache_sound ("demon/dpain1.wav");		// monk

	/////////////////
	// rune models //
	/////////////////

	precache_model ("progs/end1.mdl");		// earth magic
	precache_model ("progs/end2.mdl");		// black magic
	precache_model ("progs/end3.mdl");		// hell magic
	precache_model ("progs/end4.mdl");		// elder magic

	///////////
	// runes //
	///////////

	// RN_STRENGTH
	precache_sound ("items/damage3.wav");		// strength

	// RN_REGEN
	precache_sound ("items/r_item2.wav");		// regeneration rune

	// RN_RESIST

	// RN_HASTE
	precache_sound ("boss1/sight1.wav");		// haste rune

	// RN_ENVIRO
	precache_sound ("doors/airdoor2.wav");		// enviro-jump

	// RN_FLY

	// RN_BERSERK

	// RN_RECALL

	// RN_ZAP
	precache_model ("progs/bolt2.mdl");		// electric rune

	// RN_CLOAK
	precache_sound ("enforcer/sight3.wav");
	precache_sound ("wizard/widle1.wav");
	precache_sound ("fish/idle.wav");

	// RN_BOMB

	// RN_DSPOTS
	precache_sound ("buttons/switch04.wav");	// death spot placed
	precache_model ("progs/v_spike.mdl");		// death spot active model
	precache_sound ("items/inv1.wav");		// death spot actived
	precache_sound ("boss2/idle.wav");		// blowing up in a death spot

	// RN_HOLO
	precache_model ("progs/player.mdl");
	precache_sound ("misc/basekey.wav");		// holorune activate

	// RN_ORB

	// RN_BLINK

	// RN_CAMO

	// RN_JUMP

	// RN_AMMO

	// RN_VAMP
	precache_sound ("wizard/wpain.wav");		// vampire steals health

	// RN_SHIELD

	// RN_HEALTH

	// RN_RADIO
	precache_sound ("items/damage.wav");		// radiation

	// RN_SWITCH

	// RN_FREEZE
	precache_sound ("enforcer/sight2.wav");		// ice trap placed
	precache_sound ("fish/bite.wav");		// ice trap activated
	precache_sound ("shambler/smack.wav");		// frozen
	precache_sound ("blob/death1.wav");		// released

	// RN_SUCK

	// RN_TWALK

	// RN_IMPACT

	// RN_VENG

	// RN_SHUB
	precache_model ("progs/oldone.mdl");		// shub hat

	// RN_REPEL

	// RN_PHASE

	// RN_SHAMB
	precache_model ("progs/shambler.mdl");
	precache_model ("progs/s_light.mdl");
	precache_model ("progs/h_shams.mdl");
	precache_model ("progs/bolt.mdl");
	precache_sound ("shambler/sattck1.wav");
	precache_sound ("shambler/sboom.wav");
	precache_sound ("shambler/sdeath.wav");
	precache_sound ("shambler/shurt2.wav");
	precache_sound ("shambler/sidle.wav");
	precache_sound ("shambler/ssight.wav");
	precache_sound ("shambler/melee1.wav");
	precache_sound ("shambler/melee2.wav");
	precache_sound ("shambler/smack.wav");

	// RN_DUAL

	// RN_WEIRD

	// RN_PHOENIX

	// RN_CLOUD
	precache_model ("progs/teleport.mdl");		// big spiky ball
	precache_sound ("zombie/z_miss.wav");		// chaff hits someone

	// RN_FIREWALK
	precache_model ("progs/flame2.mdl");		// firewalk, burning
	precache_sound ("hknight/hit.wav");		// firewalk, flame missiles, fire trap

	// RN_HOOK

	// RN_ATHLETE

	// RN_LUMBER
	precache_sound ("knight/sword1.wav");		// lumberjack axe
	precache_sound ("knight/sword2.wav");		// lumberjack axe

	// RN_ZOMBIE
	precache_model ("progs/zombie.mdl");
	precache_model ("progs/h_zombie.mdl");
	precache_model ("progs/zom_gib.mdl");
	precache_sound ("zombie/z_idle.wav");
	precache_sound ("zombie/z_idle1.wav");
	precache_sound ("zombie/z_shot1.wav");
	precache_sound ("zombie/z_gib.wav");
	precache_sound ("zombie/z_pain.wav");
	precache_sound ("zombie/z_pain1.wav");
	precache_sound ("zombie/z_fall.wav");
	precache_sound ("zombie/z_miss.wav");
	precache_sound ("zombie/z_hit.wav");
	precache_sound ("zombie/idle_w2.wav");

	// RN_PIERCING
	precache_sound ("weapons/ric1.wav");		// pierce

	// RN_SELFPRES

	// RN_MONK

	// RN_TORCH
	precache_sound ("hknight/hit.wav");		// firewalk, flame missiles, fire trap
	precache_sound ("boss1/throw.wav");		// trigger fire trap

	// RN_PACK_RAT

	// RN_ARMOR

	// RN_QUAD
	precache_model ("progs/quaddama.mdl");		// quad model
	precache_sound ("items/damage3.wav");		// strength

	// RN_JACK
	precache_sound ("weapons/ric1.wav");		// jack

	// RN_GLUE
	precache_model ("progs/tarbaby.mdl");		// glue model
	precache_sound ("blob/sight1.wav");		// glue toss
	precache_sound ("blob/hit1.wav");		// glue caught

	// RN_BLIZZARD

	// RN_THOR

	// RN_SNIPER

	// RN_ANTIPACK
	precache_sound ("demon/ddeath.wav");
	precache_sound ("demon/dhit2.wav");

	// RN_DEFLECT

	// RN_BETTY

	// RN_TORNADO
	precache_model ("progs/w_spike.mdl");		// tornado model
	precache_sound ("doors/meduse.wav");		// tornado toss
	precache_sound ("boss1/out1.wav");		// tornado suck

	// RN_REQUIEM

	precache_model ("progs/laser.mdl");

	precache_model ("progs/s_light.spr");		// Death orb and gravity well

	precache_sound (SOUND_RUNE_PICKUP);		// You got a rune
	precache_sound ("items/protect2.wav");		// shielding or resistance?
	precache_sound ("items/protect3.wav");		// shielding or resistance?
	precache_sound ("items/r_item1.wav");
};
