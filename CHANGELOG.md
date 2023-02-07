# Change Log

All notable changes for the PostgreSQL dbpatch extension are documented in this file.

## [X.Y.Z] - YYYY-MM-DD

### Removed

Drop Ubuntu 18.04 support after
[GitHub dropped their runner support](https://github.com/actions/runner-images/issues/6002).

## [1.8.8] - 2022-12-20

### Improved

Release for Ubuntu 22.04 (Jammy)

## [1.8.7] (broken because of https://github.com/linz/linz-software-repository/issues/118) - 2022-06-01

### Improved

Release for Ubuntu 22.04 (Jammy)

## [1.8.6] (broken because of https://github.com/linz/linz-software-repository/issues/118) - 2022-05-30

### Improved

Release for Ubuntu 22.04 (Jammy)

## [1.8.5] - 2022-05-26

### Fixed

No-op release to make sure the latest Git tag is in the history of origin/master.

## [1.8.4] - 2022-05-03

### Fixed

- Bump EXTVERSION _after_ release

## [1.8.3] - 2022-05-03

### Fixed

- Force pushing changes to origin remote

## [1.8.2] - 2022-05-03

### Fixed

- Hard-code extension version

## [1.8.1] - 2022-02-02

### Improved

- Build on Ubuntu 20.04 (Focal)

## [1.8.0] - 2022-01-27

### Improved

- Add linting

## [1.7.0] - 2022-01-12

### Improved

- Updated supported versions of Postgres

## [1.6.0] - 2021-01-05

### Added

- [debian] provide a postgresql-agnostic package "dbpatch"

## [1.5.0] - 2019-07-29

### Improved

- Progress message from `dbpatch-loader` (#47)
- Send patch application messages to NOTICE channel instead of INFO (#48)
- Allow overriding `PG_CONFIG` via env variable

### Fixed

- Handling of --version loader switch
- Make sure all upgrade scripts are always installed
- ALlow upgrading from 1.4.0

## [1.4.1dev] - 2019-MM-DD

### Fixed

- Installation of upgrade scripts on `make install` (#44)
- `dbpatch-loader` handling of --version switch (#46)

## [1.4.0] - 2019-01-14

### Improved

- Add stdout support in `dbpatch-loader` (#35)

## [1.3.0] - 2018-10-18

### Changed

- Loader script now installs by default in /usr/local/bin/ and does not depend on `pg_config`
  anymore (#22)

### Added

- New `reapply_patch` function (#30)

## [1.2.0] - 2017-11-15

### Changed

- Allow loading dbpatch w/out system support (#13)

### Added

- New `dbpatch-loader` utility script (#14)
- New `dbpatch_version()` function (#17)

## [1.1.1] - 2017-09-26

### Fixed

- Do not install META.json
- Fix revision detection from git tags containing slashes

## [1.1.0] - 2017-09-18

### Changed

- Generate upgrade scripts (#10)
- Fix install against PostgreSQL 9.5+ (#4)
- Embed git revision in function sources (#6)

## [1.0.1] - 2016-05-02

### Changed

- Improve markup formatting and documentation
- Improved version numbering management

## [1.0.0] - 2016-01-18

### Added

- Initial release
