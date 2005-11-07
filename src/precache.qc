/*  $Id: precache.qc,v 1.6 2005/11/07 23:11:42 slotzero Exp $

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
//
// *** = used by C code
void ()
precaches =
{
	// blob/
	precache_sound ("blob/death1.wav");		// unfrozen/unglued
	precache_sound ("blob/hit1.wav");		// glue caught
	precache_sound ("blob/land1.wav");		// hook tears/glue stops
	precache_sound ("blob/sight1.wav");		// glue toss

	// boss1/
	precache_sound ("boss1/out1.wav");		// tornado pull
	precache_sound ("boss1/sight1.wav");		// haste attack
	precache_sound ("boss1/throw.wav");		// trigger fire trap

	// boss2/
	precache_sound ("boss2/idle.wav");		// (dspot/weirdness) touch

	// buttons/
	precache_sound ("buttons/switch04.wav");	// (dspot/ice/well) placed/divine tick

	// demon/
	precache_sound ("demon/ddeath.wav");		// antipack pickup
	precache_sound ("demon/dhit2.wav");		// antipack pickup
	precache_sound ("demon/dland2.wav");		// *** SV_Physics_Step()
	precache_sound ("demon/dpain1.wav");		// monk

	// doors/
	precache_sound ("doors/airdoor2.wav");		// enviro-jump
	precache_sound ("doors/meduse.wav");		// tornado toss
	precache_sound ("doors/runetry.wav");		// bomb tick

	// enforcer/
	precache_sound ("enforcer/sight2.wav");		// (ice/blizzard) placed
	precache_sound ("enforcer/sight3.wav");		// sonar activated

	// fish/
	precache_sound ("fish/bite.wav");		// ice trap (activated/deactivated)

	// hknight/
	precache_sound ("hknight/attack1.wav");		// fire magic shotgun
	precache_sound ("hknight/hit.wav");		// *** TE_KNIGHTSPIKE/flame missiles/firewalk/fire trap

	// items/
	precache_sound ("items/armor1.wav");		// (armor/good armor) pickup/regen activate
	precache_sound ("items/damage.wav");		// quad pickup/radiation set
	precache_sound ("items/damage2.wav");		// (quad/phoenix) wears off
	precache_sound ("items/damage3.wav");		// (quad/berserk/strength/phoenix) does damage
	precache_sound ("items/inv1.wav");		// ring/death spot actived/cloaked
	precache_sound ("items/itembk2.wav");		// item respawn sound
	precache_sound ("items/protect2.wav");		// (pent/shield) off
	precache_sound ("items/protect3.wav");		// (pent/shield/resistance) takes damage
	precache_sound ("items/r_item1.wav");		// health box/(enviro/regen/radio) heal/requiem
	precache_sound ("items/r_item2.wav");		// mega health/regen activate

	// knight/
	precache_sound ("knight/sword1.wav");		// lumberjack axe
	precache_sound ("knight/sword2.wav");		// flame thrower fire

	// misc/
	precache_sound ("misc/basekey.wav");		// place hologram
	precache_sound ("misc/h2ohit1.wav");		// *** SV_CheckWaterTransition()
	precache_sound ("misc/outwater.wav");		// leaving water sound
	precache_sound ("misc/power.wav");		// phoenix respawn
	precache_sound ("misc/r_tele1.wav");		// teleport
	precache_sound ("misc/r_tele2.wav");		// teleport
	precache_sound ("misc/r_tele3.wav");		// teleport
	precache_sound ("misc/r_tele4.wav");		// teleport/uncloak
	precache_sound ("misc/r_tele5.wav");		// teleport
	precache_sound ("misc/talk.wav");		// player talk/world message/countdown timer
	precache_sound ("misc/water1.wav");		// swimming/underwater (lava/flamethrower) discharge
	precache_sound ("misc/water2.wav");		// swimming/underwater (lava/flamethrower) discharge

	// player/
	precache_sound ("player/axhit1.wav");		// axe hits meat
	precache_sound ("player/axhit2.wav");		// axe hits world/hook bounce
	precache_sound ("player/death1.wav");		// normal death
	precache_sound ("player/death2.wav");		// normal death
	precache_sound ("player/death3.wav");		// normal death
	precache_sound ("player/death4.wav");		// normal death
	precache_sound ("player/death5.wav");		// normal death
	precache_sound ("player/drown1.wav");		// drowning
	precache_sound ("player/drown2.wav");		// drowning
	precache_sound ("player/gasp1.wav");		// soft gasping
	precache_sound ("player/gasp2.wav");		// hard gasping
	precache_sound ("player/gib.wav");		// gibbed
	precache_sound ("player/h2odeath.wav");		// drowned
	precache_sound ("player/h2ojump.wav");		// player jumping into water
	precache_sound ("player/inh2o.wav");		// player enter water
	precache_sound ("player/inlava.wav");		// player enter lava/enviro lava heal
	precache_sound ("player/land.wav");		// player landing
	precache_sound ("player/land2.wav");		// hurt landing
	precache_sound ("player/lburn1.wav");		// slime/lava burn
	precache_sound ("player/lburn2.wav");		// slime/lava burn
	precache_sound ("player/pain1.wav");		// normal pain
	precache_sound ("player/pain2.wav");		// normal pain
	precache_sound ("player/pain3.wav");		// normal pain
	precache_sound ("player/pain4.wav");		// normal pain
	precache_sound ("player/pain5.wav");		// normal pain
	precache_sound ("player/pain6.wav");		// normal pain
	precache_sound ("player/plyrjmp8.wav");		// player jump/jumping rune/jump weirdness
	precache_sound ("player/slimbrn2.wav");		// player enter slime/enviro slime heal
	precache_sound ("player/teledth1.wav");		// telefragged
	precache_sound ("player/tornoff2.wav");		// player disconnect
	precache_sound ("player/udeath.wav");		// gibbed

	// progs/
	precache_model ("progs/armor.mdl");		// armor drop
	precache_model ("progs/backpack.mdl");		// backpack/antipack
	precache_model ("progs/bolt.mdl");		// *** TE_LIGHTNING1
	precache_model ("progs/bolt2.mdl");		// *** TE_LIGHTNING2
	precache_model ("progs/bolt3.mdl");		// *** TE_LIGHTNING3
	precache_model ("progs/end1.mdl");		// earth magic
	precache_model ("progs/end2.mdl");		// black magic
	precache_model ("progs/end3.mdl");		// hell magic
	precache_model ("progs/end4.mdl");		// elder magic
	precache_model ("progs/eyes.mdl");		// ring/admin eyes/cloak rune
	precache_model ("progs/flame2.mdl");		// burning/firewalk/torch hat
	precache_model ("progs/gib1.mdl");		// gibs
	precache_model ("progs/gib2.mdl");		// gibs
	precache_model ("progs/gib3.mdl");		// gibs
	precache_model ("progs/grenade.mdl");		// grenade/divine hat/betty
	precache_model ("progs/h_player.mdl");		// (death/vengeance) head
	precache_model ("progs/h_shams.mdl");		// shambler head
	precache_model ("progs/h_zombie.mdl");		// zombie head
	precache_model ("progs/laser.mdl");		// wall traps/sniper rune
	precache_model ("progs/lavaball.mdl");		// lavaballs/bfg projectile
	precache_model ("progs/missile.mdl");		// rocket/alt weapon bomb/betty
	precache_model ("progs/oldone.mdl");		// shub hat
	precache_model ("progs/player.mdl");		// player model/hologram
	precache_model ("progs/quaddama.mdl");		// quad (model/hat)
	precache_model ("progs/s_bubble.spr");		// drowning bubbles/extinguished fire/weirdness
	precache_model ("progs/s_explod.spr");		// sprite explosion
	precache_model ("progs/s_light.mdl");		// shambler lightning
	precache_model ("progs/s_light.spr");		// death orb/gravity well
	precache_model ("progs/s_spike.mdl");		// super spike
	precache_model ("progs/shambler.mdl");		// shambler
	precache_model ("progs/spike.mdl");		// spike
	precache_model ("progs/tarbaby.mdl");		// glue model
	precache_model ("progs/teleport.mdl");		// big spiky ball
	precache_model ("progs/v_axe.mdl");		// axe
	precache_model ("progs/v_light.mdl");		// lightning gun
	precache_model ("progs/v_nail.mdl");		// nailgun
	precache_model ("progs/v_nail2.mdl");		// super nailgun
	precache_model ("progs/v_rock.mdl");		// grenade launcher
	precache_model ("progs/v_rock2.mdl");		// rocket launcher
	precache_model ("progs/v_shot.mdl");		// shotgun
	precache_model ("progs/v_shot2.mdl");		// super shotgun
	precache_model ("progs/v_spike.mdl");		// death spot active model
	precache_model ("progs/w_spike.mdl");		// tornado model
	precache_model ("progs/zom_gib.mdl");		// zombie gib
	precache_model ("progs/zombie.mdl");		// zombie

	// shalrath/
	precache_sound ("shalrath/sight.wav");		// player connect

	// shambler/
	precache_sound ("shambler/melee1.wav");		// shambler melee 1
	precache_sound ("shambler/melee2.wav");		// shambler melee 2
	precache_sound ("shambler/sattck1.wav");	// shambler attack
	precache_sound ("shambler/sboom.wav");		// launch lava
	precache_sound ("shambler/sdeath.wav");		// shambler death
	precache_sound ("shambler/shurt2.wav");		// shambler hurt
	precache_sound ("shambler/sidle.wav");		// shambler idle
	precache_sound ("shambler/smack.wav");		// hook first contact/frozen
	precache_sound ("shambler/ssight.wav");		// shambler sight

	// weapons/
	precache_sound ("weapons/ax1.wav");		// axe swoosh/launch hook/firewalk walk
	precache_sound ("weapons/bounce.wav");		// grenade bounce/hook bounce
	precache_sound ("weapons/grenade.wav");		// lob grenade
	precache_sound ("weapons/guncock.wav");		// fire shotgun
	precache_sound ("weapons/lhit.wav");		// lightning gun working/electric attack
	precache_sound ("weapons/lock4.wav");		// (ammo/backpack/antipack) pickup
	precache_sound ("weapons/lstart.wav");		// fire lightning/bfg countdown/electric discharge
	precache_sound ("weapons/pkup.wav");		// weapon pickup
	precache_sound ("weapons/r_exp3.wav");		// *** TE_EXPLOSION/TE_TAREXPLOSION
	precache_sound ("weapons/ric1.wav");		// *** TE_SPIKE/TE_SUPERSPIKE/pierce rune/jack rune
	precache_sound ("weapons/ric2.wav");		// *** TE_SPIKE/TE_SUPERSPIKE/reflect rockets
	precache_sound ("weapons/ric3.wav");		// *** TE_SPIKE/TE_SUPERSPIKE/reflect rockets/sniper rune
	precache_sound ("weapons/rocket1i.wav");	// launch spike/bomb countdown
	precache_sound ("weapons/sgun1.wav");		// launch rocket/launch bfg
	precache_sound ("weapons/shotgn2.wav");		// fire super shotgun
	precache_sound ("weapons/spike2.wav");		// launch super spike/wall spikes
	precache_sound ("weapons/tink1.wav");		// *** TE_SPIKE/TE_SUPERSPIKE/runes bounce

	// wizard/
	precache_sound ("wizard/hit.wav");		// *** TE_WIZSPIKE
	precache_sound ("wizard/wpain.wav");		// vampire steals health

	// zombie/
	precache_sound ("zombie/idle_w2.wav");		// zombie idle
	precache_sound ("zombie/z_fall.wav");		// zombie fall
	precache_sound ("zombie/z_gib.wav");		// zombie gib
	precache_sound ("zombie/z_hit.wav");		// zombie hit
	precache_sound ("zombie/z_idle.wav");		// zombie idle 1
	precache_sound ("zombie/z_idle1.wav");		// zombie idle 2
	precache_sound ("zombie/z_miss.wav");		// impact/spiky ball touch
	precache_sound ("zombie/z_pain.wav");		// zombie pain 1/monk protect
	precache_sound ("zombie/z_pain1.wav");		// zombie pain 2/monk protect
	precache_sound ("zombie/z_shot1.wav");		// zombie shot/burning

	// settings.qc
	precache_sound (SOUND_RUNE_PICKUP);		// you got a rune
};
