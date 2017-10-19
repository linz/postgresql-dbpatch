
EXTVERSION = 1.2.0dev
REVISION  = $(shell test -d .git && which git > /dev/null && git describe --always)

META         = META.json
EXTENSION    = $(shell grep -m 1 '"name":' $(META).in | sed -e 's/[[:space:]]*"name":[[:space:]]*"\([^"]*\)",/\1/')

TEMPLATE_SQL_INSTALLDIR = $(DESTDIR)/usr/share/dbpatch/sql/

TGT_VERSION=$(subst dev,,$(EXTVERSION))
PREV_VERSION=$(shell ls sql/dbpatch--*--*.sql | sed 's/.*$(EXTENSION)--.*--//;s/\.sql//' | grep -Fv $(TGT_VERSION) | sort -n | tail -1)

SED = sed

UPGRADEABLE_VERSIONS = 1.0.0 1.0.1 1.1.0dev 1.1.0

SCRIPTS_built = $(EXTENSION)-loader

# This is a workaround for a bug in "install" rule in
# PostgreSQL 9.4 and lower
SCRIPTS = $(SCRIPTS_built)

DATA_built = \
  $(EXTENSION)--$(EXTVERSION).sql \
  $(EXTENSION)-$(EXTVERSION).sql.tpl \
  $(wildcard upgrade-scripts/*--*.sql)
DATA         = $(wildcard sql/*--*.sql)
DOCS         = $(wildcard doc/*.md)
TESTS        = $(wildcard test/sql/*.sql)
REGRESS      = $(patsubst test/sql/%.sql,%,$(TESTS))
REGRESS_OPTS = --inputdir=test --load-language=plpgsql
REGRESS_PREP = testdeps

#
# Uncoment the MODULES line if you are adding C files
# to your extention.
#
#MODULES      = $(patsubst %.c,%,$(wildcard src/*.c))
PG_CONFIG    = pg_config
PG91         = $(shell $(PG_CONFIG) --version | grep -qE " 8\.| 9\.0" && echo no || echo yes)

ifeq ($(PG91),yes)
all: $(EXTENSION)--$(EXTVERSION).sql

$(EXTENSION)--$(EXTVERSION).sql: sql/$(EXTENSION).sql $(META) Makefile
	$(SED) -e 's|\$$Id\$$|$(REVISION)|' $< | \
	$(SED) -e 's/@@VERSION@@/$(EXTVERSION)/' > $@

$(META): $(META).in Makefile
	$(SED) -e 's/@@VERSION@@/$(EXTVERSION)/' $< > $@

$(EXTENSION).control: $(EXTENSION).control.in Makefile
	$(SED) -e 's/@@VERSION@@/$(EXTVERSION)/' $< > $@
 
EXTRA_CLEAN = \
	sql/$(EXTENSION)--$(EXTVERSION).sql \
	$(EXTENSION).control \
	$(META) upgrade-scripts
endif

PGXS := $(shell $(PG_CONFIG) --pgxs)
include $(PGXS)

.PHONY: upgrade-scripts
upgrade-scripts: $(EXTENSION)--$(EXTVERSION).sql
	mkdir -p upgrade-scripts
	for OLD_VERSION in $(UPGRADEABLE_VERSIONS); do \
    cat $< > upgrade-scripts/$(EXTENSION)--$$OLD_VERSION--$(EXTVERSION).sql; \
  done
	# allow upgrading to same version (for same-version-but-different-revision)
	cat $< > upgrade-scripts/$(EXTENSION)--$(EXTVERSION)--$(EXTVERSION)next.sql
	cat $< > upgrade-scripts/$(EXTENSION)--$(EXTVERSION)next--$(EXTVERSION).sql

all: upgrade-scripts

deb:
	pg_buildext updatecontrol
	dpkg-buildpackage -us -uc -b


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
      $(SED) -e 's/^--UPGRADE-- //' -e "s/@@FROM_VERSION@@/$$UPGRADE_FROM/"; \
	  elif test "${PREPAREDB_NOEXTENSION}" = 1; then \
      grep -v dbpatch; \
    else \
      cat; \
    fi | \
	  $(SED) -e 's/@@VERSION@@/$(EXTVERSION)/' -e 's/@@FROM_VERSION@@//' > $@

installcheck-upgrade:
	PREPAREDB_UPGRADE=1 make installcheck

installcheck-loader: dbpatch-loader
	PREPAREDB_NOEXTENSION=1 make test/sql/preparedb
	dropdb --if-exists contrib_regression
	createdb contrib_regression
	`pg_config --bindir`/dbpatch-loader $(DBPATCH_LOADER_OPTS) contrib_regression
	$(pg_regress_installcheck) $(REGRESS_OPTS) --use-existing $(REGRESS)
	dropdb contrib_regression

installcheck-loader-noext: dbpatch-loader
	$(MAKE) installcheck-loader DBPATCH_LOADER_OPTS=--no-extension

check: check-noext

check-noext: dbpatch-loader
	PREPAREDB_NOEXTENSION=1 $(MAKE) test/sql/preparedb
	dropdb --if-exists contrib_regression
	createdb contrib_regression
	DBPATCH_EXT_DIR=.  ./dbpatch-loader --no-extension contrib_regression
	$(pg_regress_installcheck) $(REGRESS_OPTS) --use-existing $(REGRESS)
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
	cat $< > $@
	chmod +x $@
