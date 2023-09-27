BabashkaInfo = provider(
    fields = {
        "binary": "path to the wrapper that should be used for all in-Bazel actions",
    }
)

def _babashka_toolchain_impl(ctx):
    bb = ctx.executable.binary

    wrapper = ctx.actions.declare_file("bin/bb")
    ctx.actions.symlink(
        output = wrapper,
        target_file = bb,
        is_executable = True,
    )

    default_info = DefaultInfo(
        executable = wrapper,
        files = depset([wrapper, bb]),
        runfiles = ctx.runfiles([wrapper, bb]).merge(
            ctx.attr.binary[DefaultInfo].default_runfiles,
        ),
    )

    babashka_info = BabashkaInfo(
        binary = wrapper,
    )

    template_variables = platform_common.TemplateVariableInfo({
        "BB": wrapper.path,
    })

    toolchain_info = platform_common.ToolchainInfo(
        babashka = babashka_info,
        default = default_info,
        template_variables = template_variables,
    )

    return [
        default_info,
        toolchain_info,
        template_variables,
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
    executable = True,
)
