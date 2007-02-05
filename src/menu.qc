/*  $Id: menu.qc,v 1.14 2007/02/05 03:21:59 slotzero Exp $

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

float (entity e)
aq_menu_get_e =
{
	return e.aqstate & AQS_MENU_MASK;
};

float ()
aq_menu_get =
{
	return aq_menu_get_e (self);
};

void (float m)
aq_menu_set =
{
	self.aqstate = self.aqstate - self.aqstate & AQS_MENU_MASK + m;
	aq_menu_print ();
};

void (float i)
aq_menu_next =
{
	local float m;

	m = aq_menu_get ();
	m = m + i;
	if (m > AQS_MENU_HELP_LAST)
		m = AQS_MENU_HELP_FIRST;
	else if (m < AQS_MENU_HELP_FIRST)
		m = AQS_MENU_HELP_LAST;
	aq_menu_set (m);
};

void ()
aq_menu_print =
{
	local float m;

	m = aq_menu_get ();
	if (m == 0)
	{
		centerprint (self, string_null);
		return;
	}
	aq_menu_print_n (m);
	self.count = time + CENTERPRINT_REFRESH;
};

void (string s1, string s2, string s3)
aq_menu_print_help =
{
	centerprint4 (self, s1, s2, s3,
		"\n\n\n\n\<\3 \bPrev\b\-\-\-\-\-\-\1 \bMain\b\-\-\-\-\-\-\-\-\2 \bNext\b\>\n");
};

void (float m)
aq_menu_print_n =
{
	local float i;

	i = AQS_MENU_HELP_FIRST - 1;

	if (m == AQS_MENU_SPLASH)
	{
		centerprint7 (self,
			"Type \1 for the menu,\n"
			"\2 to start playing\n\n"
			"\bRune Quake\b\n"
			"Version ", version, "\n\n",
			SPLASH_1, SPLASH_2, SPLASH_3, SPLASH_4);
	}

	else if (m == AQS_MENU_MAIN)
	{
		centerprint (self,
			"\n\n\bMain Menu\b\n\n"
			"\1\b.\b View instructions \n"
			"\2\b.\b Join the game     \n"
			"\3\b.\b View credits      \n"
			"\4\b.\b Observe (menu off)\n"
			"\5\b.\b Ride next player  \n"
			"\6\b.\b Admin menu        \n"
			"\7\b.\b Weapon toggles    \n"
			);
	}

	else if (m == AQS_MENU_CREDITS)
	{
		centerprint (self,
			//----------------------------------*------
			"Rune Quake was created by David   \n"
			"'Slot Zero' Roberts.              \n"
			"                                  \n\n"
			"To report bugs, please e-mail     \n"
			"slotzero@runequake.com            \n"
			"                                  \n\n"
			"For more info visit,              \n\n"
			"     \bwww.runequake.com\b        \n\n"
			"Type 1 to return to the menu.     \n"
			);
	}

	else if (m == AQS_MENU_ADMIN)
	{
		centerprint (self,
			"\n\n\bAdmin Menu\b\n\n"
			"\1\b.\b Back to Main Menu   \n"
			"\2\b.\b Action Menu         \n"
			"\3\b.\b Teamplay Menu       \n"
			"\4\b.\b Change Level Menu   \n"
			"\5\b.\b Toggle model eyes   \n"
			);
	}

	else if (m == AQS_MENU_ADMIN_ACTION)
	{
		centerprint (self,
			"\n\n\bAction Menu\b\n\n"
			"\1\b.\b Back to Admin Menu  \n"
			"\2\b.\b Kill player         \n"
			"\3\b.\b Kick player         \n"
			"\4\b.\b Strip player's rune \n"
			"\5\b.\b Unbind player's keys\n"
			"\6\b.\b Rename player       \n"
			"\7\b.\b Put player in game  \n"
			);
	}

	else if (m == AQS_MENU_ADMIN_TEAMPLAY)
	{
		centerprint (self,
			"\n\n\bTeamplay Menu\b\n\n"
			"\1\b.\b Back to Admin Menu  \n"
			"\2\b.\b Toggle vote-team    \n"
			"\3\b.\b Toggle team changing\n"
			"\4\b.\b Reset teamplay      \n"
			"\5\b.\b Change player's team\n"
			);
	}

	else if (m == AQS_MENU_EPISODE)
	{
		centerprint (self,
			"Choose an episode, use\n"
			"any other impulse to cancel.\n\n"
			"\1\b.\b Dimension of the Doomed \n"
			"\2\b.\b The Realm of Black Magic\n"
			"\3\b.\b The Netherworld         \n"
			"\4\b.\b The Elder World         \n"
			"\5\b.\b The Deathmatch Arenas   \n"
			"\6\b.\b Let the game pick       \n"
			);
	}

	else if (m == AQS_MENU_EPISODE_1)
	{
		centerprint (self,
			"Dimension of the Doomed\n\n"
			"\1\b.\b e1m1: Slipgate Complex    \n"
			"\2\b.\b e1m2: Castle of the Damned\n"
			"\3\b.\b e1m3: The Necropolis      \n"
			"\4\b.\b e1m4: The Grisly Grotto   \n"
			"\5\b.\b e1m5: Gloom Keep          \n"
			"\6\b.\b e1m6: The Door To Chthon  \n"
			"\7\b.\b e1m7: The House of Chthon \n"
			"\8\b.\b e1m8: Ziggurat Vertigo    \n"
			);
	}

	else if (m == AQS_MENU_EPISODE_2)
	{
		centerprint (self,
			"The Realm of Black Magic\n\n"
			"\1\b.\b e2m1: The Installation    \n"
			"\2\b.\b e2m2: Ogre Citadel        \n"
			"\3\b.\b e2m3: Crypt of Decay      \n"
			"\4\b.\b e2m4: The Ebon Fortress   \n"
			"\5\b.\b e2m5: The Wizard's Manse  \n"
			"\6\b.\b e2m6: The Dismal Oubliette\n"
			"\7\b.\b e2m7: Underearth          \n"
			);
	}

	else if (m == AQS_MENU_EPISODE_3)
	{
		centerprint (self,
			"The Netherworld\n\n"
			"\1\b.\b e3m1: Termination Central \n"
			"\2\b.\b e3m2: The Vaults of Zin   \n"
			"\3\b.\b e3m3: The Tomb of Terror  \n"
			"\4\b.\b e3m4: Satan's Dark Delight\n"
			"\5\b.\b e3m5: Wind Tunnels        \n"
			"\6\b.\b e3m6: Chambers of Torment \n"
			"\7\b.\b e3m7: The Haunted Halls   \n"
			);
	}

	else if (m == AQS_MENU_EPISODE_4)
	{
		centerprint (self,
			"The Elder World\n\n"
			"\1\b.\b e4m1: The Sewage System   \n"
			"\2\b.\b e4m2: The Tower of Despair\n"
			"\3\b.\b e4m3: The Elder God Shrine\n"
			"\4\b.\b e4m4: The Palace of Hate  \n"
			"\5\b.\b e4m5: Hell's Atrium       \n"
			"\6\b.\b e4m6: The Pain Maze       \n"
			"\7\b.\b e4m7: Azure Agony         \n"
			"\8\b.\b e4m8: The Nameless City   \n"
			);
	}

	else if (m == AQS_MENU_EPISODE_5)
	{
		centerprint (self,
			"The Deathmatch Arenas\n\n"
			"\1\b.\b   dm1: Place of Two Deaths \n"
			"\2\b.\b   dm2: Claustrophobopolis  \n"
			"\3\b.\b   dm3: The Abandoned Base  \n"
			"\4\b.\b   dm4: The Bad Place       \n"
			"\5\b.\b   dm5: The Cistern         \n"
			"\6\b.\b   dm6: The Dark Zone       \n"
			"\7\b.\b start: Introduction        \n"
			"\8\b.\b   end: Shub-Niggurath's Pit\n"
			);
	}

	else if (m == AQS_MENU_FORWARD)
	{
		centerprint3 (self,
			//----------------------------------*------
			"The game is full, forwarding to\n",
			FORWARD_NAME, "...\n");
	}

	else { i = i + 1; if (m == i)
	{
		aq_menu_print_help (
			//----------------------------------*------
			"Welcome to Rune Quake!  These     \n"
			"instructions are highly           \n"
			"abbreviated.  For the complete    \n"
			"documentation visit,              \n\n"
			"       \bwww.runequake.com\b      \n"
			"                                  \n",
			string_null, string_null);
	}

	else { i = i + 1; if (m == i)
	{
		aq_menu_print_help (
			//----------------------------------*------
			"You start the game as an observer.\n"
			"Press 2 to to play, 4 to remain   \n"
			"an observer, or choose one of the \n"
			"other options from the menu.  You \n"
			"can return to being an observer   \n"
			"after playing by pressing 4 when  \n"
			"you're dead.                      \n",
			string_null, string_null);
	}

	else { i = i + 1; if (m == i)
	{
		aq_menu_print_help (
			//----------------------------------*------
			"If the game is full you'll have   \n"
			"to wait for somebody to leave     \n"
			"or to become an observer before   \n"
			"you can play.  In this case you'll\n"
			"be put into the game queue.  Press\n"
			"2 again to see how close you are  \n"
			"to the head of the line.          \n",
			string_null, string_null);
	}

	else { i = i + 1; if (m == i)
	{
		aq_menu_print_help (
			//----------------------------------*------
			"There are a few dozen different   \n"
			"types of runes on the server.  See\n"
			"the web page or just experiment to\n"
			"find out what they do.            \n\n\n\n",
			string_null, string_null);
	}

	else { i = i + 1; if (m == i)
	{
		aq_menu_print_help (
			//----------------------------------*------
			"You'll need to bind at least two  \n"
			"keys in order to use the runes    \n"
			"effectively.  It's useful to bind \n"
			"a few other keys as well, but you \n"
			"can get by with just two.         \n\n\n",
			string_null, string_null);
	}

	else { i = i + 1; if (m == i)
	{
		aq_menu_print_help (
			//----------------------------------*------
			"On the main menu there's a command\n"
			"which will bind the most useful   \n"
			"commands to standard keys.  The   \n"
			"keys which are used are listed    \n"
			"along with the descriptions of the\n"
			"commands on the following pages.  \n\n",
			string_null, string_null);
	}

	else { i = i + 1; if (m == i)
	{
		aq_menu_print_help (
			//----------------------------------*------
			"command \brune-use\b, key \bX\b           \n\n"
			"This command is needed to activate\n"
			"some of the runes, such as death  \n"
			"spots and radiation.  Most runes  \n"
			"don't require activation.         \n\n",
			string_null, string_null);
	}

	else { i = i + 1; if (m == i)
	{
		aq_menu_print_help (
			//----------------------------------*------
			"command \brune-delete\b, key \bQ\b        \n\n"
			"This command deletes your current \n"
			"rune.  Since you can only have one\n"
			"rune at a time, you have to do    \n"
			"this to get a different rune.     \n\n",
			string_null, string_null);
	}

	else { i = i + 1; if (m == i)
	{
		aq_menu_print_help (
			//----------------------------------*------
			"command \brune-tell\b, key \bC\b          \n\n"
			"This command tells you what rune  \n"
			"you currently have.               \n\n\n\n",
			string_null, string_null);
	}

	else { i = i + 1; if (m == i)
	{
		aq_menu_print_help (
			//----------------------------------*------
			"command \bweapon-mode\b, key \b9\b        \n\n"
			"This command toggles some guns    \n"
			"between normal and alternate      \n"
			"modes.  If the blue key is lit the\n"
			"gun is in alternate mode.         \n\n",
			string_null, string_null);
	}

	else { i = i + 1; if (m == i)
	{
		aq_menu_print_help (
			//----------------------------------*------
			"command \bshow-riders\b, key \b[\b        \n\n"
			"This will list the observers      \n"
			"currently riding you.  If you have\n"
			"any riders the gold key will light\n"
			"up in your status bar.            \n\n",
			string_null, string_null);
	}

	else { i = i + 1; if (m == i)
	{
		aq_menu_print_help (
			//----------------------------------*------
			"command \bfix-angles\b, key \b]\b         \n\n"
			"Use this command if your view is  \n"
			"tilted to the side, or if you are \n"
			"experiencing one of the weirdness \n"
			"effects inapproriately.  Sometimes\n"
			"teleporting also works.           \n",
			string_null, string_null);
	}

	else { i = i + 1; if (m == i)
	{
		aq_menu_print_help (
			//----------------------------------*------
			"command \bshow-players\b              \n\n"
			"This command lists the players    \n"
			"connected to the server, and      \n"
			"whether each is playing, observing\n"
			"or riding.                        \n\n",
			string_null, string_null);
	}

	else { i = i + 1; if (m == i)
	{
		aq_menu_print_help (
			//----------------------------------*------
			"command \bshow-settings\b             \n\n"
			"This command shows how the mod is \n"
			"currently configured.  See the web\n"
			"page for an explanation of what   \n"
			"the settings mean                 \n\n",
			string_null, string_null);
	}

	else { i = i + 1; if (m == i)
	{
		aq_menu_print_help (
			//----------------------------------*------
			"Those are the basics.  Again, see \n"
			"the web page at                   \n\n"
			"       \bwww.runequake.com\b      \n\n"
			"for more information.  Have fun,  \n"
			"and let's be careful out there.   \n",
			string_null, string_null);
	}

	else
	{
		local string s;

		s = ftos (m);
		aq_menu_print_help ("Invalid menu number ", s, "\n\n\n\n\n\n\n");
	}}}}}}}}}}}}}}}}

};
