#! /bin/bash

set -e

if [[ ! -d "$ANDROID_HOME"/ndk ]]; then
    echo "Error: either env var ANDROID_HOME is not set, or Android SDK/NDK is not installed; install them and set ANDROID_HOME via"
    echo "   $ export ANDROID_HOME=<path>/<to>/<android-sdk>"
    exit 1
fi

if [[ ! -f $Z3_HOME/CMakeLists.txt ]]; then
    echo "Error: env var Z3_HOME is not set, set it using "
    echo "   $ export Z3_HOME=<path>/<to>/<z3>"
    exit 1
fi

prog="$0"
progdir=$(dirname $prog)

DF_CMAKE_BUILD_DIR=cmake-build
DF_ANDROID_ABI=x86_64
DF_ANDROID_PLATFORM=28
DF_ANDROID_NDK_VERSION=20.0.5594570

if [[ "$1" == "-h" ]]; then
    echo "$ [CMAKE_BUILD_DIR=<build_dir>] [ANDROID_ABI=<abi>] [ANDROID_PLATFORM=<api_version>] [ANDROID_NDK_VERSION=<ndk_version>] $prog"
    echo "Defaults:"
    echo "  CMAKE_BUILD_DIR=$DF_CMAKE_BUILD_DIR-$DF_ANDROID_ABI"
    echo "  ANDROID_ABI=$DF_ANDROID_ABI (armeabi-v7a, arm64-v8a, x86, x86_64)"
    echo "  ANDROID_PLATFORM=$DF_ANDROID_PLATFORM"
    echo "  ANDROID_NDK_VERSION=$DF_ANDROID_NDK_VERSION"
    exit 0
fi

if [[ -z $ANDROID_ABI ]]; then
    ANDROID_ABI=$DF_ANDROID_ABI
fi

if [[ -z $ANDROID_PLATFORM ]]; then
    ANDROID_PLATFORM=$DF_ANDROID_PLATFORM
fi

if [[ -z $ANDROID_NDK_VERSION ]]; then
    ANDROID_NDK_VERSION=$DF_ANDROID_NDK_VERSION
fi

if [[ -z $CMAKE_BUILD_DIR ]]; then
    CMAKE_BUILD_DIR=$Z3_HOME/$DF_CMAKE_BUILD_DIR-$ANDROID_ABI
    mkdir -p $CMAKE_BUILD_DIR
else
    oldwd=`pwd`
    mkdir -p $CMAKE_BUILD_DIR
    cd $CMAKE_BUILD_DIR
    CMAKE_BUILD_DIR=`pwd`
    cd $oldwd
fi

echo "Using:"
echo "  CMAKE_BUILD_DIR:     $CMAKE_BUILD_DIR"
echo "  ANDROID_ABI:         $ANDROID_ABI"
echo "  ANDROID_PLATFORM:    $ANDROID_PLATFORM"
echo "  ANDROID_NDK_VERSION: $ANDROID_NDK_VERSION"

# https://developer.android.com/studio/projects/configure-cmake#call-cmake-cli
cmake \
    -DANDROID_ABI=$ANDROID_ABI \
    -DANDROID_PLATFORM=android-$ANDROID_PLATFORM \
    -DANDROID_NDK=$ANDROID_HOME/ndk/$ANDROID_NDK_VERSION \
    -DCMAKE_TOOLCHAIN_FILE=$ANDROID_HOME/ndk/$ANDROID_NDK_VERSION/build/cmake/android.toolchain.cmake \
    -DZ3_BUILD_JAVA_BINDINGS=ON \
    -S $Z3_HOME \
    -B $CMAKE_BUILD_DIR

make -j6 -C $CMAKE_BUILD_DIR
