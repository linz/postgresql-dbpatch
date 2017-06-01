\set VERBOSITY terse
BEGIN;

CREATE EXTENSION dbpatch;

SELECT apply_patch('test patch 1', ARRAY['SELECT 1', 'SELECT 2']);
SELECT apply_patch('test patch 2', 'SELECT 1');
SELECT apply_patch('test patch 2', 'SELECT 1');
SELECT apply_patch('test bad patch SQL', 'SELET 1');

ROLLBACK;

