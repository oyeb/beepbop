# Contributing

## Set up `git` hooks

The repo includes some handy `git` hooks under `.scripts/`:

* `pre-commit` Runs the `format --check-formatted` task.
* `post-commit` Runs a customised `credo` check.

We strongly recommend that you set up these git hooks on your machine by:
```sh
# in the project root!
ln -sf ../../.scripts/pre-commit .git/hooks/pre-commit
ln -sf ../../.scripts/post-commit .git/hooks/post-commit
```

> Note that the CI will fail your PR if you dont run `mix format` in the project
> root.

## Styling

We follow
[lexmag/elixir-style-guide](https://github.com/lexmag/elixir-style-guide) and
[rrrene/elixir-style-guide](https://github.com/rrrene/elixir-style-guide) (both
overlap a lot).

## PR submission checklist

* [ ] `git` hooks had been set up before development.
* [ ] You ran `mix dialyzer` and no new warnings were emitted (especially due to
      your changes).
