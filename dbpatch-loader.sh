#!/bin/sh

TGT_SCHEMA=
TGT_DB=
EXT_MODE=on
EXT_NAME=dbpatch
EXT_DIR=`pg_config --sharedir`/extension/
TPL_FILE=
VER=

if test -n "$DBPATCH_EXT_DIR"; then
  EXT_DIR="$DBPATCH_EXT_DIR"
fi

while test -n "$1"; do
  if test "$1" = "--no-extension"; then
    EXT_MODE=off
  elif test "$1" = "--version"; then
    VER=$1; shift
  elif test -z "${TGT_DB}"; then
    TGT_DB=$1
  elif test -z "${TGT_SCHEMA}"; then
    TGT_SCHEMA=$1
  else
    echo "Unused argument $1" >&2
  fi
  shift
done

if test -z "$TGT_DB"; then
  echo "Usage: $0 [--no-extension] [--version <ver>] <dbname> [<schema>]" >&2
  exit 1
fi

export PGDATABASE=$TGT_DB

if test -z "${VER}"; then
# TPL_FILE is expected to have the following format:
#   dbpatch-1.4.0dev.sql.tpl
  VER=`ls ${EXT_DIR}/${EXT_NAME}-*.sql.tpl | sed "s/^.*${EXT_NAME}-//;s/\.sql\.tpl//" | tail -1`
  if test -z "${VER}"; then
    echo "Cannot find template loader, maybe set DBPATCH_EXT_DIR?" >&2
    exit 1
  fi
fi

TPL_FILE=${EXT_DIR}/${EXT_NAME}-${VER}.sql.tpl

if test -z "$TGT_SCHEMA"; then
  TGT_SCHEMA=`psql -tAc "select current_schema()"`
  if test -z "$TGT_SCHEMA"; then exit 1; fi # failed connection to db ?
fi

echo "Loading ver ${VER} in ${TGT_DB}.${TGT_SCHEMA} (EXT_MODE ${EXT_MODE})";

if test "${EXT_MODE}" = 'on'; then
  cat <<EOF | psql -tA
DO \$\$
  DECLARE
    rec record;
  BEGIN

    SELECT n.nspname, e.extversion
      INTO rec
      FROM pg_catalog.pg_extension e,
           pg_catalog.pg_namespace n
      WHERE e.extname = 'dbpatch'
        AND n.oid = e.extnamespace
    ;

    IF rec IS NULL THEN
      IF NOT EXISTS (
        SELECT * FROM pg_catalog.pg_namespace
        WHERE nspname = '${TGT_SCHEMA}'
      )
      THEN
        CREATE SCHEMA "${TGT_SCHEMA}";
      END IF;
      CREATE EXTENSION ${EXT_NAME}
        VERSION '${VER}'
        SCHEMA ${TGT_SCHEMA};
    ELSE
      IF rec.nspname != '${TGT_SCHEMA}' THEN
        RAISE EXCEPTION 'dbpatch is already installed in schema %',
          rec.nspname;
      END IF;
      ALTER EXTENSION ${EXT_NAME} UPDATE TO '${VER}';
    END IF;
  END
\$\$ LANGUAGE 'plpgsql';
EOF
else
  cat ${TPL_FILE} | sed "s/@extschema@/${TGT_SCHEMA}/g" |
  psql --set ON_ERROR_STOP=1 > /dev/null
fi
