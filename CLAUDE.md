# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

RGL (Ruby Graph Library) is a framework for graph data structures and algorithms,
inspired by the C++ Boost Graph Library (BGL). First commit: August 2002.

The library is **stable and mature** — no new features unless requested by the community.
Contributions focus on maintenance: bug fixes, dependency updates, and modernization.

See README.md for design principles and algorithm overview.

## Commands

```bash
bundle install                                           # Install dependencies
bundle exec rake test                                    # Run all tests (default rake task)
bundle exec ruby -Ilib -Itest test/dijkstra_test.rb      # Single test file
bundle exec ruby -Ilib -Itest test/dijkstra_test.rb -n test_method_name  # Single test method
bundle exec rake yard                                    # Generate YARD docs
bundle exec rake TAGS                                    # Emacs TAGS
```

## Architecture

The core abstraction is the `RGL::Graph` module (an Enumerable of vertices) with two
abstract iterators: `each_vertex` and `each_adjacent`. All algorithms are built on top
of these. Concrete graph classes include `AdjacencyGraph` and `DirectedAdjacencyGraph`
via `MutableGraph`.

### Key Design Patterns

- **Graph = module, not class.** Any object that implements `each_vertex` + `each_adjacent` can be a graph.
- **Visitor pattern** for algorithm events. Algorithms call `handle_*` methods on visitors; users set event handlers via `set_*_event_handler` blocks.
- **Vertex coloring** for traversals: `:WHITE` (undiscovered), `:GRAY` (in queue/stack), `:BLACK` (finished).
- **Any Ruby object can be a vertex.** There is no vertex class.

## Test Framework

Tests use **test-unit** (not minitest). Pattern: `test/*_test.rb`.

`test/test_helper.rb` patches `Array#add` as alias for `push` so Arrays can serve as
edgelist class in tests.

GraphViz must be installed for DOT-related tests.

## Dependencies

**Runtime:** `stream` (iterator protocol), `pairing_heap` (priority queue for Dijkstra/Prim), `rexml` (GraphML import).

**Development:** `rake`, `yard`, `test-unit`, `simplecov`.

## Release Process

- Versioning in `lib/rgl/version.rb`
- Changelog managed by [release-please](https://github.com/googleapis/release-please) on push to `master`
- Gem publishing is manual via `gh workflow run publish-gem.yml` (requires RubyGems OTP)
- Commits follow [Conventional Commits](https://www.conventionalcommits.org/) format

## Code Style

- No RuboCop configured; follow existing patterns
- Use `require` (not `require_relative`) for internal requires — standard for gems
- YARD for documentation (`@param`, `@return`, `@example`, `@see`)
- `# frozen_string_literal: true` in new files (migration in progress, see #151)
