# Contributing to SQueaL

First off, thanks for taking the time to contribute! 🎉

## How Can I Contribute?

### Reporting Bugs

- Check the [issue tracker](https://github.com/s4cha/Squeal/issues) to see if the bug has already been reported.
- If not, open a new issue with a clear title and description.
- Include a minimal reproducible example and the Swift/macOS version you're using.

### Suggesting Features

- Open an issue describing the feature and why it would be useful.
- Discuss your idea before starting work to make sure it aligns with the project's direction.

### Pull Requests

1. Fork the repository.
2. Create a feature branch from `main` (`git checkout -b my-feature`).
3. Make your changes.
4. Add or update tests as needed.
5. Make sure the project builds and tests pass:
   ```
   swift build
   swift test
   ```
6. Commit your changes with a clear, descriptive commit message.
7. Push to your fork and open a pull request against `main`.

## Development Setup

- **Swift 6.0+** is required.
- Clone the repo and open it in Xcode or build from the command line:
  ```
  git clone https://github.com/s4cha/Squeal.git
  cd Squeal
  swift build
  ```

## Code Style

- Follow existing conventions in the codebase.
- Keep code clear and well-documented.
- Prefer small, focused pull requests over large sweeping changes.

## Testing

- Add tests for any new functionality.
- Tests live in the `SquealTests` target. Run them with `swift test`.

## Code of Conduct

Be kind, respectful, and constructive. We're all here to build something useful together.

## License

By contributing, you agree that your contributions will be licensed under the [MIT License](LICENSE).
