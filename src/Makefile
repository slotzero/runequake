#    $Id: Makefile,v 1.15 2010/02/04 04:16:14 slotzero Exp $

#    Copyright (C) 1998-2001  Roderick Schertler.
#
#    This program is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation; either version 2 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program; if not, write to the Free Software
#    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA

# The source here makes both the POQ and QW versions.  The files are
# preprocessed with m4 with either QW or POQ defined.

all:

src_files	:= Makefile progs.src map map-auto.qc *.qc *.m4

this_dir	:= src
orig_dir	:= orig
patch		:= ../patch

src_m4		:= $(sort $(wildcard *.qc) map-auto.qc progs.src)
src_extra_dep	:= Makefile

types		:= poq qw
type		:= xxx # overridden by target-specific value

dir_poq		:= ../poq
dir_shamck_poq	:= runequake
progs_poq	:= ../progs.dat
progs_poq_ts	:= $(progs_poq).ts
src_m4_poq	:= $(addprefix $(dir_poq)/,$(src_m4))
src_files	+= $(src_m4_poq) $(dir_poq)/func.qc
m4_def_poq	:= -DPOQ -DPROGS_FILE=$(progs_poq)

$(progs_poq) $(progs_poq_ts) $(dir_poq)/%: type := poq
$(progs_poq):	$(src_m4_poq) $(dir_poq)/func.qc $(src_extra_dep)
$(progs_poq_ts): $(progs_poq)

dir_qw		:= ../qw
dir_shmack_qw	:= qwshmack
progs_qw	:= ../qwprogs.dat
progs_qw_ts	:= $(progs_qw).ts
src_m4_qw	:= $(addprefix $(dir_qw)/,$(src_m4))
src_files	+= $(src_m4_qw) $(dir_qw)/func.qc
m4_def_qw	:= -DQW -DPROGS_FILE=$(progs_qw)

$(progs_qw) $(progs_qw_ts) $(dir_qw)/%: type := qw
$(progs_qw):	$(src_m4_qw) $(dir_qw)/func.qc $(src_extra_dep)
$(progs_qw_ts):	$(progs_qw)

dir_all		:= $(foreach type,$(types),$(dir_$(type)))
progs_all	:= $(foreach type,$(types),$(progs_$(type)))

M4		:= m4
M4FLAGS		:= --prefix-builtins

base_files	:=  Changes Configuring Copying Playing \
			example.cfg gnu.txt runequake.qst
base_files_src	:= Notes

dist_version	:= runequake-$(shell \
			perl -ne 'print $$1 if /version\s*=\s*"(.*?)";/' \
				version.qc)
dist_noversion	:= runes
dist_tar	:= ../Arch/$(dist_version).tar.gz
dist_zip	:= ../Arch/$(dist_version).zip
dist_tarsrc	:= ../Arch/$(dist_version)-src.tar.gz
dist_zipsrc	:= ../Arch/$(dist_version)-src.zip
dist_files	:= $(dist_tar) $(dist_zip) $(dist_tarsrc) $(dist_zipsrc)

t_patch		:= $(patch).tmp
diff		:= cd .. && diff -rNc -x progdefs.h -x func.qc -x TAGS -x CVS \
				-x .cvsignore -x '*[\#~]' -x '*.bak' \
				$(orig_dir) $(this_dir)

# These two work on the source in the current directory.

source_list	:= \
    `perl -anle 'print $$F[0] unless m-^//|^\s*$$- || $$F[0] eq "func.qc"' \
	progs.src | tail -n +2`

make_func	:= \
	perl -0777ne 'print "$$1 $$2 $$3;\n" \
			while /^((?:void|float|entity|string|vector)) \
				\s* (\([\s\w(),]*\)) \s* (\w+) \s* =/gsmx' \
	    $(source_list) >func.qc

all: $(progs_all)

map-auto.qc: map
	rm -f $@
	./map > $@
	chmod a-w $@

func: $(foreach type,$(types),$(src_m4_$(type)))
	rm -f $(foreach type,$(types),$(dir_$(type))/func.qc)
    # XXX not parallelized
	for dir in $(dir_all); \
	    do $(MAKE) -C $$dir -f $(shell pwd)/Makefile func.qc; done
#	$(MAKE) TAGS
$(foreach type,$(types),$(dir_$(type))/func.qc):
	    $(MAKE) func
func.qc:
	$(make_func)
.PHONY: func func.qc

TAGS:
	qc-etags $(source_list)
.PHONY: TAGS

# Preprocess source files with m4.
#
# Originally I specified this as a pattern rule, with
#
#     $(foreach type,$(types),$(dir_$(type))/%): %
#
# That fails becuase multiple targets for a patter rule require the
# commands to make all the targets.  XXX The current solution causes
# engine-specific duplication outside of the configuration section.

define m4-process
	@[ -d $(dir $@) ] || { echo "mkdir $(dir $@)"; mkdir $(dir $@); }
	@echo "[m4 >$@]"; \
	(echo "m4_include(head.m4)m4_dnl"; cat $<) | \
	    $(M4) $(M4FLAGS) $(m4_def_$(type)) > $@
endef

$(dir_poq)/%: % head.m4
	$(m4-process)
$(dir_qw)/%: % head.m4
	$(m4-process)

# Build progs from pre-processed source.

$(progs_all):
    # Filter settings.qc through ~/.quake-passcode if that program
    # exists.  I use this to substitute in my admin and Qsmack
    # passcodes.
	cd $(dir_$(type)); cp -p settings.qc settings.qc.real
	cd $(dir_$(type)); [ ! -x $$HOME/.quake-passcode ] || \
	    $$HOME/.quake-passcode < settings.qc.real > settings.qc
	cd $(dir_$(type)); \
	    qccx /O2; cp -p settings.qc.real settings.qc && exit $$ret
    # XXX fastqcc umask bug
	chmod o-w $@
	[ ! -d $$HOME/quake/runequake ] || cp $@ $$HOME/quake/runequake

# XXX This hasn't been updated since QW changes.

#monster_dir := build-monster
#$(progs_monster): $(src) XXX
#	rm -rf $(monster_dir)
#	mkdir $(monster_dir)
#	cd $(monster_dir) && cp ../*.qc .
#	cd $(monster_dir) && perl -pi -we 's,^\s*//nomonster,,' *.qc
#	cd $(monster_dir) && perl -nlwe '\
#		s/^\s+//; \
#		s/\s+$$//; \
#		next if $$_ eq "nomonst.qc"; \
#		s-^//nomonster\s+--; \
#		$$c = $$c = "fastqcc chokes on the long progs.dat path"; \
#		s|^\.\./progs\.dat$$|progs.dat| and $$ok = 1; \
#		print; \
#		END { $$ok or die "did not see ../progs.dat" }' \
#		../progs.src > progs.src
#	cd $(monster_dir) && rm -f func.qc
#	cd $(monster_dir) && $(make_func)
#	cd $(monster_dir) && fastqcc
#	mv $(monster_dir)/progs.dat $@
## XXX fastqcc umask bug
#	chmod o-w $@
#	rm -rf $(monster_dir)

$(patch) $(t_patch): $(src_m4) $(src_extra_dep)
	@[ ! -f $@ ] || { echo "mv $@ $@.bak"; mv $@ $@.bak; }
	($(diff)) > $@; \
	[ $$? = 0 -o $$? = 1 ]

diff: $(t_patch)
	cat $(t_patch)

diffdiff: $(t_patch)
	diff -t $(DIFFARGS) $(patch) $(t_patch)

install: $(foreach type,$(types),$(progs_$(type)_ts)) $(patch)

$(foreach type,$(types),$(progs_$(type)_ts)):
	ssh -C shmack "\
	    cd /usr/local/quake/jail/$(dir_shmack_$(type)) && \
	    cat >progs.tmp && \
	    mv progs.tmp $(notdir $<)" < $<
	touch $@

clean:
	rm -f $(foreach type,$(types),$(progs_$(type)) $(src_m4_$(type)) \
	    	    	    	    	$(dir_$(type))/func.qc \
					$(dir_$(type))/progdefs.h \
					$(dir_$(type))/settings.qc.real)
	for dir in $(dir_all); do [ ! -d $$dir ] || rmdir $$dir; done

dist: clean
    # Make without ~/.quake-passcode so admin mode is disabled.
	HOME=/nonesuch $(MAKE)
	$(MAKE) $(dist_files)
	$(MAKE) clean

$(dist_tar)    $(dist_zip):    $(addprefix ../, $(base_files)) $(progs_poq) $(progs_qw)
$(dist_tarsrc) $(dist_zipsrc): $(addprefix ../, $(base_files) $(base_files_src)) $(src_files)
$(dist_files):
	[ ! -f $@ ]
	set -e; \
		dir=`pwd`; \
		cd ../..; \
		if expr "$@" : '.*-src\.' >/dev/null; \
			then link=$(dist_version); \
			else link=$(dist_noversion); \
		fi; \
		[ -d $$link ] || ln -s $$dir/.. $$link; \
		set -- $$dir/$@ \
			$(patsubst ../%, $$link/%, $(filter ../%, $^)) \
			$(patsubst %, $$link/src/%, $(filter-out ../%, $^)); \
		if expr "$@" : '.*\.zip$$' >/dev/null; \
			then zip "$$@"; \
			else tar cvfz "$$@"; \
		fi; \
		rm $$link
