m4_dnl $Id: head.m4,v 1.1 2002/02/21 21:47:52 slotzero Exp $
m4_dnl
m4_dnl Copyright (c) 2001, 2002 Rune Quake Development Team.  All rights reserved.
m4_dnl See the file `Copying' in the distribution for terms.
m4_dnl
m4_divert(-1)

m4_changequote([-, -])
m4_changecom([-//-])

m4_define([-IN_POQ-], [-m4_ifdef([-POQ-], $@)-])
m4_define([-IN_QW-],  [-m4_ifdef([-QW-],  $@)-])

m4_divert[--]m4_dnl
