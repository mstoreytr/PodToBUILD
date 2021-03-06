#!/bin/bash
set -e

PLATFORM_NAME="${PLATFORM_NAME:-iphoneos}"
CURRENT_ARCH="${CURRENT_ARCH:-armv7}"

export CC=/usr/bin/clang
export CXX=/usr/bin/clang++

# Remove automake symlink if it exists
if [ -h "test-driver" ]; then
    rm test-driver
fi

# source ../PodSpecs/react-native-third-party-0.51.0/Env.sh

echo  "set -o xtrace" > config2
chmod +x config2
cat configure >> config2

./config2 --host arm-apple-darwin

# Fix build for tvOS
cat << EOF >> src/config.h

/* Add in so we have Apple Target Conditionals */
#ifdef __APPLE__
#include <TargetConditionals.h>
#include <Availability.h>
#endif

/* Special configuration for AppleTVOS */
#if TARGET_OS_TV
#undef HAVE_SYSCALL_H
#undef HAVE_SYS_SYSCALL_H
#undef OS_MACOSX
#endif

/* Special configuration for ucontext */
#undef HAVE_UCONTEXT_H
#undef PC_FROM_UCONTEXT
#if defined(__x86_64__)
#define PC_FROM_UCONTEXT uc_mcontext->__ss.__rip
#elif defined(__i386__)
#define PC_FROM_UCONTEXT uc_mcontext->__ss.__eip
#endif
EOF
