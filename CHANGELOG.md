# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Fixed
- Clicking a toast's action while `max_toasts` toasts are shown no longer hides the oldest toast for good when the action sends a new toast

## [0.3.1] - 2026-10-21

### Fixed
- No dead-code warnings from `flash_group` on Elixir 1.20

## [0.3.0] - 2026-10-21

### Added
- `theme="system"`: follows the page theme (`data-theme` or a `.dark` class), or the OS color scheme when the page sets none (#11)
- `expanded` option to always show toasts expanded (#13)
- Opt-in connection toasts for LiveView disconnects, with `connection_toasts`, `client_error_title`, `client_error_message`, `server_error_title` and `server_error_message` (#12)
- `Toast.flash_group/1` for controller pages that aren't LiveViews
- The `id` attr on `toast_group` sets the group's DOM id

### Changed
- Styles are scoped to `.live-toast-group`, so they no longer apply to markup outside the toast group
- `theme="light"` stays light under a `.dark` or `data-theme="dark"` parent. Use `theme="system"` to follow the page
- Hovering the group pauses every toast, and each one resumes with the time it had left
- Closed toasts fade out before they are removed
- Light theme text meets WCAG AA contrast

### Fixed
- `put_toast` toasts are kept across `push_navigate` and `redirect`, work in `mount/3` and from LiveComponents (#10)
- `update_toast` updates the toast (#15)
- No inline styles, so Toast works under a strict Content Security Policy (#14)
- Rich colors apply in the dark theme
- Toast actions use the action stored on the server instead of the event name sent by the browser
- `max_toasts` removes extra toasts on the server, so they no longer come back
- `animation_duration` no longer resets to 400ms after a LiveView patch
- An updated toast behind the front one no longer replays its entry animation
- Clicking toast buttons while disconnected no longer throws errors
- Closing a flash message sends its events once
- Clicks between flash messages reach the page
- Theme frameworks such as daisyUI no longer paint a background behind toasts or override their colors
- `put_toast` titles and descriptions show in the static flash list
- Setup docs work on Phoenix 1.8

## [0.2.0] - 2025-07-28

### Added
- HTML rendering support - Toasts can now render HTML content with the `html` option
- Configurable animation duration - Animation timing can be customized (defaults to 400ms)

### Fixed
- DaisyUI style conflict documentation

## [0.1.0] - 2025-07-18

Initial release

[View on Hex.pm](https://hex.pm/packages/toast)

### Added
- Server-rendered toast notifications for Phoenix LiveView
- Initial implementation
