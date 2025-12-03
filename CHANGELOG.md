# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## 2.1.2 - 2025-12-03
### Changed
- Updated min sdk version to ^3.10.0
- Updated dependencies

## 2.1.1+1 - 2025-10-11
### Changed
- Update dependencies
- Update min dart sdk to 3.9.0

## 2.1.1 - 2025-03-16
### Changed
- Update dependencies
- Update min dart sdk to 3.7.0

## 2.1.0 - 2025-01-19
### Changed
- Added support for running against firebase emulator (#10, #11)
- Update dependencies
- Update min dart sdk to 3.6.0

### Fixed
- Fixed wrong payload format for profile updates (#10)

## 2.0.6 - 2024-06-04
### Changed
- Moved `FirebaseAccount.restore` to `FirebaseAuth.restoreAccount`

### Deprecated
- Deprecated `FirebaseAccount.restore` and `FirebaseAccount.apiRestore` in favor of `FirebaseAuth.restoreAccount`

### Fixed
- Fixed refresh timer not being canceled on `FirebaseAccount.dispose`

## 2.0.5 - 2024-05-21
### Changed
- Update dependencies
- Update min dart sdk to 3.4.0
- Modernize build configuration and ci integration

## 2.0.4 - 2023-06-16
### Changed
- Update dependencies
- Update min dart sdk to 3.0.0

## 2.0.3 - 2021-11-11
### Fixed
- Publishing error

## 2.0.2 - 2021-11-11
### Changed
- Fix some linter issues

### Fixed
- Removed errornous localId parameter from custom sign in responses (#5)

## 2.0.1 - 2021-05-04
### Added
- JavaScript/Web CI tests

### Changed
- Changed mocking framework to mocktail
- Improve build scripts

### Security
- Updated dependency requirements

## 2.0.0 - 2021-03-09
### Added
- Integration tests

### Changed
- Migrated to null-safety
- Explicit token refreshes no longer propagate errors to idTokenStream listeners

### Removed
- Logging integration

## 1.0.2 - 2021-02-02
### Changed
- Updated dependencies

## 1.0.1 - 2020-11-05
### Fixed
- Repair broken linter config
- Fixup code based on working lints

## 1.0.0 - 2020-10-22
### Added
- Full documentation for REST models
- Extended logging support

### Changed
- Use final members instead of read-only getters

### Fixed
- Fixed automatic deployments
- Exchange git hooks backend for improved git performance

## 0.1.1 - 2020-09-16
### Added
- Automatic deployment on new releases to pub.dev
- Automatic upload of release-docs to github pages
- Complete README

## 0.0.1 - 2020-09-04
### Added
- Initial release
