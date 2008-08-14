/*  $Id: heads.qc,v 1.4 2008/08/14 05:07:49 slotzero Exp $

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

// XXX This function needs some clarification with respect to the argument "head", that is
// what do you submit, the head or the head.owner?
void (entity head)
bprint_head_owner =
{
	if (head.owner.classname == "player" && head.owner.netname != string_null)
		bprint (head.owner.netname);
	else
		bprint ("somebody");
};

void () altar_touch =
{
	if (other.classname != "player")
		return;

	if (other.num_heads)
	{
		if (other.num_heads > 1)
		{
			bprint (other.netname);
			bprint (" scores multiple heads\n");
		}
		else
		{
			bprint (other.netname);
			bprint (" brings ");
			bprint_head_owner (other.head_chain);
			bprint ("'s head to the altar\n");
		}
		add_frag (other, (0.5 * (other.num_heads - 1) * other.num_heads) + other.num_heads);
		other.num_heads = 0;


	}
	misc_touch ();
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

void (vector spot) altar_create =
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
head_client_disconnect =
{
	head_drop ();
};

void ()
head_touch =
{
	if (other.classname != "player")
		return;

	self.touch	= SUB_Null;
	self.movetype	= MOVETYPE_NONE;
	self.solid	= SOLID_NOT;
	self.velocity	= VEC_ORIGIN;
	self.avelocity	= VEC_ORIGIN;

	// bprint messages call
	bprint (other.netname);
	bprint (" picks up ");
	bprint_head_owner (self);
	bprint ("'s head\n");

	other.num_heads = other.num_heads + 1;
	if (other.head_chain)
	{
		self.head_chain = other.head_chain;
		other.head_chain = self;
	}
	else
		other.head_chain = self;
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

	setmodel (self, "progs/spike.mdl");
	self.movetarget	= head;
	self.num_heads	= 0; // only do this here?
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

	if (self.num_heads)
	{
		e_chain = self.head_chain;
		heads = self.num_heads;
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
				//e_chain.nextthink = time + 20;
				//e_chain.think = head_think;
				e_chain.touch		= head_touch;
				e_chain.velocity	= VEC_ORIGIN;
				e_chain.velocity	= VelocityForDamage (-100);
				e_chain.flags		= e_chain.flags - e_chain.flags & FL_ONGROUND;
				e_chain.avelocity	= crandom () * '0 600 0';
				e_chain.movetype	= MOVETYPE_BOUNCE;
				e_chain.takedamage	= DAMAGE_NO;
				e_chain.solid		= SOLID_TRIGGER;

				setorigin (e_chain, self.origin); // ??
			}
			e_chain = e_chain.head_chain;
			heads = heads - 1;
		}
		self.num_heads = 0;
		self.head_chain = world;
	}
};

void ()
head_carry =
{
	local entity e_chain;
	local vector e_org, e_drag;
	local float heads;

	if (self.num_heads > 0)
	{
		makevectors (self.angles);
		e_org		= self.origin - (v_right * 16);
		e_chain		= self.head_chain;
		heads		= self.num_heads;

		while (heads > 0)
		{
			// move this to its own function?
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
