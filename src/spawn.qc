/*  $Id: spawn.qc,v 1.4 2003/11/30 23:29:04 slotzero Exp $

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

void ()
place_my_targets =
{
	if (mapname == "start")
	{
		if	(self.map == "end")
			self.target = "T5";
		else if (self.map == "e1m1")
			self.target = "T4";
		else if (self.map == "e2m1")
			self.target = "T3";
		else if (self.map == "e3m1")
			self.target = "T2";
		else if (self.map == "e4m1")
			self.target = "T1";
	}
	else if (mapname == "e1m1")
	{
		if (self.map == "e1m2")
			self.target = "T1";
	}
	else if (mapname == "e1m7")
	{
		if (self.map == "start")
			self.target = "T1";
	}
	else if (mapname == "e2m6")
	{
		if (self.map == "start")
		{
			self.target = "t74";
			setmodel (self, string_null);
			setorigin (self, '-609 496 -984');
		}
	}
};

void (string ec, float ea, vector eo, float es)
spawn_item =
{
	local entity e, o;

	e		= spawn ();
	e.classname	= ec;
	e.origin	= eo;
	e.angles_y	= ea;
	e.spawnflags	= es;

	o = self;
	self = e;
	     if (e.classname == "item_armor1")		item_armor1 ();
	else if (e.classname == "item_armor2")		item_armor2 ();
	else if (e.classname == "item_armorInv")	item_armorInv ();
	else if (e.classname == "item_cells")		item_cells ();
	else if (e.classname == "item_health")		item_health ();
	else if (e.classname == "item_rockets")		item_rockets ();
	else if (e.classname == "item_shells")		item_shells ();
	else if (e.classname == "item_spikes")		item_spikes ();
	else if (e.classname == "weapon_grenadelauncher") weapon_grenadelauncher ();
	else if (e.classname == "weapon_lightning")	weapon_lightning ();
	else if (e.classname == "weapon_nailgun")	weapon_nailgun ();
	else if (e.classname == "weapon_rocketlauncher")weapon_rocketlauncher ();
	else if (e.classname == "weapon_supernailgun")	weapon_supernailgun ();
	else if (e.classname == "weapon_supershotgun")	weapon_supershotgun ();
	self = o;
};

void ()
place_my_items =
{
	if (scratch1 & S1_ORIGINAL_LEVELS)
		return;

	if (mapname == "e1m1")
	{
		// Same room as environmetal protection suit.
		spawn_item ("item_armorInv", 0, '1232 2048 -216', 0);
		// Top of crate next to level exit.
		spawn_item ("weapon_rocketlauncher", 0, '1445 608 -192', 0);
	}
	else if (mapname == "e1m2")
	{
		// Replace the RL.
		spawn_item ("item_armorInv", 0, '680.0 728.0 184.0', 0);
		// Place new RL.
		spawn_item ("weapon_rocketlauncher", 0, '-96.0 605.0 320.0', 0);
		// Place new RL.
		spawn_item ("weapon_rocketlauncher", 0, '1104.0 640.0 312.0', 0);
	}
	else if (mapname == "e1m6")
	{
		// Under the stairs.
		spawn_item ("weapon_grenadelauncher", 0, '-510 355 -155', 0);
	}
	else if (mapname == "e1m7")
	{
		// Between GL and quad.
		spawn_item ("item_armor2", 0, '-260 64 56', 0);
		// In front of the level's exit.
		spawn_item ("item_health", 0, '848 46 -1064', 0);
	}
	else if (mapname == "e2m1")
	{
		// Same room as the RA that's near quad.
		spawn_item ("weapon_grenadelauncher", 0, '1178.5 1965 24', 0);
	}
	else if (mapname == "e2m4")
	{
		// Armor added near the start of level.
		spawn_item ("item_armor1", 0, '832.0 465.0 32.0', 0);
		// Added LG in water near SNG.
		spawn_item ("weapon_grenadelauncher", 0, '1015.0 941.5 -168', 0);
	}
	else if (mapname == "e2m6")
	{
		// Middle level near shells to the left of the pentagram door.
		spawn_item ("item_armorInv", 0, '870 1280 -968', 0);
		// Bottom level of all lifts.
		spawn_item ("weapon_grenadelauncher", 0, '1250 1140 -744', 0);
	}
	else if (mapname == "e3m2")
	{
		// On long pole above double shotgun.
		spawn_item ("weapon_rocketlauncher", 0, '1072 -80 20', 0);
		// Under the elevator lift.
		spawn_item ("item_armorInv", 0, '481 -801 -232', 0);
		// Replaces the only nailgun.
		spawn_item ("weapon_supernailgun", 0, '-384 384 8', 0);
	}
	else if (mapname == "dm1")
	{
		// Replaces yellow armor.
		spawn_item ("item_armorInv", 0, '-380 1415 24', 0);
		// Room where entrance requires trigger activation.
		spawn_item ("weapon_rocketlauncher", 0, '423 1532 -120', 0);
	}
};

void (vector e_origin, float e_mangle, string e_targetname)
spawn_info_teleport_destination =
{
	local entity e;

	e		= spawn ();
	e.classname	= "info_teleport_destination";
	e.mangle_y	= e_mangle;
	e.targetname	= e_targetname;

	setorigin (e, e_origin);
};

void (vector e_origin, float e_angle)
spawn_info_player_deathmatch =
{
	local entity e;

	e		= spawn ();
	e.classname	= "info_player_deathmatch";
	e.origin	= e_origin;
	e.angles_y	= e_angle;
};

void ()
place_my_spots =
{
	if (mapname == "start")
	{
		// Across from super nailgun.
		spawn_info_player_deathmatch ('1210 1728 -360', 0);
		// Next to rockets at level exit.
		spawn_info_player_deathmatch ('-268 1755 -360', 90);

		// E1M1 map teleporter.
		spawn_info_teleport_destination ('-65 1689 136', 7, "T1");
		// E1M2 map teleporter.
		spawn_info_teleport_destination ('-494.0 2369.7 168', 0, "T2");
		// E1M3 map teleporter.
		spawn_info_teleport_destination ('1537.5 2992.7 264.0', -90, "T3");
		// E1M4 map teleporter.
		spawn_info_teleport_destination ('1955 1726.5 -216', 180, "T4");
		// Start of map.
		spawn_info_teleport_destination ('545.1 679.5 353.0', -90, "T5");
	}
	else if (mapname == "e1m1")
	{
		// Near bridge by SSG.
		spawn_info_player_deathmatch ('647 1675 -200', -159);
		// Teleporter to pent.
		spawn_info_player_deathmatch ('1216 841 -408', 90);

		spawn_info_teleport_destination ('480.4 -351.4 88', 90, "T1");
	}
	else if (mapname == "e1m2")
	{
		// Near level exit.
		spawn_info_player_deathmatch ('-300 -285.5 480', -126);
	}
	else if (mapname == "e1m3")
	{
		// Ledge above secret normally occupied by an ogre in single player.
		spawn_info_player_deathmatch ('360 -1281 -40', 80);
	}
	else if (mapname == "e1m7")
	{
		// Start of map.
		spawn_info_teleport_destination ('-450 64 366', 0, "T1");
	}
	else if (mapname == "e2m1")
	{
		spawn_info_player_deathmatch ('546 -803 72', 85);
		// Red armor/super shotgun teleport.
		spawn_info_player_deathmatch ('1971 1656.5 -56', 175);
	}
	else if (mapname == "e2m3")
	{
		// Weird textured button by super nailgun.
		spawn_info_player_deathmatch ('-1267 1120 -56', 90);
	}
	else if (mapname == "e2m5")
	{
		// End of level.
		spawn_info_player_deathmatch ('-1247.5 2733.5 -96', 50);
	}
	else if (mapname == "e3m6")
	{
		// Platform next to shells from RA.
		spawn_info_player_deathmatch ('-1999 -472.5 88', 0);
	}
};

void ()
remove_my_items =
{
	if (world.model == "maps/e1m2.bsp")
	{
		// Remove rocket launcher.
		remove_classname_origin ("weapon_rocketlauncher", '680.0 728.0 184.0');
	}
	else if (world.model == "maps/e3m2.bsp")
	{
		// Remove nail gun.
		remove_classname_origin ("weapon_nailgun", '-384 384 8');
	}
	else if (world.model == "maps/dm1.bsp")
	{
		// Remove yellow armor.
		remove_classname_origin ("item_armor2", '-392.0 1416.0 0.0');
	}
};

float ()
remove_func_wall =
{
	if (!scratch1 & S1_CUSTOM_EXITS)
		return FALSE;

	if (self.classname != "func_wall")
		return FALSE;

	if (mapname == "start")
	{
		if (self.model == "*30" || self.model == "*31" || self.model == "*32" || self.model == "*33")
			return TRUE;
	}
	else if (mapname == "e1m1")
	{
		if (self.model == "*57")
			return TRUE;
	}
	else if (mapname == "e2m6")
	{
		if (self.model == "*84")
			return TRUE;
	}

	return FALSE;
};

void ()
fix_map =
{
	if (!scratch1 & S1_ORIGINAL_LEVELS)
	{
		place_my_spots ();
		remove_my_items ();
	}

	remove (self);
};

void ()
fix_map_spawn =
{
	local entity e;

	e		= spawn ();
	e.think		= fix_map;
	e.nextthink	= time + 0.3;	// after items start
};
