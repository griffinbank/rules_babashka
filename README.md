# Babashka rules for [Bazel](https://bazel.build)

Status: Alpha.

## Features
- babashka toolchains for multiple execution platforms

## Setup

Add the following to your `WORKSPACE`:

```skylark
RULES_BABASHKA_SHA = $CURRENT_SHA1
http_archive(
    name = "rules_babashka",
    strip_prefix = "rules_babashka-%s" % RULES_BABASHKA_SHA,
    url = "https://github.com/griffinbank/rules_babashka/archive/%s.zip" % RULES_BABASHKA_SHA
)

load("@rules_babashka//:repo.bzl", "babashka")

BABASHKA_VERSION="1.12.196"

babashka(
    name = "babashka-local",
    version = BABASHKA_VERSION,
)
register_toolchains("@babashka-local//:toolchain")
```

You can then use the `bb` binary within a `genrule` as a tool:

```skylark
genrule(
    name = "bb-rule",
    srcs = ["bb.edn"],
    outs = ["output.edn"],
    tools = ["@babashka-local//:bin/bb"],
    cmd = """
        $(execpath @babashka-local//:bin/bb) task:bb
    """
)
```

If you need to use an alternate Babashka to the execution environment, to build into a deployment artifact, you can override the `arch` and `os`:

```skylark
babashka(
    name = "babashka-linux-x86",
    arch = "amd64",
    os = "linux",
    version = BABASHKA_VERSION,
)
```

and then reference the `bb` binary from the alternate version.

## Testing

If your script has tests defined via task, as per https://blog.michielborkent.nl/babashka-test-runner.html, you can define those tests to be run as a Bazel rule:

```skylark
babashka_test(
    name = "example-test",
    srcs = [
        ":srcs",
        ":tests",
    ],
    bb_edn = ":bb.edn",
)
```

The above assumes your Babashka task is simply called `test`. If that is not correct (e.g. if you have called it `test:bb`) you can override the expected task name:

```skylark
babashka_test(
    name = "example-test",
    srcs = [
        ":srcs",
        ":tests",
    ],
    bb_edn = ":bb.edn",
    task_name = "test:bb",
)
```

## Script dependencies

Use the `babashka_deps_jar` rule within a `BUILD` file to generate a jar of all the dependencies referenced in `bb.edn`:

```skylark
load("@rules_babashka//deps:deps.bzl", "babashka_deps_jar")

babashka_deps_jar(
    name = "deps",
    bb_edn = "bb.edn",
)
```

The output will be called `{name}.jar`. If that's not suitable, it can be overridden with the `output` parameter:

```skylark
load("@rules_babashka//deps:deps.bzl", "babashka_deps_jar")

babashka_deps_jar(
    name = "deps-jar",
    bb_edn = "bb.edn",
    output = "deps.jar",
)
```
## Self-contained jar

Use the `babashka_jar` rule within a `BUILD` file to generate a jar of script and dependencies from `bb.edn`, that can
be invoked via `bb -jar ${jar_file}`:

```skylark
load("@rules_babashka//deps:deps.bzl", "babashka_jar")

babashka_jar(
    name = "script",
    bb_edn = "bb.edn",
    main_ns = "example.core",
)
```

The output will be called `{name}.jar`. If that's not suitable, it can be overridden with the `output` parameter:

```skylark
load("@rules_babashka//deps:deps.bzl", "babashka_jar")

babashka_jar(
    name = "script-jar",
    bb_edn = "bb.edn",
    main_ns = "example.core",
    output = "script.jar",
)
```
