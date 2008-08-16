/*  $Id: heads.qc,v 1.9 2008/08/16 08:55:47 slotzero Exp $

    Copyright (C) 2008  David 'Slot Zero' Roberts.

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
	* command to see how many heads,or use rune-tell?
	* quakenbake found himself 1/2 way in the floor, movetarget issue?
	* phoenix not working properly
	* evaluate the dead head carry code, will this cause problems?
	* investigate pickup/dropoff sound, maybe chan_auto not good?

	[FIXED] remember to lose owner during client disconnect
	[FIXED] head count still not reset, put in PCIS / Resurrect!
	[FIXED] client disconnect on intermission drops heads
	[FIXED] head tilt (self.health)
	[FIXED] altar touch dropoff sound
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
			e_chain.nextthink	= time;
			e_chain.think		= head_think;
			e_chain.dropdelay	= time + 10;
			e_chain.movetype	= MOVETYPE_BOUNCE;
			e_chain.takedamage	= DAMAGE_NO;
			e_chain.solid		= SOLID_TRIGGER;
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
	-])

	self.nextthink	= time + 0.1;
};

void (vector spot)
altar_create =
{
	local entity altar;

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
	if (self.owner)
	{
		if (!self.owner.cl[CL_ACTIVE])
		self.owner = world;
	}

	// head fell out of level
	if (pointcontents (self.origin) == CONTENT_SOLID)
	{
		dprint ("debug: head fell out of level, respawning\n");
		e		= SelectRuneSpawnPoint ();
		self.velocity	= VEC_ORIGIN;
		setorigin (self, e.origin);
		self.velocity	= VelocityForDamage (-150);
		return;
	}

	// head timed out
	if (self.dropdelay < time)
	{
		dprint ("debug: head timed out\n");
		if (self.owner.movetarget == self)
			self.owner.movetarget = world;
		remove (self);
	}

	self.nextthink = time + 1;
};

void ()
head_touch =
{
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

	// head pick-up sound, move to settings?
	sound (other, CHAN_AUTO, "player/pain1.wav", 1, ATTN_NONE);

	bprint_head_touch ();
};

void (string gibname, float dm)
head_throw =
{
	local entity head;

	head_drop ();

	head		= spawn ();
	head.classname	= "thrown_head";

	setmodel (head, gibname);
	setorigin (head, self.origin);

	head.owner	= self;
	head.movetype	= MOVETYPE_BOUNCE;
	head.takedamage	= DAMAGE_NO;
	head.solid	= SOLID_TRIGGER;
	head.view_ofs	= '0 0 8';
	setsize (head, '-16 -16 0', '0 0 8');
	head.velocity	= VelocityForDamage (dm - 140);
	head.origin_z	= head.origin_z - 24;
	head.flags	= head.flags - self.flags & FL_ONGROUND;
	head.avelocity	= crandom () * '0 600 0';
	head.touch	= head_touch;
	head.nextthink	= time;
	head.think	= head_think;
	head.dropdelay	= time + 120; // head timeout

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
			{
				e_chain.nextthink	= time;
				e_chain.think		= head_think;
				e_chain.dropdelay	= time + 120; // make global, move to settings.qc
				e_chain.touch		= head_touch;
				e_chain.velocity	= VEC_ORIGIN;
				e_chain.velocity	= VelocityForDamage (-100);
				e_chain.flags		= e_chain.flags - e_chain.flags & FL_ONGROUND;
				e_chain.avelocity	= crandom () * '0 600 0';
				e_chain.movetype	= MOVETYPE_BOUNCE;
				e_chain.takedamage	= DAMAGE_NO;
				e_chain.solid		= SOLID_TRIGGER;

				setorigin (e_chain, self.origin);
			}
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
			if (e_chain.owner)
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
			num = random ();
			if (num < 0.2)
			{
				bprint (other.netname);
				bprint (" presented ");
				bprint_head_owner (other.head_chain);
				bprint ("'s head at the altar!!\n");
			}
			else if (num < 0.4)
			{
				bprint (other.netname);
				bprint (" donates ");
				bprint_head_owner (other.head_chain);
				bprint ("'s head to the gods!!\n");
			}
			else if (num < 0.6)
			{
				bprint_head_owner (other.head_chain);
				bprint ("'s head gains favor for ");
				bprint (other.netname);
				bprint ("!!\n");
			}
			else if (num < 0.8)
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
	num = random ();
	if (num < 0.1)
		bprint (" picked up ");
	else if (num < 0.2)
		bprint (" grabbed ");
	else if (num < 0.3)
		bprint (" looted ");
	else if (num < 0.4)
		bprint (" latched onto ");
	else if (num < 0.5)
		bprint (" scooped up ");
	else if (num < 0.6)
		bprint (" found ");
	else if (num < 0.7)
		bprint (" took ");
	else if (num < 0.8)
		bprint (" came upon ");
	else if (num < 0.9)
		bprint (" was lucky to find ");
	else
		bprint (" plucked up ");

	bprint_head_owner (self);
	num = random ();
	if (num < 0.1)
		bprint ("'s worm infested");
	else if (num < 0.2)
		bprint ("'s bloody");
	else if (num < 0.3)
		bprint ("'s empty");
	else if (num < 0.4)
		bprint ("'s ugly");
	else if (num < 0.5)
		bprint ("'s putrid");
	else if (num < 0.6)
		bprint ("'s deformed");
	else if (num < 0.7)
		bprint ("'s bloated");
	else if (num < 0.8)
		bprint ("'s crusty");
	else if (num < 0.9)
		bprint ("'s slimey");
	else if (num < 0.95)
		bprint ("'s poor excuse for a");
	else
		bprint ("'s lifeless");

	num = random ();
	if (num < 0.2)
		bprint (" skull.");
	else if (num < 0.36)
		bprint (" noggin.");
	else if (num < 0.5)
		bprint (" brain.");
	else if (num < 0.65)
	 	bprint (" melon.");
	else if (num < 0.8)
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

// XXX Use a custom file for this using an x,y,z method via cvar so servers can move these without recompiling.

float place_my_altars;

void ()
altar_place =
{
	dprint ("altar_place\n");

	if (place_my_altars)
		return;

	place_my_altars = 1;

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
		altar_create ('1177 -350 190');
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
		altar_create ('193 904 -30');
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
		// XXX fix this
		altar_create (self.origin);
	}
};
