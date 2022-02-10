
EXTVERSION = 1.8.2dev
REVISION  = $(shell git describe --always)
ifeq ($(REVISION),)
$(warning "REVISION is empty")
endif

PREFIX ?= /usr/local
LOCAL_BINDIR = $(PREFIX)/bin
LOCAL_SHAREDIR = $(PREFIX)/share/$(EXTENSION)
LOCAL_SHARE = $(EXTENSION)-$(EXTVERSION).sql.tpl
LOCAL_BIN = $(EXTENSION)-loader

DISTFILES = \
        doc \
        sql \
        test \
        LICENSE \
        Makefile \
        $(META) \
        $(META).in \
        README.md \
        dbpatch-loader.sh \
        dbpatch.control.in

META         = META.json
EXTENSION    = $(shell grep -m 1 '"name":' $(META).in | sed -e 's/[[:space:]]*"name":[[:space:]]*"\([^"]*\)",/\1/')
ifeq ($(EXTENSION),)
$(error "EXTENSION is empty")
endif

UPGRADEABLE_VERSIONS = $(shell test/ci/get_versions.bash)

UPGRADE_SCRIPTS_BUILT = $(patsubst %,upgrade-scripts/$(EXTENSION)--%--$(EXTVERSION).sql,$(UPGRADEABLE_VERSIONS))

DATA_built = \
  $(EXTENSION)--$(EXTVERSION).sql \
  $(UPGRADE_SCRIPTS_BUILT)
DATA         = $(wildcard sql/*--*.sql)
DOCS         = $(wildcard doc/*.md)
TESTS        = $(wildcard test/sql/*.sql)
REGRESS      = $(patsubst test/sql/%.sql,%,$(TESTS))
REGRESS_OPTS = --inputdir=test

all: $(EXTENSION)--$(EXTVERSION).sql

$(EXTENSION)--$(EXTVERSION).sql: sql/$(EXTENSION).sql $(META) Makefile
	sed -e 's|\$$Id\$$|$(REVISION)|' $< | \
	sed -e 's/@@VERSION@@/$(EXTVERSION)/' > $@

$(META): $(META).in Makefile
	sed -e 's/@@VERSION@@/$(EXTVERSION)/' $< > $@

$(EXTENSION).control: $(EXTENSION).control.in Makefile
	sed -e 's/@@VERSION@@/$(EXTVERSION)/' $< > $@

EXTRA_CLEAN = \
  $(LOCAL_BIN) \
	sql/$(EXTENSION)--$(EXTVERSION).sql \
	$(EXTENSION).control \
	$(META) upgrade-scripts

PGXS := $(shell pg_config --pgxs)
ifeq ($(PGXS),)
$(error "PGXS is empty")
endif
include $(PGXS)

$(UPGRADE_SCRIPTS_BUILT): upgrade-scripts

.PHONY: upgrade-scripts
upgrade-scripts: $(EXTENSION)--$(EXTVERSION).sql
	mkdir -p upgrade-scripts
	for OLD_VERSION in $(UPGRADEABLE_VERSIONS); do \
    cat $< > upgrade-scripts/$(EXTENSION)--$$OLD_VERSION--$(EXTVERSION).sql; \
  done
	# allow upgrading to same version (for same-version-but-different-revision)
	cat $< > upgrade-scripts/$(EXTENSION)--$(EXTVERSION)--$(EXTVERSION)next.sql
	cat $< > upgrade-scripts/$(EXTENSION)--$(EXTVERSION)next--$(EXTVERSION).sql

all: upgrade-scripts $(LOCAL_SHARE) $(LOCAL_BIN)

deb-check:
	#TODO: Verify that packages actually exist
	# Test postgresql dependent packages do NOT contain loader
	@for pkg in build-area/postgresql-*dbpatch*.deb; do \
		dpkg -c $$pkg > $$pkg.contents || break; \
		if grep -q loader $$pkg.contents; then  \
                echo "Package $$pkg contains loader" >&2 \
                && false; \
		fi; \
	done
	# Test postgresql-agnostic package DOES contain loader
	@for pkg in build-area/dbpatch*.deb; do \
		dpkg -c $$pkg > $$pkg.contents || break; \
			if grep -q loader $$pkg.contents; then  \
				:; \
			else \
				echo "Package $$pkg does NOT contain loader" >&2 \
				&& false; \
			fi; \
		done


# This is phony because it depends on env variables
.PHONY: test/sql/preparedb
test/sql/preparedb: test/sql/preparedb.in
	cat $< | \
	  if test "${PREPAREDB_UPGRADE}" = 1; then \
      if test -n "${PREPAREDB_UPGRADE_FROM}"; then \
        UPGRADE_FROM="version '${PREPAREDB_UPGRADE_FROM}'"; \
      else \
        UPGRADE_FROM=""; \
      fi; \
      sed -e 's/^--UPGRADE-- //' -e "s/@@FROM_VERSION@@/$$UPGRADE_FROM/"; \
	  elif test "${PREPAREDB_NOEXTENSION}" = 1; then \
      grep -v dbpatch; \
    else \
      cat; \
    fi | \
	  sed -e 's/@@VERSION@@/$(EXTVERSION)/' -e 's/@@FROM_VERSION@@//' > $@

installcheck: testdeps

installcheck-upgrade:
	PREPAREDB_UPGRADE=1 make installcheck

installcheck-loader: dbpatch-loader
	PREPAREDB_NOEXTENSION=1 make test/sql/preparedb
	dropdb --if-exists contrib_regression
	createdb contrib_regression
	PATH="$$PATH:$(LOCAL_BINDIR)" dbpatch-loader $(DBPATCH_LOADER_OPTS) contrib_regression
	pg_prove -d contrib_regression test/sql
	dropdb contrib_regression

installcheck-loader-noext: dbpatch-loader
	$(MAKE) installcheck-loader DBPATCH_LOADER_OPTS=--no-extension

check: check-noext

check-noext: dbpatch-loader
	PREPAREDB_NOEXTENSION=1 $(MAKE) test/sql/preparedb
	dropdb --if-exists contrib_regression
	createdb contrib_regression
	DBPATCH_EXT_DIR=.  ./dbpatch-loader --no-extension contrib_regression
	pg_prove -d contrib_regression test/sql
	dropdb contrib_regression

.PHONY: testdeps
testdeps: test/sql/preparedb

$(EXTENSION)-$(EXTVERSION).sql.tpl: $(EXTENSION)--$(EXTVERSION).sql Makefile sql/noextension.sql.in
	echo "BEGIN;" > $@
	cat sql/noextension.sql.in >> $@
	grep -v 'CREATE EXTENSION' $< \
  | grep -v 'pg_extension_config_dump' \
	>> $@
	echo "COMMIT;" >> $@

$(EXTENSION)-loader: $(EXTENSION)-loader.sh Makefile
	cat $< | sed 's|@@LOCAL_SHAREDIR@@|$(LOCAL_SHAREDIR)|' > $@
	chmod +x $@

install: local-install
uninstall: local-uninstall

local-install:
	$(INSTALL) -d $(DESTDIR)$(LOCAL_BINDIR)
	$(INSTALL) $(LOCAL_BIN) $(DESTDIR)$(LOCAL_BINDIR)
	$(INSTALL) -d $(DESTDIR)$(LOCAL_SHAREDIR)
	$(INSTALL) -m 644 $(LOCAL_SHARE) $(DESTDIR)$(LOCAL_SHAREDIR)

local-uninstall:
	for b in $(LOCAL_BIN); do rm -f $(DESTIDIR)$(LOCAL_BINDIR)/$$b; done
	for b in $(LOCAL_SHARE); do rm -f $(DESTIDIR)$(LOCAL_SHAREDIR)/$$b; done

dist: distclean $(DISTFILES)
	mkdir $(EXTENSION)-$(EXTVERSION)
	cp -r $(DISTFILES) $(EXTENSION)-$(EXTVERSION)
	zip -r $(EXTENSION)-$(EXTVERSION).zip $(EXTENSION)-$(EXTVERSION)
	rm -rf $(EXTENSION)-$(EXTVERSION)
