BabashkaInfo = provider(
    fields = {
        "binary": "path to the binary"
    }
)

def _babashka_toolchain_impl(ctx):
    bb = ctx.files.binary[0]

    default_info = DefaultInfo(
        files = depset([bb]),
        runfiles = ctx.runfiles([bb])
    )

    babashka_info = BabashkaInfo(
        binary = bb
    )

    template_variables = platform_common.TemplateVariableInfo({
        "BB": bb.path
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
        )
    }
)
