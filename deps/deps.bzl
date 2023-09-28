load("@bazel_tools//tools/jdk:toolchain_utils.bzl", "find_java_runtime_toolchain")

def _babashka_deps_jar_impl(ctx):
    bb_toolchain = ctx.toolchains["@rules_babashka//toolchain:toolchain_type"]
    java_toolchain = find_java_runtime_toolchain(ctx, ctx.attr._host_javabase)

    tools, input_manifests = ctx.resolve_tools(tools = [bb_toolchain.target])

    ctx.actions.run(
        inputs = [ctx.file.bb_edn] + java_toolchain.files.to_list(),
        input_manifests = input_manifests,
        tools = tools,
        outputs = [
            ctx.outputs.output
        ],
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
            mandatory=True,
            allow_single_file=True,
            default="bb.edn"
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
