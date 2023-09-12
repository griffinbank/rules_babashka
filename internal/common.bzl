def babashka_os(os_name):
    if os_name == "linux":
        return "linux"
    elif os_name == "mac os x" or os_name == "macos":
        return "macos"
    fail("Unsupported OS: " + os_name)

def babashka2platform_os(os):
    # Return the OS string as used in bazel platform constraints.
    return {"macos": "osx", "linux": "linux"}[os]

def babashka_arch(arch_name):
    if arch_name == "aarch64" or arch_name == "arm64":
        return "aarch64"
    elif arch_name == "amd64" or arch_name == "x86_64":
        return "amd64"
    fail("Unsupported architecture: " + arch_name)

def babashka_arch2platform_cpu(arch):
    # Return the cpu string as used in bazel platform constraints.
    return {"aarch64": "arm64", "amd64": "x86_64"}[arch]

