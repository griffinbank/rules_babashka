load("@bazel_tools//tools/jdk:toolchain_utils.bzl", "find_java_runtime_toolchain")

def _bb_env(bb_toolchain):
    """Returns (env_prefix, tools_depset) for running bb in run_shell actions."""
    # raw_executable is at bin/pkg/bb relative to the repo root
    bb_path = bb_toolchain.raw_executable.path
    repo_root = bb_path[:bb_path.rfind("/bin/pkg/bb")]
    env_prefix = (
        'export CLJ_CONFIG="$(pwd)/{root}/.clojure"\n'
        + 'export DEPS_CLJ_TOOLS_DIR="$(pwd)/{root}/.deps.clj/ClojureTools"\n'
        + 'export GITLIBS="$(pwd)/{root}/.gitlibs"\n'
        + 'BB_MVN_REPO="$(pwd)/{root}/.m2/repository"\n'
    ).format(root = repo_root)
    return env_prefix, [bb_toolchain.runtime_files[DefaultInfo].files]

def _babashka_deps_jar_impl(ctx):
    bb_toolchain = ctx.toolchains["@rules_babashka//toolchain:toolchain_type"]
    java_toolchain = find_java_runtime_toolchain(ctx, ctx.attr._host_javabase)

    bb_env, bb_tools = _bb_env(bb_toolchain)

    bb_deps_edn = ctx.actions.declare_file("bb_deps.edn")
    conversion_script = """
        (let [config (-> \"{bb_edn}\" slurp clojure.edn/read-string)
              deps-only (select-keys config [:deps])]
          (clojure.pprint/pprint deps-only (clojure.java.io/writer \"{output}\")))
    """.format(
        bb_edn = ctx.file.bb_edn.path,
        output = bb_deps_edn.path
    )

    ctx.actions.run_shell(
        inputs = [ctx.file.bb_edn],
        tools = bb_tools,
        outputs = [bb_deps_edn],
        command = bb_env + """{bb} -Sdeps '{{:mvn/local-repo "'$BB_MVN_REPO'"}}' -e '{script}'""".format(
            bb = bb_toolchain.raw_executable.path,
            script = conversion_script.replace("'", "'\\''"),
        ),
    )

    uberjar_exec = bb_env + """
        export JAVA_HOME="$(pwd)/{java_home}"
        {bb} -Sdeps '{{:mvn/local-repo "'$BB_MVN_REPO'"}}' --config "{bb_edn}" uberjar "{output}"
    """.format(
        java_home = str(java_toolchain.java_home),
        bb = bb_toolchain.raw_executable.path,
        bb_edn = bb_deps_edn.path,
        output = ctx.outputs.output.path,
    )

    ctx.actions.run_shell(
        inputs = [bb_deps_edn] + java_toolchain.files.to_list(),
        tools = bb_tools,
        outputs = [ctx.outputs.output],
        command = uberjar_exec
    )

_babashka_deps_jar = rule(
    implementation = _babashka_deps_jar_impl,
    toolchains = [
        "@bazel_tools//tools/jdk:runtime_toolchain_type",
        "@rules_babashka//toolchain:toolchain_type",
    ],
    attrs = {
        "bb_edn": attr.label(
            mandatory = True,
            allow_single_file = True,
            default = "bb.edn"
        ),
        "output": attr.output(mandatory = True),
        "_host_javabase": attr.label(
            default = Label("@bazel_tools//tools/jdk:current_java_runtime"),
        ),
    },
)

def babashka_deps_jar(**kwargs):
    if kwargs.get("output"):
        _babashka_deps_jar(
            **kwargs,
        )
    else:
        _babashka_deps_jar(
            output = "{name}.jar".format(**kwargs),
            **kwargs,
        )

def _babashka_jar_impl(ctx):
    bb_toolchain = ctx.toolchains["@rules_babashka//toolchain:toolchain_type"]
    java_toolchain = find_java_runtime_toolchain(ctx, ctx.attr._host_javabase)

    bb_env, bb_tools = _bb_env(bb_toolchain)

    uberjar_exec = bb_env + """
        export JAVA_HOME="$(pwd)/{java_home}"
        {bb} -Sdeps '{{:mvn/local-repo "'$BB_MVN_REPO'"}}' --config "{bb_edn}" uberjar "{output}" -m "{main_ns}"
    """.format(
        java_home = str(java_toolchain.java_home),
        bb = bb_toolchain.raw_executable.path,
        bb_edn = ctx.file.bb_edn.path,
        output = ctx.outputs.output.path,
        main_ns = ctx.attr.main_ns
    )

    ctx.actions.run_shell(
        inputs = [ctx.file.bb_edn] + ctx.files.srcs + java_toolchain.files.to_list(),
        tools = bb_tools,
        outputs = [ctx.outputs.output],
        command = uberjar_exec,
    )

_babashka_jar = rule(
    implementation = _babashka_jar_impl,
    toolchains = [
        "@bazel_tools//tools/jdk:runtime_toolchain_type",
        "@rules_babashka//toolchain:toolchain_type",
    ],
    attrs = {
        "bb_edn": attr.label(
            mandatory = True,
            allow_single_file = True,
            default = "bb.edn"
        ),
        "srcs": attr.label_list(allow_files = True),
        "main_ns": attr.string(
            mandatory = True
        ),
        "output": attr.output(mandatory = True),
        "_host_javabase": attr.label(
            default = Label("@bazel_tools//tools/jdk:current_java_runtime"),
        ),
    },
)

def babashka_jar(**kwargs):
    if kwargs.get("output"):
        _babashka_jar(
            **kwargs,
        )
    else:
        _babashka_jar(
            output = "{name}.jar".format(**kwargs),
            **kwargs,
        )

def _babashka_test_impl(ctx):
    bb_toolchain = ctx.toolchains["@rules_babashka//toolchain:toolchain_type"]
    test_executable = ctx.actions.declare_file(ctx.label.name + "_test")

    ctx.actions.write(
        output = test_executable,
        is_executable = True,
        content = """#!/usr/bin/env bash
            bb=$(realpath "{bb}")
            cd $(dirname "{bb_edn}")
            $bb --config $(basename "{bb_edn}") {task_name}
        """.format(
            bb = bb_toolchain.executable.short_path,
            bb_edn = ctx.file.bb_edn.path,
            task_name = ctx.attr.task_name
        ),
    )

    runfiles = ctx.runfiles(
        files = [bb_toolchain.executable, ctx.file.bb_edn] +
            ctx.files.srcs
    ).merge(bb_toolchain.target[DefaultInfo].default_runfiles)

    return [
        DefaultInfo(
            executable = test_executable,
            runfiles = runfiles,
        )
    ]

_babashka_test = rule(
    implementation = _babashka_test_impl,
    toolchains = [
        "@rules_babashka//toolchain:toolchain_type",
    ],
    test = True,
    attrs = {
        "bb_edn": attr.label(
            mandatory = True,
            allow_single_file = True,
            default = "bb.edn"
        ),
        "srcs": attr.label_list(allow_files = True),
        "task_name": attr.string(default = "test"),
    },
)

def babashka_test(**kwargs):
    _babashka_test(
        **kwargs,
    )
