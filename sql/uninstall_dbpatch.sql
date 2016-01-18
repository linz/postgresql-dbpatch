--
-- NOTE: use this script only with PostgreSQL before 9.1
-- Starting from PostgreSQL 9.1 use DROP EXTENSION dbpatch instead.
--

DROP FUNCTION apply_patch(p_patch_name TEXT, p_patch_sql TEXT);
DROP FUNCTION apply_patch(p_patch_name TEXT, p_patch_sql TEXT[]);

DROP TABLE applied_patches;

