/*
    Copyright (C) 2008-2015  David 'Slot Zero' Roberts.

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

HEAD DEVELOPMENT:

	* maybe draw head spike and head > value
	* how to implement max heads?
	* command to see how many heads,or use rune-tell? (currently in show-riders)
	* quakenbake found himself 1/2 way in the floor, movetarget issue?
	* evaluate the dead head carry code, will this cause problems?
	* investigate pickup/dropoff sound, maybe chan_auto not good?
	* put head count in ammo count?
	* should heads live in slime?

	[FIXED] switch rune switches heads
	[FIXED] phoenix not working properly
	[FIXED] remember to lose owner during client disconnect
	[FIXED] head count still not reset, put in PCIS / Resurrect!
	[FIXED] client disconnect on intermission drops heads
	[FIXED] head tilt (self.health)
	[FIXED] altar touch dropoff sound
	[FIXED] heads don't spawn in phoenix
*/

void ()
altar_touch =
{
	local entity e_chain;
	local float heads;

	if (other.classname != "player")
		return;

	misc_touch ();

	if (!other.num_heads)
		return;

	sound (other, CHAN_AUTO, "player/pain2.wav", 1, ATTN_NONE);

	bprint_altar_touch (other.num_heads);

	heads		 = other.num_heads;
	e_chain		 = other.head_chain;
	other.num_heads	 = 0;
	other.head_chain = world;

	add_frag (other, (0.5 * (heads - 1) * heads) + heads);

	while (heads > 0)
	{
		if (e_chain.classname == "thrown_head")
		{
			e_chain.dropdelay	= time + 5 + random() * 5;
			e_chain.nextthink	= time;
			e_chain.think		= head_think;
			e_chain.movetype	= MOVETYPE_BOUNCE;
			e_chain.takedamage	= DAMAGE_NO;
			e_chain.solid		= SOLID_TRIGGER;
			e_chain.last_drop_delay	= 1; // don't respawn head
			e_chain.flags		= e_chain.flags - e_chain.flags & FL_ONGROUND;

			// do this from head_think?
			if (e_chain.owner.movetarget)
			{
				e_chain.owner.movetarget = world;
				setmodel (e_chain.owner, string_null);
			}
		}
		e_chain = e_chain.head_chain;
		heads = heads - 1;
	}
};

// XXX Don't forget to fix QW!
void ()
altar_spit =
{
	local float color;

	color		= random () * 255;

	IN_POQ([-
		particle (self.origin, '0 0 1000', color, 100);
	-], [-
		create_te_gunshot (self.origin, 30);
	-])

	self.nextthink	= time + 0.1;
};

void (vector spot)
altar_create =
{
	local entity altar;

	// don't spawn altar outside level
	if (pointcontents (spot) == CONTENT_SOLID)
		return dprint ("altar_create: invalid pointcontents\n");

	// don't place altars on top of each other
	altar = findradius (spot, 50);
	while (altar)
	{
		if (altar.classname == "altar")
			return dprint ("altar_create: too close to existing altar\n");
		altar = altar.chain;
	}

	dprint ("altar created at ");
	dprint_vec (spot);
	dprint ("\n");

	altar		= spawn ();
	setorigin (altar, spot);
	altar.touch	= altar_touch;
	altar.movetype	= MOVETYPE_TOSS;
	altar.solid	= SOLID_BBOX;
	setsize (altar, '-8 -8 0', '8 8 8');
	altar.nextthink	= time;
	altar.think	= altar_spit;
	altar.classname	= "altar";
};

void ()
head_death_think =
{
	if (self.movetarget)
	{
		setorigin (self, self.movetarget.origin);
		self.angles = self.movetarget.angles;
	}
};

void ()
head_think =
{
	local entity e;

	// forget owner
	if (IN_POQ(self.owner,0))
	{
		if (!self.owner.cl[CL_ACTIVE])
		self.owner = world;
	}

	// head timed out
	if (self.dropdelay < time)
	{
		if (self.owner.movetarget == self)
			self.owner.movetarget = world;

		ThrowGib ("progs/gib1.mdl", 1);
		remove (self);
		return;
	}

	// head fell out of level
	if ((pointcontents (self.origin) == CONTENT_SOLID || pointcontents (self.origin) == CONTENT_LAVA) && !self.last_drop_delay)
	{
		dprint ("debug: head fell out of level or is in lava, respawning\n");
		e		= SelectRuneSpawnPoint ();
		self.velocity	= VEC_ORIGIN;
		setorigin (self, e.origin);
		self.velocity	= VelocityForDamage (-150);
		self.flags	= self.flags - self.flags & FL_ONGROUND;
		self.nextthink	= time + 2;
		return;
	}

	self.nextthink = time + 1;
};

void ()
head_touch =
{
	local entity e;
	local float heads;

	if (other.classname != "player")
		return;

	if (other.deadflag)
		return;

	if (self.owner.movetarget == self)
	{
		if (self.owner.runetype == RN_PHOENIX)
			return;

		self.owner.health = 1;
		self.owner.flags = self.owner.flags | FL_ONGROUND;
	}

	self.touch	= SUB_Null;
	self.movetype	= MOVETYPE_NONE;
	self.solid	= SOLID_NOT;
	self.velocity	= VEC_ORIGIN;
	self.avelocity	= VEC_ORIGIN;
	self.nextthink	= -1;

	other.num_heads = other.num_heads + 1;
	if (other.head_chain)
	{
		self.head_chain = other.head_chain;
		other.head_chain = self;
	}
	else
		other.head_chain = self;

	if (MAX_VISIBLE_HEADS > 0)
	{
		heads = 0;
		e = other.head_chain;
		while (heads < other.num_heads)
		{
			if (heads >= MAX_VISIBLE_HEADS)
				setmodel (e, string_null);

			e = e.head_chain;
			heads = heads + 1;
		}
	}

	// head pick-up sound, move to settings?
	sound (other, CHAN_AUTO, "player/pain1.wav", 1, ATTN_NONE);

	bprint_head_touch ();
};

void (entity head, string gibname, float dm)
set_thrown_head =
{
	setmodel (head, gibname);
	setorigin (head, self.origin);
	setsize (head, '-16 -16 0', '0 0 8');

	head.movetype	= MOVETYPE_BOUNCE;
	head.takedamage	= DAMAGE_NO;
	head.solid	= SOLID_TRIGGER;
	head.view_ofs	= '0 0 8';
	head.velocity	= VEC_ORIGIN;
	head.velocity	= VelocityForDamage (dm);
	head.origin_z	= head.origin_z - 24;
	head.flags	= head.flags - head.flags & FL_ONGROUND;
	head.avelocity	= crandom () * '0 600 0';
	head.touch	= head_touch;
	head.dropdelay	= time + HEAD_TIMEOUT;
	head.nextthink	= time;
	head.think	= head_think;
};

void (string gibname, float dm)
head_throw =
{
	local entity head;

	head_drop ();

	head		= spawn ();
	head.owner	= self;
	head.classname	= "thrown_head";

	set_thrown_head (head, gibname, (dm - 125));

	setmodel (self, "progs/spike.mdl");
	self.movetarget	= head;
	self.frame	= 0;
	self.nextthink	= -1;
	self.movetype	= MOVETYPE_BOUNCE;
	self.takedamage	= DAMAGE_NO;
	self.solid	= SOLID_NOT;
	self.view_ofs	= '0 0 8';
	setsize (self, '-16 -16 0', '16 16 56');
	self.origin_z	= self.origin_z - 24;
	self.flags	= self.flags - self.flags & FL_ONGROUND;
	//self.effects	= self.effects | EF_MAYBE_DRAW;
};

void ()
head_drop =
{
	local entity e_chain;
	local float heads;

	e_chain		= self.head_chain;
	heads		= self.num_heads;
	self.num_heads	= 0;
	self.head_chain	= world;

	if (intermission_running)
		return;

	if (heads)
	{
		if (heads == 1)
		{
			bprint_head_owner (e_chain);
			bprint ("'s head is fumbled!\n");
		}
		else if (heads == 2)
			bprint ("Two heads are dropped!\n");

		else if (heads < 5)
			bprint ("Many heads fly free!\n");

		else
			bprint ("It's a sea of heads!!!\n");

		while (heads > 0)
		{
			if (e_chain.classname == "thrown_head")
				set_thrown_head (e_chain, "progs/h_player.mdl", -100);

			e_chain = e_chain.head_chain;
			heads = heads - 1;
		}
	}
};

void ()
head_carry =
{
	local entity e_chain;
	local vector e_org, e_drag;
	local float heads;

	if (self.num_heads)
	{
		makevectors (self.angles);
		e_org		= self.origin - (v_right * 16);
		e_chain		= self.head_chain;
		heads		= self.num_heads;

		while (heads > 0)
		{
			if (IN_POQ(e_chain.owner,0))
			{
				if (!e_chain.owner.cl[CL_ACTIVE])
					e_chain.owner = world;
			}

			setorigin (e_chain, e_org + e_drag);
			e_org		= e_chain.origin;
			e_chain		= e_chain.head_chain;
			heads		= heads - 1;

			if (heads > 0)
			{
				e_drag = e_org - e_chain.origin + e_chain.velocity + '0 0 2';
				e_drag = normalize (e_drag);
				e_drag = e_drag * -10;
			}
		}
	}
};

// XXX This function needs some clarification with respect to the argument "head", that is
// what do you submit, the head or the head.owner? (currently it is head)
void (entity head)
bprint_head_owner =
{
	if (head.owner.classname == "player" && head.owner.netname != string_null)
		bprint (head.owner.netname);
	else
		bprint ("somebody");
};

void (float heads)
bprint_altar_touch =
{
	local float num;

	if (heads == 1)
	{
		if (other.head_chain.owner == other)
		{
			bprint (other.netname);
			bprint (" brought his own head to the altar.\n");
		}
		else
		{
			num = rint (random () * 5);
			if (num == 1)
			{
				bprint (other.netname);
				bprint (" presented ");
				bprint_head_owner (other.head_chain);
				bprint ("'s head at the altar!!\n");
			}
			else if (num == 2)
			{
				bprint (other.netname);
				bprint (" donates ");
				bprint_head_owner (other.head_chain);
				bprint ("'s head to the gods!!\n");
			}
			else if (num == 3)
			{
				bprint_head_owner (other.head_chain);
				bprint ("'s head gains favor for ");
				bprint (other.netname);
				bprint ("!!\n");
			}
			else if (num == 4)
			{
				bprint (other.netname);
				bprint (" blesses the altar with ");
				bprint_head_owner (other.head_chain);
				bprint ("'s head!!\n");
			}
			else
			{
				bprint_head_owner (other.head_chain);
				bprint ("'s head moves the gods.  Thanks ");
				bprint (other.netname);
				bprint ("!!\n");
			}
		}
	}
	else if (heads == 2)
	{
		bprint (other.netname);
		bprint (" brought two heads to the altar!\n");
	}
	else
	{
		if (heads < 5)
		{
			bprint (other.netname);
			bprint (" scores multiple heads!\n");
		}
		else
		{
			bprint (other.netname);
			bprint (" hits the big time!!!\n");
		}
	}
};

void ()
bprint_head_touch =
{
	local float num;

	bprint (other.netname);
	num = rint (random () * 10);
	if (num == 1)
		bprint (" picked up ");
	else if (num == 2)
		bprint (" grabbed ");
	else if (num == 3)
		bprint (" looted ");
	else if (num == 4)
		bprint (" latched onto ");
	else if (num == 5)
		bprint (" scooped up ");
	else if (num == 6)
		bprint (" found ");
	else if (num == 7)
		bprint (" took ");
	else if (num == 8)
		bprint (" came upon ");
	else if (num == 9)
		bprint (" was lucky to find ");
	else
		bprint (" plucked up ");

	if (self.owner == other)
		bprint ("his own ");
	else
	{
		bprint_head_owner (self);
		bprint ("'s ");
	}

	num = rint (random () * 11);
	if (num == 1)
		bprint ("worm infested");
	else if (num == 2)
		bprint ("bloody");
	else if (num == 3)
		bprint ("empty");
	else if (num == 4)
		bprint ("ugly");
	else if (num == 5)
		bprint ("putrid");
	else if (num == 6)
		bprint ("deformed");
	else if (num == 7)
		bprint ("bloated");
	else if (num == 8)
		bprint ("crusty");
	else if (num == 9)
		bprint ("slimey");
	else if (num == 10)
		bprint ("poor excuse for a");
	else
		bprint ("lifeless");

	num = rint (random () * 6);
	if (num == 1)
		bprint (" skull.");
	else if (num == 2)
		bprint (" noggin.");
	else if (num == 3)
		bprint (" brain.");
	else if (num == 4)
	 	bprint (" melon.");
	else if (num == 5)
		bprint (" cranium.");
	else
		bprint (" head.");

	if (other.num_heads > 1)
	{
		bprint (" He has ");
		bprint_float (other.num_heads);
		bprint (".\n");
	}
	else
		bprint ("\n");
};

// This function only gets called if the map doesn't have a hard-coded altar.  I run it a few seconds after
// I exec the altar config file to allow it time to load.  If no altar was created by the config, it places
// one at info_player_start().
void ()
delayed_altar_place =
{
	if (!find (world, classname, "altar"))
		altar_create (self.origin); // info_player_start

	remove (self);
};

float place_my_altars;

void ()
altar_place =
{
	if (place_my_altars)
		return;

	place_my_altars = 1;

	// custom altars
	localcmd ("exec altars/");
	localcmd (mapname);
	localcmd (".alt\n");

	if (world.model == "maps/dm1.bsp")
	{
		altar_create ('158 1140 -120');
	}
	else if (world.model == "maps/dm2.bsp")
	{
		altar_create ('2120 -110 32');
		altar_create ('2459 -1532 24');
	}
	else if (world.model == "maps/dm3.bsp")
	{
		altar_create ('1670 -32 -168');
		altar_create ('84 -702 -16');
	}
	else if (world.model == "maps/dm4.bsp")
	{
		altar_create ('510 -180 -100');
	}
	else if (world.model == "maps/dm5.bsp")
	{
		altar_create ('-100 -220 216');
		altar_create ('330 -224 -112');
	}
	else if (world.model == "maps/dm6.bsp")
	{
		altar_create ('68 -1640 40');
	}
	else if (world.model == "maps/e1m1.bsp")
	{
		altar_create ('832 2040 -408');
		altar_create ('130 1580 -200');
	}
	else if (world.model == "maps/e1m2.bsp")
	{
		altar_create ('1104 208 308');
	}
	else if (world.model == "maps/e1m3.bsp")
	{
		altar_create ('1177 -350 -190');
		altar_create ('-1216 -160 -60');
	}
	else if (world.model == "maps/e1m4.bsp")
	{
		altar_create ('785 -575 840');
		altar_create ('705 2570 944');
	}
	else if (world.model == "maps/e1m5.bsp")
	{
		altar_create ('-547 1245 160');
	}
	else if (world.model == "maps/e1m6.bsp")
	{
		altar_create ('352 864 31');
	}
	else if (world.model == "maps/e1m8.bsp")
	{
		altar_create ('671.4 38.5 -664');
		altar_create ('694 150 32');
	}
	else if (world.model == "maps/e2m1.bsp")
	{
		altar_create ('1580 260 -8');
		altar_create ('1267 1974 282');
	}
	else if (world.model == "maps/e2m2.bsp")
	{
		altar_create ('162 896 88');
	}
	else if (world.model == "maps/e2m3.bsp")
	{
		altar_create ('175 598 -136');
		altar_create ('196.1 -911.1 -27');
	}
	else if (world.model == "maps/e2m4.bsp")
	{
		altar_create ('1146 2600 344');
		altar_create ('596 1706 104');
	}
	else if (world.model == "maps/e2m5.bsp")
	{
		altar_create ('794.8 1149.1 -20');
	}
	else if (world.model == "maps/e2m6.bsp")
	{
		altar_create ('1921.1 149.4 -580');
		altar_create ('595.5 945.4 -480');
	}
	else if (world.model == "maps/e2m7.bsp")
	{
		altar_create ('1676 472 -108');
		altar_create ('614 197 56');
	}
	else if (world.model == "maps/e3m1.bsp")
	{
		altar_create ('-258 -570 -104');
	}
	else if (world.model == "maps/e3m2.bsp")
	{
		altar_create ('190 502 24');
		altar_create ('193 -904 -30');
	}
	else if (world.model == "maps/e3m4.bsp")
	{
		altar_create ('216 -2010 200');
		altar_create ('680 -360 24');
		altar_create ('1474 -544 -40');
	}
	else if (world.model == "maps/e3m5.bsp")
	{
		altar_create ('-244 -2272 536');
		altar_create ('606 -1666 -289');
	}
	else if (world.model == "maps/e3m6.bsp")
	{
		altar_create ('286 -1225 -136');
		altar_create ('-1084 -997 104');
	}
	else if (world.model == "maps/e3m7.bsp")
	{
		altar_create ('-492 -242 -104');
		altar_create ('212 -243 24');
	}
	else if (world.model == "maps/e4m1.bsp")
	{
		altar_create ('1312 896 104');
		altar_create ('2086 11 104');
	}
	else if (world.model == "maps/e4m2.bsp")
	{
		altar_create ('786 -2377 536');
		altar_create ('-138 876 793');
	}
	else if (world.model == "maps/e4m4.bsp")
	{
		altar_create ('405 2269 56');
		altar_create ('-1236 -1495 24');
		altar_create ('-120 -974 24');
	}
	else if (world.model == "maps/e4m5.bsp")
	{
		altar_create ('417 -205 24');
		altar_create ('-1549 -1599 -376');
	}
	else if (world.model == "maps/e4m6.bsp")
	{
		altar_create ('285 350 24');
		altar_create ('546 -672 24');
	}
	else if (world.model == "maps/e4m7.bsp")
	{
		altar_create ('-1056 782 -248');
		altar_create ('415 -195 24');
	}
	else if (world.model == "maps/e4m8.bsp")
	{
		altar_create ('1940 1000 24');
		altar_create ('1426 969 24');
	}
	else if (world.model == "maps/end.bsp")
	{
		altar_create ('-448 573 48');
	}
	else if (world.model == "maps/death32c.bsp")
	{
		altar_create ('32 -1312 26');
		altar_create ('-404 172 26');
		altar_create ('715 -1169 90');
		altar_create ('609.5 671.8 66');
	}
	else if (world.model == "maps/base32b.bsp")
	{
		altar_create ('-67 1701 -406');
		altar_create ('-2831 -569 -102');
		altar_create ('1710 -872 -6');
	}
	else if (world.model == "maps/zoiddm1.bsp")
	{
		altar_create ('-957 324 26');
		altar_create ('1924 298 -38');
		altar_create ('-1214 -1164 -166');
	}
	else if (world.model == "maps/trimp.bsp")
	{
		altar_create ('1150 -1030.5 -998');
	}
	else if (world.model == "maps/manson1.bsp")
	{
		altar_create ('157.5 -353 -406');
	}
	else if (world.model == "maps/kndybase.bsp")
	{
		altar_create ('725.8 243.6 252');
		altar_create ('561.8 270.8 -196');
	}
	else if (world.model == "maps/dapak.bsp")
	{
		altar_create ('-63.9 62.6 10');
	}
	else if (world.model == "maps/dapak1.bsp")
	{
		altar_create ('-3256.3 -588.8 282');
		altar_create ('-2189.8 -451.2 74');
	}
	else if (world.model == "maps/dapak2.bsp")
	{
		altar_create ('-784.2 491.7 -518');
		altar_create ('47.5 435.1 -34');
	}
	else if (world.model == "maps/dapak3.bsp")
	{
		altar_create ('1420.7 -56.8 26');
	}
	else if (world.model == "maps/dapak4.bsp")
	{
		altar_create ('-349.6 -133.4 122');
	}
	else if (world.model == "maps/dapak5.bsp")
	{
		altar_create ('-712.5 391.2 -102');
	}
	else if (world.model == "maps/dapak6.bsp")
	{
		altar_create ('50.4 132.7 22');
	}
	else if (world.model == "maps/dapak7.bsp")
	{
		altar_create ('-596.6 743.5 -102');
	}
	else if (world.model == "maps/dapak8.bsp")
	{
		altar_create ('241.4 588.3 282');
	}
	else
	{
		// wait for custom altars to process
		local entity e;

		e		= spawn ();
		e.origin	= self.origin;
		e.nextthink	= time + 1.5;
		e.think		= delayed_altar_place;
	}
};

void (vector spot)
spawn_altar =
{
	local entity altar;

	altar			= spawn ();
	altar.classname		= "altar_fake";

	setorigin (altar, spot);

	altar.think		= altar_spit;
	altar.nextthink		= time;
};

void ()
heads_tell =
{
	local float heads;

	heads = self.num_heads;

	if (!heads)
		self_sprint (self, "You aren't carrying any heads\n");
	else if (heads == 1)
		self_sprint (self, "Carrying 1 head (1 frag)\n");
	else
	{
		self_sprint (self, "Carrying ");
		self_sprint_float (self, heads);
		self_sprint (self, " heads (");
		self_sprint_float (self, (heads - 1) * heads * 0.5 + heads);
		self_sprint (self, " frags)\n");
	}
};
