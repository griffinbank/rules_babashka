def _babashka_deps_jar_impl(ctx):
    bb_toolchain = ctx.toolchains["@rules_babashka//toolchain:toolchain_type"].babashka
    java_toolchain = ctx.toolchains["@bazel_tools//tools/jdk:runtime_toolchain_type"].java_runtime

    ctx.actions.run(
        inputs = java_toolchain.files.to_list() + [
            ctx.file.bb_edn,
            bb_toolchain.binary,
        ],
        outputs = [
            ctx.outputs.output
        ],
        env = {
            "JAVA_HOME": str(java_toolchain.java_home),
        },
        executable = bb_toolchain.binary,
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
        "output": attr.output(mandatory = True)
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
