EXTVERSION   = 1.1.0dev
EXTREVISION  = $(shell test -d .git && which git > /dev/null && git describe --always)

META         = META.json
EXTENSION    = $(shell grep -m 1 '"name":' $(META).in | sed -e 's/[[:space:]]*"name":[[:space:]]*"\([^"]*\)",/\1/')

TGT_VERSION=$(subst dev,,$(EXTVERSION))
PREV_VERSION=$(shell ls sql/dbpatch--*--*.sql | sed 's/.*$(EXTENSION)--.*--//;s/\.sql//' | grep -Fv $(TGT_VERSION) | sort -n | tail -1)

SED = sed

UPGRADEABLE_VERSIONS = 1.0.0 1.0.1

DATA_built = $(EXTENSION)--$(EXTVERSION).sql $(META) \
  $(wildcard upgrade-scripts/*--*.sql)
DATA         = $(wildcard sql/*--*.sql)
DOCS         = $(wildcard doc/*.md)
TESTS        = $(wildcard test/sql/*.sql)
REGRESS      = $(patsubst test/sql/%.sql,%,$(TESTS))
REGRESS_OPTS = --inputdir=test --load-language=plpgsql
#
# Uncoment the MODULES line if you are adding C files
# to your extention.
#
#MODULES      = $(patsubst %.c,%,$(wildcard src/*.c))
PG_CONFIG    = pg_config
PG91         = $(shell $(PG_CONFIG) --version | grep -qE " 8\.| 9\.0" && echo no || echo yes)

ifeq ($(PG91),yes)
all: $(EXTENSION)--$(EXTVERSION).sql

$(EXTENSION)--$(EXTVERSION).sql: sql/$(EXTENSION).sql $(META)
	$(SED) -e 's/$$Id$$/$(EXTREVISION)/' $< > $@

$(META): $(META).in
	$(SED) -e 's/@@VERSION@@/$(EXTVERSION)/' $< > $@

$(EXTENSION).control: $(EXTENSION).control.in
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
