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

/*
==============================================================================

			SOURCE FOR GLOBALVARS_T C STRUCTURE

==============================================================================
*/

////////////////////
/* system globals */
////////////////////

entity	self;
entity	other;
entity	world;
float	time;
float	frametime;

IN_QW([-
// if this is set, the entity that just run created a new missile that should
// be simulated immediately
entity	newmis;
-])

// force all entities to touch triggers next frame.  this is needed because
// non-moving things don't normally scan for triggers, and when a trigger is
// created (like a teleport trigger), it needs to catch everything.
// decremented each frame, so set to 2 to guarantee everything is touched
float	force_retouch;
string	mapname;

IN_POQ([-
float	deathmatch;
float	coop;
float	teamplay;
-])

// propagated from level to level, used to keep track of completed episodes
float	serverflags;

float	total_secrets;
float	total_monsters;

float	found_secrets;		// number of secrets found
float	killed_monsters;	// number of monsters killed

// spawnparms are used to encode information about clients across server
// level changes
float	parm1;
float	parm2;
float	parm3;
float	parm4;
float	parm5;
float	parm6;
float	parm7;
float	parm8;
float	parm9;
float	parm10;
float	parm11;
float	parm12;
float	parm13;
float	parm14;
float	parm15;
float	parm16;

////////////////////////////////////////////////
/* global variables set by built in functions */
////////////////////////////////////////////////

// set by makevectors()
vector	v_forward;
vector	v_up;
vector	v_right;

// set by traceline() / tracebox()
float	trace_allsolid;
float	trace_startsolid;
float	trace_fraction;
vector	trace_endpos;
vector	trace_plane_normal;
float	trace_plane_dist;
entity	trace_ent;
float	trace_inopen;
float	trace_inwater;

entity	msg_entity;	// destination of single entity writes

/////////////////////////////
/* required prog functions */
/////////////////////////////

void ()	main;			// only for testing
void ()	StartFrame;
void ()	PlayerPreThink;
void ()	PlayerPostThink;
void ()	ClientKill;
void ()	ClientConnect;
void ()	PutClientInServer;	// call after setting the parm1... parms
void ()	ClientDisconnect;

// called when a client first connects to a server. sets parms so they
// can be saved off for restarts
void ()	SetNewParms;

// call to set parms for self so they can be saved for a level transition
void ()	SetChangeParms;

// flag for structure dumping
void	end_sys_globals;

/*
==============================================================================

			SOURCE FOR ENTVARS_T C STRUCTURE

==============================================================================
*/

/////////////////////////////////////////////////////////////////////////
/* system fields (*** = do not set in prog code, maintained by C code) */
/////////////////////////////////////////////////////////////////////////

.float	modelindex;	// *** model index in the precached list

.vector	absmin;		// *** origin + mins
.vector absmax;		// *** origin + maxs

.float	ltime;		// local time for entity

IN_QW([-
.float	lastruntime;	// *** to allow entities to run out of sequence
-])

.float	movetype;
.float	solid;

.vector	origin;		// ***
.vector	oldorigin;	// ***
.vector	velocity;
.vector	angles;
.vector	avelocity;

IN_POQ([-
.vector	punchangle;	// temp angle adjust from damage or recoil
-])

.string	classname;	// spawn function
.string	model;
.float	frame;
.float	skin;
.float	effects;

// bounding box extents reletive to origin
.vector	mins;
.vector	maxs;
.vector	size;		// maxs - mins

.void()	touch;
.void()	use;
.void()	think;
.void()	blocked;	// for doors or plats, called when can't push other

.float	nextthink;
.entity	groundentity;

// stats
.float	health;
.float	frags;
.float	weapon;		// one of the IT_SHOTGUN, etc flags
.string	weaponmodel;
.float	weaponframe;
.float	currentammo;
.float	ammo_shells;
.float	ammo_nails;
.float	ammo_rockets;
.float	ammo_cells;

.float	items;		// bit flags

.float	takedamage;
.entity	chain;
.float	deadflag;

.vector	view_ofs;	// add to origin to get eye point

.float	button0;	// fire
.float	button1;	// use
.float	button2;	// jump

.float	impulse;	// weapon changes

.float	fixangle;
.vector	v_angle;	// view / targeting angle for players

IN_POQ([-
.float	idealpitch;	// calculated pitch angle for lookup up slopes
-])

.string	netname;

.entity	enemy;

.float	flags;

.float	colormap;
.float	team;

.float	max_health;	// players maximum health is stored here

.float	teleport_time;	// don't back up

.float	armortype;	// save this fraction of incoming damage
.float	armorvalue;

.float	waterlevel;	// -1 = dead (?), 0 = not in, 1 = feet, 2 = wast, 3 = eyes
.float	watertype;	// a contents value

.float	ideal_yaw;
.float	yaw_speed;

.entity	aiment;

.entity	goalentity;	// a movetarget or an enemy

.float	spawnflags;

.string	target;
.string	targetname;

// damage is accumulated through a frame. and sent as one single
// message, so the super shotgun doesn't generate huge messages
.float	dmg_take;
.float	dmg_save;
.entity	dmg_inflictor;

.entity	owner;		// who launched a missile
.vector	movedir;	// mostly for doors, but also used for waterjump

.string	message;	// trigger messages

.float	sounds;		// either a cd track number or sound number

// contains names of wavs to play
.string	noise;
.string	noise1;
.string	noise2;
.string	noise3;

// flag for structure dumping
void	end_sys_fields;

//////////////////////////////////////////////////////////////////////////////
/*================> DO NOT ALTER ANYTHING ABOVE THIS POINT <================*/
//////////////////////////////////////////////////////////////////////////////

/*
==============================================================================

				VARS NOT REFERENCED BY C CODE

==============================================================================
*/

/////////////////////
/* RUNE QUAKE VARS */
/////////////////////

// Global total rune var and current in-level var
float runemax;
float runecurrent;

// Param for every so often, a new rune enters the level.
float runespawntime;

// Needed for spawn selection.
entity runespawn;

// Each players' rune type. Runes' runetype used for what they are.
.float runetype;

// Time at which you can drop your rune.  If negative, you've already
// requested the drop, this is 0 - the time it will be dropped.
.float dropdelay;

// vars for 'special' things that different runes do.
.entity runent;

// For players, various functions based on rune.  For observers, time at
// which to tell ridee of new rider.  For weapons, time at which it will
// be charged in DM_WEAPONS_STAY mode.
.float runetime;
// For players, various functions based on rune.  For observers, time at
// which joined game queue.  For weapons, primary model index.
.float runevar;
.vector runevector;

// various per-player flags, some retained across levels
.float aqflags;

// various per-player flags, retained across levels
.float rqflags;

// state information, not retained across levels
.float aqstate;

// state information, not retained across levels
.float rqstate;

// vote information
.float vote_flags;

// if 0 player hasn't suicided yet this level, if positive the time of
// the last suicide.
.float last_suicide;

// For players, keeps count of existing rune related entities.  For observers,
// length of time to centerprint display player identification.
.float class_cnt;

// For players, holds the number of the player to perform an admin action against.
.float admin_victim_num;

// If true the T_RadiusDamage() won't harm people out of water.  This is
// a hack to restrict lightning gun discharge to harming people in the
// water.  It isn't perfect in that it doesn't require the water the
// victim is in to be connected to the water the attacker is in.
float discharge_hack;

// A similar hack.  Monks are protected against a couple of kinds of radius
// damage.  This is set when one of those is calling T_RadiusDamage().
float monk_radius_hack;

// Another hack.  This one tells the spawn functions not to precache
// their models.  It's used to call the spawn functions after the level
// has started.  You're responsible for precaching the models yourself.
float spawn_no_precache;

// Another hack!  This communicates to centerprint() that it's really the
// HUD that's being output, so don't update the hud refresh time.
float in_hud_hack;

// This is used similarly for printing the rune description.
float in_runedesc_hack;

// This is used to return a second value from team_stats_1().
float team_stats_1_lead;
float NO_FRAGS = -23000;

// This holds either the passcode in settings.qc or gamecfg.
float ADMIN_PASSCODE_REAL;

// Holds the amount of players to allow before forwarding.
float FORWARD_MAX_PLAYERS_REAL;

// Various cvars initialized only at the start of the level.
float sys_ticrate;
float sv_gravity;

// Used to save off the serverflags to prevent the start map hole, yet
// still detect when its time to play the DM maps.
float orig_serverflags;

// In T1_LITHIUM_HOOK mode, this counts the number of hooks either held
// by players or lying on the ground.
float current_hooks;

// XXX BFG hack
.float last_bfg_zap;

// Track the amount of damage done by each player in DM_DAMAGE_MATCH
// mode.
.float damage_done;

// Hack used to simply add_frag() handling.
float damage_match_hack;

// This is a hack used to detect phantom players.  There are circumstances
// in which a player can be disconnected yet ClientDisconnect() never
// runs.  In this case the game doesn't think for the player, so I detect
// such a player by their not having thought for a while.
//
// XXX This should be extended a bit, perhaps a periodic check for such
// players (this can be fast because you only have to check the first
// maxplayers entities) and manual ClientDisconnect() for them.
.float last_thought;

// This is used by Qsmack to prevent kick races as players leave and join.
float qsmack_status_valid;

// If this is set it's used as the next map no matter what.  It's used
// by the admin map changing code.
string forced_nextmap;

// Weighted frag rate and the counter used to compute it
.float frag_rate;
.float recent_frags;
float update_frag_rates_time;

// If the map is custom, send message to players about downloading maps.
float MAP_IS_CUSTOM;

// Rune constants (NONE MAY BE OVER 100!)

float RN_STRENGTH	= 1;
float RN_REGEN		= 2;
float RN_RESIST		= 3;
float RN_HASTE		= 4;
float RN_ENVIRO		= 5;
float RN_FLY		= 6;
float RN_BERSERK	= 7;
float RN_RECALL		= 8;
float RN_ZAP		= 9;
float RN_CLOAK		= 10;
float RN_BOMB		= 11;
float RN_DSPOTS		= 12;
float RN_HOLO		= 13;
float RN_ORB		= 14;
float RN_BLINK		= 15;
float RN_CAMO		= 16;
float RN_JUMP		= 17;
float RN_AMMO		= 18;
float RN_VAMP		= 19;
float RN_SHIELD		= 20;
float RN_HEALTH		= 21;
float RN_RADIO		= 22;
float RN_SWITCH		= 23;
float RN_FREEZE		= 24;
float RN_SUCK		= 25;
float RN_TWALK		= 26;
float RN_IMPACT		= 27;
float RN_VENG		= 28;
float RN_SHUB		= 29;
float RN_REPEL		= 30;
float RN_PHASE		= 31;
float RN_SHAMB		= 32;
float RN_DUAL		= 33;
float RN_WEIRD		= 34;
float RN_PHOENIX	= 35;
float RN_CLOUD		= 36;
float RN_FIREWALK	= 37;
float RN_HOOK		= 38;
float RN_ATHLETE	= 39;
float RN_LUMBER		= 40;
float RN_ZOMBIE		= 41;
float RN_PIERCING	= 42;
float RN_SELFPRES	= 43;
float RN_MONK		= 44;
float RN_TORCH		= 45;
float RN_PACK_RAT	= 46;
float RN_ARMOR		= 47;
float RN_QUAD		= 48;
float RN_JACK		= 49;
float RN_GLUE		= 50;
float RN_BLIZZARD	= 51;
float RN_THOR		= 52;
float RN_SNIPER		= 53;
float RN_ANTIPACK	= 54;
float RN_DEFLECT	= 55;
float RN_BETTY		= 56;
float RN_TORNADO	= 57;
float RN_REQUIEM	= 58;
float RN_MAX		= 58;

// Only partially runes.

float RN_LITHIUM_HOOK	= 59;
float RN_MAX_ALL	= 59;

// impulses

//    1-8 weapon selection
//      9 idkfa cheat
//     10 next weapon
//     11 serverflags cheat
//     12 previous weapon
//     20 don't use (drop ammo in CTF)
//     21 don't use (drop weapon in CTF)
//     22 don't use (grapple in CTF)
//     23 don't use (flag info in CTF)
//     73 don't use (qsmack)

float IMP_VOTE_YES		= 255;
float IMP_VOTE_NO		= 254;
//				= 238 - 253	[weapon aliases]
//				= 220 - 237	[qsmack]
//				= 219 - 207	[free]
float IMP_IGNORE_MUTE_CLIENT	= 208;
float IMP_CHANGE_MAP2		= 207;
float IMP_VOTE_NEVER		= 206;
float IMP_STATS			= 205;
float IMP_KILLSTATS		= 204;
float IMP_HELP_OPTIONS		= 203;
float IMP_HELP_MATCH		= 202;
float IMP_OBSERVER		= 201;
//				= 200 - 101	[cheat impulses]
float IMP_RUNE_CHEAT_BASE	= 101;
float IMP_RUNE_USE		= 100;
float IMP_RUNE_TELL		= 99;
float IMP_RUNE_DELETE		= 98;
float IMP_SHOW_PLAYERS		= 97;
float IMP_SHOW_RIDERS		= 96;
float IMP_FIX_BATMAN		= 95;
float IMP_SHOW_SETTINGS		= 94;
float IMP_BIND_DEFAULT_KEYS	= 93;
float IMP_BEST_WEAPON		= 92;
float IMP_ADMIN_TOGGLE		= 91;
float IMP_RIDER_HIDE		= 90;
float IMP_EXIT_LEVEL		= 89;
float IMP_HOOK_ON		= 88;
float IMP_HOOK_OFF		= 87;
float IMP_WEAPON_MODE		= 86;
float IMP_ADMIN_COMMAND		= 85;
float IMP_SHOW_VOTES		= 84;
float IMP_EFFICIENCY		= 83;
float IMP_REMOVE_FRAGS		= 82;
float IMP_HUD_TOGGLE		= 81;
float IMP_TEAM_ROTATE		= 80;
float IMP_SHOW_POS		= 79;
float IMP_HELP_VOTE		= 78;
float IMP_QUIET_TOGGLE		= 77;
float IMP_HOOK_TOGGLE		= 76;
float IMP_HELP_LEVELS		= 75;
float IMP_WEAPON_TOGGLES	= 74;
// reserve 73 for QSMACK_IMPULSE_1
float IMP_COMMANDS		= 72;
float IMP_TEAM_STATS		= 71;
float IMP_CHANGE_MAP		= 70;
float IMP_CUSTOM		= 69;
float IMP_LEVELS		= 68;
float IMP_LAST			= 67;
float IMP_VOTE_COMMAND		= 66;
float IMP_LAG			= 65;
float IMP_CUSTOM_SOUNDS		= 64;
float IMP_TEAMSCORES_ON		= 63;
float IMP_TEAMSCORES_OFF	= 62;
float IMP_READY			= 61;
float IMP_NOTREADY		= 60;
float IMP_CYCLE_ALTERNATES	= 59;
float IMP_AUTOSTATS		= 58;
float IMP_SWITCHFIRE_BEST	= 57;
//				= 57 - 41	[sattack aliases]
float IMP_SWITCHFIRE_BASE	= 41;
float IMP_SWITCHFIRE_OFF	= 40;
float IMP_SWITCHFIRE_COUNT	= 16;

float IMP_WEAPON_BASE		= 238;
float IMP_WEAPON_START		= 1;
float IMP_WEAPON_COUNT		= 16;

float IMP_QSMACK_LOOKING	= 220;
float IMP_QSMACK_KICK_BASE	= 221;
float IMP_QSMACK_KICK_COUNT	= 16;
float IMP_QSMACK_COMMAND	= 237;

// extended impulses for levels
float IMP_LEVEL_MIN		= 300;
float IMP_LEVEL_MAX		= 655;

// admin impulse commands
float IMP_ADMIN_KICK		= 1;
float IMP_ADMIN_KILL		= 2;
float IMP_ADMIN_RUNE_DELETE	= 3;
float IMP_ADMIN_TEAM_CHANGE_TOGGLE = 4;
float IMP_ADMIN_TEAM_CHANGE	= 5;
float IMP_ADMIN_JOIN		= 6;
float IMP_ADMIN_UNBIND		= 7;
float IMP_ADMIN_RENAME		= 8;
float IMP_ADMIN_EYES		= 9;
float IMP_ADMIN_VOTE_TEAM_TOGGLE = 10;
float IMP_ADMIN_TEAMPLAY_ZERO	= 11;
float IMP_ADMIN_CYCLE		= 12;
float IMP_ADMIN_CYCLE_SHOW	= 13;
float IMP_ADMIN_CHANGE_MAP	= 14;
float IMP_ADMIN_DISP_INFO	= 15;
float IMP_ADMIN_DISP_INFO_ALL	= 16;
float IMP_ADMIN_BANLIST		= 17;
float IMP_ADMIN_BANIP		= 18;
float IMP_ADMIN_UNBANIP		= 19;
float IMP_ADMIN_MUTELIST	= 20;
float IMP_ADMIN_MUTEIP		= 21;
float IMP_ADMIN_UNMUTEIP	= 22;


// extended impulses for admin commands
float IMP_ADMIN_MIN		= 700;
float IMP_ADMIN_MAX		= 722;

// vote impulse commands
float IMP_VOTE_EXIT		= 1;
float IMP_VOTE_TEAM		= 2;
float IMP_VOTE_HOOK		= 3;
float IMP_VOTE_FREE		= 4;
float IMP_VOTE_LITHIUM		= 5;
float IMP_VOTE_PRACTICE		= 6;
float IMP_VOTE_NORMAL		= 7;
float IMP_VOTE_QUAD		= 8;
float IMP_VOTE_PENT		= 9;
float IMP_VOTE_RING		= 10;
float IMP_VOTE_SUIT		= 11;
float IMP_VOTE_ARMOR		= 12;
float IMP_VOTE_ROTATE		= 13;
float IMP_VOTE_RUNES		= 14;
float IMP_VOTE_ALTS		= 15;
float IMP_VOTE_SHIELDS		= 16;
float IMP_VOTE_HOOK_DAMAGE	= 17;
float IMP_VOTE_ARENA		= 18;
float IMP_VOTE_MEGA		= 19;
float IMP_VOTE_WEAPONS_STAY	= 20;
float IMP_VOTE_MATCH		= 21;
float IMP_VOTE_TIMESET		= 22;
float IMP_VOTE_ARMOR_DROP	= 23;
float IMP_VOTE_FASTSTART	= 24;
float IMP_VOTE_UNLOCK		= 25;
float IMP_VOTE_LOCK		= 26;
float IMP_VOTE_BACKPACKS	= 27;
float IMP_VOTE_MIDAIR		= 28;
float IMP_VOTE_POWERUP_DROP	= 29;
float IMP_VOTE_RUNE_DROP	= 30;
float IMP_VOTE_LG_DISCHARGE	= 31;
float IMP_VOTE_CLASSIC_MEGA	= 32;
float IMP_VOTE_HEADS		= 33;
float IMP_VOTE_RANDOM_SPAWN	= 34;
float IMP_VOTE_SHOOT_BUTTONS	= 35;
float IMP_VOTE_POWERUP_HATS	= 36;
float IMP_VOTE_DEFAULT		= 37;

// extended impulses for votes
float IMP_VOTE_MIN		= 800;
float IMP_VOTE_MAX		= 837;

// deathmatch flags
float DM_RESPAWN		= 1;
float DM_LONG_QUAD_RESPAWN	= 2;
float DM_QUAD_REPLACEMENT	= 4;
float DM_PENT_REPLACEMENT	= 8;
float DM_EXIT_NON_FATAL		= 16;
float DM_RANDOM_POWERUP_RESPAWN	= 32;
float DM_DAMAGE_MATCH		= 64;

// This mask includes the DM_* bits which indicates that the game is in
// an actual deathmatch mode.  Bits other than these make sense in
// single player or coop mode.
//
// 1 + 2 + 4 + 64
float DM_DM_MASK = 71;

// teamplay flags
float TEAM_HEALTH_PROT		= 1;
float TEAM_FRAG_PENALTY		= 2;
float TEAM_ARMOR_PROT		= 4;
float TEAM_ENFORCE_MASK		= 24;
float TEAM_2_TEAMS		= 8;
float TEAM_3_TEAMS		= 16;
float TEAM_4_TEAMS		= 24;
float TEAM_MODE_MATCH		= 32;
float TEAM_CHANGE_MASK		= 192;
float TEAM_CHANGE_NONE		= 0;
float TEAM_CHANGE_ANY		= 64;
float TEAM_CHANGE_TOPDOG	= 128;
float TEAM_NO_VOTE		= 256;
float TEAM_SELF_HEALTH_PROT	= 512;
float TEAM_SELF_ARMOR_PROT	= 1024;

// This masks teamplay bits which actually correspond to a team mode,
// like DM_DM_MASK.
//
// 1 + 2 + 4 + 24
float TEAM_TEAM_MASK = 31;

// noexit flags.  New flags should just control the logic used to select
// the next map, else update the logic in changelevel_touch().
float noexit;
float NOEXIT_NO_EXITING		= 1;
float NOEXIT_ALLOW_EXITING_START = 2;
float NOEXIT_RANDOMIZE		= 4;
float NOEXIT_CHOOSE_BY_NPLAYERS	= 8;
float NOEXIT_MARLINSPIKE_LEVELS	= 16;
float NOEXIT_DM_NO_LOOP		= 32;
float NOEXIT_FORWARD_MULT	= 64;
float NOEXIT_FORWARD_MASK	= 960;
float NOEXIT_NO_CUSTOM_LEVELS	= 1024;
float NOEXIT_CUSTOM_LEVELS_ONLY	= 2048;
float NOEXIT_VOTE_ALL_MAPS	= 4096;

// aqflags flags (saved across levels)
float AQ_INIT_DONE		= 1;
float AQ_TEAM_MASK		= 14;	// bits 2, 4, 8, but currently only 6 values
float AQ_TEAM_NIL		= 2;
float AQ_TEAM_1			= 4;
float AQ_TEAM_2			= 6;
float AQ_TEAM_3			= 8;
float AQ_TEAM_4			= 10;
float AQ_OBSERVER		= 16;
float AQ_NAME_WARN		= 32;
float AQ_KICKED			= 64;
float AQ_ADMIN			= 128;
float AQ_RIDER_HIDE		= 256;

// The AQ_ALT_* bits provide one of the interfaces to weapon selection.
// They're used to select which weapon the user gets when she uses one
// of the standard weapon selection impulses (1-8).
float AQ_ALT_1			= 512;
float AQ_ALT_2			= 1024;
float AQ_ALT_3			= 2048;
float AQ_ALT_4			= 4096;
float AQ_ALT_5			= 8192;
float AQ_ALT_6			= 16384;
float AQ_ALT_7			= 32768;
float AQ_ALT_8			= 65536;

float AQ_QUIET			= 131072;
float AQ_NO_WEAPON_TOGGLE	= 262144;
float AQ_NO_HUD			= 524288;
float AQ_HOOK			= 1048576;
float AQ_QSMACK			= 2097152;

// rqflags flags (saved across levels)
float RQ_CYCLE_ALTERNATES	= 1;
float RQ_LOW_BANDWIDTH_CLIENT	= 2;
float RQ_CUSTOM_SOUNDS		= 4;
float RQ_BINDINGS_RECEIVED	= 8;
float RQ_TEAMSCORES_ON		= 16;
float RQ_AUTOSTATS		= 32;
float RQ_MUTE			= 64;
float RQ_AUTO_VOTE_NO		= 128;
float RQ_IGNORE_MUTE_CLIENT	= 256;

// rqstate flags (not saved across levels)
float RQS_LAGGED_OUT		= 1;
float RQS_READY			= 2;
float RQS_AFK			= 4;
float RQS_RESTORE_GHOST		= 8;
float RQS_TIMESET_OVERRIDE	= 16;
float RQS_GUIDED_MISSILE	= 32;

// aqstate flags (not saved across levels)
float AQS_MENU_MASK		= 31;
float AQS_MENU_SPLASH		= 1;
float AQS_MENU_MAIN		= 2;
float AQS_MENU_CREDITS		= 3;
float AQS_MENU_ADMIN		= 4;
float AQS_MENU_EPISODE		= 5;
float AQS_MENU_EPISODE_1	= 6;
float AQS_MENU_EPISODE_2	= 7;
float AQS_MENU_EPISODE_3	= 8;
float AQS_MENU_EPISODE_4	= 9;
float AQS_MENU_EPISODE_5	= 10;
float AQS_MENU_FORWARD		= 11;
float AQS_MENU_HELP_FIRST	= 12;
float AQS_MENU_HELP_LAST	= 26;
float AQS_MENU_ADMIN_ACTION	= 27;
float AQS_MENU_ADMIN_TEAMPLAY	= 28;
float AQS_SWITCHFIRING		= 32;

// The weapon used before switchfiring is encoded in bits 64, 128, 256,
// and 512.  It's the weapon number (1-16) minus 1 (0-15).
float AQS_SWITCH_WEAPON_MASK	= 960;
float AQS_SWITCH_WEAPON_MULT	= 64;

// Bits 1024 and 2048 hold the number of failed attempts at admin mode.
float AQS_ADMIN_ATTEMPTS_MASK	= 3072;
float AQS_ADMIN_ATTEMPTS_MULT	= 1024;

// Bits 4096, 8192, and 16384 control impulse overrides.  If one of
// these is set the normal impulse commands aren't used, the impulses
// are used to gather input for a previous command.
float AQS_IMPOVER_MASK		= 28672;
float AQS_IMPOVER_PASSWORD	= 4096;
float AQS_IMPOVER_QSMACK_PASSWORD = 8192;
float AQS_IMPOVER_MAP		= 12288;
float AQS_IMPOVER_ADMIN_COMMANDS = 16384;
float AQS_IMPOVER_VOTE_COMMANDS	= 20480;
float AQS_IMPOVER_MAP2		= 24576;
//				= 28672;

float AQS_HOOK			= 32768;
float AQS_HAS_RIDERS		= 65536;

// It would be possible to combine these with non-observer state flags.
// NB:  The number of bits here is hardcoded in the parm13 calculations.
float AQS_RIDE_MASK		= 393216;
float AQS_RIDE_DIV		= 131072;
float AQS_RIDE_FAST		= 131072;
float AQS_RIDE_HIGH		= 262144;

float AQS_BURNING		= 1048576;
float AQS_SPAWN_PROTECT		= 2097152;
float AQS_SWITCH_WEAPON_WAS_BEST = 4194304;
float AQS_ADMIN_CHANGE_MAP_MENU	= 8388608;

// temp1 flags
float temp1;
float T1_NRUNES_MASK		= 63;
float T1_RUNE_CHEAT		= 64;
// float T1_NO_DROP_ON_DEATH	= 128;
float T1_CAN_GET_OWN_RUNE	= 256;
// drop delay			= 512;
float T1_RANDOM_RUNE_MODELS	= 1024;
float T1_FAST_RUNE_SPAWN	= 2048;
float T1_MAX_PLAYERS_MULT	= 4096;
float T1_MAX_PLAYERS_MASK	= 61440;
// drop delay			= 65536;
// drop delay			= 131072;
//float T1_HOOK_MASK		= 786432;
//float T1_FREE_HOOK		= 262144;
//float T1_LITHIUM_HOOK		= 524288;
//float T1_HOOK_NO_VOTE		= 1048576;
//float T1_HOOK_DEFAULT_ON	= 2097152;

// Three bits set the rune drop delay, they're 512, 65536 and 131072.
// They aren't contiguous, and the delay for 60 is out of order, for
// compatibility's sake.

.float last_drop_delay;
float rune_drop_delay;
float T1_RUNE_DROP_DELAY_MASK	= 197120;	// 7
float T1_RUNE_DROP_DELAY_0	= 65536;	// 2
float T1_RUNE_DROP_DELAY_15	= 66048;	// 3
float T1_RUNE_DROP_DELAY_30	= 131072;	// 4
float T1_RUNE_DROP_DELAY_60	= 512;		// 1
float T1_RUNE_DROP_DELAY_120	= 131584;	// 5
float T1_RUNE_DROP_DELAY_240	= 196608;	// 6
float T1_RUNE_DROP_DELAY_INF	= 197120;	// 7

// scratch1 bit settings
float scratch1;
float S1_EQUALIZE_LIGHTSTYLE	= 1;
float S1_AMBIENT_SOUND_OFF	= 2;
float S1_LIGHT_MAKESTATIC_OFF	= 4;
float S1_BPRINT_TO_CONSOLE	= 8;
float S1_ORIGINAL_LEVELS	= 16;
float S1_MAX_TRAPS_FOR_LEVEL	= 32;
float S1_BASIC_RUNES		= 64;
float S1_CUSTOM_EXITS		= 128;
float S1_NO_DEFAULT		= 256;
float S1_DEFAULT_USES_CONFIGS	= 512;
float S1_NORMAL_DEFAULT		= 1024;
float S1_PRACTICE_DEFAULT	= 2048;
float S1_ARENA_DEFAULT		= 4096;
float S1_MATCH_DEFAULT		= 8192;
float S1_MIDAIR_DEFAULT		= 16384;
float S1_HEADS_DEFAULT		= 32768;

// vote flags
float VOTE_YES			= 1;
float VOTE_NO			= 2;
float VOTE_LAST_YES		= 4;
float VOTE_LAST_NO		= 8;

// bit settings for POWERUP_PICKUP_WARN and Hat_Spawn()
float ITEM_PENT			= 1;
float ITEM_QUAD			= 2;
float ITEM_EYES			= 4;
float ITEM_SUIT			= 8;
float ITEM_POWERUP_ANY		= 15;

// miscellaneous constants which should have been defined
float SERVERFLAGS_RUNE_MASK	= 15;
vector PLAYER_WEAPON_OFFSET	= '0 0 16';
vector PLAYER_VIEW_OFFSET	= '0 0 22';
float CENTERPRINT_TIME		= 2;		// default scr_centertime
float CENTERPRINT_REFRESH	= 1.5;		// a little less

// attenuations used by T_RadiusDamage()
float RADIUS_NORMAL		= 0;
float RADIUS_150		= 1;
//float RADIUS_MORTAR		= 2;
float MIN_TEAM			= 1;
float MAX_TEAM			= 14;
float SURE_KILL_DAMAGE		= 50000;
float KILL_DAMAGE		= 25000;
float DEFAULT_GRAVITY		= 800;

// free player entity variable
// '.float speed'  bit-flag defines:
// float CHSCAM_ALT    = 4;
// float CHSCAM_ON     = 2;
// float LASERTARG_ON  = 1;

/////////////////////////
/* RUNE QUAKE VARS END */
/////////////////////////

//
// constants
//

float	FALSE				= 0;
float 	TRUE				= 1;

// edict.flags
float	FL_FLY				= 1;
float	FL_SWIM				= 2;
float	FL_CLIENT			= 8;	// set for all client edicts
float	FL_INWATER			= 16;	// for enter / leave water splash
float	FL_MONSTER			= 32;
float	FL_GODMODE			= 64;	// player cheat
float	FL_NOTARGET			= 128;	// player cheat
float	FL_ITEM				= 256;	// extra wide size for bonus items
float	FL_ONGROUND			= 512;	// standing on something
float	FL_PARTIALGROUND		= 1024;	// not all corners are valid
float	FL_WATERJUMP			= 2048;	// player jumping out of water
float	FL_JUMPRELEASED			= 4096;	// for jump debouncing

// requires manquake dedicated server
float	FL_LOW_BANDWIDTH_CLIENT		= 8192;	// don't draw ents with EF_MAYBE_DRAW
float	FL_OBSERVER			= 16384;// observers can chat using mm2
float	FL_IGNORE_MUTE_CLIENT		= 32768;// don't show chat from muted clients
float	FL_MUTE_CLIENT			= 65536;// muted client

// edict.movetype values
float	MOVETYPE_NONE			= 0;	// never moves
//float	MOVETYPE_ANGLENOCLIP		= 1;
//float	MOVETYPE_ANGLECLIP		= 2;
float	MOVETYPE_WALK			= 3;	// players only
float	MOVETYPE_STEP			= 4;	// discrete, not real time unless fall
float	MOVETYPE_FLY			= 5;
float	MOVETYPE_TOSS			= 6;	// gravity
float	MOVETYPE_PUSH			= 7;	// no clip to world, push and crush
float	MOVETYPE_NOCLIP			= 8;
float	MOVETYPE_FLYMISSILE		= 9;	// fly with extra size against monsters
float	MOVETYPE_BOUNCE			= 10;
float	MOVETYPE_BOUNCEMISSILE		= 11;	// bounce with extra size

// edict.solid values
float	SOLID_NOT			= 0;	// no interaction with other objects
float	SOLID_TRIGGER			= 1;	// touch on edge, but not blocking
float	SOLID_BBOX			= 2;	// touch on edge, block
float	SOLID_SLIDEBOX			= 3;	// touch on edge, but not an onground
float	SOLID_BSP			= 4;	// bsp clip, touch on edge, block

// range values
float	RANGE_MELEE			= 0;
float	RANGE_NEAR			= 1;
float	RANGE_MID			= 2;
float	RANGE_FAR			= 3;

// deadflag values
float	DEAD_NO				= 0;
float	DEAD_DYING			= 1;
float	DEAD_DEAD			= 2;
float	DEAD_RESPAWNABLE		= 3;

// takedamage values
float	DAMAGE_NO			= 0;
float	DAMAGE_YES			= 1;
float	DAMAGE_AIM			= 2;

// items
float	IT_AXE				= 4096;
float	IT_SHOTGUN			= 1;
float	IT_SUPER_SHOTGUN		= 2;
float	IT_NAILGUN			= 4;
float	IT_SUPER_NAILGUN		= 8;
float	IT_GRENADE_LAUNCHER		= 16;
float	IT_ROCKET_LAUNCHER		= 32;
float	IT_LIGHTNING			= 64;
// XXX used differently by me
//IN_QW([-
//float   IT_EXTRA_WEAPON                 = 128;
//-])

// In the standard source self.weapon is a simple IT_* constant.  In
// this mod it's an IT_* constant combined with one of these to indicate
// the mode the weapon is in.
//
// XXX You can't define these in terms of other constants.
float WEAPON_NONALT_MASK		= 4223;
float WEAPON_ALT			= 128;
float WEAPON_HOOK			= 4224;
float WEAPON_MAGIC_SHOTGUN		= 129;
float WEAPON_FLAMETHROWER		= 130;
float WEAPON_LAVA			= 132;
float WEAPON_BOMB			= 136;
float WEAPON_FLASH_GRENADE		= 144;
float WEAPON_GUIDED_MISSILE		= 160;
float WEAPON_BFG			= 192;

float	IT_SHELLS			= 256;
float	IT_NAILS			= 512;
float	IT_ROCKETS			= 1024;
float	IT_CELLS			= 2048;

float	IT_ARMOR1			= 8192;
float	IT_ARMOR2			= 16384;
float	IT_ARMOR3			= 32768;
float	IT_SUPERHEALTH			= 65536;

float	IT_KEY1				= 131072;
float	IT_KEY2				= 262144;

float	IT_INVISIBILITY			= 524288;
float	IT_INVULNERABILITY		= 1048576;
float	IT_SUIT				= 2097152;
float	IT_QUAD				= 4194304;

// point content values
float	CONTENT_EMPTY			= -1;
float	CONTENT_SOLID			= -2;
float	CONTENT_WATER			= -3;
float	CONTENT_SLIME			= -4;
float	CONTENT_LAVA			= -5;
float	CONTENT_SKY			= -6;

float	STATE_TOP			= 0;
float	STATE_BOTTOM			= 1;
float	STATE_UP			= 2;
float	STATE_DOWN			= 3;

vector	VEC_ORIGIN			= '0 0 0';
vector	VEC_HULL_MIN			= '-16 -16 -24';
vector	VEC_HULL_MAX			= '16 16 32';

vector	VEC_HULL2_MIN			= '-32 -32 -24';
vector	VEC_HULL2_MAX			= '32 32 64';

// protocol bytes

float	SVC_SETVIEWPORT			= 5;
float	SVC_STUFFTEXT			= 9;
float	SVC_SETVIEWANGLES		= 10;
float	SVC_UPDATENAME			= 13;
float	SVC_UPDATEFRAGS			= 14;
float	SVC_UPDATECOLORS		= 17;
float	SVC_TEMPENTITY			= 23;
float	SVC_KILLEDMONSTER		= 27;
float	SVC_FOUNDSECRET			= 28;
float	SVC_INTERMISSION		= 30;
float	SVC_FINALE			= 31;
float	SVC_CDTRACK			= 32;
float	SVC_SELLSCREEN			= 33;
IN_QW([-
float   SVC_SMALLKICK			= 34;
float   SVC_BIGKICK                     = 35;
float   SVC_MUZZLEFLASH			= 39;
-])

float	TE_SPIKE			= 0;
float	TE_SUPERSPIKE			= 1;
float	TE_GUNSHOT			= 2;
float	TE_EXPLOSION			= 3;
float	TE_TAREXPLOSION			= 4;
float	TE_LIGHTNING1			= 5;
float	TE_LIGHTNING2			= 6;
float	TE_WIZSPIKE			= 7;
float	TE_KNIGHTSPIKE			= 8;
float	TE_LIGHTNING3			= 9;
float	TE_LAVASPLASH			= 10;
float	TE_TELEPORT			= 11;
IN_QW([-
float   TE_BLOOD			= 12;
float   TE_LIGHTNINGBLOOD		= 13;
-])

// sound channels
// channel 0 never willingly overrides
// other channels (1-7) allways override a playing sound on that channel
float	CHAN_AUTO			= 0;
float	CHAN_WEAPON			= 1;
float	CHAN_VOICE			= 2;
float	CHAN_ITEM			= 3;
float	CHAN_BODY			= 4;
float	CHAN_JUMP			= 5;
float	CHAN_FLUID			= 6;
float   CHAN_NO_PHS_ADD			= IN_QW(8, 0);    // ie: CHAN_BODY+CHAN_NO_PHS_ADD

float	ATTN_NONE			= 0;
float	ATTN_NORM			= 1;
float	ATTN_IDLE			= 2;
float	ATTN_STATIC			= 3;

// update types
float	UPDATE_GENERAL			= 0;
float	UPDATE_STATIC			= 1;
float	UPDATE_BINARY			= 2;
float	UPDATE_TEMP			= 3;

// entity effects
float	EF_BRIGHTFIELD			= IN_POQ(1, 8);
IN_POQ([-
float	EF_MUZZLEFLASH 			= 2;
-])
float	EF_BRIGHTLIGHT 			= 4;
float	EF_DIMLIGHT 			= 8;
//	EF_NO_DRAW			= 16;		// joequake uses this
float	EF_FROZEN			= 32;		// EF_ZERO_VELOCITY (requires manquake dedicated server)
float	EF_WEIRD			= 64;
float	EF_MAYBE_DRAW			= 32768;	// requires manquake dedicated server

// messages
float	MSG_BROADCAST			= IN_POQ(0, 4);	// unreliable to all
float	MSG_ONE				= 1;		// reliable to one (msg_entity)
float	MSG_ALL				= 2;		// reliable to all
float	MSG_INIT			= 3;		// write to the init string

IN_QW([-
// message levels
float   PRINT_LOW			= 0;            // pickup messages
float   PRINT_MEDIUM			= 1;            // death messages
float   PRINT_HIGH			= 2;            // critical messages
float   PRINT_CHAT			= 3;            // also goes to chat console
-])

// multicast sets.  These are defined in POQ because multicast() is
// defined as a no-op there.
float   MSG_MULTICAST			= 4;            // for multicast() call
float   MULTICAST_ALL			= 0;            // every client
float   MULTICAST_PHS			= 1;            // within hearing
float   MULTICAST_PVS			= 2;            // within sight
float   MULTICAST_ALL_R			= 3;            // every client, reliable
float   MULTICAST_PHS_R			= 4;            // within hearing, reliable
float   MULTICAST_PVS_R			= 5;            // within sight, reliable

// proquake engine features
float	PQC_NOP				= 1;
float	PQC_NEW_TEAM			= 2;
float	PQC_ERASE_TEAM			= 3;
float	PQC_TEAM_FRAGS			= 4;
float	PQC_MATCH_TIME			= 5;
float	PQC_MATCH_RESET			= 6;
float	PQC_PING_TIMES			= 7;

//================================================

//
// globals
//

float	movedist;
float	gameover;		// set when a rule exits

string	string_null;		// null string, nothing should be held here
float	empty_float;

IN_POQ([-
entity	newmis;			// launch_spike sets this after spawning it
-])

entity	activator;		// the entity that activated a trigger or brush
entity	damage_attacker;	// set by T_Damage
entity	damage_inflictor;
float	framecount;

float	skill;

// custom cvars
string	CVAR_C1	= "saved1";	// levels
string	CVAR_C2	= "saved2";	// console commands
string	CVAR_C3	= "cl_crossx";	// game mode
string	CVAR_C4 = "cl_crossy";	// options
string	CVAR_C5 = "lcd_x";	// options2
string	CVAR_C6 = "lcd_yaw";	// storage

// console commands
float	C2_UPDATE_BINDINGS	= 1;
float	C2_SHOW_PLAYERS		= 2;
float	C2_SHOW_SETTINGS	= 3;
float	C2_TOGGLE_RUNE_CHEAT	= 4;
float	C2_LAST			= 5;
float	C2_LEVELS		= 6;
float	C2_CUSTOM		= 7;
float	C2_COMMANDS		= 8;
float	C2_LEVEL_TIME		= 9;
float	C2_MODE_PRACTICE	= 10;
float	C2_MODE_NORMAL		= 11;
float   C2_UPDATE_HUNKINIT	= 12;
float	C2_QUADON		= 13;
float	C2_QUADOFF		= 14;
float	C2_PENTON		= 15;
float	C2_PENTOFF		= 16;
float	C2_RINGON		= 17;
float	C2_RINGOFF		= 18;
float	C2_SUITON		= 19;
float	C2_SUITOFF		= 20;
float	C2_ARMORON		= 21;
float	C2_ARMOROFF		= 22;
float	C2_ROTATEON		= 23;
float	C2_ROTATEOFF		= 24;
float	C2_RUNESON		= 25;
float	C2_RUNESOFF		= 26;
float	C2_ALTSON		= 27;
float	C2_ALTSOFF		= 28;
float	C2_SHIELDSON		= 29;
float	C2_SHIELDSOFF		= 30;
float	C2_HOOKDAMAGEON		= 31;
float	C2_HOOKDAMAGEOFF	= 32;
float	C2_MODE_ARENA		= 33;
float	C2_CLIENT_PING_TIMES	= 34;
float	C2_MEGAON		= 35;
float	C2_MEGAOFF		= 36;
float	C2_BAN_ADD		= 37;
float	C2_BAN_REMOVE		= 38;
float	C2_BAN_LIST		= 39;
float	C2_CONPRINT		= 40;
float	C2_EFFICIENCY		= 41;
float	C2_MODE_MATCH		= 42;
float	C2_ARMORDROPON		= 43;
float	C2_ARMORDROPOFF		= 44;
float	C2_FASTSTARTON		= 45;
float	C2_FASTSTARTOFF		= 46;
float	C2_BACKPACKSON		= 47;
float	C2_BACKPACKSOFF		= 48;
float	C2_MODE_MIDAIR		= 49;
float	C2_MODE_LOCK		= 50;
float	C2_MODE_UNLOCK		= 51;
float	C2_POWERDROPON		= 52;
float	C2_POWERDROPOFF		= 53;
float	C2_HELP_OPTIONS		= 54;
float	C2_KILLSTATS		= 55;
float	C2_STATS		= 56;
float	C2_RUNEDROPON		= 57;
float	C2_RUNEDROPOFF		= 58;
float	C2_LGDISCHARGEON	= 59;
float	C2_LGDISCHARGEOFF	= 60;
float	C2_MUTE_ADD		= 61;
float	C2_MUTE_REMOVE		= 62;
float	C2_MUTE_LIST		= 63;
float	C2_CLASSICMEGAON	= 64;
float	C2_CLASSICMEGAOFF	= 65;
float	C2_CURRENT_MODE		= 66;
float	C2_WEAPONSSTAYON	= 67;
float	C2_WEAPONSSTAYOFF	= 68;
float	C2_MODE_HEADS		= 69;
float	C2_RANDOMSPAWNON	= 70;
float	C2_RANDOMSPAWNOFF	= 71;
float	C2_FREEHOOKON		= 72;
float	C2_LITHHOOKON		= 73;
float	C2_HOOKOFF		= 74;
float	C2_HELP_DEATHMATCH	= 75;
float	C2_HELP_TEAMPLAY	= 76;
float	C2_HELP_NOEXIT		= 77;
float	C2_HELP_TEMP1		= 78;
float	C2_HELP_SCRATCH1	= 79;
float	C2_SHOOTBUTTONSON	= 80;
float	C2_SHOOTBUTTONSOFF	= 81;
float	C2_MAXRUNES		= 82;
float	C2_SETAFK		= 83;
float	C2_POWERUPHATSON	= 84;
float	C2_POWERUPHATSOFF	= 85;
float	C2_VOTEHOOKON		= 86;
float	C2_VOTEHOOKOFF		= 87;
float	C2_SETDEFAULT		= 88;
float	C2_CREATE_ALTAR		= 89;
float	C2_REMOVE_ALTAR		= 90;

// game mode
float	gamemode;
float	MODE_NORMAL		= 0;
float	MODE_PRACTICE		= 1;
float	MODE_ARENA		= 2;
float	MODE_MATCH		= 4;
float	MODE_MIDAIR		= 10;
float	MODE_HEADS		= 16;

// options
float	options;
float	NO_QUAD			= 1;
float	NO_PENT			= 2;
float	NO_RING			= 4;
float	NO_SUIT			= 8;
float	NO_ARMOR		= 16;
float	ARMOR_ROTATE		= 32;
float	NO_RUNES		= 64;
float	NO_ALT_WEAPONS		= 128;
float	NO_SPAWN_SHIELDS	= 256;
float	NO_HOOK_DAMAGE		= 512;
float	NO_MEGA			= 1024;
float	FASTSTART		= 2048;
float	NO_BACKPACKS		= 4096;
float	CLASSIC_MEGA		= 8192;
float	MODE_LOCKED		= 16384;
float	WEAPONS_STAY		= 32768;
float	NO_DROP_POWERUP		= 65536;
float	NO_DROP_ON_DEATH	= 131072;
float	NO_DROP_ARMOR		= 262144;
float	NO_DISCHARGE		= 524288;
float	RANDOM_SPAWN		= 1048576;
float	SHOOT_BUTTONS		= 2097152;
float	NO_POWERUP_HATS		= 4194304;
//float	[FREE]			= 8388608;

// options2
float	options2;
float	FREE_HOOK		= 1;
float	LITHIUM_HOOK		= 2;
float	HOOK_MASK		= 3;
float	VOTE_HOOK_DISABLED	= 4;

// storage
float storage;
float	CONSOLE_ALIASES		= 1;
float	AFK_TIME;
float	SETAFK_MULTIPLIER	= 8;		// starting bit
float	SETAFK_MASK		= 248;		// 8, 16, 32, 64, 128 (5 bits)
float	DROP_DELAY_MUTLIPLIER	= 256;		// starting bit
float	DROP_DELAY_MASK		= 65280;	// 256, 512, 1024, 2048, 4096, 8192, 16384, 32768 (8 bits)

IN_QW([-
//
// cvars checked each frame
//

float	teamplay;
//float	timelimit;
//float	fraglimit;
float	deathmatch;
float	rj;
float	coop;
-])

float	intermission_running;
float	intermission_exittime;
float	fraglimit;
float	timelimit;

//================================================

//
// world fields (FIXME: make globals)
//

.string	wad;
.string	map;
.float	worldtype;	// 0=medieval 1=metal 2=base

//================================================

.string	killtarget;

//
// quakeed fields
//

.float	light_lev;	// not used by game, but parsed by light util
.float	style;

//
// monster ai
//

.void()	th_stand;
.void()	th_walk;
.void()	th_run;
.void()	th_missile;
.void()	th_melee;
.void(entity attacker, float damage)	th_pain;
.void()	th_die;

.entity	oldenemy;	// mad at this player before taking damage
.float	speed;
.float	lefty;		// keeps track of last +teamscores update (for players)
.float	search_time;
.float	attack_state;

float	AS_STRAIGHT		= 1;
float	AS_SLIDING		= 2;
float	AS_MELEE		= 3;
float	AS_MISSILE		= 4;

//
// player only fields
//

.float	walkframe;
.float	attack_finished;
.float	pain_finished;
.float	invincible_finished;
.float	invisible_finished;
.float	super_damage_finished;
.float	radsuit_finished;
.float	invincible_time;
.float	invincible_sound;
.float	invisible_time;
.float	invisible_sound;
.float	super_time;
.float	super_sound;
.float	rad_time;
.float	fly_sound;
.string	damage_type;	// useful for determining pain & death sounds.

// Set to time + 0.2 whenever a client fires a weapon or takes damage.
// Used to alert monsters that otherwise would let the player go.
.float	show_hostile;

.float	jump_flag;	// player jump flag
.float	swim_flag;	// player swimming sound flag
.float	air_finished;	// when time > air_finished, start drowning
.float	next_breath;	// controls how quickly your drown
.float	bubble_count;	// keeps track of the number of bubbles

//
// object stuff
//

.string	mdl;
.vector	mangle;		// angle at start
.float	t_length;
.float	t_width;

//
// doors, etc
//

.vector	dest;
.vector	dest1;
.vector	dest2;
.float	wait;		// time from firing to restarting
.float	delay;		// time from activation to firing
.entity	trigger_field;	// door's trigger entity
.string	noise4;

//
// monsters
//

.float	pausetime;
.entity	movetarget;

//
// doors
//

// For dead players, the time left to idle as a corpse.
// For ammo items, the amount of ammo for that item.
.float	aflag;
.float	dmg;		// damage done by door when hit

//
// misc
//

.float	cnt;		// misc flag, next hud print time

//
// subs
//

.void()	think1;
.vector	finaldest;
.vector	finalangle;

//
// triggers
//

// For players, time at which to redisplay the menu.
.float	count;		// for counting triggers

//
// plats / doors / buttons
//

// For players, time at which to check nick.
// For burn thinkers, time at which to do burn damage.
// For zombie campers, amount of damage taken since getting up.
// For runes, time dropped by a pack rat.
.float	lip;

// For players, currently entered part of password.  If in a qsmack init
// sequence, the sequence number of the last code received, plus 8 if
// the password was wrong.
.float	state;

// pos1 is used to store angles for dual teleport and recall runes
// pos1 is used for misc. settings for flaming missiles
.vector	pos1;
.vector	pos2;		// top and bottom positions

// For players, time last ran fix-angles.
// For zombie campers, whether a quick pain sequence was done since getting up.
.float	height;

//
// sounds
//

// For players waitmin and waitmax are used for displaying the rune
// type.  See the comments in rjs.qc above the rune_tell_*() functions.
.float	waitmin;
.float	waitmax;

//===========================================================================

//
// builtin functions
//

void	(vector ang)				makevectors	= #1;	// sets v_forward, etc globals
void	(entity e, vector o)			setorigin	= #2;
void	(entity e, string m)			setmodel	= #3;	// set movetype and solid first
void	(entity e, vector min, vector max)	setsize		= #4;
string	(string format)				strftime	= #5;	// requires manquake dedicated server
//void	()					break		= #6;	[disabled]
float	()					random		= #7;	// returns 0 - 1
void	(entity e, float chan, string samp,
		float vol, float atten)		xsound		= #8;
vector	(vector v)				normalize	= #9;
void	(string e)				error		= #10;
void	(string e)				objerror	= #11;
float	(vector v)				vlen		= #12;
float	(vector v)				vectoyaw	= #13;
entity	()					spawn		= #14;
void	(entity e)				remove		= #15;
void	(vector v1, vector v2, float nomonsters,
		entity forent)			traceline	= #16;	// sets trace_* globals
entity	()					checkclient	= #17;	// returns a client to look for
entity	(entity start, .string fld,
		string match)			find		= #18;
string	(string s)				precache_sound	= #19;
string	(string s)				precache_model	= #20;
void	(entity client, string s)		self_stuffcmd	= #21;
entity	(vector org, float rad)			findradius	= #22;

IN_POQ([-
void (string s, ...)				xbprint		= #23;
void (string s, ...)				bprint2		= #23;
void (string s, ...)				bprint3		= #23;
void (string s, ...)				bprint4		= #23;
void (string s, ...)				bprint5		= #23;
void (string s, ...)				bprint6		= #23;
void (string s, ...)				bprint7		= #23;
void (entity client, string s)			xself_sprint	= #24;
void (entity client, string s, ...)		self_sprint2	= #24;
void (entity client, string s, ...)		self_sprint3	= #24;
void (entity client, string s, ...)		self_sprint4	= #24;
void (entity client, string s, ...)		self_sprint5	= #24;
void (entity client, string s, ...)		self_sprint6	= #24;
void (entity client, string s, ...)		self_sprint7	= #24;
-],[-
void (float level, string s, ...)		xbprint		= #23;
void (entity client, float level, string s, ...)xself_sprint	= #24;
-])

void	(string s, ...)				dprint		= #25;
string	(float f)				ftos		= #26;
string	(vector v)				vtos		= #27;
void	()					coredump	= #28;	// prints all edicts
void	()					traceon		= #29;	// turns statment trace on
void	()					traceoff	= #30;
void	(entity e)				eprint		= #31;	// prints an entire edict
float	(float yaw, float dist)			walkmove	= #32;	// returns TRUE or FALSE
//								= #33;	[removed]
float	()					droptofloor	= #34;	// TRUE if landed on floor
void	(float style, string value)		lightstyle	= #35;
float	(float v)				rint		= #36;	// round to nearest int
float	(float v)				floor		= #37;	// largest integer <= v
float	(float v)				ceil		= #38;	// smallest integer >= v
//								= #39;	[removed]
float	(entity e)				checkbottom	= #40;	// true if self is on ground
float	(vector v)				pointcontents	= #41;	// returns a CONTENT_*
//								= #42;	[removed]
float	(float f)				fabs		= #43;
vector	(entity e, float speed)			aim		= #44;	// returns the shooting vector
float	(string s)				cvar		= #45;	// return cvar.value
string	(string s, ...)				cvar_string	= #45;	// requires manquake dedicated server
void	(string s)				localcmd	= #46;	// put string into local que
entity	(entity e)				nextent		= #47;	// for looping through all ents

IN_POQ([-
void	(vector o, vector d, float color,
		float count)			particle	= #48;	// start a particle effect
-])

void	()					ChangeYaw	= #49;	// turn towards self.ideal_yaw at self.yaw_speed
//								= #50;	[removed]
vector	(vector v)				vectoangles	= #51;

//
// direct client message generation
//
void	(float to, float f)			WriteByte	= #52;
void	(float to, float f)			WriteChar	= #53;
void	(float to, float f)			WriteShort	= #54;
void	(float to, float f)			WriteLong	= #55;
void	(float to, float f)			WriteCoord	= #56;
void	(float to, float f)			WriteAngle	= #57;
void	(float to, string s)			WriteString	= #58;
void	(float to, entity s)			WriteEntity	= #59;

//
// broadcast client message generation
//
// void	(float f)				bWriteByte	= #59;
// void	(float f)				bWriteChar	= #60;
// void	(float f)				bWriteShort	= #61;
// void	(float f)				bWriteLong	= #62;
// void	(float f)				bWriteCoord	= #63;
// void	(float f)				bWriteAngle	= #64;
// void	(string s)				bWriteString	= #65;
// void	(entity e)				bWriteEntity	= #66;

// requires manquake dedicated server
float	(float f)				sin		= #60;
float	(float f)				cos		= #61;
float	(float f)				sqrt		= #62;

void	(float step)				movetogoal	= #67;
//string (string s)				precache_file	= #68;	[disabled]
void	(entity e)				makestatic	= #69;
void	(string s)				xchangelevel	= #70;
//								= #71;	[removed]
void	(string var, string val, ...)		cvar_set	= #72;	// sets cvar.value (use 2 to mute variable)
void	(entity client, string s, ...)		self_centerprint= #73;	// sprint, but in middle
void	(vector pos, string samp, float vol,
		float atten)			ambientsound	= #74;
//string(string s)				precache_model2	= #75;	[disabled]
//string(string s)				precache_sound2	= #76;	[disabled]
//string(string s)				precache_file2	= #77;	[disabled]
void	(entity e)				setspawnparms	= #78; // set parm1... to the values at level start for coop respawn
float	(string s, ...)				xstof		= #81; // requires manquake dedicated server

IN_QW([-
void	(entity killer, entity killee)		logfrag		= #79; // add to stats
string	(entity e, string key)			infokey		= #80; // get a key value (world = serverinfo)
float	(string s)				stof		= #81; // convert string to float
void	(vector where, float set)		multicast	= #82; // sends the temp message to a set
-])

//============================================================================

// client.qc
.float	dmgtime;

//============================================================================

// arena mode
entity	arena;

// match mode
.float	team_colors;
entity	match;
float	MATCHLOCK;
float	MATCH_LOCKED;
float	VOTE_TIMESET;
string	timeset = "5\{0}":"10":"15":"20":"25":"30";
string	timeset_gold = "\5\{0}":"\1\0":"\1\5":"\2\0":"\2\5":"\3\0";

// head hunters mode
.float	num_heads;
.entity	head_chain;

// eff, kill, killstats
.float	shell_dmg_max;
.float	shell_dmg;
.float	nail_dmg_max;
.float	nail_dmg;
.float	rocket_dmg_max;
.float	rocket_dmg;
.float	cell_dmg_max;
.float	cell_dmg;
.float	suicide;
.float	enemy_kills;
.float	mate_kills;
.float	killed;

// net functions
.entity cl;
.entity	netconnection;
.vector	subnet;
.float	packed;
.string address;

// proquake client
float	UPDATE_CLIENT_PINGS;

// manquake dedicated server
.entity viewentity;
float	MOD_PROTOCOL;

// vote
.float	last_vote;
float	LAST_VOTE_IMPULSE;
string	LAST_VOTE_LEVEL;
float	maybe_bprint_option_hack;

//misc
.float	grenade_spam_time;
.float	afk;
entity	last_teleport;

// development
float	gamemode_set;
float	console_warp;
