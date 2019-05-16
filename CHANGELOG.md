# Change Log

All notable changes for the PostgreSQL dbpatch extension are documented 
in this file.

## [1.4.1dev] - 2019-MM-DD
### Fixed
- Installation of upgrade scripts on `make install` (#44)
- `dbpatch-loader` handling of --version switch (#46)

## [1.4.0] - 2019-01-14
### Improved
- Add stdout support in `dbpatch-loader` (#35)

## [1.3.0] - 2018-10-18
### Changed
- Loader script now installs by default in /usr/local/bin/
  and does not depend on `pg_config` anymore (#22)
### Added
- New `reapply_patch` function (#30)

## [1.2.0] - 2017-11-15
### Changed
- Allow loading dbpatch w/out system support (#13)
### Added
- New `dbpatch-loader` utility script (#14)
- New `dbpatch_version()` function (#17)

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

