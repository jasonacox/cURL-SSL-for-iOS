#!/bin/sh

#  Automatic build script for libssl and libcrypto 
#  for iPhoneOS and iPhoneSimulator
#
#  Created by Felix Schulze on 16.12.10.
#  Copyright 2010 Felix Schulze. All rights reserved.
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#  http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#
###########################################################################
#  Change values here							  #
#									  #
#VERSION="1.0.1l"
VERSION="1.0.2"
SDKVERSIONSIM="8.1"							  #
SDKVERSION="8.1"							  #
#									  #
###########################################################################
#									  #
# Don't change anything under this line!				  #
#									  #
###########################################################################

CURRENTPATH=`pwd`
DEVELOPER=`xcode-select --print-path`

#set -e
if [ ! -e openssl-${VERSION}.tar.gz ]; then
	echo "Downloading openssl-${VERSION}.tar.gz"
    curl -O http://www.openssl.org/source/openssl-${VERSION}.tar.gz
else
	echo "Using openssl-${VERSION}.tar.gz"
fi

if [ -d  ${CURRENTPATH}/src ]; then
	rm -rf ${CURRENTPATH}/src
fi

if [ -d ${CURRENTPATH}/bin ]; then
	rm -rf ${CURRENTPATH}/bin
fi

mkdir -p "${CURRENTPATH}/src"
tar zxf openssl-${VERSION}.tar.gz -C "${CURRENTPATH}/src"
cd "${CURRENTPATH}/src/openssl-${VERSION}"

############
# iPhone Simulator
ARCH="i386"
PLATFORM="iPhoneSimulator"
echo "Building openssl for ${PLATFORM} ${SDKVERSIONSIM} ${ARCH}"
echo "Please stand by..."

export CC="${DEVELOPER}/Platforms/${PLATFORM}.platform/Developer/usr/bin/gcc -arch ${ARCH}"
mkdir -p "${CURRENTPATH}/bin/${PLATFORM}${SDKVERSIONSIM}.sdk"

LOG="${CURRENTPATH}/bin/${PLATFORM}${SDKVERSIONSIM}.sdk/build-openssl-${VERSION}.log"

#export IPHONEOS_DEPLOYMENT_TARGET="4.3"
export IPHONEOS_DEPLOYMENT_TARGET="6.1"
export CPPFLAGS="-D__IPHONE_OS_VERSION_MIN_REQUIRED=${IPHONEOS_DEPLOYMENT_TARGET%%.*}0000"

echo "Configure openssl for ${PLATFORM} ${SDKVERSIONSIM} ${ARCH}"

#./configure BSD-generic32 --openssldir="${CURRENTPATH}/bin/${PLATFORM}${SDKVERSIONSIM}.sdk" > "${LOG}" 2>&1
./configure darwin-i386-cc --openssldir="${CURRENTPATH}/bin/${PLATFORM}${SDKVERSIONSIM}.sdk" > "${LOG}" 2>&1
# add -isysroot to CC=
sed -ie "s!^CFLAG=!CFLAG=-isysroot ${DEVELOPER}/Platforms/${PLATFORM}.platform/Developer/SDKs/${PLATFORM}${SDKVERSIONSIM}.sdk !" "Makefile"

echo "Make openssl for ${PLATFORM} ${SDKVERSIONSIM} ${ARCH}"

make >> "${LOG}" 2>&1
make install >> "${LOG}" 2>&1
if [ ! -d  ${CURRENTPATH}/bin/${PLATFORM}${SDKVERSIONSIM}.sdk/man ]; then
	echo "*** ERROR IN BUILD ***"
	exit 0
fi
make clean >> "${LOG}" 2>&1

echo "Building openssl for ${PLATFORM} ${SDKVERSIONSIM} ${ARCH}, finished"
#############

############
# iPhone Simulator
ARCH="x86_64"
PLATFORM="iPhoneSimulator"
echo "Building openssl for ${PLATFORM} ${SDKVERSIONSIM} ${ARCH}"
echo "Please stand by..."

export CC="${DEVELOPER}/Platforms/${PLATFORM}.platform/Developer/usr/bin/gcc -arch ${ARCH}"
mkdir -p "${CURRENTPATH}/bin/${PLATFORM}${SDKVERSIONSIM}-${ARCH}.sdk"

LOG="${CURRENTPATH}/bin/${PLATFORM}${SDKVERSIONSIM}-${ARCH}.sdk/build-openssl-${VERSION}.log"

export IPHONEOS_DEPLOYMENT_TARGET="6.1"
export CPPFLAGS="-D__IPHONE_OS_VERSION_MIN_REQUIRED=${IPHONEOS_DEPLOYMENT_TARGET%%.*}0000"

echo "Configure openssl for ${PLATFORM} ${SDKVERSIONSIM} ${ARCH}"

#./configure BSD-generic32 --openssldir="${CURRENTPATH}/bin/${PLATFORM}${SDKVERSIONSIM}-${ARCH}.sdk" -DOPENSSL_NO_ASM > "${LOG}" 2>&1
./configure darwin64-x86_64-cc --openssldir="${CURRENTPATH}/bin/${PLATFORM}${SDKVERSIONSIM}-${ARCH}.sdk" -DOPENSSL_NO_ASM > "${LOG}" 2>&1
# add -isysroot to CC=
#sed -ie "s!^CFLAG=!CFLAG=-isysroot ${DEVELOPER}/Platforms/${PLATFORM}.platform/Developer/SDKs/${PLATFORM}${SDKVERSIONSIM}.sdk !" "Makefile"

echo "Make openssl for ${PLATFORM} ${SDKVERSIONSIM} ${ARCH}"

make >> "${LOG}" 2>&1
make install >> "${LOG}" 2>&1
if [ ! -d  ${CURRENTPATH}/bin/${PLATFORM}${SDKVERSIONSIM}.sdk/man ]; then
	echo "*** ERROR IN BUILD ***"
	exit 0
fi
make clean >> "${LOG}" 2>&1

echo "Building openssl for ${PLATFORM} ${SDKVERSIONSIM} ${ARCH}, finished"
#############

#############
# iPhoneOS armv7
ARCH="armv7"
PLATFORM="iPhoneOS"
echo "Building openssl for ${PLATFORM} ${SDKVERSION} ${ARCH}"
echo "Please stand by..."

export CC="${DEVELOPER}/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang -arch ${ARCH}"
mkdir -p "${CURRENTPATH}/bin/${PLATFORM}${SDKVERSION}-${ARCH}.sdk"

LOG="${CURRENTPATH}/bin/${PLATFORM}${SDKVERSION}-${ARCH}.sdk/build-openssl-${VERSION}.log"

echo "Configure openssl for ${PLATFORM} ${SDKVERSION} ${ARCH}"

./configure iphoneos-cross --openssldir="${CURRENTPATH}/bin/${PLATFORM}${SDKVERSION}-${ARCH}.sdk"  > "${LOG}" 2>&1

#sed -ie "s!^CFLAG=!CFLAG=-isysroot ${DEVELOPER}/Platforms/${PLATFORM}.platform/Developer/SDKs/${PLATFORM}${SDKVERSION}.sdk !" "Makefile"
# remove sig_atomic for iPhoneOS
sed -ie "s!static volatile sig_atomic_t intr_signal;!static volatile intr_signal;!" "crypto/ui/ui_openssl.c"

echo "Make openssl for ${PLATFORM} ${SDKVERSION} ${ARCH}"

make >> "${LOG}" 2>&1
make install >> "${LOG}" 2>&1
if [ ! -d  ${CURRENTPATH}/bin/${PLATFORM}${SDKVERSIONSIM}.sdk/man ]; then
	echo "*** ERROR IN BUILD ***"
	#exit 0
fi
make clean >> "${LOG}" 2>&1

echo "Building openssl for ${PLATFORM} ${SDKVERSION} ${ARCH}, finished"
#############

#############
# iPhoneOS armv7s
ARCH="armv7s"
PLATFORM="iPhoneOS"
echo "Building openssl for ${PLATFORM} ${SDKVERSION} ${ARCH}"
echo "Please stand by..."

export CC="${DEVELOPER}/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang -arch ${ARCH}"
mkdir -p "${CURRENTPATH}/bin/${PLATFORM}${SDKVERSION}-${ARCH}.sdk"

LOG="${CURRENTPATH}/bin/${PLATFORM}${SDKVERSION}-${ARCH}.sdk/build-openssl-${VERSION}.log"

echo "Configure openssl for ${PLATFORM} ${SDKVERSION} ${ARCH}"

./configure iphoneos-cross --openssldir="${CURRENTPATH}/bin/${PLATFORM}${SDKVERSION}-${ARCH}.sdk"  > "${LOG}" 2>&1

sed -ie "s!^CFLAG=!CFLAG=-isysroot ${DEVELOPER}/Platforms/${PLATFORM}.platform/Developer/SDKs/${PLATFORM}${SDKVERSION}.sdk !" "Makefile"
# remove sig_atomic for iPhoneOS
sed -ie "s!static volatile sig_atomic_t intr_signal;!static volatile intr_signal;!" "crypto/ui/ui_openssl.c"

echo "Make openssl for ${PLATFORM} ${SDKVERSION} ${ARCH}"

make >> "${LOG}" 2>&1
make install >> "${LOG}" 2>&1
if [ ! -d  ${CURRENTPATH}/bin/${PLATFORM}${SDKVERSIONSIM}.sdk/man ]; then
	echo "*** ERROR IN BUILD ***"
	#exit 0
fi
make clean >> "${LOG}" 2>&1

echo "Building openssl for ${PLATFORM} ${SDKVERSION} ${ARCH}, finished"

#############

#############
# iPhoneOS arm64
ARCH="arm64"
PLATFORM="iPhoneOS"
echo "Building openssl for ${PLATFORM} ${SDKVERSION} ${ARCH}"
echo "Please stand by..."

export CC="${DEVELOPER}/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang -arch ${ARCH}"
mkdir -p "${CURRENTPATH}/bin/${PLATFORM}${SDKVERSION}-${ARCH}.sdk"

LOG="${CURRENTPATH}/bin/${PLATFORM}${SDKVERSION}-${ARCH}.sdk/build-openssl-${VERSION}.log"

echo "Configure openssl for ${PLATFORM} ${SDKVERSION} ${ARCH}"

./configure iphoneos-cross --openssldir="${CURRENTPATH}/bin/${PLATFORM}${SDKVERSION}-${ARCH}.sdk" > "${LOG}" 2>&1

sed -ie "s!^CFLAG=!CFLAG=-isysroot ${DEVELOPER}/Platforms/${PLATFORM}.platform/Developer/SDKs/${PLATFORM}${SDKVERSION}.sdk !" "Makefile"
# remove sig_atomic for iPhoneOS
sed -ie "s!static volatile sig_atomic_t intr_signal;!static volatile intr_signal;!" "crypto/ui/ui_openssl.c"

echo "Make openssl for ${PLATFORM} ${SDKVERSION} ${ARCH}"

make >> "${LOG}" 2>&1
make install >> "${LOG}" 2>&1
if [ ! -d  ${CURRENTPATH}/bin/${PLATFORM}${SDKVERSIONSIM}.sdk/man ]; then
	echo "*** ERROR IN BUILD ***"
	#exit 0
fi
make clean >> "${LOG}" 2>&1

echo "Building openssl for ${PLATFORM} ${SDKVERSION} ${ARCH}, finished"
#############

#############
# Universal Library
echo " "
echo "Build universal library..."

lipo -create ${CURRENTPATH}/bin/iPhoneSimulator${SDKVERSIONSIM}.sdk/lib/libssl.a ${CURRENTPATH}/bin/iPhoneSimulator${SDKVERSIONSIM}-x86_64.sdk/lib/libssl.a ${CURRENTPATH}/bin/iPhoneOS${SDKVERSION}-armv7.sdk/lib/libssl.a ${CURRENTPATH}/bin/iPhoneOS${SDKVERSION}-armv7s.sdk/lib/libssl.a ${CURRENTPATH}/bin/iPhoneOS${SDKVERSION}-arm64.sdk/lib/libssl.a -output ${CURRENTPATH}/libssl.a

lipo -create ${CURRENTPATH}/bin/iPhoneSimulator${SDKVERSIONSIM}.sdk/lib/libcrypto.a ${CURRENTPATH}/bin/iPhoneSimulator${SDKVERSIONSIM}-x86_64.sdk/lib/libcrypto.a ${CURRENTPATH}/bin/iPhoneOS${SDKVERSION}-armv7.sdk/lib/libcrypto.a ${CURRENTPATH}/bin/iPhoneOS${SDKVERSION}-armv7s.sdk/lib/libcrypto.a ${CURRENTPATH}/bin/iPhoneOS${SDKVERSION}-arm64.sdk/lib/libcrypto.a -output ${CURRENTPATH}/libcrypto.a

mkdir -p ${CURRENTPATH}/include
cp -R ${CURRENTPATH}/bin/iPhoneSimulator${SDKVERSIONSIM}.sdk/include/openssl ${CURRENTPATH}/include/
echo "Building done."
echo "Cleaning up..."
#rm -rf ${CURRENTPATH}/src
#rm -rf ${CURRENTPATH}/bin
echo "Done."
