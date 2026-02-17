# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is MetaZ, an mp4 metadata editor for macOS. It was created as a reimplementation of MetaX after the original project stopped being updated and had broken functionality with web services.

## Development Environment Setup

To build and develop in this repository:

1. Install Xcode and Carthage
2. Initialize submodules:
   ```
   git submodule update --init
   ```
3. Bootstrap dependencies with Carthage:
   ```
   carthage bootstrap
   ```

## Build Process

The project uses Xcode for building. The main Xcode project is located at:
- `MetaZ.xcodeproj/`

To build the project:
- Use Xcode directly to compile the project
- The project can be built using `xcodebuild` commands
- The CI system uses `xcodebuild -target Package` for building

## Key Directories

- `App/` - Main application source code
- `Plugins/` - Plugin implementations for various metadata services
- `Scripts/` - Build scripts and automation tools
- `Externals/` - External dependencies
- `Framework/` - Custom frameworks used by the application
- `build/` - Build artifacts and intermediate files

## Technology Stack

- macOS native application
- Objective-C and AppleScript
- Carthage for dependency management
- Sparkle for auto-updating
- Git submodules for external dependencies

## Testing

There are no explicit test files visible in the repository structure. Development should follow standard macOS application development practices with Xcode's testing tools.

## Contribution Workflow

The project follows GitHub Flow:
1. Create a feature branch in your fork
2. Make your change with documentation as appropriate
3. Run and test a release build before submitting a pull request
4. Submit a pull request from your branch
5. Someone with commit access will review and merge the code

## Release Process

Releases are built using:
- `xcodebuild` commands
- Scripts in the `Scripts/` directory
- GitHub releases with Sparkle auto-update support
- The build system is configured in `.github/build.yml` for CI/CD

## Important Files

- `README.markdown` - Project introduction and build instructions
- `compile-applescripts.sh` - Script for compiling AppleScript files
- `Cartfile` and `Cartfile.resolved` - Carthage dependency definitions
- `.github/build.yml` - Continuous integration configuration