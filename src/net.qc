/*  $Id: net.qc,v 1.5 2003/10/10 20:43:39 slotzero Exp $

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

//-------------------------------------------------------------------
// NET FUNCTIONS
//-------------------------------------------------------------------

entity (entity e)
qs_address_e =
{
	local entity client;

	client = e.netconnection;
	return *AddInt(&client, 4 * QS_ADDRESS);
};

entity ()
qs_address =
{
	return qs_address_e (self);
};

string (entity e)
net_address_e =
{
	local entity client;

	client = qs_address_e (e);
	return @AddInt(&client, PQUAKEC_TO_PSTRING);
};

string ()
net_address =
{
	return net_address_e (self);
};
