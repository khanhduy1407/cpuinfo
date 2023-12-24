# CPU Information

cpuinfo is a library to detect essential for performance optimization information about host CPU.

## Examples

Log processor name:

```c
cpuinfo_initialize();
printf("Running on %s CPU\n", cpuinfo_get_package(0)->name);
```

Detect if target is a 32-bit or 64-bit ARM system:

```c
#if CPUINFO_ARCH_ARM || CPUINFO_ARCH_ARM64
    /* 32-bit ARM-specific code here */
#endif
```

Check if the host CPU supports ARM NEON

```c
cpuinfo_initialize();
if (cpuinfo_has_arm_neon()) {
    neon_implementation(arguments);
}
```

Check if the host CPU supports x86 AVX

```c
cpuinfo_initialize();
if (cpuinfo_has_x86_avx()) {
    avx_implementation(arguments);
}
```

Check if the thread runs on a Cortex-A53 core

```c
cpuinfo_initialize();
switch (cpuinfo_get_current_core()->uarch) {
    case cpuinfo_uarch_cortex_a53:
        cortex_a53_implementation(arguments);
        break;
    default:
        generic_implementation(arguments);
        break;
}
```

Get the size of level 1 data cache on the fastest core in the processor (e.g. big core in big.LITTLE ARM systems):

```c
cpuinfo_initialize();
const size_t l1_size = cpuinfo_get_processor(0)->cache.l1d->size;
```

Pin thread to cores sharing L2 cache with the current core (Linux or Android)

```c
cpuinfo_initialize();
cpu_set_t cpu_set;
CPU_ZERO(&cpu_set);
const struct cpuinfo_cache* current_l2 = cpuinfo_get_current_processor()->cache.l2;
for (uint32_t i = 0; i < current_l2->processor_count; i++) {
    CPU_SET(cpuinfo_get_processor(current_l2->processor_start + i)->linux_id, &cpu_set);
}
pthread_setaffinity_np(pthread_self(), sizeof(cpu_set_t), &cpu_set);
```

## Use via pkg-config

If you would like to provide your project's build environment with the necessary compiler and linker flags in a portable manner, the library by default when built enables `CPUINFO_BUILD_PKG_CONFIG` and will generate a [pkg-config](https://www.freedesktop.org/wiki/Software/pkg-config/) manifest (_libcpuinfo.pc_). Here are several examples of how to use it:

### Command Line

If you used your distro's package manager to install the library, you can verify that it is available to your build environment like so:

```console
$ pkg-config --cflags --libs libcpuinfo
-I/usr/include/x86_64-linux-gnu/ -L/lib/x86_64-linux-gnu/ -lcpuinfo
```

If you have installed the library from source into a non-standard prefix, pkg-config may need help finding it:

```console
$ PKG_CONFIG_PATH="/home/me/projects/cpuinfo/prefix/lib/pkgconfig/:$PKG_CONFIG_PATH" pkg-config --cflags --libs libcpuinfo
-I/home/me/projects/cpuinfo/prefix/include -L/home/me/projects/cpuinfo/prefix/lib -lcpuinfo
```

### GNU Autotools

To [use](https://autotools.io/pkgconfig/pkg_check_modules.html) with the GNU Autotools include the following snippet in your project's `configure.ac`:

```makefile
# CPU INFOrmation library...
PKG_CHECK_MODULES(
    [libcpuinfo], [libcpuinfo], [],
    [AC_MSG_ERROR([libcpuinfo missing...])])
YOURPROJECT_CXXFLAGS="$YOURPROJECT_CXXFLAGS $libcpuinfo_CFLAGS"
YOURPROJECT_LIBS="$YOURPROJECT_LIBS $libcpuinfo_LIBS"
```

### Meson

To use with Meson you just need to add `dependency('libcpuinfo')` as a dependency for your executable.

```meson
project(
    'MyCpuInfoProject',
    'cpp',
    meson_version: '>=0.55.0'
)

executable(
    'MyCpuInfoExecutable',
    sources: 'main.cpp',
    dependencies: dependency('libcpuinfo')
)
```

### CMake

To use with CMake use the [FindPkgConfig](https://cmake.org/cmake/help/latest/module/FindPkgConfig.html) module. Here is an example:

```cmake
cmake_minimum_required(VERSION 3.6)
project("MyCpuInfoProject")

find_package(PkgConfig)
pkg_check_modules(CpuInfo REQUIRED IMPORTED_TARGET libcpuinfo)

add_executable(${PROJECT_NAME} main.cpp)
target_link_libraries(${PROJECT_NAME} PkgConfig::CpuInfo)
```

### Makefile

To use within a vanilla makefile, you can call pkg-config directly to supply compiler and linker flags using shell substitution.

```makefile
CFLAGS=-g3 -Wall -Wextra -Werror ...
LDFLAGS=-lfoo ...
...
CFLAGS+= $(pkg-config --cflags libcpuinfo)
LDFLAGS+= $(pkg-config --libs libcpuinfo)
```
