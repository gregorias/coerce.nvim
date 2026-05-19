# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog][kac], and this project adheres to
[Semantic Versioning][semver].

## Unreleased

### Added

### Changed

### Deprecated

### Removed

### Fixed

### Security

## 5.0.0 — 2026-05-19

### Added

- Added a vimdoc.
- Added `<Plug>` keymaps and Which Key expand bindings.

### Changed

- Decoupled the mode type from its keymap (`coerce.Mode`) and moved to its own
  module.
- Moved case registry into a global module.

### Deprecated

### Removed

- Removed keymap setting.
  The user is now responsible for configuring their keymaps, which is a best
  practice.
- Removed keymap registry

### Fixed

### Security

## 4.3.0 — 2026-05-13

### Added

- Added a health check.

### Changed

### Deprecated

### Removed

### Fixed

### Security

## 4.2.1 — 2026-04-20

### Added

- Started a changelog.

### Changed

### Deprecated

### Removed

### Fixed

### Security

[semver]: https://semver.org/spec/v2.0.0.html
[kac]: https://keepachangelog.com/en/1.1.0/
