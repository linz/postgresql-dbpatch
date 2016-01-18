-- complain if script is sourced in psql, rather than via CREATE EXTENSION
\echo Use "CREATE EXTENSION dbpatch FROM unpackaged" to load this file. \quit

ALTER EXTENSION dbpatch ADD TABLE applied_patches;
ALTER EXTENSION dbpatch ADD FUNCTION apply_patch(p_patch_name TEXT, p_patch_sql TEXT);
ALTER EXTENSION dbpatch ADD FUNCTION apply_patch(p_patch_name TEXT, p_patch_sql TEXT[]);

