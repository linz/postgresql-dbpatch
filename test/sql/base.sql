\set ECHO none
\i test/sql/preparedb
BEGIN;

SELECT 't1', apply_patch('test patch 1', ARRAY['SELECT 1', 'SELECT 2']);
SELECT 't2', apply_patch('test patch 2', 'SELECT 1');
SELECT 't3', apply_patch('test patch 2', 'SELECT 1');
SELECT 't4', apply_patch('test bad patch SQL', 'SELET 1');

ROLLBACK; BEGIN;

SELECT no_plan();

SELECT has_function( 'dbpatch_version' );

ROLLBACK;

