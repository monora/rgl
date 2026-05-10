# Contributing to Ruby Graph Library

Thank you for your interest in contributing to rgl! We welcome all
contributions, whether they're big or small. Here are some guidelines to get you
started.

## Code of Conduct

Please note that this project is released with a
[Contributor Code of Conduct](../CODE_OF_CONDUCT.md). By participating in this
project you agree to abide by its terms.

## Development Setup

### Ruby

We recommend [rbenv](https://github.com/rbenv/rbenv) with
[ruby-build](https://github.com/rbenv/ruby-build) to manage Ruby versions:

```bash
# Install rbenv and ruby-build (see https://github.com/rbenv/rbenv#installation)
git clone https://github.com/rbenv/rbenv.git ~/.rbenv
git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(rbenv init - bash)"' >> ~/.bashrc
source ~/.bashrc

# Install the required Ruby version (reads .ruby-version automatically)
rbenv install
```

### Dependencies

```bash
gem install bundler
bundle install
```

### GraphViz

DOT/GraphViz related tests require a local GraphViz installation:

```bash
# Debian/Ubuntu
sudo apt-get install graphviz

# macOS
brew install graphviz
```

### Running Tests

```bash
bundle exec rake test                                            # full test suite
bundle exec ruby -Ilib -Itest test/dijkstra_test.rb             # single file
bundle exec ruby -Ilib -Itest test/dijkstra_test.rb -n test_X   # single test
```

## How to Contribute

1. Fork the repository.
2. Create a branch for your changes: `git checkout -b my-feature-branch`
3. Make your changes and commit them with descriptive commit messages.
4. Ensure that tests pass by running `bundle exec rake` locally.
5. Push your changes to your fork: `git push origin my-feature-branch`
6. Submit a pull request with your changes.

## Commit Guidelines

We follow the [Conventional
Commits](https://www.conventionalcommits.org/en/v1.0.0/) guidelines for commit
messages in this repository. Please ensure that all commit messages follow the
format:

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

Where:

- `<type>`: The type of change being made (e.g. feat, fix, docs, style, refactor, test, chore)
- `<scope>` (optional): The scope of the change (e.g. component name, file name)
- `<description>`: A brief description of the change
- `[optional body]`: A more detailed description of the change
- `[optional footer(s)]`: Any important information related to the change, such
  as a breaking change note

By following these guidelines, it will be easier to understand the purpose of
each commit and track changes over time.

Please note that we may ask you to amend your commit message(s) if they do not
follow these guidelines.

## Issue Tracker

If you find a bug or want to request a new feature, please create an issue in
the GitHub issue tracker. Please provide as much detail as possible, including
steps to reproduce the issue (if applicable).

## Code Reviews

All submissions, including submissions by project members, require review. We
use GitHub pull requests for this purpose. Consult [GitHub
Help](https://help.github.com/articles/about-pull-requests/) for more
information on using pull requests.

## Release Process

Releases are managed by maintainers with push access to `master`.

### How it works

1. Merging a PR to `master` triggers the
   [release-please](https://github.com/googleapis/release-please) workflow,
   which automatically creates or updates a release PR. The release PR bumps
   the version in `lib/rgl/version.rb` and updates `CHANGELOG.md` based on
   [Conventional Commits](https://www.conventionalcommits.org/).

2. When ready to release, merge the release PR.

3. Publish the gem to RubyGems.org:

   ```bash
   gh workflow run publish-gem.yml
   ```

   No OTP or API key is needed. Publishing uses
   [RubyGems Trusted Publishing (OIDC)](https://guides.rubygems.org/trusted-publishing/),
   which grants a short-lived token automatically via GitHub Actions.

### RubyGems ownership

Current gem owners on RubyGems.org can be listed with:

```bash
gem owner rgl
```

To add a new owner (requires existing owner credentials):

```bash
gem owner rgl --add new-maintainer@example.com
```

### Trusted Publisher setup

The `publish-gem.yml` workflow is registered as a Trusted Publisher on
RubyGems.org under the `monora/rgl` repository. If the workflow file is ever
renamed, the Trusted Publisher entry at
`https://rubygems.org/gems/rgl/trusted_publishers` must be updated accordingly.

## License

By contributing, you agree that your contributions will be licensed under the
[LICENSE](../LICENSE).
