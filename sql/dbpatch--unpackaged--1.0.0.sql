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

ALTER EXTENSION dbpatch ADD TABLE applied_patches;
ALTER EXTENSION dbpatch ADD FUNCTION apply_patch(p_patch_name TEXT, p_patch_sql TEXT);
ALTER EXTENSION dbpatch ADD FUNCTION apply_patch(p_patch_name TEXT, p_patch_sql TEXT[]);

