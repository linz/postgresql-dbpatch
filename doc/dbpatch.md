dbpatch
=======

Synopsis
--------

    #= CREATE EXTENSION dbpatch;
    CREATE EXTENSION

    #= SELECT apply_patch('myapp 1.0.1 - create foo table', 'CREATE TABLE foo (bar TEXT)');

    NOTICE:  Applying patch myapp 1.0.1 - create foo table
     apply_patch 
    -------------
     t
    (1 row)


Description
-----------

PostgreSQL database patch change management extension. This extension supports
conducting database changes and deploying them in a robust and automated way.
Useful when you need to robustly apply database changes to multiple installations
(e.g dev, test, prod) and keep track off the changes.

Usage
-----

Applying a patch to the database is easy - just run the "apply_patch" function:

    #= SELECT apply_patch('myapp 1.0.1 - create foo table', 'CREATE TABLE foo (bar TEXT)');
    
    NOTICE:  Applying patch myapp 1.0.1 - create foo table
     apply_patch 
    -------------
     t
    (1 row)
    
The two parameters for the function are:

patch_name - The unique name for the patch. This name must not have been used
before. Generally it's best to follow a naming convention which includes an,
application name, version number and reason for applying the patch. e.g. 
"app_name version - description"

patch_sql - The SQL for execution against the database. Can be any SQL statement
that the current user has rights to run.

The result of the function is a boolean true or false indicated that the application
was successful. If you try to apply a patch with the same name as a patch that has
already been applied it will return false. e.g 

    #= SELECT apply_patch('myapp 1.0.1 - create foo table', 'CREATE TABLE foo (bar TEXT)');
    
    NOTICE:  Patch myapp 1.0.1 - create foo table is already applied
     apply_patch 
    -------------
     f
    (1 row)

If the SQL statement can not be executed a general exception with be thrown.

An overloaded version of the "apply_patch" function allows you to apply
multiple SQL statements in one patch using an array of SQL statements
as the second parameter:

    #= SELECT apply_patch(
           'myapp 1.0.1 - create foo table and index',
           ARRAY[
               'CREATE TABLE foo (bar TEXT)',
               'CREATE INDEX ON foo USING BTREE (bar)'
           ]
       );
    
    NOTICE:  Applying patch myapp 1.0.1 - create foo table and index
     t
    (1 row)

A `reapply_patch` function exists to force re-application of a
previously applied patch. This may be useful if the patch code
depends on data which changes over time. Example:

    #= SELECT apply_patch(
               'myapp 1.0.1 - reindex foo',
               'REINDEX TABLE foo'
           );
    NOTICE:  Applying patch myapp 1.0.1 - reindex foo
     apply_patch
    -------------
     t
    (1 row)

    #= SELECT reapply_patch('myapp 1.0.1 - reindex foo');
    NOTICE:  Applying patch myapp 1.0.1 - reindex foo
     reapply_patch
    ---------------
     t
    (1 row)

Configuration table
-------------------

The extension creates a configuration table called "applied_patches" which
records the patches that have been applied to the database. Whenever a new
patch is run it is recorded in this table and the datetime it was applied. 
When databases using the dbpatch extension are dumped the applied_patches table
data is also dumped to ensure the patch history data is persisted.

**WARNING**: If the extension is dropped by the user the applied_patches configuration
table and it's data will also be dropped, meaning the patch history will be lost.
Only drop the extension if you are sure the history data is no longer required.

Installing into specific schema
--------------------------------

There are two ways to install the extension: into the default public schema; or
into a specific schema. It is recommended that you install dbpatch into a
dedicated schema to simplify management. This example creates a schema for the 
patch extension to be installed into and then installs the extension:

    CREATE SCHEMA IF NOT EXISTS _patches;
    COMMENT ON SCHEMA _patches IS 'Schema for patch change management extension';
    GRANT USAGE ON SCHEMA _patches TO public;
    CREATE EXTENSION dbpatch SCHEMA _patches;

Migrate existing dbpatch installation
-------------------------------------

If you already have the dbpatch functions and config table installed in your
database not using the PostgreSQL extension you can upgrade it using the following
command:

    CREATE EXTENSION dbpatch FROM unpackaged SCHEMA _patches;

This example will upgrade the patch management software to an extension from
the existing "_patches" schema.

Support
-------

This library is stored in an open [GitHub
repository](http://github.com/linz/postgresql-dbpatch). Feel free to fork and
contribute! Please file bug reports via [GitHub
Issues](http://github.com/linz/postgresql-dbpatch/issues/).

Author
------

[Jeremy Palmer](http://www.linz.govt.nz)

Copyright and License
---------------------

Copyright 2016 Crown copyright (c) Land Information New Zealand and the New
Zealand Government. All rights reserved

This software is provided as a free download under the 3-clause BSD License. See
the LICENSE file for more details.


