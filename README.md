[![Build Status](https://secure.travis-ci.org/linz/postgresql-dbpatch.svg)](http://travis-ci.org/linz/postgresql-dbpatch)
[![Actions Status](https://github.com/linz/postgresql-dbpatch/workflows/test/badge.svg?branch=master)](https://github.com/linz/postgresql-dbpatch/actions)

# postgresql-dbpatch

PostgreSQL database patch change management extension. This extension supports conducting database
changes and deploying them in a robust and automated way.

## Installation

To build it, install and check installation, just do this:

    make
    make install
    make installcheck

If you encounter an error such as:

    "Makefile", line 8: Need an operator

You need to use GNU make, which may well be installed on your system as `gmake`:

    gmake
    gmake install
    gmake installcheck

If you encounter an error such as:

    make: pg_config: Command not found

Be sure that you have `pg_config` installed and in your path. If you used a package management
system such as RPM to install PostgreSQL, be sure that the `-devel` package is also installed. If
necessary tell the build process where to find it:

    env PG_CONFIG=/path/to/pg_config make && make installcheck && make install

And finally, if all that fails (and if you're on PostgreSQL 8.1 or lower, it likely will), copy the
entire distribution directory to the `contrib/` subdirectory of the PostgreSQL source tree and try
it there without `pg_config`:

    env NO_PGXS=1 make && make installcheck && make install

If you encounter an error such as:

    ERROR:  must be owner of database regression

You need to run the test suite using a super user, such as the default "postgres" super user:

    make installcheck PGUSER=postgres

## Building Debian packaging

Build the Debian packages using the following command:

    make deb

The number of packages built will depend on the number of supported PostgreSQL versions on your
system. Make sure to install the postgresql-server-dev-all package, and consider adding the
postgresql.org apt repository to get the most versions out of it (see
https://wiki.postgresql.org/wiki/Apt

## Installing the extension

Once dbpatch is installed, you can add it to a database. If you're running PostgreSQL 9.1.0 or
greater, it's a simple as connecting to a database as a super user and running:

    CREATE EXTENSION dbpatch;

If you want to install dbpatch into a specific schema run:

    CREATE EXTENSION dbpatch my_schema;

If you've upgraded your cluster to PostgreSQL 9.1 and already had dbpatch installed, you can upgrade
it to a properly packaged extension with:

    CREATE EXTENSION dbpatch;

For versions of PostgreSQL less than 9.1.0, you'll need to run the installation script:

    psql -d mydb -f /path/to/pgsql/share/contrib/dbpatch.sql

If you want to install dbpatch and all of its supporting objects into a specific schema, use the
`PGOPTIONS` environment variable to specify the schema, like so:

    PGOPTIONS=--search_path=extensions psql -d mydb -f dbpatch.sql

To simplify the above tasks you may use the `dbpatch-loader` script which is installed in
`pg_config --bindir`. Syntax is:

    dbpatch-loader [--no-extension] [--version <ver>] <dbname> [<schema>]

## Dependencies

The `dbpatch` extension has no dependencies other than PostgreSQL and PL/PgSQL

## Linting

Prerequisites: [Nix](https://nixos.org/download.html)

Run `nix-shell --pure --run 'pre-commit run --all-files'`.

## License

This project is under 3-clause BSD License, except where otherwise specified. See the LICENSE file
for more details.
