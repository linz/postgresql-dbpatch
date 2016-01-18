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
--
-- NOTE: use this script only with PostgreSQL before 9.1
-- Starting from PostgreSQL 9.1 use DROP EXTENSION dbpatch instead.
--

DROP FUNCTION apply_patch(p_patch_name TEXT, p_patch_sql TEXT);
DROP FUNCTION apply_patch(p_patch_name TEXT, p_patch_sql TEXT[]);

DROP TABLE applied_patches;

