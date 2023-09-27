def _babashka_deps_jar_impl(ctx):
    bb_toolchain = ctx.toolchains["@rules_babashka//toolchain:toolchain_type"]
    java_toolchain = ctx.toolchains["@bazel_tools//tools/jdk:runtime_toolchain_type"]

    ctx.actions.run(
        inputs = [
            ctx.file.bb_edn,
        ],
        tools = [
            bb_toolchain.default.default_runfiles.files,
            java_toolchain.java_runtime.files,
        ],
        outputs = [
            ctx.outputs.output
        ],
        env = {
            "JAVA_HOME": str(java_toolchain.java_runtime.java_home),
        },
        executable = bb_toolchain.babashka.binary,
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
