def _babashka_toolchain_impl(ctx):
    toolchain_info = platform_common.ToolchainInfo(
        target = ctx.attr.binary,
        executable = ctx.executable.binary,
        raw_executable = ctx.executable.raw_binary,
        raw_target = ctx.attr.raw_binary,
        runtime_files = ctx.attr.runtime_files,
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
            cfg = "exec",
        ),
        "raw_binary": attr.label(
            mandatory = True,
            executable = True,
            allow_single_file = True,
            cfg = "exec",
        ),
        "runtime_files": attr.label(
            mandatory = True,
            cfg = "exec",
        ),
    },
)
