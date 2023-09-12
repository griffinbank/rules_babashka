load("@rules_babashka//toolchain:toolchain.bzl", "babashka_toolchain")

package(default_visibility=["//visibility:public"])

exports_files(["%{raw_binary}", "%{wrapper}"])

babashka_toolchain(
    name = "toolchain_impl",
    binary = "%{wrapper}"
)

toolchain(
    name="toolchain",
    exec_compatible_with=["@platforms//os:%{os}", "@platforms//cpu:%{cpu}"],
    target_compatible_with=["@platforms//os:%{os}", "@platforms//cpu:%{cpu}"],
    toolchain = ":toolchain_impl",
    toolchain_type = "@rules_babashka//toolchain:toolchain_type"
)
