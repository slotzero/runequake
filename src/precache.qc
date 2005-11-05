/*  $Id: precache.qc,v 1.2 2005/11/05 05:35:24 slotzero Exp $

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

// the area based ambient sounds MUST be the first precache_sounds

void ()
Precaches =
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

	//////////////////////////////////////
	// player standard weapon precaches //
	//////////////////////////////////////

	// axe
	precache_sound ("weapons/ax1.wav");		// axe swoosh
	precache_sound ("player/axhit1.wav");		// axe hit meat
	precache_sound ("player/axhit2.wav");		// axe hit world

	// shotgun
	precache_sound ("weapons/guncock.wav");

	// super shotgun
	precache_sound ("weapons/shotgn2.wav");

	// nail gun
	precache_sound ("weapons/rocket1i.wav");

	// super nail gun
	precache_sound ("weapons/spike2.wav");

	// grenade launcher
	precache_sound ("weapons/grenade.wav");
	precache_sound ("weapons/bounce.wav");

	// rocket launcher
	precache_sound ("weapons/sgun1.wav");

	// lightning gun
	precache_sound ("weapons/lstart.wav");		// lightning start
	precache_sound ("weapons/lhit.wav");		// lightning continue

	///////////////////////////////////////
	// player alternate weapon precaches //
	///////////////////////////////////////

	// hook
	precache_sound ("shambler/smack.wav");		// hook lands on meat
	precache_sound ("blob/land1.wav");		// hook tears flesh

	// magic shotgun
	precache_sound ("hknight/attack1.wav");

	// flame thrower
	precache_sound ("knight/sword2.wav");

	// lava gun
	precache_sound ("shambler/sboom.wav");

	// bomb
	precache_sound ("doors/runetry.wav");		// bomb tick

	// reflective rockets
	precache_sound ("weapons/ric2.wav");
	precache_sound ("weapons/ric3.wav");
};
