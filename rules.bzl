load("@bazel_tools//tools/jdk:toolchain_utils.bzl", "find_java_runtime_toolchain")

def _babashka_deps_jar_impl(ctx):
    bb_toolchain = ctx.toolchains["@rules_babashka//toolchain:toolchain_type"]
    java_toolchain = find_java_runtime_toolchain(ctx, ctx.attr._host_javabase)

    tools, input_manifests = ctx.resolve_tools(tools = [bb_toolchain.target])

    ctx.actions.run(
        inputs = [ctx.file.bb_edn] + java_toolchain.files.to_list(),
        input_manifests = input_manifests,
        tools = tools,
        outputs = [ctx.outputs.output],
        env = {
            "JAVA_HOME": str(java_toolchain.java_home)
        },
        executable = bb_toolchain.executable,
        arguments = [
            "--config",
            ctx.file.bb_edn.path,
            "uberjar",
            ctx.outputs.output.path,
        ],
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
