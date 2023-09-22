load("//internal:common.bzl", "babashka_arch", "babashka_arch2platform_cpu", "babashka_os", "babashka2platform_os")
load("//:releases.bzl", "BABASHKA", "CLOJURE_TOOLS", "TOOLS_MAPPING")

EXTRACT_DIR = "bin/pkg"

def _download_babashka(repository_ctx, arch, os):
    version = repository_ctx.attr.version

    babashka_filename = "babashka-{version}-{os}-{arch}.tar.gz".format(
        version = version,
        os = os,
        arch = arch,
    )

    babashka_url = "https://github.com/babashka/babashka/releases/download/v{version}/{filename}".format(
        version = version,
        filename = babashka_filename,
    )

    repository_ctx.download_and_extract(
        url = [babashka_url],
        output = EXTRACT_DIR,
        sha256 = BABASHKA[babashka_filename],
    )

    tools_version = TOOLS_MAPPING[version]
    tools_url = "https://github.com/clojure/brew-install/releases/download/{version}/clojure-tools.zip".format(
        version = tools_version,
    )

    repository_ctx.download_and_extract(
        url = [tools_url],
        output = ".deps.clj",
        sha256 = CLOJURE_TOOLS[tools_version],
    )

def _babashka_impl(repository_ctx):
    arch = babashka_arch(repository_ctx.attr.arch or repository_ctx.os.arch)
    os = babashka_os(repository_ctx.attr.os or repository_ctx.os.name)

    _download_babashka(repository_ctx, arch, os)
    raw_binary = "{extract_dir}/bb".format(
        extract_dir = EXTRACT_DIR
    )

    repository_ctx.template(
        "bin/bb",
        repository_ctx.attr._wrapper_script_template,
        substitutions = {
            "%{repo_root}": repository_ctx.execute(["pwd"]).stdout.strip(),
            "%{raw_binary}": raw_binary,
        },
    )

    repository_ctx.template(
        "BUILD.bazel",
        repository_ctx.attr._build_repo_template,
        substitutions = {
            "%{cpu}": babashka_arch2platform_cpu(arch),
            "%{os}": babashka2platform_os(os),
            "%{raw_binary}": raw_binary,
            "%{wrapper}": "bin/bb",
        },
    )

babashka = repository_rule(
    implementation = _babashka_impl,
    attrs = {
        "arch": attr.string(),
        "os": attr.string(),
        "version": attr.string(
            doc = "The version of Babashka to fetch",
            mandatory = True,
        ),
        "_build_repo_template": attr.label(
            default = "//:BUILD.repo.tpl"
        ),
        "_wrapper_script_template": attr.label(
            default = "//internal:bb.sh.tpl"
        ),
    }
)
