# Contributing to Toast

Thank you for your interest in contributing to Toast! This guide will help you get started with contributing to the project.

## Table of Contents

- [Development Setup](#development-setup)
- [Development Workflow](#development-workflow)
- [Testing](#testing)
- [Code Style](#code-style)
- [Submitting Changes](#submitting-changes)
- [Reporting Issues](#reporting-issues)
- [Feature Requests](#feature-requests)

## Development Setup

1. **Fork and clone the repository**
   ```bash
   git clone https://github.com/YOUR_USERNAME/toast.git
   cd toast
   ```

2. **Install dependencies**
   ```bash
   mix deps.get
   ```

3. **Set up the demo application**
   ```bash
   cd demo
   mix setup
   ```

## Development Workflow

Toast includes a demo application in the `demo/` directory that makes development easier. We've created Mix tasks to streamline the development process:

### Working with Local Changes

1. **Switch to local development mode**
   ```bash
   cd demo
   mix mode.local
   ```
   This creates a symlink from `demo/deps/toast` to your local toast project, allowing you to see changes immediately.

2. **Check current mode**
   ```bash
   mix mode
   ```
   This shows whether you're using the local version or the published Hex package.

3. **Switch to published mode**
   ```bash
   mix mode.published
   ```
   This uses the published Hex package, useful for testing the actual release.

### Running the Demo

```bash
cd demo
mix phx.server
```

Visit [`localhost:4000`](http://localhost:4000) to see the demo application with live examples of toast notifications.

## Testing

### Running Tests

```bash
# Run tests in the main project
mix test

# Run tests in the demo
cd demo && mix test
```

### Testing Your Changes

1. Make your changes to the toast library
2. Ensure you're in local mode (`mix mode.local` in the demo directory)
3. Test your changes in the demo application
4. Write or update tests as needed

## Code Style

- Follow standard Elixir conventions
- Run the formatter before committing: `mix format`
- Write descriptive commit messages

### JavaScript Code

- The JavaScript hook is in `assets/js/toast.js`
- Follow existing code patterns and style

### CSS Styles

- Styles are in `assets/css/toast.css`

## Submitting Changes

1. **Create a feature branch from `dev`**
   ```bash
   git checkout dev
   git pull origin dev
   git checkout -b feature/your-feature-name
   ```

2. **Make your changes**
   - Write clear, focused commits
   - Include tests for new functionality
   - Update documentation as needed

3. **Ensure all tests pass**
   ```bash
   mix test
   mix format --check-formatted
   ```

4. **Push your branch and create a pull request**
   - **IMPORTANT: Target the `dev` branch, not `main`**
   - Provide a clear description of your changes
   - Reference any related issues
   - Include screenshots for UI changes

### Pull Request Guidelines

- **Target Branch**: All PRs should target the `dev` branch
- **Title**: Use a clear, descriptive title
- **Description**: Explain what changes you made and why
- **Testing**: Describe how you tested your changes
- **Breaking Changes**: Clearly note any breaking changes

## Reporting Issues

When reporting issues, please include:

- Elixir/Erlang versions (`elixir --version`)
- Phoenix version
- LiveView version
- Steps to reproduce the issue
- Expected behavior
- Actual behavior
- Any error messages or logs

## Feature Requests

We welcome feature requests! Please:

- Check existing issues to avoid duplicates
- Provide a clear use case
- Explain why the feature would be valuable
- If possible, suggest an implementation approach

## Publishing (Maintainers Only)

When ready to publish a new version:

1. Update the version in `mix.exs`
2. Update the CHANGELOG.md
3. From the demo directory, run:
   ```bash
   cd demo
   mix toast_publish
   ```
   This automatically switches the demo to use the published version before publishing.

## Questions?

Feel free to open an issue for any questions about contributing. We're here to help!

Thank you for contributing to Toast! 🍞
