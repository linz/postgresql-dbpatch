--------------------------------------------------------------------------------

-- postgresql-dbpatch - PostgreSQL database patch change management extension
--
-- Copyright 2016 Crown copyright (c)
-- Land Information New Zealand and the New Zealand Government.
-- All rights reserved
--
-- This software is released under the terms of the new BSD license. See the 
-- LICENSE file for more information.
--
--------------------------------------------------------------------------------

-- complain if script is sourced in psql, rather than via CREATE EXTENSION
\echo Use "CREATE EXTENSION dbpatch" to load this file. \quit

CREATE TABLE applied_patches (
    patch_name TEXT NOT NULL PRIMARY KEY,
    datetime_applied TIMESTAMP NOT NULL DEFAULT now(),
    patch_sql TEXT[] NOT NULL
);

COMMENT ON TABLE applied_patches
  IS 'dbpatch versioning data';
  
SELECT pg_catalog.pg_extension_config_dump('applied_patches', '');

CREATE OR REPLACE FUNCTION apply_patch(
    p_patch_name TEXT,
    p_patch_sql  TEXT[]
)
RETURNS
    BOOLEAN AS
$$
-- $Id$
DECLARE
    v_sql TEXT;
BEGIN
    -- Make sure that only one patch can be applied at a time
    LOCK TABLE @extschema@.applied_patches IN EXCLUSIVE MODE;

    IF EXISTS (
        SELECT patch_name
        FROM   @extschema@.applied_patches
        WHERE  patch_name = p_patch_name
    )
    THEN
        RAISE INFO 'Patch % is already applied', p_patch_name;
        RETURN FALSE;
    END IF;
    
    RAISE INFO 'Applying patch %', p_patch_name;
    
    BEGIN
        FOR v_sql IN SELECT * FROM unnest(p_patch_sql) LOOP
            RAISE DEBUG 'Running SQL: %', v_sql;
            EXECUTE v_sql;
        END LOOP;
    EXCEPTION
        WHEN others THEN
            RAISE EXCEPTION 'Could not applied % patch using %. ERROR: %',
                p_patch_name, v_sql, SQLERRM;
    END;

    INSERT INTO  @extschema@.applied_patches(
        patch_name,
        datetime_applied,
        patch_sql
    )
    VALUES(
        p_patch_name,
        now(),
        p_patch_sql
    );
    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION apply_patch(
    p_patch_name TEXT,
    p_patch_sql  TEXT
)
RETURNS
    BOOLEAN AS
$$
    -- $Id$
    SELECT @extschema@.apply_patch($1, ARRAY[$2])
$$
    LANGUAGE sql;


