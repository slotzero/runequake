/*  $Id: heads.qc,v 1.1 2008/08/09 05:53:10 slotzero Exp $

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

void () altar_touch =
{
	dprint ("altar_touch\n");
	misc_touch ();
};

void (vector spot) altar_create =
{
	dprint ("altar_create\n");
	local entity altar;

	altar = spawn ();
	setorigin (altar, spot);
	altar.touch = altar_touch;
	altar.movetype = MOVETYPE_TOSS;
	altar.solid = SOLID_BBOX;
	setsize (altar, '-8 -8 0', '8 8 8');
	altar.nextthink = time;
	altar.think = altar_spit;
	altar.classname = "altar";
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
		// warning: fix this
		altar_create (self.origin);
	}
};
