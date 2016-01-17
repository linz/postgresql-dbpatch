/*
 * Author: jpalmer@linz.govt.nz
 * Created at: 2016-01-17 18:56:19 +1300
 *
 */

--
-- This is a example code genereted automaticaly
-- by pgxn-utils.

SET client_min_messages = warning;

BEGIN;

-- You can use this statements as
-- template for your extension.

DROP OPERATOR #? (text, text);
DROP FUNCTION dbpatch(text, text);
DROP TYPE dbpatch CASCADE;
COMMIT;
