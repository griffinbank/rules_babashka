BabashkaToolchainInfo = provider(
    fields = {
        "binary": "path to the binary"
    }
)

def _babashka_toolchain_impl(ctx):
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
