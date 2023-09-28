def _babashka_toolchain_impl(ctx):
    toolchain_info = platform_common.ToolchainInfo(
        target = ctx.attr.binary,
        executable = ctx.executable.binary,
    )

    return [
        toolchain_info,
    ]

babashka_toolchain = rule(
    implementation = _babashka_toolchain_impl,
    attrs = {
        "binary": attr.label(
            mandatory = True,
            executable = True,
            cfg = "host",
        ),
    },
)
