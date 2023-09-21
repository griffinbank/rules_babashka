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

BABASHKA_VERSION="1.3.184"

babashka(
    name = "babashka-local",
    version = BABASHKA_VERSION,
)
register_toolchains("@babashka-local//:toolchain")
```

You can then use the `bb` binary within a `genrule` as a tool:

```
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

```
babashka(
    name = "babashka-linux-x86",
    arch = "amd64",
    os = "linux",
    version = BABASHKA_VERSION,
)
```

and then reference the `bb` binary from the alternate version.

