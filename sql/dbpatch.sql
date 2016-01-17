/*
 * Author: jpalmer@linz.govt.nz
 * Created at: 2016-01-17 18:56:19 +1300
 *
 */

--
-- This is a example code genereted automaticaly
-- by pgxn-utils.

SET client_min_messages = warning;

-- If your extension will create a type you can
-- do somenthing like this
CREATE TYPE dbpatch AS ( a text, b text );

-- Maybe you want to create some function, so you can use
-- this as an example
CREATE OR REPLACE FUNCTION dbpatch (text, text)
RETURNS dbpatch LANGUAGE SQL AS 'SELECT ROW($1, $2)::dbpatch';

-- Sometimes it is common to use special operators to
-- work with your new created type, you can create
-- one like the command bellow if it is applicable
-- to your case

CREATE OPERATOR #? (
	LEFTARG   = text,
	RIGHTARG  = text,
	PROCEDURE = dbpatch
);
