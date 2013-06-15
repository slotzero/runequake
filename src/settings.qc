/*
    Copyright (C) 1998-2001  Roderick Schertler.

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

// This file contains some settings which you might want to customize.  If
// you change anything in here you'll have to recompile the ../progs.dat
// or ../qwprogs.dat file in order for the settings to take effect.
//
// Most people will want to edit settings.qc in either the poq directory
// (for plain old Quake) or the qw directory (for Quakeworld).  People
// who will be working on the source more extensively should see the the
// "source editing" section of the Notes file in the source distribution.
//
// To recompile ../progs.dat or ../qwprogs.dat, you'll need a Quake-C
// compiler.  The complete list of compilers is at,
//
//     ftp://ftp.runequake.com/quake/quakec/compilers/
//
// After you unzip the compiler, run it in either the poq or qw folder.
//
// ### IMPORTANT: As of Rune Quake version 0.5, you are limited to using
//                the qccx 1.0 or frikqcc 2.5 compiler.              ###


// This is the password used to activate admin mode.  It must be 6
// digits long and it must not contain any 9s or 0s.  The special value
// 123456, which is what it is set to by default, does not work.  You
// have to set this yourself and recompile if you want to use this
// feature.

float ADMIN_PASSCODE		= 123456;

// These settings control the passcode used by Qsmack.  Qsmack is a program
// which will allow you to do more flexible and extensive banning than POQ
// provides, among other things.  See http://lemur.stanford.edu/clan9/qsmack/
// for more info.
//
// I recommend that you leave the first impulse at 73.  This guarantees
// that it won't clash with any of the impulses the mod uses.  The
// remaining 4 can safely be any value between 1 and 255 inclusive,
// which still leaves over 4 billion possible passcodes.
//
// Qsmack won't work if any of these aren't set to a value between 1 and
// 255.

float QSMACK_IMPULSE_1		= 73;
float QSMACK_IMPULSE_2		= 0;
float QSMACK_IMPULSE_3		= 0;
float QSMACK_IMPULSE_4		= 0;
float QSMACK_IMPULSE_5		= 0;

// You can configure the server so that it forwards players to
// another server when the game is full.  Set the maximum size
// of the game and the destination here.  Players who type in
// the admin code can connect to the game even though it is
// full.
//
// You have to allow more than this number of people into the
// game so that they can connect and be forwarded, though.
// That is, if you want to limit your local game to 8 players,
// you have to allow at least 9 players to connect, otherwise
// they'll just get a "server full" message.  It's best to
// allow a few extra slots so several people can be forwarded
// at once, and so that it still works if an admin connects and
// so temporarily puts the game over limit.
//
// Note that due to a bug in Quake if the other server is using
// a port other than 26000 you have to use an IP adress rather
// than a host name.  In that case specify the destination as
// something like `192.168.23.42:26001'.  You might want to use
// an IP address rather than a host name regardless, so this
// will work for people who don't have their resolver configured
// properly (bletch).

float FORWARD_MAX_PLAYERS	= 0; // 0 = disabled
string FORWARD_DEST		= IN_POQ("quake.runequake.com", "qw.runequake.com");
string FORWARD_NAME		= "Rune Quake Development Server";

// This is the name of a config file which the server will run
// at the start of every level.  It's okay if this is defined
// but the file doesn't exist.  If you want to turn it off
// anyway, set it to string_null (no quotes).

string START_LEVEL_EXEC		= "startlevel.cfg";

// You can modify the splash screen users see when they connect
// to the server via these variables.  A lot of people like to
// put the server's name and the server op's email address here.
//
// You can have up to 7 lines of text with up to 40 characters
// on each line.  If you use more lines than that players who
// use the default screen size (320x200) won't see some of the
// info.
//
// Use "\n" to start a new line.  If you don't do this the game
// will wrap your text for you.
//
// Eg:
//     SPLASH_1 = "Welcome to Mojo World!\n\n";
//     SPLASH_2 = "http://quake.mojo.com\n\n";
//     SPLASH_3 = "Server admin is quake@mojo.com\n\n";
//     SPLASH_4 = "Let's be careful out there\n";

string SPLASH_1			= "\nInstructions are right\n";
string SPLASH_2			= "here via the menu and at\n";
string SPLASH_3			= "\n";
string SPLASH_4			= "\bwww.runequake.com\b\n";

// This is the amount of water you can be standing in and still safely
// use your lightning gun.  Standard Quake uses 1 (just your feet), but
// I prefer 2 (your waist).  0 means not in water, and 3 means in up to
// your eyes.

float SAFE_DISCHARGE_WATERLEVEL	= 2;

// If this is not zero then the users can use the rider-hide command to
// hide their health, armor, ammo and weapons from their riders.

float ALLOW_RIDER_HIDE		= 0;

// If this is not zero then the code which chooses what size level to
// play (in NOEXIT_CHOOSE_BY_NPLAYERS mode) does not use any random
// variation.  A particular number of players will always play a
// particular map size.

float LEVSIZE_NON_RANDOM	= 0;

// If this percentage of the players (not observers) vote for an exit,
// and the game isn't in match mode, the level will exit.  The number
// required to exit is rounded up.  If this is > 1 or <= 0 exit voting
// is disabled.

float VOTE_EXIT_PERCENTAGE	= 0.51;

// This does the same thing for team mode (unless the TEAM_NO_VOTE bit
// is set in the teamplay variable).  If team mode is voted on it will
// use this value for teamplay.  The default mode is the state a server
// reverts to when there are no players.

float VOTE_TEAM_PERCENTAGE	= 0.51;
float VOTE_TEAM_MODE		= 141;	// health/armor prot, 2 teams, topdog
float VOTE_TEAM_MODE_DEFAULT	= -1;	// -1 teams off, 0 disabled, 1 teams on

// The percentage of players required to vote hook on or off.

float VOTE_HOOK_PERCENTAGE	= 0.51;

// This is the number of seconds of protection that newly spawned players
// get.  Set to 0 to disable.

float SPAWN_PROTECT_DURATION	= 6;

// You get a frag for doing this many points of damage in DM_DAMAGE_MATCH
// mode.

float DAMAGE_MATCH_FRAG		= 150;

// Instead of imposing the rune drop delay immediately, you can set
// the number of seconds to add with each drop until the total delay
// is accumulated.  The delay resets with each death or level change.

float DROP_INTERVAL		= 0;

// By customizing this function you can dictate which maps the server
// will play.  Change "TRUE" to "FALSE" to disallow a map.  The only
// way a map which is set to "FALSE" here can be selected is via the
// `changelevel' and `map' server console commands.

float (string m)
user_allowed_map =
{
	     if (m == "start"){ return TRUE ; } // Welcome to Quake
	else if (m == "e1m1") { return TRUE ; } // The Slipgate Complex
	else if (m == "e1m2") { return TRUE ; } // Castle of the Damned
	else if (m == "e1m3") { return TRUE ; } // The Necropolis
	else if (m == "e1m4") { return TRUE ; } // The Grisly Grotto
	else if (m == "e1m8") { return TRUE ; } // Ziggurat Vertigo
	else if (m == "e1m5") { return TRUE ; } // Gloom Keep
	else if (m == "e1m6") { return TRUE ; } // The Door To Chthon
	else if (m == "e1m7") { return TRUE ; } // The House of Chthon
	else if (m == "e2m1") { return TRUE ; } // The Installation
	else if (m == "e2m2") { return TRUE ; } // Ogre Citadel
	else if (m == "e2m3") { return TRUE ; } // Crypt of Decay
	else if (m == "e2m4") { return TRUE ; } // The Ebon Fortress
	else if (m == "e2m5") { return TRUE ; } // The Wizard's Manse
	else if (m == "e2m6") { return TRUE ; } // The Dismal Oubliette
	else if (m == "e2m7") { return TRUE ; } // Underearth
	else if (m == "e3m1") { return TRUE ; } // Termination Central
	else if (m == "e3m2") { return TRUE ; } // The Vaults of Zin
	else if (m == "e3m3") { return TRUE ; } // The Tomb of Terror
	else if (m == "e3m4") { return TRUE ; } // Satan's Dark Delight
	else if (m == "e3m5") { return TRUE ; } // Wind Tunnels
	else if (m == "e3m6") { return TRUE ; } // Chambers of Torment
	else if (m == "e3m7") { return TRUE ; } // The Haunted Halls
	else if (m == "e4m1") { return TRUE ; } // The Sewage System
	else if (m == "e4m2") { return TRUE ; } // The Tower of Despair
	else if (m == "e4m3") { return TRUE ; } // The Elder God Shrine
	else if (m == "e4m4") { return TRUE ; } // The Palace of Hate
	else if (m == "e4m5") { return TRUE ; } // Hell's Atrium
	else if (m == "e4m6") { return TRUE ; } // The Pain Maze
	else if (m == "e4m7") { return TRUE ; } // Azure Agony
	else if (m == "e4m8") { return TRUE ; } // The Nameless City
	else if (m == "end" ) { return TRUE ; } // Shub-Niggurath's Pit
	else if (m == "dm1" ) { return TRUE ; } // Place of Two Deaths
	else if (m == "dm2" ) { return TRUE ; } // Claustrophobopolis
	else if (m == "dm3" ) { return TRUE ; } // The Abandoned Base
	else if (m == "dm4" ) { return TRUE ; } // The Bad Place
	else if (m == "dm5" ) { return TRUE ; } // The Cistern
	else if (m == "dm6" ) { return TRUE ; } // The Dark Zone

	// Allow unknown maps.
	else
		return TRUE;
};

//-----------------------------------------------------------------------------
// You're unlikely to want to change settings below this.
//-----------------------------------------------------------------------------

// These dictate how long it takes the corresponding item to respawn.

float WEAPON_RESPAWN_TIME	= 30;
float AMMO_RESPAWN_TIME		= 30;
float HEALTH_RESPAWN_TIME	= 20;
float MEGAHEALTH_RESPAWN_TIME	= 60;
float ARMOR_RESPAWN_TIME	= 20;
float FAST_POWERUP_RESPAWN_TIME	= 60;	// quad, envirosuit
float SLOW_POWERUP_RESPAWN_TIME	= 300;	// invisibility, pentagram

// You can set the BARREL_RESPAWN_TIME to 0 to disable respawning
// barrels.

float BARREL_RESPAWN_TIME	= 60;

// How long dropped armor and backpacks last.

float DROP_ARMOR_DURATION	= 120;
float DROP_BACKPACK_DURATION	= 120;

// These dictate how much ammo of a certain type you can carry.

float MAX_SHELLS		= 100;
float MAX_NAILS			= 200;
float MAX_ROCKETS		= 100;
float MAX_CELLS			= 100;

// This sets the default number of runes allowed on the level.  It can
// be changed at run time via temp1 settings, see the configuration
// docs.

float DEFAULT_RUNEMAX		= 16;

// Armor

float ARMOR_TYPE_1		= 0.3;
float ARMOR_TYPE_2		= 0.6;
float ARMOR_TYPE_3		= 0.8;
float MAX_ARMOR_1		= 100;
float MAX_ARMOR_2		= 150;
float MAX_ARMOR_3		= 200;

// These only apply when deathmatch & DM_ROTATING_ARMORS is set.
float ARMOR_ROTATE_INTERVAL	= 1; // seconds
float ARMOR_ROTATE_RANDOM	= 0; // 0 disable | 1 random

// This is the amount of health you can accumulate with mega health
// boxes.  The default is 150, which when added to your base 100 health
// allows you to get up to 250 health.

float MAX_OVER_HEALTH		= 150;

// These are the colors used for the teams in enforced team mode.  These
// are team numbers, not color numbers, so they're 1 higher than the
// corresponding color numbers.
//
// Team numbers:
//     1 white		 8 burleywood
//     2 brown		 9 purple
//     3 lavender	10 pink
//     4 green		11 ivory
//     5 red		12 teal
//     6 khaki		13 yellow
//     7 peach		14 blue

float TEAM_NIL	= 1;	// white
float TEAM_1	= 5;	// red
float TEAM_2	= 14;	// blue
float TEAM_3	= 4;	// green
float TEAM_4	= 2;	// brown

// These control the colors used for the various particle effects.  I
// don't know of a list which details the color values used here.

float PARTICLE_BARREL		= 75;
float PARTICLE_BLOOD		= 73;
float PARTICLE_DEATH_SPOT	= 255;	// originally 40, same as freeze trap
float PARTICLE_ENT_DAMAGE	= 225;
float PARTICLE_FREEZE_TRAP	= 40;
float PARTICLE_IMPACT		= 96;
float PARTICLE_ORB_REMOVE	= 192;
float PARTICLE_RADIATION	= 104;
float PARTICLE_SWITCH_1		= 36;
float PARTICLE_SWITCH_2		= 44;
float PARTICLE_TELEPORT_SHUFFLE	= 8;

// This controls the height of a charged weapon in DM_WEAPONS_STAY mode.

vector WEAPON_CHARGED_OFFSET	= '0 0 25';

// Offset at which to place player from an item she is being spawned at.

vector SPAWN_ITEM_OFFSET	= '0 0 30';

// If this value is greater than or equal to 0 the intermission will
// automatically exit this many seconds after players would have been
// allowed to exit it.

float INTERMISSION_AUTO_EXIT	= 60;

// If this is set to a a value greater than 0 then players who remain
// dead for this many seconds will automatically become observers.  This
// is nice for full games (it lets somebody else join), and it helps
// vote counting, level size selection, forced teams, and the like work
// better by keeping the number of players more accurate.

float AUTO_CORPSE_OBSERVER	= 90;

// Because players reconnect at different speeds, some things shouldn't
// be allowed to happen right at the start of the level before people
// have had a chance to get back into the game.  Eg, if you allow people
// to join the game at the very beginning of a level they can join a
// full game (as not everybody will have reconnected yet).  Places which
// test that sort of thing give this many seconds as a grace period.

float LEVEL_RECONNECT_ALLOWANCE	= 15;

// If this is set to a value greater than 0, runes and weapons will not
// carry over when you start a new level.

float SET_PARMS_WITH_NEW_LEVEL	= 0;

// Timelimit countdown.  Use 1 to enable timer, 2 to enable audible timer,
// and 0 to disable.

float TIMELIMIT_COUNTDOWN	= 0;

// If you want to display a warning message to all players when someone
// picks up the Pentagram of Protection, Quad Damage, Ring of Shadows,
// or Biosuit, add up the bits below.  Use 0 to disable.
//
// 1 Pentagram of Protection	ITEM_PENT
// 2 Quad Damage		ITEM_QUAD
// 4 Ring of Shadows		ITEM_EYES
// 8 Biosuit			ITEM_SUIT

// For all powerups, add 1 + 2 + 4 + 8 = 15.

float POWERUP_PICKUP_WARN	= 0;

// Set the total amount of clients to log with the 'last'
// command.  Use 0 to disable.

float MAX_CLIENT_DISCONNECT_LOG	= 10;

// Amount of minutes a player has to remain idle before going AFK.  Use
// setafk in console to override.

float DEFAULT_AFK_TIME = 5;

//-----------------------------------------------------------------------------
// Weapons
//-----------------------------------------------------------------------------

// These specify how much ammo it takes to shoot the corresponding weapon.

float AMMO_MAGIC_SHOTGUN	= 5;
float AMMO_FLAMETHROWER		= 1;
float AMMO_LAVAGUN		= 1;
float AMMO_BOMB			= 10;
float AMMO_FLASH_GRENADE	= 3;
float AMMO_GUIDED_MISSILE	= 3;
float AMMO_BFG			= 30;

// Amount of damage done by the hook, per tick, for the various hook
// modes.  If the damage is 0 you can't hook creatures with that kind of
// hook.

float HOOK_DAMAGE_FREE		= 1;
float HOOK_DAMAGE_LITHIUM	= 2;
float HOOK_DAMAGE_RUNE		= 4;

// Maximum length of the hook's chain.

float HOOK_MAX_CHAIN_LEN	= 1600;

// Various other hook constants.

float HOOK_TRAVEL_SPEED		= 2500;
float HOOK_LINK_COUNT		= 6;

// Release hook when weapon fires or attaches to a surface too long.  Set this value
// to anything other than zero to enable.  The hook drop delay controls the amount
// of seconds to wait before releasing from surfaces.

float HOOK_CAMP_PROT		= 0;
float HOOK_DROP_DELAY		= 2;

// Settings for burning weapons.

// The _DAMAGE is the amount of damage done by a hit or near miss.
// _BURN_CHANCE is the chance that such a hit will set you on fire.
// The _BURN_DURATION is how much time you'll be burning because of it
// (multiple hits add to the amount of time you'll be burning).

float FLAMETHROWER_DAMAGE	= 15;
float FLAMETHROWER_BURN_CHANCE	= 0.2;
float FLAMETHROWER_BURN_DURATION = 5;

float LAVAGUN_DAMAGE		= 9;
float LAVAGUN_BURN_CHANCE	= 0.15;
float LAVAGUN_BURN_DURATION	= 5;

// These are the same, but for touching a burning player rather than being
// hit with a burning missile.  The chance here should be artificially low
// because this can be triggered many times per tick.

float BURN_TOUCH_CHANCE		= 0.02;
float BURN_TOUCH_DURATION	= 5;

// This controls the burn damage.  BURN_DELAY is how often the burning will
// hurt you.  While you're going to be burning for more than BURN_3_TIME,
// you get hit with BURN_3_DAMAGE every that many seconds, when you drop
// below BURN_2_TIME seconds left to burn you're hit with BURN_2_DAMAGE,
// and when you have less than BURN_2_TIME seconds left to burn you're hit
// with BURN_1_DAMAGE points per BURN_DELAY seconds.

float BURN_DELAY		= 1;
float BURN_1_DAMAGE		= 5;
float BURN_2_TIME		= 8;
float BURN_2_DAMAGE		= 10;
float BURN_3_TIME		= 12;
float BURN_3_DAMAGE		= 15;

// The damages are calculated so that a person with 200 armor and 100
// health will nearly but not quite die from a zap and a direct hit, or
// a zap and a very close hit.

float BFG_TOUCH_DAMAGE		= 225;
float BFG_RADIUS_DAMAGE		= 325;	// doesn't affect impactee
float BFG_ZAP_TIME		= 0.25;
float BFG_ZAP_RANGE		= 250;
float BFG_ZAP_DAMAGE		= 50;

// Axe settings

float AXE_REACH_NORMAL		= 64;
float AXE_REACH_LUMBER		= 140;
float AXE_DAMAGE_NORMAL		= 20;
float AXE_DAMAGE_LUMBER		= 100;	// also gets lumberjack adjustment

// The guided missile only works with manquake dedicated server.

float GUIDED_MISSILE_DAMAGE	= 90;

// Reflective rocket

float REFLECT_DAMAGE		= 90;

// Set this to a value other than zero to turn on grenade spam protection
// in all modes.

float GRENADE_SPAM_OVERRIDE	= 0;

//-----------------------------------------------------------------------------
// Runes
//-----------------------------------------------------------------------------

// Your maximum health under various circumstances.

string SOUND_RUNE_PICKUP	= "buttons/switch21.wav";

float MAX_HEALTH_NORMAL		= 100;
float MAX_HEALTH_LUMBER		= 250;
float MAX_HEALTH_GOOD_HEALTH	= 666;
float MAX_HEALTH_JACK		= 150;
float MAX_HEALTH_ATHLETE	= 125;
float MAX_HEALTH_MIDAIR		= 250;

float HEALTH_BONUS_GOOD_HEALTH	= 100;
float HEALTH_BONUS_GOOD_LUMBER	= 150;
float HEALTH_BONUS_JACK		= 50;
float HEALTH_BONUS_ATHLETE	= 25;

// Flight rune

float FLY_TIMER_ON		= 1;	// 0 to disable timer
float FLY_TIMER_DURATION	= 60;	// seconds

// If this is not zero then you won't get zapped if you go into the
// water with the electricity rune.

float ZAP_RUNE_SAFE_IN_WATER	= 0;

// The number of death spots to place.

float MAX_DSPOTS		= 3;

// The number of holograms to place.

float MAX_HOLO			= 5;

// How long it takes to re-cloak after attacking or whatever.

float RECLOAK_DELAY		= 3;

float RN_SHIELD_DURATION	= 3;
float RN_SHIELD_RECHARGE	= 4.5;

// Settings for the radiation rune.

float MAX_RADIO			= 3;
float RADIO_DURATION		= 45;
float RADIO_DIST		= 1500;
float RADIO_HEAL		= 5;
float RADIO_DAMAGE		= 5;
float RADIO_INTERVAL		= 0.8;

// The number of ice traps to place.

float MAX_FREEZE		= 3;

// The intensity of the gravity well.

float SUCK_FORCE		= IN_QW(0.35, 0.25);

// The intensity of the repulsion rune.

float PUSH_FORCE		= 0.65;

// The number of zombie campers a houngan gets.

float MAX_ZOMBIE_CAMPERS	= 5;

// How long it takes a monk to achieve the meditative state.

float MONK_MOVE_DELAY		= 0.15;
float MONK_ATTACK_DELAY		= 4;

// Torch rune

float MAX_TORCH			= 3;
float TORCH_BURN_TOUCH_CHANCE	= 0.1;		// artificially lower
float TORCH_BURN_TOUCH_DURATION	= 15;
float TORCH_BURN_ATTACK_CHANCE	= 0.15;		// per 100 points of damage
float TORCH_BURN_ATTACK_DURATION= 5;
float TORCH_TRAP_DURATION	= 120;
float TORCH_TRAP_EXPLODE_DAMAGE	= 40;

// With these numbers (and the BURN_* settings above) hitting a fire
// trap and letting it burn out takes:
//
//     30	touch
//     3 * 15	burn 3
//     4 * 10	burn 2
//     8 * 5	burn 1
//     ------
//     155	total

float TORCH_TRAP_TOUCH_DAMAGE	= 30;
float TORCH_TRAP_BURN_DURATION	= 15;

// Pack rat

float PACK_RAT_BONUS_PERCENT	= 0.33;

// Good armor

float ARMOR_BONUS_GOOD_ARMOR	= 200;
float MAX_ARMOR_GOOD_ARMOR	= 767;
float ARMOR_DECAY_RATE		= 5;

// Quad

float RN_QUAD_DURATION		= 3;
float RN_QUAD_RECHARGE		= 6;

// Jack of all runes

float RN_JACK_REGEN_HEALTH	= 0.33;		// portion of max_health
float RN_JACK_REGEN_ARMOR	= 0.5;		// portion of max armor
float RN_JACK_RESIST		= 0.8;		// saved damage
float RN_JACK_STRENGTH		= 1.2;		// extra damage
float RN_JACK_PIERCING		= 0.8;		// portion which hits armor

// Glue Gun Rune

float MAX_GLUE			= 3;

// Blizzard Rune

float BLIZZARD_RECHARGE		= 10;

// Anti-Pack Rune

float MAX_ANTIPACK		= 3;

// Delfect Telefrag Rune

float MAX_DEFLECT		= 3;

// Bouncing Betty

float AMMO_BETTY		= 10;
float MAX_LAUNCH_BETTY		= 5;

// Tornado Rune

float AMMO_TORNADO		= 30;

// Requiem Rune

float RN_REQUIEM_RECHARGE	= 0.5;

// red, green, blue, scale

string	CSHIFT_BLIND		= "v_cshift 256 256 256 200\n";
string	CSHIFT_CLOAK		= "v_cshift   0   0   0  75\n";
string	CSHIFT_FREEZE		= "v_cshift  50  50 256 100\n";
string	CSHIFT_NONE		= "v_cshift   0   0   0   0\n";
string	CSHIFT_SHIELD		= "v_cshift 100 100   0 100\n";

//-----------------------------------------------------------------------------
// Head Hunters
//-----------------------------------------------------------------------------

// Number of seconds before a head times out.

float HEAD_TIMEOUT		= 120;

// This sets the amount of visible heads you can carry.  For no limit, set to zero.

float MAX_VISIBLE_HEADS		= 16;
