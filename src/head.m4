m4_dnl     $Id: head.m4,v 1.5 2003/06/24 22:17:38 slotzero Exp $
m4_dnl
m4_dnl     Copyright (C) 1998-2001  Roderick Schertler.
m4_dnl
m4_dnl     This program is free software; you can redistribute it and/or modify
m4_dnl     it under the terms of the GNU General Public License as published by
m4_dnl     the Free Software Foundation; either version 2 of the License, or
m4_dnl     (at your option) any later version.
m4_dnl
m4_dnl     This program is distributed in the hope that it will be useful,
m4_dnl     but WITHOUT ANY WARRANTY; without even the implied warranty of
m4_dnl     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
m4_dnl     GNU General Public License for more details.
m4_dnl
m4_dnl     You should have received a copy of the GNU General Public License
m4_dnl     along with this program; if not, write to the Free Software
m4_dnl     Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
m4_dnl
m4_divert(-1)

m4_changequote([-, -])
m4_changecom([-//-])

m4_define([-IN_POQ-], [-m4_ifdef([-POQ-], $@)-])
m4_define([-IN_QW-],  [-m4_ifdef([-QW-],  $@)-])

m4_divert[--]m4_dnl
