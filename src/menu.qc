// $Id: menu.qc,v 1.3 2002/07/16 06:28:53 slotzero Exp $
//
// Copyright (c) 2001, 2002 Rune Quake Development Team.  All rights reserved.
// See the file `Copying' in the distribution for terms.

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

void (string s1, string s2, string s3, string s4, string s5, string s6)
aq_menu_print_help =
{
	centerprint7 (self, s1, s2, s3, s4, s5, s6,
		"\n\n\n\n πςεφ Νεξυ ξεψτ\n");
};

void (float m)
aq_menu_print_n =
{
	local float i;

	i = AQS_MENU_HELP_FIRST - 1;

	if (m == AQS_MENU_SPLASH)
	{
		centerprint7 (self,
			"Type 1 for the menu,\n2 to start playing\n\nÒυξε Ρυαλε\nVersion ",
			version,
			"\n\n",
			SPLASH_1, SPLASH_2, SPLASH_3, SPLASH_4);
	}

	else if (m == AQS_MENU_MAIN)
	{
		centerprint5 (self,
			"\n\nΝαιξ Νεξυ\n\n",
			"® View instructions \n® Join the game     \n",
			"® View credits      \n® Observe           \n",
			"® Ride next player  \n® Admin menu        \n",
			"® Weapon toggles    \n® Bind default keys \n"
			);
	}

	else if (m == AQS_MENU_CREDITS)
	{
		centerprint7 (self,
			//----------------------------------*------
			"Rune Quake was written by the Rune\n",
			"Quake Development Team and is     \n",
			"maintained by Slot Zero.          \n",
			"                                  \n\n",
			"To report bugs, please e-mail     \nSlot Zero <slotzero@runequake.com>\n",
			"                                  \n\nFor more info visit:              \n",
			"χχχ®ςυξερυαλε®γον                 \n\nType 1 to return to the menu.     \n");
	}

	else if (m == AQS_MENU_ADMIN)
	{
		centerprint7 (self,
			"Αδνιξ Νεξυ\n\n",
			"® Back to main menu   \n® Toggle team changing\n",
			"® Strip player's rune \n® Kill player         \n",
			"® Kick player         \n® Change level        \n",
			"® Change player's team\n® Put player in game  \n® Admin Menu 2        ",
			string_null, string_null);
	}

	else if (m == AQS_MENU_ADMIN_2)
	{
		centerprint6 (self,
			"Αδνιξ Νεξυ \n\n",
			"® Back to main menu   \n® Toggle vote-team    \n",
			"® Unbind player's keys\n® Rename player       \n",
			"® Toggle observer eyes\n",
			string_null, string_null);
	}

	else if (m == AQS_MENU_EPISODE)
	{
		centerprint7 (self,
			"Choose an episode, use\nany other impulse to cancel.\n\n",
			"® Dimension of the Doomed \n",
			"® The Realm of Black Magic\n",
			"® The Netherworld         \n",
			"® The Elder World         \n",
			"® The Deathmatch Arenas   \n",
			"® Let the game pick       \n"
			);
	}

	else if (m == AQS_MENU_EPISODE_1)
	{
		centerprint5 (self,
			"Dimension of the Doomed\n\n",
			"® e1m1: Slipgate Complex    \n® e1m2: Castle of the Damned\n",
			"® e1m3: The Necropolis      \n® e1m4: The Grisly Grotto   \n",
			"® e1m5: Gloom Keep          \n® e1m6: The Door To Chthon  \n",
			"® e1m7: The House of Chthon \n® e1m8: Ziggurat Vertigo    \n"
			);
	}

	else if (m == AQS_MENU_EPISODE_2)
	{
		centerprint5 (self,
			"The Realm of Black Magic\n\n",
			"® e2m1: The Installation    \n® e2m2: Ogre Citadel        \n",
			"® e2m3: Crypt of Decay      \n® e2m4: The Ebon Fortress   \n",
			"® e2m5: The Wizard's Manse  \n® e2m6: The Dismal Oubliette\n",
			"® e2m7: Underearth          \n"
			);
	}

	else if (m == AQS_MENU_EPISODE_3)
	{
		centerprint5 (self,
			"The Netherworld\n\n",
			"® e3m1: Termination Central \n® e3m2: The Vaults of Zin   \n",
			"® e3m3: The Tomb of Terror  \n® e3m4: Satan's Dark Delight\n",
			"® e3m5: Wind Tunnels        \n® e3m6: Chambers of Torment \n",
			"® e3m7: The Haunted Halls   \n"
			);
	}

	else if (m == AQS_MENU_EPISODE_4)
	{
		centerprint5 (self,
			"The Elder World\n\n",
			"® e4m1: The Sewage System   \n® e4m2: The Tower of Despair\n",
			"® e4m3: The Elder God Shrine\n® e4m4: The Palace of Hate  \n",
			"® e4m5: Hell's Atrium       \n® e4m6: The Pain Maze       \n",
			"® e4m7: Azure Agony         \n® e4m8: The Nameless City   \n"
			);
	}

	else if (m == AQS_MENU_EPISODE_5)
	{
		centerprint5 (self,
			"The Deathmatch Arenas\n\n",
			"®   dm1: Place of Two Deaths \n®   dm2: Claustrophobopolis  \n",
			"®   dm3: The Abandoned Base  \n®   dm4: The Bad Place       \n",
			"®   dm5: The Cistern         \n®   dm6: The Dark Zone       \n",
			"® start: Introduction        \n®   end: Shub-Niggurath's Pit\n"
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
			"Welcome to Rune Quake!  These     \n",
			"instructions are highly           \n",
			"abbreviated.  For the complete    \n",
			"documentation visit:              \n\n",
			"χχχ®ςυξερυαλε®γον                 \n",
			"                                  \n");
	}

	else { i = i + 1; if (m == i)
	{
		aq_menu_print_help (
			//----------------------------------*------
			"You start the game as an observer.\n",
			"Press 2 to to play, 4 to remain   \n",
			"an observer, or choose one of the \n",
			"other options from the menu.  You \n",
			"can return to being an observer   \n",
			"after playing by pressing 4 when  \nyou're dead.                      \n");
	}

	else { i = i + 1; if (m == i)
	{
		aq_menu_print_help (
			//----------------------------------*------
			"If the game is full you'll have   \n",
			"to wait for somebody to leave     \n",
			"or to become an observer before   \n",
			"you can play.  In this case you'll\n",
			"be put into the game queue.  Press\n",
			"2 again to see how close you are  \nto the head of the line.          \n");
	}

	else { i = i + 1; if (m == i)
	{
		aq_menu_print_help (
			//----------------------------------*------
			"There are a few dozen different   \n",
			"types of runes on the server.  See\n",
			"the web page or just experiment to\n",
			"find out what they do.            \n\n\n\n",
			string_null,
			string_null);
	}

	else { i = i + 1; if (m == i)
	{
		aq_menu_print_help (
			//----------------------------------*------
			"You'll need to bind at least two  \n",
			"keys in order to use the runes    \n",
			"effectively.  It's useful to bind \n",
			"a few other keys as well, but you \n",
			"can get by with just two.         \n\n\n",
			string_null);
	}

	else { i = i + 1; if (m == i)
	{
		aq_menu_print_help (
			//----------------------------------*------
			"On the main menu there's a command\n",
			"which will bind the most useful   \n",
			"commands to standard keys.  The   \n",
			"keys which are used are listed    \n",
			"along with the descriptions of the\n",
			"commands on the following pages.  \n\n");
	}

	else { i = i + 1; if (m == i)
	{
		aq_menu_print_help (
			//----------------------------------*------
			"command rune-use, key X           \n",
			"\n",
			"This command is needed to activate\n",
			"some of the runes, such as death  \n",
			"spots and radiation.  Most runes  \n",
			"don't require activation.         \n\n");
	}

	else { i = i + 1; if (m == i)
	{
		aq_menu_print_help (
			//----------------------------------*------
			"command rune-delete, key Q        \n",
			"\n",
			"This command deletes your current \n",
			"rune.  Since you can only have one\n",
			"rune at a time, you have to do    \n",
			"this to get a different rune.     \n\n");
	}

	else { i = i + 1; if (m == i)
	{
		aq_menu_print_help (
			//----------------------------------*------
			"command rune-tell, key C          \n",
			"\n",
			"This command tells you what rune  \n",
			"you currently have.               \n\n\n\n",
			string_null, string_null);
	}

	else { i = i + 1; if (m == i)
	{
		aq_menu_print_help (
			//----------------------------------*------
			"command weapon-mode, key 9        \n",
			"\n",
			"This command toggles some guns    \n",
			"between normal and alternate      \n",
			"modes.  If the blue key is lit the\n",
			"gun is in alternate mode.         \n\n");
	}

	else { i = i + 1; if (m == i)
	{
		aq_menu_print_help (
			//----------------------------------*------
			"command show-riders, key [        \n",
			"\n",
			"This will list the observers      \n",
			"currently riding you.  If you have\n",
			"any riders the gold key will light\n",
			"up in your status bar.            \n\n");
	}

	else { i = i + 1; if (m == i)
	{
		aq_menu_print_help (
			//----------------------------------*------
			"command fix-angles, key ]         \n\n",
			"Use this command if your view is  \n",
			"tilted to the side, or if you are \n",
			"experiencing one of the weirdness \n",
			"effects inapproriately.  Sometimes\n",
			"teleporting also works.           \n");
	}

	else { i = i + 1; if (m == i)
	{
		aq_menu_print_help (
			//----------------------------------*------
			"command show-players              \n",
			"\n",
			"This command lists the players    \n",
			"connected to the server, and      \n",
			"whether each is playing, observing\n",
			"or riding.                        \n\n");
	}

	else { i = i + 1; if (m == i)
	{
		aq_menu_print_help (
			//----------------------------------*------
			"command show-settings             \n",
			"\n",
			"This command shows how the mod is \n",
			"currently configured.  See the web\n",
			"page for an explanation of what   \n",
			"the settings mean                 \n\n");
	}

	else { i = i + 1; if (m == i)
	{
		aq_menu_print_help (
			//----------------------------------*------
			"Those are the basics.  Again, see \n",
			"the web page at                   \n\n",
			"χχχ®ςυξερυαλε®γον                 \n\n",
			"for more information.  Have fun,  \n",
			"and let's be careful out there.   \n",
			string_null);
	}

	else
	{
		local string s;

		s = ftos (m);
		aq_menu_print_help (
			"Invalid menu number ", s, "\n\n\n\n\n\n\n",
			string_null, string_null, string_null);
	}}}}}}}}}}}}}}}}

};
