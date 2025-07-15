# Toast Test Suite

This directory contains tests for the Toast toast notification system.

## Test Structure

### Elixir Tests

- `toast_test.exs` - Unit tests for the main Toast module
  - Toast struct creation and validation
  - API functions (send_toast, update_toast, clear_toast)
  - Toast building logic and ID generation

- `toast/live_component_test.exs` - Tests for the LiveComponent
  - Module interface verification
  - LiveComponent behavior checks

- `toast/components_test.exs` - Tests for UI components
  - Toast component rendering
  - Icon rendering
  - Component exports

## Running Tests

```bash
# Run all tests
mix test

# Run specific test file
mix test test/toast_test.exs

# Run with coverage
mix test --cover

# Run in watch mode
mix test.watch
```

## Test Coverage

The test suite covers:

1. **API Testing**
   - All public functions
   - Edge cases and error handling
   - Default values and overrides

2. **Component Testing**
   - Rendering with different props
   - Accessibility attributes
   - CSS classes and data attributes

## Writing New Tests

When adding new features, ensure you:

1. Add unit tests for any new functions
2. Update component tests for new rendering logic

## Test Helpers

- `build_test_toast/3` - Creates test toast structs
- `render_component_to_string/1` - Renders components to HTML strings
