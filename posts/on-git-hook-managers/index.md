
Using [git-hooks](https://git-scm.com/book/en/v2/Customizing-Git-Git-Hooks) is a
common method used to enforce constraints, standards, and static quality of a
code bases. By checking for things at the point of the "pre-commit" git hook it
allows for a faster feedback loop for the developer, rather than waiting for it
to fail in CI.

It is common to use a **hook manager** to automate the installation of the hooks
into `.git/hooks` and to pull them from either a remote repository of common
hook implementations or generate them from a simple kind of configuration.

This page ([githooks.com](githooks.com)) provides a nice third-party overview of
git hooks along with the most commonly used hook managers.

I was a little late in adopting git-hooks myself and have finally sat down and
figured out a good workflow for my tastes.

At least in my little bubble the most common hook manager is
[pre-commit](https://pre-commit.com/). I've created repository templates that
use it, bootstrap it, and integrate it with CI such that it is by default
reproduced locally to avoid version drifts [^1].

## The Problem with `pre-commit`

I found `pre-commit` to be pretty frustrating most of the time. When I imagined
a hook manager I expected that it would be a pretty simple piece of software
that simply took some commands to run, or potentially downloaded some scripts
from a git repo. `pre-commit` on the other hand is much more complicated and
actually takes on the responsibility for downloading the hook scripts from a
special "package" format, creating individual virtual environments for them, and
a host of other options for controlling their behavior. All of which can break
in non-obvious and confusing ways [^2].

I lived with the inconveniences for a while as it seemed that everyone around me
was happily using it and I must have been missing something. Unfortunately, I
don't think this to be true anymore and I'm convinced that `pre-commit` is just
adopted in cargo cult fashion. Perhaps there is even a conflation that
`pre-commit` is **git hooks**.

Regardless the straw that broke this camel's back was setting up Python type
checking to be run as a git hook. Because `pre-commit` hooks are run in their
own contained virtual environment they cannot easily import either local code
you are working on (for type stubs) and if you want to inject third-party type
stubs you need to explicitly write them all down in the `pre-commit`
configuration. The issue is that I already have all this done using other tools
or scripts which are the primary entrypoints for working on the project. I don't
want to have to maintain a duplicate listing just for my hooks to work. Managing
dependencies is hard enough without having another place to duplicate them.

This is really an issue with separation of concerns and composability.
Personally, I take great care and choose my tools such that I can generate
reproducible development environments such that they are composable with many
other tools. `pre-commit` is in opposition to this and wants to control
everything. This is useful for simple static analysis tools like `black` which
do not need to be installed alongside your code and can act on your code as
simple text blobs. However, when you want to do more complex things that require
pulling in extra dependencies and actually importing builds of your code
`pre-commit` just ceases to be simple and is in your way.

Secondly, because `pre-commit` thinks it runs the show it ends up infecting the
rest of your development automation. I typically give all my projects some kind
of "task runner" which gives a high-level and abstracted entrypoint to doing
repetitive tasks. This typically takes the form of a `Makefile`, but I've also
used and can recommend [invoke](https://github.com/pyinvoke/invoke) and
[pydoit](https://pydoit.org/) to accomplish the same thing.

Here is an example of a `Makefile` with some common tasks without using
`pre-commit`:

```Makefile
clean: ## Clean temporary files, directories etc.
	hatch clean
	rm -rf dist .pytest_cache .coverage
	find . -type f -name "*.pyc" -print -delete
.PHONY: clean

format: ## Run source code formatters manually.
	hatch run -- black src tests
	hatch run -- isort src tests
.PHONY: docstrings

validate: format-check lint docstring typecheck ## Run all linters, type checks, static analysis, etc.
.PHONY: validate

format-check: ## Run code formatting checks
	hatch run -- black --check src tests
	hatch run -- isort --check src tests
.PHONY: format-check

lint: ## Run only the linters (non-autoformatters).
	hatch run -- flake8 src tests
.PHONY: lint

docstring-check: ## Run docstring coverage only.
	hatch run -- interrogate src tests
.PHONY: docstring

typecheck: ## Run only the type checker (requires mypy)
	hatch run -- mypy --strict src tests/utils
.PHONY: typecheck

```

In this scenario `make validate` is the canonical way to run all the various
linters. This should be the only entrypoint to these tasks so that we don't get
duplication and drift in different environments, e.g. locally, CI, and
git-hooks.

Using `pre-commit` however I cannot call these `Makefile` tasks in any practical
means. So what ends up happening is that you need to replace commands in the
tasks with explicit calls to `pre-commit` to run things for you. E.g.:

`.pre-commit-config.yaml`
```yaml
repos:
- repo: https://github.com/psf/black
  rev: 22.6.0
  hooks:

  # run the formatting
  - id: black
    alias: black-format
    files: ^(src|tests)
    name: "Format: black"

  # just check
  - id: black
    alias: black-check
    args: [--check]
    files: ^(src|tests)
    name: "Check: black"
    # don't run unless done manually
    stages:
      - manual
```

Notice the rigamarole you have to go through to run a single hook type in
multiple ways.

`Makefile`
```Makefile
format: ## Run source code formatters manually.
	pre-commit run --all-files black-format
	pre-commit run --all-files isort-format
.PHONY: docstrings
```

So now `pre-commit` is not just the thing that runs things on your behalf at
specific time (the essence of what git hooks are) it is now an integral part of
how you manage dependencies for your project.

## The Solutions

At this point I decided I needed something better. I want a hook manager to be:

1. Very easy to install and bootstrap for newcomers to a project.
2. Ability to run arbitrary commands and integrate with any virtual environment
   manager and task runner I'm already using.
   
For 1 this is very important because you do not want to frustrate people before
they actually start working on your code. At this stage it should be so easy
that you should be able to write a task or shell script that can bootstrap the
manager. So ideally that means a single executable file.
   
I narrowed it down to two hook managers that seemed to accomplish this:

- [lefthook](https://github.com/evilmartians/lefthook)
- [Autohook](https://github.com/Autohook/Autohook)

I ultimately decided on `lefthook` but `Autohook` was very tempting as well.
`Autohook` is a single `bash` script that you can just download. You operate it
by maintaining a `hooks` directory that you dump executables into, and control
which hook stage and order they run in with symlinks. All `Autohook` does is
place these into `.git/hooks`. I don't think it gets any easier than that.
Looking at the code as well its just a bit more robust version of the shell
script you would have written yourself without a plethora of hook managers to
choose from.

What I liked about `lefthook` was that its a Go project and comes as a single
binary executable which is easy to download and immediately use. It should also
be easier to support on platforms like Windows since there is no reliance on a
POSIX-like shell. It also provides packages for just about every package
manager, and even for language specific ones like `pip` and `npm`.

Second, its dead simple in its operation. You write a `lefthook.yml` file which
specifies the hooks you want to use. Here is mine:

`lefthook.yml`
```yaml
pre-commit:

  parallel: true
  commands:

    format-check:
      run: make format-check

    lint:
      run: make lint

    docstrings:
      run: make docstring-check

    typecheck:
      run: make typecheck
```

The top-level groups are for each hook stage and here I am only configuring the
"pre-commit" stage. Under the `commands` section I list out the name of each
hook and how to run it. Since I already have the business logic for these in my
task runner its as simple as wiring them up!

This is great, its a hook manager thats doing only one thing, managing hooks,
and doing it well. It didn't require any refactoring of anything else in my
project, it runs the hooks in parallel and provides a bunch of other useful
options to control its behavior.

## Conclusion

Thats it! I've not even used
[lefthook](https://github.com/evilmartians/lefthook) for a full day and its
already much improved my life:

- I now can easily do complex typechecking with a git pre-commit hook,
- I don't need to run my hook manager in CI, just my task runner,
- I don't need to worry about yet-another system with caches and virtualenvs,
- I can run hooks more quickly and in parallel

I highly recommend it and encourage you to question cargo cult adoption of
sub-par tooling like `pre-commit` in other areas.


[^1]: A lot of times I see impatient developer's just ignore these kinds of
    issues and get by just fine for a long while. I have the unique (mis)fortune
    of typically running into these kinds of issues very quickly if not
    immediately and this was the same for using `pre-commit` in my CI pipelines.
    So thats just to say that, yes you really do need to worry about this as it
    will bite you sooner or later.

[^2]: For [example](https://github.com/econchick/interrogate/issues/60)
