BabashkaInfo = provider(
    fields = {
        "binary": "path to the wrapper that should be used for all in-Bazel actions",
        "_pkg_binary": "path to the unmodified package binary",
    }
)

def _babashka_toolchain_impl(ctx):
    bb = ctx.file.binary
    wrapper = ctx.files.wrapper[0]

    default_info = DefaultInfo(
        files = depset([bb, wrapper]),
        runfiles = ctx.runfiles([bb, wrapper]),
    )

    babashka_info = BabashkaInfo(
        binary = wrapper,
        _pkg_binary = bb,
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
            mandatory=True,
            allow_single_file=True,
        ),
        "wrapper": attr.label(
            mandatory=True,
        ),
    }
)
