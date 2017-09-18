EXTVERSION   = 1.0.2
EXTREVISION  = $(shell test -d .git && which git > /dev/null && git describe --always)

META         = META.json
EXTENSION    = $(shell grep -m 1 '"name":' $(META).in | sed -e 's/[[:space:]]*"name":[[:space:]]*"\([^"]*\)",/\1/')

SED = sed

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
all: sql/$(EXTENSION)--$(EXTVERSION).sql

sql/$(EXTENSION)--$(EXTVERSION).sql: sql/$(EXTENSION).sql $(META)
	$(SED) -e 's/$$Id$$/$(EXTREVISION)/' $< > $@

$(META): $(META).in
	$(SED) -e 's/@@VERSION@@/$(EXTVERSION)/' $< > $@

$(EXTENSION).control: $(EXTENSION).control.in
	$(SED) -e 's/@@VERSION@@/$(EXTVERSION)/' $< > $@
 
EXTRA_CLEAN = sql/$(EXTENSION)--$(EXTVERSION).sql $(EXTENSION).control $(META)
endif

PGXS := $(shell $(PG_CONFIG) --pgxs)
include $(PGXS)
