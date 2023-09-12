BabashkaToolchainInfo = provider(
    fields = {
        "binary": "path to the binary"
    }
)

def _babashka_toolchain_impl(ctx):
    ctx.actions.run_shell(
        inputs = [ctx.executable.binary],
        outputs = [ctx.actions.declare_file("foo")],
        execution_requirements={k: "" for k in ctx.attr.tags},
        command = ctx.executable.binary.path,
        arguments = ["clojure", "-version"],
    )

    return [
        platform_common.ToolchainInfo(
            binary = ctx.executable.binary
        )
    ]

babashka_toolchain = rule(
    implementation = _babashka_toolchain_impl,
    attrs = {
        "binary": attr.label(
            mandatory=True,
            executable=True,
            allow_single_file=True,
            cfg="host"
        )
    }
)
