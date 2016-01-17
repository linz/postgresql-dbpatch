\set ECHO 0
BEGIN;
\i sql/dbpatch.sql
\set ECHO all

-- You should write your tests

SELECT dbpatch('foo', 'bar');

SELECT 'foo' #? 'bar' AS arrowop;

CREATE TABLE ab (
    a_field dbpatch
);

INSERT INTO ab VALUES('foo' #? 'bar');
SELECT (a_field).a, (a_field).b FROM ab;

SELECT (dbpatch('foo', 'bar')).a;
SELECT (dbpatch('foo', 'bar')).b;

SELECT ('foo' #? 'bar').a;
SELECT ('foo' #? 'bar').b;

ROLLBACK;
